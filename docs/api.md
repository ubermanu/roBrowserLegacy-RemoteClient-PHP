# API Endpoints

The remote client provides several API endpoints for monitoring and diagnostics.

## Health Check & Validation

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
