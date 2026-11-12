# 04 — Change rules

**Purpose:** Change rules guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## 1. Instruction and document set

**Verified paths:**

1. `AGENTS.md`
2. `glass-squid-api/AGENTS.md`
3. `glass-squid-android/AGENTS.md`
4. `glass-squid-web/AGENTS.md`
5. `glass-squid-specs/AGENTS.md`
6. `glass-squid-specs/skills/*.md`
7. `glass-squid-specs/git-guidelines.md`

The root instruction requires reading items 2–7. When moving an instruction or adding a skills document, check the root list and [00_INDEX](00_INDEX.md). **Miss →** newcomers can follow stale paths or omit required guidance. Retest by listing files and resolving local Markdown links.

## 2. Future runtime contracts

**Verified absence:** no mirrored constants, enums, registries, columns, error codes, types, or runtime contracts were found. The declared API/client relationship suggests future coordination, but no lockstep runtime set is verified.

**Proposed:** for the first shared contract, record numbered producer/consumer paths, compatibility behavior, and tests here before changing it. **Miss →** independently updated clients may interpret the same payload differently. Retest affected client/API flows once those exist; see 11. This is a predicted failure, not an incident (see 06).

## 3. Release metadata

`glass-squid-specs/git-guidelines.md` couples identity placeholders, product prefixes, version examples, next-release entries, and tag tables. Resolve these together when the project identity is approved. **Miss →** a syntactically valid tag can identify the wrong product. Compare all identity references and existing tags before any tagging (see 10). No tags are created by this task.
