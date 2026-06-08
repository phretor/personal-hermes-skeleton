---
type: meta
status: evergreen
tags:
  - telos
created: 2026-04-24
updated: 2026-05-12
---

> **Note**: anonymized sample. Mostly navigation prose; kept nearly
> verbatim. See [README.md](../README.md) for context.

# Journal

The daily journal lives in **[[30 - Daily]]**. Daily notes sit at `30 - Daily/YYYY/YYYY-MM/YYYY-MM-DD.md`, auto-created from the [[90 - Xtras/Templates/Daily Note|Daily Note template]] via the Periodic Notes plugin.

Review notes (weekly / monthly / quarterly / yearly) also live under `30 - Daily/`. See `[[Review schedule]]` for the recurring cadence and templates.

## What's in the daily note vs. what's elsewhere

- **In the daily note:** the [[04 - Goals|goal-tracker properties]] (`f1a_present`, `f1b_with`, `h2_workout`, `w1_business`, `l1_corpus`), free-form notes about the day, scratch thoughts, daily todos tagged `#TODO`.
- **Not in the daily note:** project-specific work (goes in the project's directory under `10 - Projects/`), reference notes (go in their proper PARA-folder), ideas that need their own page (go in [[40 - Concepts]]).

## How this file is used

This Telos slot exists for navigation. The actual journal is the daily notes.

- **Aggregation**: daily-note properties roll up into [[11 - Metrics|Metrics]] (rollups, charts, gauges) and `11 - Metrics.base`.
- **Search**: full-text search across daily notes via Omnisearch.
- **Calendar view**: Obsidian's Calendar plugin sidebar gives a month grid linking to daily notes.
