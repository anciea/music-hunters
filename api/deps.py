'''
Function:
    Shared FastAPI dependency accessors for app.state resources
'''
from concurrent.futures import ThreadPoolExecutor
from fastapi import Request
from musicdl.musicdl import MusicClient


def get_music_client(request: Request) -> MusicClient:
    '''Return the singleton MusicClient stored in app.state.'''
    return request.app.state.music_client


def get_executor(request: Request) -> ThreadPoolExecutor:
    '''Return the dedicated ThreadPoolExecutor stored in app.state.'''
    return request.app.state.executor
