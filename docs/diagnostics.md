# Diagnostics & Validation

## Doctor Command

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

## Validation API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /api/validate` | GET | Run basic validation |
| `GET /api/validate?deep=true` | GET | Run deep validation |

See [api.md](api.md) for the full endpoint list.
