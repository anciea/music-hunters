'''
Function:
    X-API-Key authentication dependency for MusicDL API
'''
import os
from fastapi import HTTPException, Security
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name='X-API-Key', auto_error=False)


async def verify_api_key(api_key: str = Security(api_key_header)) -> None:
    '''Raises HTTP 401 if X-API-Key header is missing or does not match MUSICDL_API_KEY env var.'''
    expected = os.environ.get('MUSICDL_API_KEY', '')
    if not expected:
        raise HTTPException(status_code=500, detail={'error': 'API key not configured on server', 'code': 'SERVER_MISCONFIGURED'})
    if api_key != expected:
        raise HTTPException(status_code=401, detail={'error': 'Invalid or missing API key', 'code': 'UNAUTHORIZED'})
