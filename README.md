# roBrowser Remote Client (PHP)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/MrAntares/roBrowserLegacy-Remoteclient-PHP)

The remote client exist to help users without a FullClient on their computer to play by downloading resources from an external server.
Because pushing directly the fullclient on a server/ftp can provoke some errors, this tool allow to :

 - Get the files from a client used in another domain (Cross-origin resource sharing).
 - Extracting files directly from GRF archive (versions 0x200 and 0x300 supported).
 - Converting BMP files to PNG to speed up the transfer.
 - Optimized to don't call any script if files are already extracted/converted (resource friendly).
 - **File Index for O(1) lookups**: Files are indexed at startup for instant lookups instead of sequential search through GRFs.
 - **Gzip/Deflate Compression**: Automatically compresses text-based responses (XML, TXT, LUA, etc.) to reduce bandwidth.
 - **HTTP Cache Headers** (ETag, Cache-Control, 304 Not Modified) for browser caching.
 - **LRU Cache** for fast repeated file access (in-memory caching).
 - **Missing Files Log** for tracking and debugging missing game assets.
 - **Health Check API** (`/api/health`) for monitoring and diagnostics.
 - **Korean Path Mapping** for CP949/EUC-KR filename encoding support.
 - **Warm Cache** for pre-loading frequently accessed files at startup.
 - **Startup Validator** for system validation and diagnostics.
 - **Doctor Command** (`bin/doctor`) for CLI-based diagnostics.

## Quick Start

### 1. Add your fullclient

Put your GRFs, DATA.INI and the `data/`, `BGM/`, `System/` and `AI/` folders from your fullclient
in the `client/` directory (see [client/README.md](client/README.md)).

> [!TIP]
> To be sure to use a compatible version of your GRFs, download *GRF Builder* and repack them
> manually (Option > Repack type > Repack), it will ensure the GRFs files are converted in the
> proper version.

### 2. Configure

Copy the file [.env.example](.env.example) to the same directory as `.env`.
Every setting is optional - the defaults are defined in [configs.php](configs.php).

### 3. Run diagnostics

```bash
bin/doctor              # Basic validation
bin/doctor --deep       # Deep validation with encoding analysis
```

See [docs/diagnostics.md](docs/diagnostics.md) for what it checks.

### 4. Start the server

Using Docker or your preferred web server (Apache, Nginx).

#### Using Docker

The containers do not handle or copy the game files - set those up in `client/` first (step 1).

```bash
# NGINX
docker compose --profile nginx up --build

# Apache
docker compose --profile apache up --build
```

The webserver will be answering requests on the 80 port.

#### Using your own web server

Point the document root to the `public/` directory and map the game content URLs to the `client/`
directory (see [docker/apache/Dockerfile](docker/apache/Dockerfile) or
[docker/nginx/Dockerfile](docker/nginx/Dockerfile) for reference):

```
/data   -> client/data
/BGM    -> client/BGM
/System -> client/System
/AI     -> client/AI
```

Requests for files that are not found on disk must be routed to `public/index.php` (404 handler), which
extracts them from the GRF archives.

## GRF Version Support

| Version | Status | Notes |
|---------|--------|-------|
| 0x200 | ✅ Supported | 32-bit file offsets, no DES encryption |
| 0x300 | ✅ Supported | 64-bit file offsets (files > 4GB), no DES encryption |
| DES Encrypted | ✅ Supported | |

## Documentation

| Document | Contents |
|----------|----------|
| [docs/diagnostics.md](docs/diagnostics.md) | Doctor command and validation API |
| [docs/api.md](docs/api.md) | Health check and monitoring endpoints |
| [docs/performance.md](docs/performance.md) | HTTP cache headers, LRU cache, warm cache |
| [docs/korean-path-mapping.md](docs/korean-path-mapping.md) | CP949/EUC-KR filenames and `var/path-mapping.json` |
| [docs/faq.md](docs/faq.md) | Vhost overrides, testing your setup, how it works |
