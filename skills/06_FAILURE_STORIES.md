# 06 — Failure stories

**Purpose:** Failure stories guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Verified history

No product incidents, fixes, reverts, or outage narratives were found. The inspected histories consist of initial instruction additions and one Git-guidelines addition:

| Repository | Evidence commit |
|---|---|
| API | `0a6aa99` — Add agent instructions |
| Android | `8a1c4f5` — Add agent instructions |
| Web | `c5bf6c2` — Add agent instructions |
| Specs | `1574f36` — Add agent instructions; `9f671aa` — Add git-guidelines |

The missing skills directory observed during generation is a setup gap (see 05), not evidence of a runtime incident. No historical workaround or rejected framework can be reconstructed.

## Future incident format

**Proposed:** append incidents with stable numbers and record what happened, why, how it was found, the fix, lesson, confidence, and evidence revision. Missing fields make a story harder to distinguish from a guess. Mark uncertain reconstructions explicitly.

Link each incident from the relevant change rule in 04, symptom in 05, and any proposed principle in 16. **Miss →** engineers may encounter the guard without finding the failure it prevents. There are no incident numbers to reference yet.
