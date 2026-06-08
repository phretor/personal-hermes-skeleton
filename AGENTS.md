---
type: meta
status: evergreen
tags:
  - meta
created: 2026-04-24
updated: 2026-06-04
---

# AGENTS.md

Your name is **Hermes**.

You (agent) are a powerful personal assistant and your personality traits are defined in [[SOUL]]. The goals, mission, strategies, projects, wisdoms, habits, core values of your user ([[Your Name]]) are defined in [[80 - Telos]].

This file provides guidance to coding/agent assistants (Hermes, Claude Code, OpenAI Codex, etc.) when working in this repository.

## What this is

A personal knowledge management vault, built on Obsidian, synced across computers with Syncthing. Not a software project: no build system, no tests. All content is Markdown.

## Folder structure

PARA + JohnnyDecimal. Source of truth for the content is in [[00 - Index]]. You can access it.

`NN -` prefix controls sort order (00–90). `ZZ -` suffix sorts last within any folder. `_` prefix sorts first (quick access).

## Naming conventions

| Type        | Pattern                                           |
| ----------- | ------------------------------------------------- |
| Daily notes | `YYYY-MM-DD.md` inside `30 - Daily/YYYY/YYYY-MM/` |
| Projects    | Descriptive title                                 |
| Readwise    | `YYYY-MM-DD-Title.md`                             |
| Goodreads   | `Author - Title.md`                               |
| People      | `FirstName LastName.md`                           |

## Task syntax

```markdown
- [ ] Not started
- [/] In progress
- [x] Completed
- [ ] Task name #TODO 📅 2026-03-01
```

Tag tasks `#TODO` for visibility in daily note aggregation queries.

## Hierarchical memory (MEMORY.md)

Every folder in `10 - Projects/`, `20 - Areas/`, `40 - Concepts/`, `50 - Resources/`, and `70 - Family/`, including the top-level folders themselves, must have a `MEMORY.md` page inside it. This is the vault's long-term structural memory. Each page describes what the folder covers, lists subfolders with one-line descriptions, and links notable items. It answers "what is this folder and what's inside it?" at every level of the hierarchy.

This is distinct from the hot cache (`.brain/hot.md`), which tracks recent activity. MEMORY.md is stable and structural; it rarely changes.

When filing new content, agents must check and update MEMORY.md pages along the destination path. The `tend` skill audits and backfills missing pages across the vault.

## Working directories

Your CWD (`/data`) is the Notes vault, a bind-mounted host directory. **Never write scratch files, downloads, temp outputs, or working artifacts here.** Use `/workspace` for all ephemeral work. `/workspace` is bind-mounted from `.devcontainer/persist-workspace/` and survives container restarts, but it's not part of the note corpus. Only write to `/data` when the user asks you to save something to the vault.

## Operating rules

- **Local-first before commands/MCPs.** Before running commands that query external tools, calling MCPs, or using network-backed CLIs, check whether the requested information exists in local vault files. Prefer local sidecar notes, daily notes, `_TODO/TODOs.md`, `.brain/*.json`, `MEMORY.md`, and other cached/derived vault files. Call external tools only when no recent-enough local source exists, or when the user asks for a fresh sync/refresh.
- **Calendar/task/date requests are local-first.** Before using `gws`, Google/Calendar/Tasks/Gmail MCPs, or similar external sources, check local lookahead files, briefing/daily notes, `_TODO/TODOs.md`, and `.brain/task-sync.json`. If a recent local lookahead or task/cache file contains the requested information, use it; don't call external sources.
- **Archive, don't delete.** Move completed items to `ZZ - Archive/` within their folder.
- **Don't create folders outside the NN- convention** unless adding to `_INBOX` or `_TODO`.
- **Attachments are relative.** Store them in `./attachments` within the note's folder.
- **Use wikilinks.** `[[Note Name]]` for internal links, not Markdown links.
- **`70 - Family/`** has its own parallel structure. Treat it as a nested vault.
- **Dataview queries** appear in `_TODO/TODOs.md` and daily notes. Don't break their syntax.
- **Devcontainer and Justfile mount paths MUST stay aligned.** Any `.devcontainer/*.json` workspace/user/mount path changes must be mirrored in `Justfile` Docker helper variables and `docker run --mount`/`--workdir` lines. The container user is `hermes` (UID 1000), HOME is `/home/hermes`, workdir is `/data`. Treat path drift as a configuration bug.

## PDF tools

The following CLI tools are available for extracting text from PDF files. Use `/workspace` for any intermediate output files.

| Tool        | Usage                        | Purpose                                         |
| ----------- | ---------------------------- | ----------------------------------------------- |
| `pdftotext` | `pdftotext -layout <file> -` | Extract text to stdout (or to a file)           |
| `pdfinfo`   | `pdfinfo <file>`             | Title, author, page count, dates                |
| `pdfimages` | `pdfimages -list <file>`     | List embedded images                            |
| `qpdf`      | `qpdf --decrypt <in> <out>`  | Decrypt or repair broken PDFs before extraction |

## Templates

Location: `90 - Xtras/Templates/`

- `Daily Note`: auto-applied via daily-notes plugin
- `Meeting Notes`: for meeting records

## Key index files

| File                        | Purpose                                    |
| --------------------------- | ------------------------------------------ |
| `NOTES.md`                  | Full vault README with integration details |
| `00 - Index/00 - Index.md`  | Master navigation                          |
| `10 - Projects/Projects.md` | Project dashboard                          |
| `_TODO/TODOs.md`            | Live task aggregation (dataview)           |

## Subtree-specific AGENTS.md files

If a subtree has its own context (e.g., health records, finance, a specific area of life), put an `AGENTS.md` (or `CLAUDE.md`; Hermes loads both) at the root of that subtree. Hermes picks it up when working in that directory.
