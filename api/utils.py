'''
Function:
    Shared utility helpers for MusicDL API
'''
import asyncio
import base64
from concurrent.futures import Executor
from functools import partial
from typing import Any, Callable


def encode_track_id(source: str, identifier: str) -> str:
    '''Encode (source, identifier) as URL-safe base64 opaque token.'''
    return base64.urlsafe_b64encode(f'{source}:{identifier}'.encode()).decode()


def decode_track_id(track_id: str) -> tuple[str, str]:
    '''Decode base64 token back to (source, identifier). Raises ValueError on bad input.'''
    try:
        raw = base64.urlsafe_b64decode(track_id.encode()).decode()
        source, identifier = raw.split(':', 1)
        return source, identifier
    except Exception as err:
        raise ValueError(f'Invalid track_id: {track_id}') from err


async def run_sync(executor: Executor, func: Callable, *args: Any, **kwargs: Any) -> Any:
    '''Dispatch a synchronous blocking call to a thread pool executor.
    Always use this for MusicClient calls — never call them directly in async handlers.
    '''
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(executor, partial(func, *args, **kwargs))
