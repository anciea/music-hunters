'''
Function:
    Pydantic models for MusicDL API request/response schemas
'''
from typing import Optional
from pydantic import BaseModel


class TrackDTO(BaseModel):
    track_id: str               # base64url("{source}:{identifier}")
    song_name: Optional[str] = None
    singers: Optional[str] = None
    album: Optional[str] = None
    cover_url: Optional[str] = None
    duration_s: Optional[int] = None
    duration: Optional[str] = None
    source: Optional[str] = None
    ext: Optional[str] = None
    bitrate: Optional[int] = None
    codec: Optional[str] = None
    file_size: Optional[str] = None
    file_size_bytes: Optional[int] = None


class SearchResponse(BaseModel):
    tracks: list[TrackDTO]
    warnings: list[str]         # source names that failed or timed out


class ErrorResponse(BaseModel):
    error: str
    code: str
