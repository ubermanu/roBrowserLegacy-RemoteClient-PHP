# Korean Path Mapping

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

## Generating path-mapping.json

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
