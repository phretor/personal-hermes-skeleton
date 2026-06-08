---
type: project
status: developing
tags:
created: 2026-04-24
updated: 2026-05-15
---

> **Note**: anonymized sample from a real vault. The lifecycle rules and
> conventions match what I actually use; specific projects have been
> replaced with placeholders. See [README.md](../README.md) for context.

# Projects

Active and past projects. Each project has its own subfolder with a main note and supporting materials.

A project earns a slot here when all three hold:

1. It serves at least one [[04 - Goals|goal]] (or, rarely, a [[15 - Priorities and Core Values|value]] without a goal).
2. It has a defined outcome: a "done" condition, even if soft.
3. It takes more than ~2 weeks of intermittent effort, or spans more than 5–10 actionable steps.

Anything smaller is a task or note, not a project.

Live status lives in `10 - Projects.base` (a Bases dashboard). Telos alignment review lives in [[80 - Telos/07 - Projects|Telos Projects]].

## Lifecycle

- **Add**: create `10 - Projects/<name>/<name>.md` with `type: project`, `status: developing`, `tags: [project]`.
- **Retire**: move to `ZZ - Archive/` within this folder, or set `status: completed`.
- **Monthly review**: confirm each active project still serves a current goal. Projects without a goal are leaks.
- **Quarterly review**: purge abandoned projects from the active surface.
