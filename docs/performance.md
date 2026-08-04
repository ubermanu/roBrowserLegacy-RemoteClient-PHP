# Performance Features

## HTTP Cache Headers

The server implements proper HTTP cache headers for browser caching:

- **ETag**: Content-based validation for conditional requests
- **304 Not Modified**: Reduces bandwidth by validating client cache
- **Cache-Control**: Optimized per file type
  - Game assets (sprites, maps, etc.): 1 year with `immutable`
  - Other files: 30 days
- **Expires**: HTTP/1.0 compatibility

This significantly reduces bandwidth and speeds up repeated requests, as unchanged files are served from browser cache.

## LRU File Cache

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

## Warm Cache

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
