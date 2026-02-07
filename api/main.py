'''
Function:
    FastAPI application entry point for MusicDL API
'''
import logging
import os
from contextlib import asynccontextmanager
from concurrent.futures import ThreadPoolExecutor
from logging.handlers import RotatingFileHandler

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from musicdl.musicdl import MusicClient
from api.routers import search, stream, download


# --- logging setup ---
_log_dir = os.path.join(os.path.expanduser('~'), '.local', 'share', 'musicdl')
os.makedirs(_log_dir, exist_ok=True)
_handler = RotatingFileHandler(os.path.join(_log_dir, 'musicdl-api.log'), maxBytes=10 * 1024 * 1024, backupCount=3)
_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(name)s: %(message)s'))
logging.basicConfig(level=logging.INFO, handlers=[_handler])
logger = logging.getLogger('musicdl.api')

# Music sources to enable (cloud deployment — DRM sidecar sources omitted)
ENABLED_SOURCES = [
    'MiguMusicClient', 'NeteaseMusicClient', 'QQMusicClient', 'KuwoMusicClient',
    'QianqianMusicClient', 'SpotifyMusicClient', 'YoutubeMusicClient',
    'TidalMusicClient', 'QobuzMusicClient', 'DeezerMusicClient',
    'GDStudioMusicClient', 'XimalayaMusicClient', 'LizhiMusicClient',
    'QingtingMusicClient', 'LRTSMusicClient',
]
MAX_EXECUTOR_WORKERS = int(os.environ.get('MUSICDL_EXECUTOR_WORKERS', '4'))


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info('MusicDL API starting up')
    app.state.executor = ThreadPoolExecutor(max_workers=MAX_EXECUTOR_WORKERS)
    app.state.music_client = MusicClient(music_sources=ENABLED_SOURCES)
    logger.info('MusicClient initialized with %d sources', len(ENABLED_SOURCES))
    yield
    app.state.executor.shutdown(wait=True)
    logger.info('MusicDL API shut down')


app = FastAPI(
    title='MusicDL API',
    version='1.0.0',
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)

app.include_router(search.router, prefix='/search', tags=['search'])
app.include_router(stream.router, prefix='/stream', tags=['stream'])
app.include_router(download.router, prefix='/download', tags=['download'])


@app.get('/health', tags=['meta'])
async def health() -> dict:
    return {'status': 'ok'}
