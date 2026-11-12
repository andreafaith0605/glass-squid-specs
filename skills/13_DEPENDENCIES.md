# 13 — Dependencies

**Purpose:** Dependencies guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Inventory

| Item | Evidence | Reason and limits |
|---|---|---|
| Supabase database API | `glass-squid-api/AGENTS.md` | Declared database connection target; product choice rationale and version unknown |
| Git | Separate repository metadata and Git guidelines | Version history and controlled promotion; not an application dependency |
| Runtime packages and toolchains | No manifests or lockfiles found | Not selected in the inspected files |

Android and web describe products, not verified SDK/framework dependencies. No rejected library, pinned version, or upgrade incident was found.

## Proposed dependency policy

When adopting a dependency, record its manifest/lockfile paths, purpose, version source, compatibility constraints, upgrade verification, and any actual rejection rationale. **Miss →** upgrades may remove behavior on which callers rely without a visible contract.

Do not install a guessed framework to make setup instructions executable. Select the stack as a decision in 01, then add its real setup and verification commands to 14 and 11. No vendor documentation or current package-version claims are made here.
