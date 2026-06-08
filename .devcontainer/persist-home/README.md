# Persisted Hermes home

This directory is bind-mounted read/write as the persistent state
directory for the `hermes` user inside the container:

```text
.devcontainer/persist-home -> /opt/data
```

I keep only **state** here, never tool binaries. The Dockerfile installs
every CLI (hermes, gws, yt-dlp, uv, plaid-cli, chromium, snaptrade, ...)
into `/usr/local/*` or `/opt/*`. This folder is for:

- `.hermes/`: Hermes runtime. config.yaml, .env (provider creds),
  state.db (conversation/memory), session history, plans, sandboxes,
  memories, skills cache, hooks, logs.
- `.config/`: per-tool config (gws OAuth tokens, gccli credentials,
  browser profile for cli-web-linkedin, etc.).
- `.cache/`, `.local/`, `.npm/`: standard XDG and npm caches.
- `.agent-browser/`: persisted Chromium profile (cookies, logged-in
  sessions) used by `agent-browser`.
- Shell state: `.bash_history`, `.hermes_history`, `.lesshst`.

This directory persists across container rebuilds, so credentials, OAuth
sessions, and conversation memory survive `just rebuild`.

The contents are gitignored by default (`*` in `.gitignore`; only
`.gitignore` and `README.md` are tracked). **Do not commit secrets from
this directory.**

## Bootstrap

The first time you bring the container up, expect this directory to be
empty except for the two tracked files. Hermes creates everything else
on first run. To seed your LLM provider credentials before that first
run, drop them in:

```text
.devcontainer/persist-home/.hermes/.env
```

`just start` warns if that file is missing or empty.
