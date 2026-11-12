# 10 — Deployment

**Purpose:** Deployment guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Current capability

No deployable artifacts, build commands, CI jobs, hosting configuration, release website, or component deployment order exist in the inspected files. The dependency sketch in 01 does not prove a safe release order.

## Verified release policy

Source: `glass-squid-specs/git-guidelines.md`.

1. Develop and unit-test on `main`; promote reviewed work to `beta` for QA/system testing. **Miss →** unaccepted development can reach independent testers.
2. Promote accepted work to `release`, bundle it, and publish to the designated release website. Independent integration testers test the published bundle. **Miss →** testing can certify a different artifact.
3. After planned development is complete, iterate `a`, `b`, then `rc`; failed stages use suffixes such as `a2` or `rc2`. Candidate suffix changes do not increment the build number.
4. Obtain separate production approval and deploy the exact approved candidate. Presence on `release` alone is not approval.
5. Create candidate tags only from `release`; never move or reuse tags. A tag is not a GitHub Release.

Weekly tags skip weeks without commits, use chronological build numbers, and cannot cover the current week before Friday 17:00 local time. Identity and prefix examples are still placeholders (15 #2); do not invent Glass Squid prefixes.

## Before an executable release

**Proposed:** record build prerequisites, artifact identity, component compatibility/order, configuration names, verification, and recovery procedures here. Without them, the policy cannot be executed reproducibly.

For specs, the approved baseline replaces deployment and stakeholder/implementation review replaces runtime testing. Post-production defects use a separate maintenance lifecycle: increment minor, reset build to `001`, and preserve the production baseline. This task performs no promotion, tagging, publication, or deployment.
