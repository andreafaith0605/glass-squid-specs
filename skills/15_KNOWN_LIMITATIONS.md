# 15 — Known limitations

**Purpose:** Known limitations guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Ranked surprises

1. **No implementation or setup exists in the inspected repositories.** No manifests, entry points, routes, migrations, tests, CI, or runtime configuration were found. Repository names do not establish a usable stack. See 07–13.
2. **Git policy remains partly a template.** `git-guidelines.md` contains `code-name`, `CN`, feature placeholders, empty tag tables, and dated examples about another current week. These are not verified Glass Squid release identifiers or current dates. Android's directory name also differs from the historical `glass-squid-app` commit scope. Resolve identity before generating tags (04 #3).
3. **Declared architecture is unimplemented.** The API/Supabase/client flow is inferred from instructions; authentication, regulatory requirements, data sensitivity, deployment order, and schema are unknown.
4. **History has no product failure evidence.** No incidents can justify runtime engineering principles, anti-pattern bans, or frequency-ranked diagnoses.
5. **Local evidence has limits.** No remote database, hosted deployment, package registry, or external issue tracker was inspected. Missing local files do not establish absence elsewhere.

No deferred feature, accepted security weakness, runtime bug, or architectural performance constraint is verified.

## Proposed redesign/investigation priorities

1. Resolve specification identity and release placeholders before release automation.
2. Establish architecture, contracts, and trust boundaries before implementation.
3. Establish reproducible setup and tests before deployment.

These are investigation priorities, not evidence that an existing system needs redesign. Record decisions in 01 rather than silently turning proposals into requirements.
