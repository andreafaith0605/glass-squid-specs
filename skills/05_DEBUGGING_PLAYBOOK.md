# 05 — Debugging playbook

**Purpose:** Debugging playbook guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Logs and symptoms

**Verified:** no runtime logging configuration, executable, or application error messages exist in the inspected repositories. Log locations and cause frequencies are unknown; no production debugging shortcut is justified.

During this investigation, PowerShell reported `Cannot find path` when listing `glass-squid-specs/skills` before it existed. Cause: the folder had not been created. Check the workspace root and folder existence before diagnosing missing documents as a Git problem. This is a setup observation, not a product outage (see 06).

## Read-only triage

Run from the workspace root:

```powershell
Get-Location
rg --files --hidden -g '!**/.git/**'
git -C glass-squid-api status --short
git -C glass-squid-android status --short
git -C glass-squid-web status --short
git -C glass-squid-specs status --short
git -C glass-squid-specs log --oneline
```

1. Confirm the repository and working directory; otherwise a missing file can look like a missing feature.
2. Match the failing behavior to an exact revision and message before ranking causes. **Miss →** a fix can target code the user is not running.
3. Once runtime logs exist, record their real locations and redact secrets before adding evidence.
4. Record a verified reconstruction in 06 and update the affected lockstep set in 04. No failure stories currently exist.
