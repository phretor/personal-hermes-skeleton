# Personal Hermes skills

Personal skills in Hermes SKILL.md format. Travels with the vault.

Hermes auto-loads them via `skills.external_dirs` in
`.devcontainer/persist-home/.hermes/config.yaml`:

```yaml
skills:
  external_dirs:
    - /data/.agent/skills          # this directory
    - /data/.agent/custom-skills   # legacy Claude-format skills
```

