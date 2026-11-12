# 02 — Project structure

**Purpose:** Project structure guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Verified tree

Paths throughout this folder are workspace-relative unless explicitly described otherwise.

```text
glass-squid-ecosystem/
  AGENTS.md                    # Required instruction entry point
  handoff.md                   # Skills authoring and refresh procedure
  glass-squid-api/AGENTS.md     # Back-end responsibility
  glass-squid-android/AGENTS.md # Android responsibility
  glass-squid-web/AGENTS.md     # Web responsibility
  glass-squid-specs/
    AGENTS.md                  # Specification responsibility
    git-guidelines.md          # Commit and release rules
    skills/                    # This generated knowledge set
```

Each product directory is a separate Git repository. Before this generation, the tracked inventories contained only the files above outside `skills/`.

## Placement and naming

**Proposed:** place future implementation in its owning product repository and shared specifications in specs. Mixing implementation into specs would obscure which repository builds a product. No source-directory layout or framework naming scheme has been established.

**Verified handoff rule:** use `NN_TOPIC.md`, append new numbers, and never renumber existing knowledge. Renumbering breaks references such as 04 #2. Android's directory is `glass-squid-android`; existing commit history uses `glass-squid-app`. See 15 for the naming ambiguity.
