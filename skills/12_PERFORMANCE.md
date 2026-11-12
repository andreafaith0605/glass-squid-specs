# 12 — Performance

**Purpose:** Performance guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Current evidence

No implementation, telemetry, benchmark, limits, query plans, or workload data exists in the inspected repositories. There are no verified hot paths, deliberate inefficiencies, expensive operations, or profiling commands to preserve.

**Proposed:** when a runnable flow exists, record the exact revision, representative workload, latency/throughput measurement, and resource cost before optimizing. **Miss →** an apparent improvement may measure a different workload or move cost into another component.

Potential client/API/database boundaries in 01 are investigation targets, not proven bottlenecks. Do not add caching, indexes, batching, or provider limit values without evidence; those choices can introduce stale data, write overhead, or incorrect constraints. Put verified database findings in 07 and dependency-specific limits in 13.
