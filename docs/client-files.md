# Game client files

The remote client reads your fullclient but never writes to it, so it can live
anywhere and be mounted read-only. Point `CLIENT_PATH` at it, or link it as
`client/` in the project root:

```bash
ln -s ~/kRO_FullClient client
```

Expected layout:

```
client/
├── DATA.INI        # Lists the GRFs to load, and in which order
├── *.grf           # Your GRF archives (e.g. data.grf, rdata.grf, custom.grf)
├── data/           # Game files on disk (served as /data/...)
├── BGM/            # Background music (served as /BGM/...)
├── System/         # System files (served as /System/...)
└── AI/             # Homunculus / mercenary AI (served as /AI/...)
    └── USER_AI/
```

Example `DATA.INI`:

```ini
[Data]
0=custom.grf
1=rdata.grf
2=data.grf
```

## Extracted files

When `CLIENT_AUTOEXTRACT` is enabled, files read from the GRFs are written to
`EXTRACT_PATH` (`var/extracted/` by default), mirroring the client layout - so
they end up in `var/extracted/data/...` and `var/extracted/BGM/...`. The web
server serves those directly on subsequent requests, without going through PHP.

Requests are resolved in this order:

1. `var/extracted/` - files already extracted from the GRFs (including BMP images stored as PNG)
2. `client/` - the fullclient's own files
3. the GRF archives, via `public/index.php`

`EXTRACT_PATH` is the only location that needs to be writable. Deleting
`var/extracted/` clears the extracted files and is always safe.

> [!TIP]
> To be sure to use a compatible version of your GRFs, download *GRF Builder* and
> repack them manually (Option > Repack type > Repack).
