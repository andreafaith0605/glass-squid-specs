# 08 — API

**Purpose:** API guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Verified scope

`glass-squid-api/AGENTS.md` describes the back end as the connector between the Supabase database API and web/Android clients. There is no server entry point or route code.

| Contract surface | Status |
|---|---|
| Routes and authentication per route | Not defined |
| Request validation | No validators found |
| Response envelope and error codes | Not defined |
| Versioning and compatibility | Not defined |
| Pagination, retries, idempotency | Not defined |

## Adding the first endpoint

**Proposed procedure:**

1. Record the actual server/router and source path once selected; otherwise future maintainers cannot locate execution.
2. Define request, response, validation failures, authorization, and compatibility in specs before adding consumers. **Miss →** clients can implement mutually incompatible assumptions (04 #2).
3. Add producer and consumer paths to 04 and meaningful behavior checks to 11 so later changes expose mismatches.
4. Document the actual route and access policy here; inferred routes must not become public contracts.

No command, framework, status-code convention, or API version is established yet.
