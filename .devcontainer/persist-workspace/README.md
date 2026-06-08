# Persisted devcontainer workspace

I bind-mount this directory read/write as the devcontainer's scratch
workspace:

```text
.devcontainer/persist-workspace -> /workspace
```

Use `/workspace` inside the container for intermediate output files (PDF
extracts, generated artifacts, temporary downloads, etc.) that you want
to keep across container restarts but that don't belong in the Notes
vault at `/data`.

The `.gitignore` skips this folder's contents by default. Don't commit
secrets from here.
