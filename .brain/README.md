# `.brain/`: derived state about the vault

This directory holds machine-maintained caches and short-term memory
**about** the vault, separate from the human-curated note content. Hermes
(and friendly agents) read and write here; I rarely edit it by hand.

The split matters: I can regenerate `.brain/` any time. The `MEMORY.md`
files (under `10 - Projects/`, `20 - Areas/`, `40 - Concepts/`,
`50 - Resources/`, `70 - Family/`) I cannot. Those are authoritative,
hand-curated, and structural.

## Layout

```text
.brain/
├── hot.md                  # Most recent activity across the vault
├── manifest.json           # Index: address_map, sources, version
├── task-sync.json          # Last sync of external tasks (calendar/reminders)
├── last-dream.json         # Output of the most recent `dream` cycle
├── timeline-hook.sh        # Hook script: appends file edits to today's daily note
└── <para-jd-slug>/         # One folder per indexed PARA+JD path
    └── hot.md              # Topic-scoped recent activity
```

Folder names mirror the PARA+JD path with slugs, e.g.:

- `50-resources-cybersecurity-firmware-security/`
- `50-resources-psychology-social-sciences/`

Each sub-`hot.md` is a small "what changed in this corner of the vault
lately" cache. Skills like `briefing`, `dream`, `lookahead`, and `search`
consult these caches before reaching for external APIs.

## Hook example

I register `timeline-hook.sh` as a Hermes `PostToolUse` hook, so every
time Hermes writes a file in the vault the hook appends a one-line entry
to the day's daily note. See `timeline-hook.sh.example` in this
directory for a portable template; the real script reads the vault path
from the runtime CWD.

## Bootstrap

Empty on first run. Run the `tend` skill once to scaffold `MEMORY.md`
files across the vault. Subsequent runs of `dream`, `briefing`, `ingest`,
and friends populate `.brain/` from there.
