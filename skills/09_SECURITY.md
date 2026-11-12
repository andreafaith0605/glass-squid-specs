# 09 — Security

**Purpose:** Security guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Evidence and threat model

**Verified:** there is no authentication, authorization, secret loading, database policy, input handling, or debug configuration in the inspected files. No security test or live audit was performed. These are unassessed areas, not accepted security gaps.

**Inferred assets and boundaries:** application data, client/API requests, and API/database requests follow from the declared component responsibilities. Data sensitivity, tenant model, user roles, injection surfaces, and direct database access are unknown.

## Proposed change checklist

1. Identify caller identity and enforce permissions at the actual data boundary. **Miss →** a hidden client control may be mistaken for authorization.
2. Identify untrusted input and verify the chosen database/query interface handles it safely. **Miss →** input may alter a query instead of remaining data.
3. Document secret variable names and storage mechanisms without values, as required by `handoff.md`. **Miss →** repository history can retain credentials.
4. Identify debug and logging gates before deployment. **Miss →** internal data may be exposed through diagnostics.
5. Record evidence and unresolved risks alongside endpoint and schema changes (07, 08, 11).

These are proposed checks; no implementation or accepted risk decision is implied. Record accepted decisions in 01 with an owner and consequences when available.
