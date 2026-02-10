'''
Function:
    GET /stream/{track_id} — proxied audio streaming with HTTP Range support
'''
import logging
import tempfile
import os
import shutil

import httpx
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request
from fastapi.responses import StreamingResponse, FileResponse

from api.auth import verify_api_key
from api.deps import get_executor, get_music_client
from api.utils import decode_track_id, run_sync

logger = logging.getLogger('musicdl.api.stream')
router = APIRouter()

_EXT_CONTENT_TYPES = {
    'mp3': 'audio/mpeg',
    'flac': 'audio/flac',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'wav': 'audio/wav',
}


def _get_fresh_song_info(music_client, source: str, identifier: str):
    '''Fetch fresh SongInfo from source client by searching the identifier.

    Called inside a thread pool (blocking). Returns SongInfo or None.
    CDN URLs from search results expire — always call this at stream time, never cache download_url.
    '''
    try:
        source_client = music_client.music_clients.get(source)
        if not source_client:
            return None
        results = source_client.search(keyword=identifier, num_threadings=1)
        if not results:
            return None
        # Find track with matching identifier; fall back to first result
        for si in results:
            if si.identifier == identifier:
                return si
        return results[0]
    except Exception as err:
        logger.warning('Failed to fetch fresh SongInfo for %s:%s — %s', source, identifier, err)
        return None


def _download_to_temp(music_client, song_info, temp_dir: str):
    '''Download track to temp_dir using source client. Blocking.

    Uses the source-specific client directly so download goes to temp_dir.
    CDN signed URLs may expire — this always fetches a fresh copy.
    '''
    try:
        source = song_info.source or song_info.identifier
        source_client = music_client.music_clients.get(source)
        if source_client:
            song_info.work_dir = temp_dir
            source_client.download(song_infos=[song_info])
        else:
            # Fall back to top-level MusicClient.download
            song_info.work_dir = temp_dir
            music_client.download(song_infos=[song_info])
    except Exception as err:
        logger.warning('_download_to_temp failed: %s', err)


@router.get('/{track_id}', dependencies=[Depends(verify_api_key)])
async def stream_track(
    track_id: str,
    request: Request,
    background_tasks: BackgroundTasks,
) -> StreamingResponse:
    '''Proxy audio bytes for a track to the client with Range request support.

    Never exposes raw CDN URLs. Forwards the client Range header upstream
    so just_audio can seek within the stream.
    '''
    try:
        source, identifier = decode_track_id(track_id)
    except ValueError:
        raise HTTPException(status_code=400, detail={'error': 'Invalid track_id', 'code': 'INVALID_TRACK_ID'})

    music_client = get_music_client(request)
    executor = get_executor(request)

    if source not in music_client.music_clients:
        raise HTTPException(status_code=404, detail={'error': f'Unknown source: {source}', 'code': 'SOURCE_NOT_FOUND'})

    # Fetch fresh SongInfo (CDN URLs expire — never use cached download_url)
    song_info = await run_sync(executor, _get_fresh_song_info, music_client, source, identifier)
    if not song_info:
        raise HTTPException(status_code=404, detail={'error': 'Track not found', 'code': 'TRACK_NOT_FOUND'})

    download_url = song_info.download_url
    if not download_url or not isinstance(download_url, str) or not download_url.startswith('http'):
        # No direct HTTP URL available — fall back to file-based streaming
        return await _stream_via_file(music_client, executor, song_info, background_tasks)

    # Proxy mode: forward client Range header to CDN, stream response back.
    # Always merge default_download_headers — many CDNs require signed Referer/Cookie headers.
    client_range = request.headers.get('Range', 'bytes=0-')
    upstream_headers = {'Range': client_range, **song_info.default_download_headers}

    try:
        async_client = httpx.AsyncClient(timeout=30.0, follow_redirects=True)
        upstream = await async_client.send(
            httpx.Request('GET', download_url, headers=upstream_headers),
            stream=True,
        )

        ext = (song_info.ext or 'mp3').lstrip('.')
        content_type = upstream.headers.get(
            'Content-Type',
            _EXT_CONTENT_TYPES.get(ext, 'audio/mpeg'),
        )

        response_headers = {
            'Content-Type': content_type,
            'Accept-Ranges': 'bytes',
        }
        if upstream.headers.get('Content-Range'):
            response_headers['Content-Range'] = upstream.headers['Content-Range']
        if upstream.headers.get('Content-Length'):
            response_headers['Content-Length'] = upstream.headers['Content-Length']

        async def stream_and_close():
            try:
                async for chunk in upstream.aiter_bytes(chunk_size=65536):
                    yield chunk
            finally:
                await upstream.aclose()
                await async_client.aclose()

        return StreamingResponse(
            stream_and_close(),
            status_code=upstream.status_code,
            headers=response_headers,
        )
    except httpx.HTTPError as err:
        logger.warning('httpx proxy failed for %s:%s (%s) — falling back to file', source, identifier, err)
        return await _stream_via_file(music_client, executor, song_info, background_tasks)


async def _stream_via_file(music_client, executor, song_info, background_tasks: BackgroundTasks) -> FileResponse:
    '''Fallback: download audio file to temp directory and serve via FileResponse.

    Used when the CDN URL is unavailable or the httpx proxy fails.
    Temp directory is cleaned up via BackgroundTask after response is sent.
    '''
    temp_dir = tempfile.mkdtemp(prefix='musicdl_stream_')
    await run_sync(executor, _download_to_temp, music_client, song_info, temp_dir)

    file_path = song_info.save_path
    if not file_path or not os.path.exists(file_path):
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise HTTPException(status_code=502, detail={'error': 'Failed to fetch audio', 'code': 'UPSTREAM_ERROR'})

    background_tasks.add_task(shutil.rmtree, temp_dir, True)

    ext = (song_info.ext or 'mp3').lstrip('.')
    safe_name = f'{song_info.song_name} - {song_info.singers}.{ext}'.replace('/', '_').replace('\\', '_')
    content_type = _EXT_CONTENT_TYPES.get(ext, 'audio/mpeg')

    return FileResponse(
        path=file_path,
        media_type=content_type,
        filename=safe_name,
        headers={'Accept-Ranges': 'bytes'},
    )
