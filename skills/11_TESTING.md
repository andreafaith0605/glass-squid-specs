# 11 — Testing

**Purpose:** Testing guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Honest coverage

No tests, test runner, CI configuration, executable code, or coverage report was found. Runtime coverage is unknown; it is not measured as zero. No application tests can currently be run.

## Verified confidence gates

The Git guidelines assign unit testing to developers on `main`, system testing to QA on `beta`, independent integration testing of published bundles on `release`, and production approval to a designated approver (see 10).

## Proposed validation plan

| Change | Evidence to obtain | What omission can hide |
|---|---|---|
| Shared API contract | Producer and both client behavior checks | Serialization/version mismatch |
| Database shape | Migration and integrity checks | Lost records or broken consumers |
| Access policy | Allowed and denied requests | Unauthorized access |
| Release artifact | Test the published artifact identity | Approval of a different build |
| Skills documentation | Resolve paths, links, commands, and source claims | Confident but unusable guidance |

Mocking policy, device/browser matrix, load expectations, offline behavior, and recovery drills are undecided. Select them from actual requirements rather than assuming supported platforms.

For this document generation, validation is limited to source inventories, history inspection, file completeness, local links, and diff checks. It establishes documentation consistency, not system correctness.
