---
type: meta
status: evergreen
tags:
  - meta
created: 2026-04-24
updated: 2026-04-24
---

> **Note**: anonymized sample. Sample tasks below illustrate the
> Obsidian Tasks syntax (`#TODO`, dates, completion). See
> [README.md](../README.md) for context.

# `_TODO`

Inbox-style TODO list. The user and the agent can both add TODOs here. See [[00 - Index]] for the rest of the vault.

## Examples

- [ ] Open task with a due date #TODO 📅 2026-07-01
- [ ] Open task with a recurrence rule #TODO 🔁 every Monday
- [/] In-progress task #TODO
- [x] Completed task #TODO ✅ 2026-06-02
- [-] Cancelled task #TODO
- [ ] Plain task without tags or dates

## TODOs (dataview)

The live aggregation lives in `TODOs.md` (a dataview query across the
whole vault). The query collects every `- [ ]` line tagged `#TODO`
across daily notes, project pages, and this file.
