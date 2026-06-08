---
ingested: 2026-05-18
updated: 2026-05-18
---

> **Note**: anonymized sample. Kept verbatim because the dataviewjs
> blocks are generic (they enumerate `_INBOX/<source>/` subfolders).
> See [README.md](../README.md) for context.

# `_INBOX`

This folder contains categorized inputs to this knowledge base. Categories are not topics, just the provenance. Once processed, content doesn't leave this folder; rather, it's marked as processed with a property.

See [[00 - Index]] for the rest of the vault.

## Pending items

```dataviewjs
const folders = [
  "_INBOX/Goodreads",
  "_INBOX/Omnivore",
  "_INBOX/Readwise/Articles",
  "_INBOX/Readwise/Books",
  "_INBOX/Readwise/Full Document Contents",
  "_INBOX/Readwise/Tweets",
  "_INBOX/Telegram",
  "_INBOX/Webclips",
  "_INBOX/Zotero",
];

let rows = [];

for (const folder of folders) {
  const pages = dv.pages(`"${folder}"`);
  for (const p of pages) {
    if (p.ingested) continue;

    const parts = p.file.folder.replace("_INBOX/", "").split("/");
    const source = parts[0];

    const date = p.published ?? p.date ?? p.dateRead ?? p.created ?? p.file.cday;

    const tags = (p.tags ?? p.file.tags ?? [])
      .filter(t => t && t !== "source" && t !== "seed");

    rows.push([
      p.file.link,
      source,
      date,
      tags.join(", "),
    ]);
  }
}

rows.sort((a, b) => {
  const da = a[2]?.toString() ?? "";
  const db = b[2]?.toString() ?? "";
  return db.localeCompare(da);
});

dv.table(["Item", "Source", "Date", "Tags"], rows);
```

## Summary by source

```dataviewjs
const folders = [
  ["Goodreads",     "_INBOX/Goodreads"],
  ["Omnivore",      "_INBOX/Omnivore"],
  ["Readwise/Articles", "_INBOX/Readwise/Articles"],
  ["Readwise/Books",    "_INBOX/Readwise/Books"],
  ["Readwise/Full Docs", "_INBOX/Readwise/Full Document Contents"],
  ["Readwise/Tweets",   "_INBOX/Readwise/Tweets"],
  ["Telegram",      "_INBOX/Telegram"],
  ["Webclips",      "_INBOX/Webclips"],
  ["Zotero",        "_INBOX/Zotero"],
];

let rows = [];
for (const [label, path] of folders) {
  const all = dv.pages(`"${path}"`);
  const total = all.length;
  const filed = all.filter(p => p.ingested).length;
  const pending = total - filed;
  if (total > 0) {
    rows.push([label, total, filed, pending]);
  }
}

dv.table(["Source", "Total", "Filed", "Pending"], rows);
```
