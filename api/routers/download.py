'''
Function:
    GET /download/{track_id} — download audio file for local storage
'''
import logging
import os
import shutil
import tempfile

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request
from fastapi.responses import FileResponse

from api.auth import verify_api_key
from api.deps import get_executor, get_music_client
from api.utils import decode_track_id, run_sync
from api.routers.stream import _get_fresh_song_info, _download_to_temp

logger = logging.getLogger('musicdl.api.download')
router = APIRouter()

EXT_CONTENT_TYPES = {
    'mp3': 'audio/mpeg',
    'flac': 'audio/flac',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'wav': 'audio/wav',
}


@router.get('/{track_id}', dependencies=[Depends(verify_api_key)])
async def download_track(
    track_id: str,
    request: Request,
    background_tasks: BackgroundTasks,
) -> FileResponse:
    '''Download audio file for local storage.

    Writes audio to a temp directory, serves it as an attachment via FileResponse,
    then deletes the temp directory via BackgroundTask after the response is sent.
    Raw CDN URLs are never returned to the client — only the audio bytes.
    '''
    try:
        source, identifier = decode_track_id(track_id)
    except ValueError:
        raise HTTPException(status_code=400, detail={'error': 'Invalid track_id', 'code': 'INVALID_TRACK_ID'})

    music_client = get_music_client(request)
    executor = get_executor(request)

    if source not in music_client.music_clients:
        raise HTTPException(status_code=404, detail={'error': f'Unknown source: {source}', 'code': 'SOURCE_NOT_FOUND'})

    # Get fresh SongInfo (CDN URLs expire — always re-fetch at request time)
    song_info = await run_sync(executor, _get_fresh_song_info, music_client, source, identifier)
    if not song_info:
        raise HTTPException(status_code=404, detail={'error': 'Track not found', 'code': 'TRACK_NOT_FOUND'})

    # Download to temp directory
    temp_dir = tempfile.mkdtemp(prefix='musicdl_dl_')
    await run_sync(executor, _download_to_temp, music_client, song_info, temp_dir)

    file_path = song_info.save_path
    if not file_path or not os.path.exists(file_path):
        shutil.rmtree(temp_dir, ignore_errors=True)
        raise HTTPException(status_code=502, detail={'error': 'Failed to download audio', 'code': 'UPSTREAM_ERROR'})

    # Cleanup temp dir after FileResponse has been sent — prevents temp file leaks
    background_tasks.add_task(shutil.rmtree, temp_dir, True)

    ext = (song_info.ext or 'mp3').lstrip('.')
    content_type = EXT_CONTENT_TYPES.get(ext, 'audio/mpeg')
    safe_name = (
        f'{song_info.song_name} - {song_info.singers}.{ext}'
        .replace('/', '_')
        .replace('\\', '_')
    )

    logger.info('Serving download for %s:%s as %s', source, identifier, safe_name)

    return FileResponse(
        path=file_path,
        media_type=content_type,
        filename=safe_name,
    )
