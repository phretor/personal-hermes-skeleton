# personal-hermes

A portable, containerized personal agent that lives inside my notes
directory. This repo is the **public skeleton**: a working layout you can
read to understand the approach. The notes, memories, credentials, and
conversations stay private. Your version will look different from mine.

---

## What this is

A personal AI assistant (based on [Hermes][hermes] from Nous Research) running
in a Docker container that I bind-mount into a single notes directory (e.g.,
`~/Notes`). I bake binaries, browser, scheduler, and tool configs into the
container image; the build recipe sits in `~/Notes/.devcontainer/Dockerfile`.
Hermes writes its memory, sessions, auth tokens, and OAuth state to
`~/Notes/.devcontainer/persist-home/`. The notes themselves sit at the root,
in a [PARA](https://fortelabs.com/blog/para/) +
[JohnnyDecimal](https://johnnydecimal.com/) layout.

I drive Hermes mostly from Telegram throughout the day, drop into a TUI
when I want to attach to a session, and let scheduled tasks (cron) trigger
ingestion, briefings, and maintenance on their own.

### Current state

I use it daily. Telegram, calendar, email, Drive, fitness, and financial
integrations work. Three pieces remain in progress: financial-vault wiring,
agent-to-agent comms, and macOS-side data. See "Next steps" for the
details.

### How this started

I did not set out to build an agent. In December 2025 I started using
Claude to help migrate notes I had scattered across Readwise, Zotero,
Google Drive, my filesystem, and Obsidian (PARA + JD) into one place, so
I could have a single home for everything from then on. I wrote small,
vibe-coded migration scripts to do it.

As I learned about skill engineering and harness design, I started
automating small recurring tasks via CLIs. First ad-hoc, then under Claude
Code's `.claude/skills/`, then under Hermes once it had a stable harness.
I prefer CLIs over MCP servers: they consume fewer tokens per call, and
they don't need a separate process or remote service running. APIs and
CLIs already exist for everything I want to do.

Most of the skills, harness wiring, and config in this repo got drafted
**by agents** equipped with their own documentation and a skill-creation
skill. Claude, Pi, and Hermes write better skills for themselves than I
do for them. My job was to compare approaches (Daniel Miessler's
[PAI][pai], [GBrain][gbrain], [obsidian-claude][obs-claude]) against what
I had, decide the layout, and stay in the loop while the agents drafted
and revised.

[hermes]: https://github.com/NousResearch/hermes-agent
[pai]: https://github.com/danielmiessler/PAI
[gbrain]: https://github.com/g0t4/g-brain
[obs-claude]: https://github.com/loganpowell/obsidian-claude

---

## Daily interactions

Most of what I do with my personal Hermes install runs through Telegram
from my phone. A handful of examples from a normal week:

- **Ingest a resource.** I forward an article, paper, or blog post to the
  Telegram chat. Hermes routes it through the `ingest` skill, picks the
  right destination folder under `50 - Resources/`, writes a summary, and
  links it back to relevant projects in `10 - Projects/`. Heavier content
  (PDFs, GitHub repos, YouTube transcripts) goes through `media-ingest`
  and `youtube-transcript`. Hermes links the ingested resources from the
  daily note.
- **Brainstorm.** "What are five different angles on X?" Hermes pulls
  related notes from the vault, runs the `be-creative` or `ideate` skill,
  and replies with options I can react to.
- **Daily briefing.** Each morning, `briefing` aggregates calendar events,
  deadlines, open threads, and Telos goal status from the local vault
  first, then refreshes from Google APIs for the deltas. Hermes prepends
  the result to today's daily note and pushes it to Telegram.
- **Act on calendar / reminders / drive / email.** Via `gws` (Google
  Workspace CLI), Hermes reads and writes my calendar and tasks, and
  reads Gmail and Drive. "Reschedule tomorrow's 3pm to Thursday morning
  and add a 30-min prep block before it" works fine, also as an audio
  note.
- **Read fitness and health data (daily at 10am).** Garmin Connect via
  `gccli` (read-only by policy, via the `garmin-readonly` skill);
  Function Health labs via CLI; weekly `fitness-journal` summaries
  pulled into the vault.
- **Financial data.** Plaid for banking, SnapTrade for brokerage. Today
  this is "data is accessible"; tomorrow it's "Hermes maintains a
  read-only Finance folder mirroring positions and transactions" (see
  Next steps).
- **Search the vault.** "What did I think about X last March?" The
  `search` skill walks `MEMORY.md` files breadth-first (folder summaries
  first, then narrow folders, then individual notes) instead of grepping
  blind.
- **Change the agent itself.** "Add a skill that does X" or "this hook
  fires too often, tighten it." Hermes uses `skill-creator` to draft new
  skills under `.agent/skills/`, and I review the diffs.

Friction stays low because the agent and the notes share a directory. I
never "upload my context" anywhere.

---

## Principles

A few constraints shaped every design choice.

### Not disruptive

This repo is a reference, not a reusable system. It augments my existing
PARA+JD vault. If yours looks different, adapt the agent to your
structure instead of importing mine. The repo ships a *skeleton* and a
`Dockerfile`, not a "starter pack": what you want is the shape of the
integration, not its contents. Your shape will differ from mine.

### Portable

Agent memory, agent state, my notes, the container definition, and the
build system **all live in one directory**. `cp -R`, `rsync`, or
Syncthing the directory and the agent moves with it. No external
database, no cloud-side state.

### Containerized

The agent's access to my local machine is the bind-mounted `~/Notes`
directory and nothing else. Everything else flows over HTTPS APIs (LLM
provider, Google, Garmin, Plaid, etc.). To revoke a credential, I revoke
it upstream; to nuke local state, I delete `persist-home/` (the `$HOME`
of the user the agent process runs as inside the Docker container).

### Disciplined PARA-like structure as the memory backbone

The folder hierarchy *is* the long-term memory. `MEMORY.md` pages at
every level give the agent a map of the territory before it reads
individual notes. `.brain/hot.md` per-topic gives it the short-term
working set. Together they let the agent answer "where would I have put
notes about X?" without a vector DB. The `/tend` skill helps me and the
agent maintain the hierarchy.

### One computer, anywhere access

The agent runs on **one** computer (a Linux box at home). My notes reach
every device via Syncthing as markdown files, and I render them in
Obsidian. Use Vim/Emacs/Nano if you'd rather. I don't need the agent
**running** on every device. I need it where the compute and the network
sit; the *output* of its work syncs to my notes wherever I am.

### Only dependency is the LLM provider

I stay LLM-API-only for model quality and elasticity. Privacy isn't the
reason; if it were, I'd buy hardware and run local models. Today they'd
be good enough; tomorrow, probably not. This setup keeps workflow,
infrastructure, and compute environment uncoupled from any one
provider's quirks. To swap models I `/model` and I'm done. A hosted
agent platform would force me to give up the workflow I designed. That
lock-in isn't worth it to me.

### Easy to debug, update, change, rebuild, backup

- Debug: `j shell` drops into the container; `j hermes` attaches to the
  running TUI session in a `tmux` that runs "forever" inside the
  container.
- Update: edit `Dockerfile`, run `j rebuild`.
- Change behavior: tell Hermes to change something. It edits its own
  config, hooks, or skills; I review the diff and `/reload-skills`.
- Rebuild: `j rebuild && j restart`.
- Backup: snapshot the directory.

---

## Directory layout

The vault root is also the Hermes working directory inside the
container. Hermes finds config, skills, and state here:

```text
.
├── README.md                       ← you are here
├── AGENTS.md                       ← what Hermes / Claude / Codex see on entry
├── SOUL.md                         ← personality / style (loaded from AGENTS.md)
├── Justfile                        ← docker helpers (build/start/hermes/shell)
│
├── _INBOX/                         ← un-filed incoming content
├── _TODO/                          ← live task aggregation (dataview)
├── 00 - Index/                     ← master navigation
├── 10 - Projects/                  ← active projects (PARA)
├── 20 - Areas/                     ← ongoing areas of responsibility
├── 30 - Daily/                     ← YYYY-MM-DD notes
├── 40 - Concepts/                  ← reusable concepts/frameworks
├── 50 - Resources/                 ← reference material (articles, papers, ...)
├── 60 - Entities/                  ← people, organizations
├── 70 - Family/                    ← parallel structure for family-shared
├── 80 - Telos/                     ← goals, missions, strategies, values
├── 90 - Xtras/                     ← templates, scratch
│
├── .agent/
│   └── skills/                     ← my custom skills, loaded by Hermes
│
├── .brain/                         ← derived state (hot caches, manifests)
│   ├── hot.md                      ← global recent activity
│   ├── manifest.json               ← index of topical sub-caches
│   ├── task-sync.json              ← last external task sync
│   ├── timeline-hook.sh            ← PostToolUse hook
│   └── <para-jd-slug>/hot.md       ← per-topic recent-activity caches
│
└── .devcontainer/
    ├── Dockerfile                  ← image build recipe
    ├── devcontainer.json           ← VS Code devcontainer wiring
    ├── persist-home/               ← bind-mounted to /opt/data (agent state)
    └── persist-workspace/          ← bind-mounted to /workspace (scratch)
```

Hermes-specific paths inside the container:

| Container path | Mounted from | Holds |
|----------------|--------------|-------|
| `/data` | repo root (the vault) | Notes, skills, brain, config |
| `/opt/data` | `.devcontainer/persist-home/` | `.hermes/`, `.config/`, `.cache/`, browser profile |
| `/workspace` | `.devcontainer/persist-workspace/` | Ephemeral scratch (PDF extracts, downloads) |
| `/usr/local/bin/*` | image | All CLI binaries (uv, gws, yt-dlp, plaid-cli, ...) |
| `/opt/venv/` | image | Python venv (Playwright lives here) |
| `/opt/ms-playwright/` | image | Chromium for `agent-browser` |

I split binaries from state on purpose. Reproducible-from-Dockerfile
material goes in the image; anything that should survive a rebuild goes
in `persist-home/`.

---

## The base image

The base is [`nousresearch/hermes-agent:latest`][hermes-image]. It ships
the Hermes harness (`hermes` TUI, skill loader, cron scheduler, hook
system, model gateway). On top of that I add:

- Go 1.25 toolchain (so I can `go install` Go tools like plaid-cli)
- Node 25 (already in base) + `npm install -g @snaptrade/snaptrade-cli`
- `uv` + a Python venv with Playwright
- `gccli` (Garmin Connect CLI, built from source via `make`)
- `gws` (Google Workspace CLI, sha256-verified binary)
- `yt-dlp` + `ffmpeg`
- `plaid-cli` (via `go install`)
- Chromium 1223 via Playwright at `/opt/ms-playwright/`
- Standard PDF tools (`pdftotext`, `pdfinfo`, `pdfimages`, `qpdf`)
- `tzdata` and a `--build-arg TZ` so container time matches host time

[hermes-image]: https://hub.docker.com/r/nousresearch/hermes-agent

---

## Walkthrough: Justfile

I drive the whole container lifecycle through `just` recipes:

```text
j build         # build the image (passes host UID/GID for clean bind-mount perms)
j rebuild       # same, --no-cache
j start         # launch the long-lived container (sleep infinity)
j stop          # remove the container
j restart       # stop + start
j ps            # status
j logs          # tail container logs
j hermes        # attach to (or create) a tmux session running `hermes` inside
j shell         # bash inside the container, as the hermes user
j root-shell    # bash inside the container, as root
j browser-setup # one-time: download Chrome for agent-browser
j clean         # stop + remove image
```

The container runs **persistently** with `sleep infinity` and `tmux`. So
multiple `j hermes` invocations reattach to the same session, long-running
cron jobs keep running, and a separate `j shell` doesn't disrupt the TUI
session.

Footnote in the Justfile: the base Hermes image uses [s6-overlay][s6] as
its `ENTRYPOINT`, which **must** be PID 1. Do *not* pass Docker's
`--init`. It puts tini at PID 1 and s6 refuses to start.

[s6]: https://github.com/just-containers/s6-overlay

---

## Walkthrough: Dockerfile

Read top-to-bottom:

1. **Header comment.** The `binaries-vs-state` rule. Don't write under
   `/home/hermes`; the bind mount shadows that path at runtime.
2. **ARGs.** Pinned versions for every tool I install (`GWS_VERSION`,
   `YTDLP_VERSION`, `UV_VERSION`, `PLAID_CLI_VERSION`), plus `USER_UID`
   and `USER_GID` passed in via `j build` for ownership parity, and
   `TZ=America/Los_Angeles`.
3. **apt layer.** Playwright OS deps (libnss3, libnspr4, libatk-*), PDF
   tools, python3 + venv + pip, tzdata, git, make, ripgrep, tmux. The
   layer ends with the timezone symlink so `date` reports local time
   inside the container.
4. **Go toolchain.** Downloaded from go.dev. Debian bookworm only ships
   Go 1.19; I need 1.25 for upstream tools.
5. **npm globals.** `@snaptrade/snaptrade-cli` (and historically the `pi`
   coding agent, now removed since Hermes replaced it).
6. **The big tools RUN.** One layer per tool would balloon image size,
   so I install gccli (from source), gws (sha256-verified binary),
   yt-dlp (sha256-verified against `SHA2-256SUMS`), and uv (sha256-
   verified) inside one shared `tmpdir` that I clean up at the end.
7. **plaid-cli.** `go install github.com/landakram/plaid-cli@v0.0.6`
   with `GOBIN=/usr/local/bin`. Works on both amd64 and arm64; the
   upstream release page only ships amd64 binaries.
8. **Python venv at `/opt/venv` + Playwright.** `uv venv`, then `uv pip
   install playwright`, then a separate layer runs `playwright install
   --with-deps chromium`. Docker caches the browser download separately
   from CLI repo changes.
9. **User setup.** `groupmod` / `usermod` to align the existing `hermes`
   user with the host's UID/GID via build args.

I end every RUN with a smoke test (`yt-dlp --version`, `uv --version`,
`plaid-cli --help`, `playwright --version` + chromium dir check), so the
build fails fast instead of at first agent run.

---

## Walkthrough: devcontainer.json

I don't use this for the VS Code integration, but I want a "source of
truth" for the bind mount points:

1. `${localWorkspaceFolder} → /data`: the vault, Hermes' workdir.
2. `${localWorkspaceFolder}/.devcontainer/persist-home → /opt/data`: the
   agent's persistent state directory.
3. `${localWorkspaceFolder}/.devcontainer/persist-workspace → /workspace`:
   scratch.

`containerUser` / `remoteUser` = `hermes`, `updateRemoteUserUID: true` so
VS Code realigns IDs if needed.

---

## Next steps

The setup is not done. What's left, in rough order:

### Financial data integration

I can read every account I care about via Plaid (banking) and SnapTrade
(brokerage). What I still need to give Hermes:

- Skills that summarize positions, transactions, and net worth into the
  `20 - Areas/Finance/` subtree
- Periodic ingestion (cron) into a read-only mirror of position state
- A budget-vs-actual report that runs weekly into the daily note

This is the next chunk I'll have Hermes draft for itself.

### Agent-to-agent communication

I have at least one Claude instance running on a remote dev workstation
for each of my personal projects. I want my personal Hermes agent (this
one) to be able to hand off tasks to it ("go work on this PR") and
receive results back. Likely via SSH.

### macOS coverage

Apple's ecosystem locks in some of our data and we're keeping it there.
My family uses Reminders, Photos, and Music. I don't want to spend
$200–300 on a used (and soon unsupported) Mac Mini to run an agent, and
an always-on Mac is more lock-in than I'll accept. What I'm exploring:

- A QEMU/KVM virtual macOS appliance booted from a USB-SSD
  ([phermes](https://github.com/phretor/phermes))
- Loadable via UEFI on any sufficiently powerful Linux box
- Doubles as a backup target for iCloud
- A Hermes-or-similar agent runs inside it for `apple-notes`,
  `apple-reminders`, `findmy`-style skills

---

## What's in this repo vs my actual vault

This is a public skeleton; the real vault stays private. What ships
here:

- Top-level folder layout (PARA+JD) with one anonymized sample
  `.md` per folder (and all 11 numbered files inside `80 - Telos/`).
  See [Sample files](#sample-files) below.
- `Dockerfile`, `devcontainer.json`, `Justfile` (the only files that
  define the agent's runtime)
- `AGENTS.md`, `SOUL.md` (anonymized)
- `.agent/skills/README.md` (explains where skills go; the skills
  themselves are personal)
- `.brain/README.md` + `timeline-hook.sh.example` (explains the
  derived-state directory; live caches stay private)
- Per-mount README + .gitignore patterns

What does **not** ship: real daily notes, real MEMORY.md content, real
entity pages, hot-cache contents, the conversation/state SQLite, OAuth
tokens, provider credentials, skill bodies, hook scripts wired with
personal paths.

For the SKILL.md format, read the Hermes documentation. The
`.agent/skills/README.md` in this repo links to the relevant config
knob.

## Sample files

Each PARA+JD folder has one anonymized `.md` sample showing the
conventions I use. The Telos folder has all 11 numbered files (skeletons
with one illustrative example per section). Each sample carries a
`> Note:` banner at the top explaining that the file is anonymized.

| Folder | Sample(s) |
|---|---|
| `00 - Index/` | `00 - Index.md`: master nav |
| `10 - Projects/` | `10 - Projects.md` + `MEMORY.md`: lifecycle rules + structural summary |
| `20 - Areas/` | `20 - Areas.md` + `MEMORY.md`: areas taxonomy |
| `30 - Daily/` | `30 - Daily.md` + `YYYY/YYYY-MM/YYYY-MM-DD.md`: daily-note skeleton with the real goal-tracker schema |
| `40 - Concepts/` | `40 - Concepts.md` |
| `50 - Resources/` | `50 - Resources.md` |
| `60 - Entities/` | `people/Jane Doe.md`: synthesized example entity page |
| `70 - Family/` | `70 - Family.md`: family vault skeleton |
| `80 - Telos/` | All 11 files (`01 - Problems.md` through `11 - Metrics.md`), skeleton + one illustrative example per section |
| `90 - Xtras/` | `Templates/Daily Note.md`: the actual Templater daily-note template |
| `_INBOX/` | `_INBOX.md`: pending-items + per-source dataviewjs blocks |
| `_TODO/` | `_TODO.md`: Obsidian Tasks syntax examples |

## License

This skeleton: MIT.
