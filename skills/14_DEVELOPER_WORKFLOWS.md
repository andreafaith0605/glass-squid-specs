# 14 — Developer workflows

**Purpose:** Developer workflows guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## 1. Orient and inspect

1. Start at the workspace root and read `AGENTS.md`, all four product instruction files, specs skills, and `git-guidelines.md`. **Miss →** product-specific instructions can be skipped (04 #1).
2. Run `rg --files --hidden -g '!**/.git/**'` and `git -C glass-squid-specs status --short` to distinguish existing files from intended structure.
3. Read 01 and 15 before choosing an implementation task. No install/build/start command exists yet; guessing one hides the missing setup decision.
4. Add what surprised you to `INBOX.md`.

## 2. Change shared behavior

1. Identify producer and consumer paths before editing; no runtime set is recorded yet (04 #2).
2. Document the compatibility decision in 01 and the lockstep set in 04. **Miss →** one client can retain the old interpretation.
3. Add relevant checks from 11 when implementation exists; no failure story currently applies (06).
4. Add what surprised you to `INBOX.md`.

## 3. Refresh skills

1. Compare repository history and diffs since the confidence revisions listed in 00. **Miss →** a still-existing path can conceal changed behavior.
2. Verify inbox entries and merge them into the home listed in 00 with author credit before removing them. For conflicts, keep both positions and evidence and ask the user to decide.
3. Preserve direct edits; move outdated knowledge into a dated Retired section identifying its replacement and reason. **Miss →** discarded rationale can be reintroduced.
4. Recheck the entire stale document, update its confidence note, and log the refresh in 00. Append numbers; never renumber (04 #1).
5. Propose proven practices for 16 and let the user decide before promotion.
6. Add what surprised you to `INBOX.md`.

## 4. Prepare a review

1. Inspect `git -C glass-squid-specs status --short` and `git -C glass-squid-specs diff --check`. Untracked files need direct inspection because ordinary diff omits their content.
2. Review source claims and links against 00's evidence revisions. **Miss →** formatting checks alone can approve inaccurate guidance.
3. Present the files for review before committing, as requested for this task; follow commit conventions in 03 if later authorized.
4. Add what surprised you to `INBOX.md`.
