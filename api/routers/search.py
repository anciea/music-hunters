'''
Function:
    GET /search endpoint — keyword search across all enabled music sources
'''
import threading
import logging
from cachetools import TTLCache
from fastapi import APIRouter, Depends, Query, Request

from api.auth import verify_api_key
from api.deps import get_executor, get_music_client
from api.models import SearchResponse, TrackDTO
from api.utils import encode_track_id, run_sync

logger = logging.getLogger('musicdl.api.search')
router = APIRouter()

# In-memory search cache — thread-safe via explicit lock (TTLCache is not thread-safe alone)
search_cache: TTLCache = TTLCache(maxsize=256, ttl=300)
cache_lock = threading.Lock()


@router.get('', response_model=SearchResponse, dependencies=[Depends(verify_api_key)])
async def search(
    q: str = Query(..., min_length=1, description='Search keyword'),
    request: Request = None,
) -> SearchResponse:
    '''Search all enabled music sources and return unified track list.

    Results are cached by keyword for 5 minutes. Failed sources are listed in
    the warnings field rather than blocking the response. Raw CDN URLs are never
    included in the response (proxy mode — tracks contain only metadata).
    '''
    # Check cache first
    with cache_lock:
        cached = search_cache.get(q)
    if cached is not None:
        logger.info('Cache hit for query: %s', q)
        return cached

    music_client = get_music_client(request)
    executor = get_executor(request)

    logger.info('Searching sources for query: %s', q)
    raw_results: dict = await run_sync(executor, music_client.search, q)

    tracks: list[TrackDTO] = []
    warnings: list[str] = []

    for source, song_infos in raw_results.items():
        if not song_infos:
            warnings.append(source)
            logger.warning('Source returned no results: %s', source)
            continue
        for si in song_infos:
            try:
                tracks.append(TrackDTO(
                    track_id=encode_track_id(source, si.identifier),
                    song_name=si.song_name,
                    singers=si.singers,
                    album=si.album,
                    cover_url=si.cover_url,
                    duration_s=si.duration_s,
                    duration=si.duration,
                    source=si.source,
                    ext=si.ext,
                    bitrate=si.bitrate,
                    codec=si.codec,
                    file_size=si.file_size,
                    file_size_bytes=si.file_size_bytes,
                ))
            except Exception as err:
                logger.warning('Failed to map SongInfo to TrackDTO from %s: %s', source, err)

    response = SearchResponse(tracks=tracks, warnings=warnings)

    # Only cache if at least one source returned data (do not cache total failures)
    if tracks:
        with cache_lock:
            search_cache[q] = response
        logger.info('Cached %d tracks for query: %s', len(tracks), q)
    else:
        logger.warning('All sources failed for query "%s" — result not cached', q)

    return response
