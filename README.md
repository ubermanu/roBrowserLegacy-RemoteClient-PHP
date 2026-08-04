Setup the remote client
=======================

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

## Project Structure

```
├── bootstrap.php       # PSR-4 autoloader (no external dependencies)
├── configs.php         # Configuration (overridable via environment variables)
├── bin/                # CLI commands
│   ├── doctor          #   Diagnostics
│   └── convert-encoding #  Korean path mapping generator
├── public/             # Web server document root
│   └── index.php       # Front controller (file extraction + API endpoints)
├── src/                # PHP sources (namespace RoBrowser\RemoteClient)
├── client/             # Your game client files - gitignored (see client/README.md)
│   ├── DATA.INI        #   GRF load order
│   ├── *.grf           #   GRF archives
│   ├── data/           #   Extracted/override files, served as /data/...
│   ├── BGM/            #   Served as /BGM/...
│   ├── System/         #   Served as /System/...
│   └── AI/             #   Served as /AI/...
├── var/                # Runtime files (gitignored)
│   ├── cache/          #   Index cache
│   └── logs/           #   Logs
└── docker/             # Apache / Nginx container recipes
```

## Quick Start

### 1. Add your fullclient

Put your GRFs files and DATA.INI file in the `client/` directory.
Add your own `data/`, `BGM/`, `System/` and `AI/` folders inside `client/` as well (see [client/README.md](client/README.md)).

**Note: to be sure to use a compatible version of your GRFs, download *GRF Builder* and repack them manually (Option > Repack type > Repack), it will ensure the GRFs files are converted in the proper version**

### 2. Run diagnostics

```bash
bin/doctor              # Basic validation
bin/doctor --deep       # Deep validation with encoding analysis
```

### 3. Start the server

Using Docker or your preferred web server (Apache, Nginx).

When configuring a web server manually, point the document root to the `public/` directory and map the game
content URLs to the `client/` directory (see [docker/apache/Dockerfile](docker/apache/Dockerfile) or
[docker/nginx/Dockerfile](docker/nginx/Dockerfile) for reference):

```
/data   -> client/data
/BGM    -> client/BGM
/System -> client/System
/AI     -> client/AI
```

Requests for files that are not found on disk must be routed to `public/index.php` (404 handler), which
extracts them from the GRF archives.

---
## Wiki

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/MrAntares/roBrowserLegacy-Remoteclient-PHP)

## Diagnostics & Validation

### Doctor Command

The `bin/doctor` command provides comprehensive system validation:

```bash
# Basic validation
bin/doctor

# Deep validation (includes encoding analysis - slower but thorough)
bin/doctor --deep

# JSON output (for automation)
bin/doctor --json

# Show help
bin/doctor --help
```

**What it validates:**
- ✓ PHP version (minimum 7.4.0)
- ✓ Required extensions (zlib, mbstring)
- ✓ Optional extensions (gd, iconv)
- ✓ Required files and directories
- ✓ Configuration (DATA.INI, memory limit)
- ✓ GRF file format (0x200 / 0x300)
- ✓ GRF file table (zlib compressed)
- ✓ Path encoding (UTF-8 vs legacy CP949/EUC-KR)
- ✓ Mojibake detection (--deep mode)

**Example output:**
```
╔════════════════════════════════════════════════════════════════════════════╗
║            🏥 roBrowser Remote Client - Doctor (PHP)                       ║
║                        System Diagnosis                                    ║
╚════════════════════════════════════════════════════════════════════════════╝

================================================================================
📋 VALIDATION REPORT
================================================================================

✓ INFORMATION:
   PHP version: 8.3.6
   Extension 'zlib' loaded
   Extension 'mbstring' loaded
   DATA.INI found: data/DATA.INI
   Valid GRF: data.grf (version 0x200)
   Memory limit: 1000M

================================================================================
✅ Validation completed successfully!
================================================================================
```

### Validation API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /api/validate` | GET | Run basic validation |
| `GET /api/validate?deep=true` | GET | Run deep validation |

