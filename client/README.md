# Game client files

Everything in this directory (except this file) is ignored by git.
Put your full client content here:

```
client/
├── DATA.INI        # Lists the GRFs to load, and in which order
├── *.grf           # Your GRF archives (e.g. data.grf, rdata.grf, custom.grf)
├── data/           # Extracted / override game files (served as /data/...)
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

Notes:

- When `CLIENT_AUTOEXTRACT` is enabled, files read from the GRFs are
  extracted into `client/data/` so subsequent requests are served directly
  by the web server. This requires write access to this directory.
- To be sure to use a compatible version of your GRFs, download *GRF Builder*
  and repack them manually (Option > Repack type > Repack).
- The locations can be changed with the `CLIENT_RESPATH` / `CLIENT_DATAPATH`
  settings in `configs.php` (or the matching environment variables).
