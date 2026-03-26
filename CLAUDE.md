<!-- GSD:project-start source:PROJECT.md -->
## Project

**MusicDL Mobile**

A Flutter Android application that provides a unified music experience across 21+ music platforms (Netease, QQ Music, Spotify, YouTube, Apple Music, Tidal, Qobuz, Deezer, etc.). The app connects to a Python FastAPI backend deployed on a cloud server, which handles music search, parsing, and streaming. Users can search songs across all platforms, manage local playlists, and enjoy seamless music playback with background audio and notification controls.

**Core Value:** Users can search and play music from any supported platform through a single, elegant mobile interface — no platform switching, no friction.

### Constraints

- **Tech stack**: Flutter (frontend) + Python FastAPI (backend) — decided during initialization
- **Platform**: Android only for v1 — personal use on user's phone
- **Backend deployment**: Cloud server — must handle API requests from mobile client
- **Storage**: Local-only playlists (SQLite) — no server-side user data
- **Network**: App requires network for search/streaming, offline mode for downloaded songs only
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Python 3 - Core application language, used throughout the project
- JavaScript - YouTube integration via `modules/js/youtube/` directory for JSInterp functionality
- CSS/HTML - Documentation and web-based interfaces
- Shell scripts - Build and deployment scripts in `scripts/` directory
## Runtime
- Python 3.11 (documented in `.readthedocs.yaml`)
- Node.js - Used via `nodejs-wheel` package (included in `requirements.txt`)
- pip - Python package management
- Lockfile: Not detected (requirements.txt used instead)
## Frameworks
- Click - CLI framework for command-line interface (`requirements.txt`)
- Rich - Terminal UI and progress reporting (`requirements.txt`)
- Not detected - No test framework configuration found
- Setuptools - Package building and distribution (`setup.py`)
- ReadTheDocs - Documentation hosting (`.readthedocs.yaml`)
- Sphinx - Documentation generation (referenced in `.readthedocs.yaml`)
## Key Dependencies
- requests - HTTP client for API calls (`requirements.txt`)
- curl_cffi - Advanced HTTP client with browser impersonation (`requirements.txt`)
- ytmusicapi - YouTube Music API wrapper (`requirements.txt`)
- aigpy - Audio processing and TIDAL download support (`requirements.txt`)
- mutagen - Audio metadata tagging (`requirements.txt`)
- pywidevine - DRM/Widevine support for protected content (`requirements.txt`)
- pycryptodome - Encryption utilities (`requirements.txt`)
- cryptography - Cryptographic operations (`requirements.txt`)
- fake_useragent - User-agent randomization (`requirements.txt`)
- beautifulsoup4 - HTML parsing (`requirements.txt`)
- lxml - XML/HTML parsing (`requirements.txt`)
- json_repair - JSON parsing resilience (`requirements.txt`)
- orjson - Fast JSON serialization (`requirements.txt`)
- av (PyAV) - Audio/video codec support (`requirements.txt`)
- m3u8 - HLS playlist parsing (`requirements.txt`)
- tinytag - Audio metadata extraction (`requirements.txt`)
- prettytable - Formatted table output (`requirements.txt`)
- tabulate - Table formatting (`requirements.txt`)
- emoji - Emoji support (`requirements.txt`)
- pathvalidate - File path validation (`requirements.txt`)
- bleach - HTML sanitization (`requirements.txt`)
- platformdirs - Platform-specific directory paths (`requirements.txt`)
- prompt_toolkit - Interactive command-line (`requirements.txt`)
- faster-whisper - Speech-to-text for lyric extraction (`requirements-optional.txt`)
- pyfreeproxy - Proxy support (`requirements-optional.txt`)
- pillow - Image processing (`requirements-optional.txt`)
## Configuration
- `.readthedocs.yaml` - ReadTheDocs build configuration
- `setup.py` - Package metadata and entry points
- Console entry point: `musicdl = musicdl.musicdl:MusicClientCMD`
- `MANIFEST.in` - Package data includes
- `setup.py` specifies `package_data={"musicdl": ["modules/js/youtube/*.js"]}`
- Custom package building with `find_packages()`
## Platform Requirements
- Python 3.11+
- Node.js (via nodejs-wheel)
- FFmpeg (for audio remuxing, optional)
- Optional: n_m3u8DL-RE binary for DASH/HLS downloads
- No external database required - file-based operation
- Works on Windows, macOS, Linux (cross-platform via Python)
- Optional proxy support via `pyfreeproxy`
- Optional speech-to-text via `faster-whisper`
## Special Notes
- **DRM Support**: Includes `pywidevine` for protected streaming services (Apple Music, TIDAL)
- **Browser Impersonation**: Uses `curl_cffi` for advanced HTTP requests with browser fingerprinting
- **Node.js Bundled**: `nodejs-wheel` provides Node.js without external installation
- **Modular Architecture**: Music service clients are pluggable in `modules/sources/`
- **Audio Format Support**: Handles multiple formats including MP3, FLAC, M4A, AAC via ffmpeg/av
- **Lyric Support**: Environment variable `ENABLE_WHISPERLRC=True` enables speech-to-text lyric extraction
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Snake_case for all module files: `netease.py`, `qq.py`, `base.py`
- Utility files grouped by functionality: `misc.py`, `logger.py`, `data.py`, `hosts.py`, `modulebuilder.py`
- Source client implementations follow pattern: `{music_source_name}.py` in lowercase
- Snake_case for all function names
- Private/internal functions prefixed with single underscore: `_constructsearchurls()`, `_search()`, `_initsession()`
- Property functions with underscores: `_parsewithofficialapiv1()`, `_parsewithxiaoqinapi()`
- Public methods without underscores: `search()`, `download()`, `parseplaylist()`
- Descriptive method names indicating operation type: `_constructuniqueworkdir()`, `_removeduplicates()`, `estimatedurationwithfilesizebr()`
- Snake_case for local and module-level variables
- Class attributes use snake_case
- Class constants in UPPERCASE with underscores: `LOSSLESS_QUALITY_DEFINITIONS`, `REGISTERED_MODULES`, `VALID_AUDIO_EXTS`
- Type hints used extensively in function signatures and class attributes
- PascalCase for class names: `BaseMusicClient`, `NeteaseMusicClient`, `SongInfo`, `LoggerHandle`, `AudioLinkTester`
- Use `Optional[T]` for nullable types
- Use `dict[str, Any]` for flexible dictionaries
- Use `list[SongInfo]` for typed lists
- Type hints after parameters: `def __init__(self, keyword: str = '', headers: dict = None, ...)`
## Code Style
- No automated formatter detected (black/autopep8)
- Multi-line methods and functions supported with extended parameter lists
- Long lambda functions used inline but can span multiple lines with indentation
- Imports organized at top of files with clear sections
- No linting configuration detected (.flake8, .pylintrc, pyproject.toml)
- Code uses `warnings.filterwarnings('ignore')` to suppress warnings when needed
- Triple-quoted strings used for docstrings and comments
- Every file begins with triple-quoted docstring containing:
## Import Organization
- No path aliases configured
- Relative imports used extensively: `from .base import BaseMusicClient`, `from ..utils import LoggerHandle`
- Conditional imports for optional dependencies: `if __name__ == '__main__':` vs normal imports
## Error Handling
- Bare `except:` clauses used for broad exception handling
- Try-except blocks with `continue` or `break` in loops to handle failure gracefully
- Common pattern for testing URLs/APIs that may fail:
- Walrus operator `:=` used to assign and check in single line
- Exception swallowing with `pass` in many cases where behavior should continue
- Lines 66-67: Try to fetch data, break if fails
- Lines 70-71: Try to get song info, pass if fails, continue
- Lines 119-120: Try to convert duration, except clause sets default
## Logging
- `LoggerHandle` class wraps Python's logging module
- Configures file logging to user log directory: `user_log_dir(appname='musicdl', appauthor='zcjin')`
- Log file location: `~/.local/share/musicdl/musicdl.log` (platform-dependent)
- Supports both file and console output
- `debug(message, disable_print=False)` - DEBUG level
- `info(message, disable_print=False)` - INFO level
- `warning(message, disable_print=False)` - WARNING level with red colorization
- `error(message, disable_print=False)` - ERROR level with red colorization
- `disable_print=True` flag writes to file only, skips console
- Color support via `colorize()` function for terminal output
- All logging methods convert input to string: `message = str(message)`
- `self.logger_handle.info(f'Start to search music files using {self.source}.', disable_print=self.disable_print)`
- `self.logger_handle.warning('No songs found from %s' % ', '.join(self.music_sources))`
## Comments
- Method purpose indicated by triple-quoted strings above method: `'''methodname'''`
- Inline section comments with triple quotes: `'''settings'''`, `'''initialize'''`
- Logic explanations using inline `# comment` style sparingly
- Not used (Python project)
- Type hints serve documentation purpose instead: `def search(self, keyword: str, num_threadings: int = 5, request_overrides: dict = None)`
## Function Design
- Functions are medium to large, sometimes exceeding 50 lines
- Lambda functions used inline for complex operations like time conversion: `to_seconds_func = lambda x: ...`
- Parsing functions in `netease.py` contain complex single-line operations with walrus operators
- Default parameters used for optional configuration
- Type hints on all parameters: `keyword: str`, `num_threadings: int = 5`, `request_overrides: dict = None`
- Optional parameters default to empty dict or None: `rule: dict = None`, `request_overrides: dict = None`
- `**kwargs` used to pass through configuration to parent class constructors
- Methods return structured objects when possible: `SongInfo` objects, lists of `SongInfo`
- Dictionary returns for status/metadata: `{'ok': bool, 'status': str, ...}`
- None returned implicitly when no explicit return (not common)
- Generator-style iteration with `as_completed()` from `concurrent.futures`
## Module Design
- Barrel file pattern in `__init__.py` files for clean imports
- `musicdl/modules/__init__.py` imports and re-exports key classes:
- Allows consumer code to import from package root: `from musicdl.modules import LoggerHandle`
- Heavy use of barrel files to organize complex module hierarchies
- `musicdl/modules/sources/__init__.py` exports all music client implementations
- `musicdl/modules/utils/__init__.py` exports utilities grouped by function
- `MusicClientBuilder` class in `sources/__init__.py` uses registry pattern
- `REGISTERED_MODULES` dict maps string identifiers to client classes
- `BuildMusicClient()` function instantiates clients by module config
## Class Inheritance and Composition
- Most music client implementations inherit from `BaseMusicClient`
- Pattern: `class NeteaseMusicClient(BaseMusicClient):`
- Parent class handles common functionality: session management, progress tracking, error handling
- `SongInfo` is a dataclass with fields and methods
- Uses `@dataclass` decorator from `dataclasses` module
- Properties and methods for complex derived values: `save_path`, `with_valid_download_url`
## Decorators and Special Methods
- Custom decorators for cookie/header management: `@usesearchheaderscookies`, `@useparseheaderscookies`, `@usedownloadheaderscookies`
- Used to automatically set appropriate headers/cookies for different API operations
- Standard dataclass magic methods in `SongInfo`: `__getitem__`, `__setitem__`, `__contains__`
- Enables dict-like access to dataclass fields
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Multiple concrete music source clients inherit from a common base class (`BaseMusicClient`)
- Each music source implements platform-specific APIs (Netease, QQ Music, Spotify, YouTube, etc.)
- Central orchestration layer (`MusicClient`) manages multiple sources simultaneously
- Plugin/registry pattern for dynamic client registration via `MusicClientBuilder`
- Uniform interface across heterogeneous music sources through `BaseMusicClient` abstraction
## Layers
- Purpose: High-level user interaction and coordination across all music sources
- Location: `musicdl/musicdl.py`
- Contains: `MusicClient` class (search, download, playlist parsing), CLI command handler `MusicClientCMD`
- Depends on: Music source clients, utilities, logging
- Used by: CLI interface, programmatic API consumers
- Purpose: Platform-specific implementation of search, parse, and download operations
- Location: `musicdl/modules/sources/` (21 different source implementations)
- Contains: Platform-specific HTTP request logic, response parsing, download URL extraction
- Depends on: Utilities (HTTP, parsing, logging, audio testing)
- Used by: Orchestration layer
- Purpose: Cross-cutting concerns and shared functionality
- Location: `musicdl/modules/utils/`
- Contains:
- Depends on: External libraries (requests, mutagen, TinyTag, etc.)
- Used by: Music source clients, orchestration layer
- Purpose: Execute platform JavaScript code (e.g., YouTube signature decipher)
- Location: `musicdl/modules/js/youtube/`
- Contains: `jsinterp.py` (JavaScript interpreter, bundled `.js` files)
- Depends on: None (internal)
- Used by: YouTube music client
## Data Flow
- **Per-source state**: Session (`self.session`), headers, cookies, user agents maintained in each `BaseMusicClient` instance
- **Per-download state**: `SongInfo` dataclass carries all metadata throughout pipeline
- **Shared state**: `LoggerHandle` singleton for coordinated logging
- **Thread safety**: `Lock` objects protect progress updates during concurrent operations
- **File system state**: Work directories created per source + keyword, search/download results pickled locally
## Key Abstractions
- Purpose: Unified domain model representing a song's metadata and download state
- Examples: `musicdl/modules/utils/data.py`
- Pattern: Dataclass with property-based computed fields (`save_path`, `with_valid_download_url`)
- Key fields: song_name, singers, album, ext, duration_s, download_url, download_url_status, work_dir, cover_url, lyric, episodes (for FM/podcasts)
- Purpose: Abstract interface all music sources implement
- Examples: `musicdl/modules/sources/base.py` (template)
- Pattern: Template Method - defines `search()` and `download()` orchestration, subclasses implement `_constructsearchurls()` and `_search()`
- Key methods: `search()`, `download()`, `parseplaylist()`, `_download()`, `_search()`, `_constructsearchurls()`
- Threading: Uses `ThreadPoolExecutor` for parallel URL fetching within a single source
- Purpose: Orchestrator managing multiple sources
- Examples: `musicdl/modules/musicdl.py`
- Pattern: Facade/Coordinator - hides complexity of multi-source interaction
- Key responsibilities: Source initialization, concurrent search across sources, result aggregation, download delegation
- Purpose: Factory/Registry for dynamic client instantiation
- Examples: `musicdl/modules/utils/modulebuilder.py` (base), `musicdl/modules/sources/__init__.py` (registry)
- Pattern: Registry Pattern - `REGISTERED_MODULES` OrderedDict maps source class names to constructors
- Extensibility: New sources can be registered via `MusicClientBuilder().register(name, SourceClass)`
- Purpose: Validate and probe audio download URLs
- Examples: `musicdl/modules/utils/misc.py`
- Pattern: Strategy - tests HTTP status, HEAD requests, stream probing
- Returns: Dictionary with `ok` (boolean), `ext` (file type), `file_size` (from Content-Length)
## Entry Points
- Location: `musicdl/musicdl.py:MusicClientCMD()`
- Triggers: Console command `musicdl` (defined in `setup.py` entry_points)
- Responsibilities: Parse CLI arguments, instantiate `MusicClient`, route to search/download/playlist flow
- Location: `musicdl/musicdl.py:MusicClient` class
- Triggers: Imported and instantiated in Python code
- Responsibilities: Provide Python API for search/download/playlist operations
## Error Handling
- **Search errors**: Source-level try/catch in `MusicClient.search()` - one source's failure doesn't block others. Returns `[]` for failed sources.
- **Download errors**: Individual song errors caught in `BaseMusicClient._download()` - skipped song logged, others continue. Progress UI shows "Error: {exception}" per song.
- **Parse errors**: Custom API responses checked for validity via `isvalidresp()`, `resp2json()`, `safeextractfromdict()`
- **URL validation**: Every download URL tested via `AudioLinkTester` before attempting download - avoids wasted bandwidth
- **Decorator-based cleanup**: `@usesearchheaderscookies`, `@usedownloadheaderscookies`, `@useparseheaderscookies` decorators manage header/cookie lifecycle
- `NotImplementedError`: Raised by abstract methods in `BaseMusicClient` (e.g., `_constructsearchurls()`)
- `AssertionError`: Input validation (e.g., valid source names in `MusicClient.__init__()`)
- Generic `Exception`: Caught and logged, operation continues (resilient design)
## Cross-Cutting Concerns
- Framework: `LoggerHandle` in `musicdl/modules/utils/logger.py`
- Approach: Centralized logger, each client/orchestrator logs via `self.logger_handle.info()/warning()/error()`
- Output: Colored console output, optional suppression via `disable_print` flag
- Input: Type checking in `__init__()` methods (dict/list/str assertions)
- Data: `SongInfo` field validation via dataclass, URL format checks, file existence checks
- Responses: Helper functions `isvalidresp()`, `resp2json()` validate HTTP responses
- Cookies: Per-source default cookies stored, overridable per request
- Headers: User-Agent randomization via `fake_useragent`, custom Referer headers per platform
- Proxies: Optional proxy auto-configuration via `freeproxy` library if enabled
- curl_cffi: Optional TLS fingerprinting via `curl_cffi` to evade detection
- Search: ThreadPoolExecutor with configurable `num_threadings` per source (default 5, audiobooks 3)
- Download: ThreadPoolExecutor with `num_threadings` per source (default 5, GDStudio 10)
- Progress tracking: `rich.Progress` with `Lock` for thread-safe updates to shared progress bars
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