---

## Performance Features

### HTTP Cache Headers

The server implements proper HTTP cache headers for browser caching:

- **ETag**: Content-based validation for conditional requests
- **304 Not Modified**: Reduces bandwidth by validating client cache
- **Cache-Control**: Optimized per file type
  - Game assets (sprites, maps, etc.): 1 year with `immutable`
  - Other files: 30 days
- **Expires**: HTTP/1.0 compatibility

This significantly reduces bandwidth and speeds up repeated requests, as unchanged files are served from browser cache.
### LRU File Cache

The server implements an in-memory LRU (Least Recently Used) cache for file content:

- **Default**: 100 files, 256MB max memory
- **O(1)** get/set operations
- Automatic eviction of least recently used files
- Configurable via environment variables

```env
CACHE_ENABLED=true
CACHE_MAX_FILES=100
CACHE_MAX_MEMORY_MB=256
```

| Setting | Description | Default |
|---------|-------------|---------|
| `CACHE_ENABLED` | Enable/disable cache | `true` |
| `CACHE_MAX_FILES` | Max files in cache | `100` |
| `CACHE_MAX_MEMORY_MB` | Max memory usage | `256` MB |

### Korean Path Mapping

Many Ragnarok GRF files contain Korean filenames encoded in CP949/EUC-KR. When these are read on non-Korean systems, they appear as mojibake (garbled characters).

**The Problem:**
```
Client requests: /data/texture/유저인터페이스/t_배경3-3.tga
GRF contains:    /data/texture/À¯ÀúÀÎÅÍÆäÀÌ½º/t_¹è°æ3-3.tga
```

**The Solution:**

The server uses a `path-mapping.json` file to map Korean UTF-8 paths to their GRF equivalents:

```env
PATH_MAPPING_ENABLED=true
PATH_MAPPING_FILE=path-mapping.json
```

| Setting | Description | Default |
|---------|-------------|---------|
| `PATH_MAPPING_ENABLED` | Enable/disable path mapping | `true` |
| `PATH_MAPPING_FILE` | Path to mapping file | `path-mapping.json` |

**Generating path-mapping.json automatically:**

```bash
# Generate path-mapping.json by scanning your GRFs
bin/convert-encoding

# Preview without writing (dry run)
bin/convert-encoding --dry-run

# Custom output file
bin/convert-encoding --output=custom-mapping.json

# Verbose output
bin/convert-encoding --verbose
```

The tool will:
1. Read DATA.INI to find your GRF files
2. Scan each GRF for non-UTF-8 filenames (Korean CP949/EUC-KR)
3. Convert filenames to proper Korean UTF-8
4. Generate mappings: Korean path → GRF path

**Example output:**
```json
{
    "generatedAt": "2026-01-18T12:00:00Z",
    "paths": {
        "data/texture/유저인터페이스/file.tga": "data/texture/À¯ÀúÀÎÅÍÆäÀÌ½º/file.tga"
    },
    "summary": {
        "totalFiles": 450000,
        "totalMapped": 12500
    }
}
```

### Warm Cache

The server can pre-load frequently accessed files into the LRU cache at startup or on-demand:

- **Essential files** pre-loaded for faster initial requests
- **Pattern matching** with wildcards for file groups
- **Memory limit aware** - stops warming when limits reached
- **Statistics tracking** for monitoring
- **API endpoint** for on-demand warming
- Configurable via environment variables

```env
WARM_CACHE_ENABLED=true
WARM_CACHE_MAX_FILES=50
WARM_CACHE_MAX_MEMORY_MB=50
```

| Setting | Description | Default |
|---------|-------------|---------|
| `WARM_CACHE_ENABLED` | Enable/disable warm cache | `true` |
| `WARM_CACHE_MAX_FILES` | Max files to warm | `50` |
| `WARM_CACHE_MAX_MEMORY_MB` | Max memory for warming | `50` MB |

