---
type: meta
status: evergreen
tags:
  - telos
created: 2026-04-24
updated: 2026-05-12
---

> **Note**: anonymized sample. The metric schema (leading/lagging
> split, status-gauge dataviewjs structure, block-link anchors back to
> [[04 - Goals]]) is kept verbatim because it's reusable. Specific
> targets are placeholders. See [README.md](../README.md) for context.

# Metrics

Metrics that say whether the [[04 - Goals]] are on track. Each metric specifies its **source** (where the data lives), **cadence** (review rhythm), and **target**.

Each metric is also flagged as:

- **Leading**: measures behavior I control today (presence days, workout days, words written).
- **Lagging**: measures outcomes that move slowly (net worth, business stage).

A healthy goal has at least one leading metric (so I can act this week) and ideally one lagging metric (so I know the actions are working).

---

## Status gauges

Aggregate snapshot per metric. Half-doughnut speedometer = current vs target. Color: **green** ≥ target / in band · **yellow** ≥ 75% of target / within 10pp of band · **red** below. Stage gauges show ladder position; the `w1Stage` / `l1Stage` constants in the code need manual edits when you advance.

```dataviewjs
// Status-gauge block. Reads goal-tracker fields off every page in
// "30 - Daily" and renders rolling 7/30/90/365-day percentages. Real
// implementation is ~150 lines of D3+dataviewjs. The structure:
//
//   const today = dv.date("today");
//   const pages = [];
//   for (const p of dv.pages('"30 - Daily"')) {
//     if (p.file.day) pages.push(p);
//   }
//   const ge = (p, start) => p.file.day.toISODate() >= start.toISODate();
//   const workout = (p) => p.h2_workout === "cardio"
//                       || p.h2_workout === "strength"
//                       || p.h2_workout === "both";
//   const has = (p, name) => p[name] === true || p[name] === "true";
//
//   // ... aggregate over rolling windows, render gauges per metric ...
```

---

## Metric specs

### M-F1a: leading metric on a daily boolean ^M-F1a

- **Goal:** [[04 - Goals#^F1a|F1a]].
- **Leading:** yes.
- **Source:** `f1a_present` boolean in each [[30 - Daily|daily note]].
- **Cadence:** weekly review (count days/week).
- **Target:** ≥ `<N>` days per rolling 7.

### M-H2: leading metric on a daily categorical ^M-H2

- **Goal:** [[04 - Goals#^H2|H2]].
- **Leading:** yes.
- **Source:** `h2_workout` field (categorical value, or empty) in each daily note.
- **Cadence:** weekly.
- **Target:** ≥ `<N>` qualifying days per rolling 7, with `<balance constraint across categories>`.

### M-L1: leading + lagging metric on a multi-stage goal ^M-L1

- **Goal:** [[04 - Goals#^L1|L1]].
- **Leading:** yes.
- **Source:** `l1_corpus` boolean in each daily note + ladder-stage tracker.
- **Cadence:** monthly (counts) + quarterly (stage advancement).
- **Target:** ≥ `<N>` qualifying days per rolling 30; advance one stage per `<period>`.

### M-W2: lagging metric on a long-horizon goal ^M-W2

- **Goal:** [[04 - Goals#^W2|W2]].
- **Lagging:** yes.
- **Source:** quarterly snapshot (manual entry).
- **Cadence:** quarterly.
- **Target:** trajectory consistent with `<your target horizon>` under `<assumed model>`.
