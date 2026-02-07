'''
Function:
    Search router stub — full implementation in plan 01-02
'''
from fastapi import APIRouter, Depends
from api.auth import verify_api_key

router = APIRouter(dependencies=[Depends(verify_api_key)])


@router.get('')
async def search_stub() -> dict:
    '''Stub — implemented in plan 01-02.'''
    return {'tracks': [], 'warnings': ['not implemented yet']}