**Essential files warmed by default:**
- `data\clientinfo.xml` - Client configuration
- `data\lua files\*.lub` - Lua scripts
- `data\sprite\*.spr` - Character sprites (basic)
- `data\texture\*.bmp` - UI textures

**API Endpoints:**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/warm-cache` | GET | Get warm cache status and stats |
| `/api/warm-cache/run` | POST | Trigger cache warming manually |

### GRF Version Support

| Version | Status | Notes |
|---------|--------|-------|
| 0x200 | ✅ Supported | 32-bit file offsets, no DES encryption |
| 0x300 | ✅ Supported | 64-bit file offsets (files > 4GB), no DES encryption |
| DES Encrypted | ✅ Supported | |

## API Endpoints

The remote client provides several API endpoints for monitoring and diagnostics:

### Health Check & Validation

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /api/health` | GET | Complete system health status |
| `GET /api/health/simple` | GET | Simple status check (fast) |
| `GET /api/validate` | GET | Run startup validation |
| `GET /api/validate?deep=true` | GET | Run deep validation with encoding |
| `GET /api/cache-stats` | GET | Cache and index statistics |
| `GET /api/missing-files` | GET | Missing files log summary |
| `POST /api/missing-files/clear` | POST | Clear missing files log |
| `GET /api/warm-cache` | GET | Warm cache status and stats |
| `POST /api/warm-cache/run` | POST | Trigger cache warming |
| `GET /api/path-mapping` | GET | Path mapping statistics |

**Example response for `/api/health`:**

```json
{
    "status": "ok",
    "timestamp": "2026-01-18T12:00:00+00:00",
    "grfs": {
        "total": 2,
        "valid": 2
    },
    "cache": {
        "enabled": true,
        "items": 45,
        "hitRate": "96.5%"
    },
    "index": {
        "totalFiles": 450000
    },
    "hasWarnings": false
}
```

## Running the Remote Client

### Using Docker container

You can use this setup with the container to run the remote client API. Using docker container does not handle/copy 
the game files. You need to set up them first on the directory.

Copy the file [.env.example](.env.example) to the same directory as .env

After copying the game files and modifiying your .env file, you can start the container services.

#### I want to use NGINX server

You can start using the remote client with NGINX using the following command:

```bash
docker compose --profile nginx up --build
```

The webserver will be answering requests on the 80 port.

#### I want to use Apache server

```bash
docker compose --profile apache up --build
```

## FAQ

### How I can change NGINX/Apache virtual host configuration?

The vhosts configuration for both Apache and NGINX are baked into the container recipe. If you need to change this, 
you have to modify the respective [Apache Dockerfile](docker/apache/Dockerfile) or [NGINX dockerfile](docker/nginx/Dockerfile)
and re-run the docker compose command.

You can also override vhost configuration on **/etc/apache2/sites-available/000-default.conf** for Apache or **/etc/nginx/conf.d/default.conf** for NGINX
using docker compose specification adding a bind mount, example:

```yaml
volumes:
  - ./:/var/www/html:ro
  - ./my-own-nginx.conf:/etc/nginx/conf.d/default.conf
```

### How can I make sure that my remote client works as expected?

If you set up all the required files correctly, you can run the python script [tester.py](docker/test/tester.py). This
script reads a file list in the same directory (list.txt) that contains multiple filenames that should be in a GRF.
The script will request each file to the target webserver defined in **TARGET_SERVER_ADDRESS** variable, checking if the 
server answers with an HTTP code 200, if not, a new log file is created with the HTTP code and the file url requested, so
you can debug it afterward.

Example, running the list against a working server (localhost, apache and nginx):

Apache
```
=== Final result ===
Total: 2784 | OK: 2784 | FAIL: 0
Elapsed time: 110.10 seconds
```
NGINX
```
=== Final result ===
Total: 2784 | OK: 2784 | FAIL: 0
Elapsed time: 1.86 seconds
```

### How this remote client works?

![](docs/how-it-works-high.png)
