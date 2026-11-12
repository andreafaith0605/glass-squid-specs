# 07 — Database

**Purpose:** Database guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Verified boundary

`glass-squid-api/AGENTS.md` names a Supabase database API. No schema, migrations, table definitions, database configuration, or SQL was found.

| Topic | Current evidence |
|---|---|
| Identity and primary keys | Unknown |
| Tables, relationships, constraints | None defined in inspected files |
| Deletes and retention | Unknown |
| Migration ownership and ordering | Unknown |
| Integrity invariants and indexes | Unknown |
| Backup and recovery | Unknown |

No database connection or live schema inspection was performed. Repository absence does not establish that a remote database is empty.

**Proposed:** before a database change, capture the actual schema, identify dependent API/client fields (04 #2), and document migration and recovery procedures. **Miss →** a seemingly local column change may break clients or lose records. No destructive command is justified by this document. Authorization must be specified alongside schema access (see 09).
