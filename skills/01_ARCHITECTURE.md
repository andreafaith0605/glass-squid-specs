# 01 — Architecture

**Purpose:** Architecture guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Model and ownership

**Verified:** the ecosystem has a back-end API connecting a Supabase database API to web and Android clients. The web repository describes a front end containing regulatory compliance. The specs repository holds ecosystem specifications. These are declared responsibilities in the four `AGENTS.md` files, not implemented behavior.

| Component | Evidence | Declared ownership |
|---|---|---|
| API | `glass-squid-api/AGENTS.md` | Database-to-client connection |
| Android | `glass-squid-android/AGENTS.md` | Android application |
| Web | `glass-squid-web/AGENTS.md` | Web front end and regulatory compliance |
| Specs | `glass-squid-specs/AGENTS.md` | Ecosystem specifications |

**Inferred flow:** Android/web → API → Supabase database API → API → client. No routing or client code verifies this; direct client database access and authorization boundaries remain unknown. Do not implement access policy from this sketch: it could expose data (see [09](09_SECURITY.md)).

## Decisions and inherited tradeoffs

No architecture decision records or rejected frameworks exist in the inspected history. Repository separation is verified; its rationale is undocumented. No runtime tradeoff can be reconstructed.

Use the handoff's format when a decision is made:

### Decision: <title> (<date>, <author>)
**Status:** proposed | accepted | superseded by <link>
**Context:** <problem and evidence>
**Choice:** <decision>
**Alternatives:** <options considered>
**Consequences:** <cost and what breaks>

## Ranked documentation debt

1. Define trust boundaries and API ownership before implementing access (see 09).
2. Define shared contracts before clients diverge (see 04 #2).
3. Record build and release evidence before shipping (see 10).

These are proposed priorities, not approved architecture decisions.
