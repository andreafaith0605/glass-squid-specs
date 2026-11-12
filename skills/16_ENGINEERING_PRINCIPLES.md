# 16 — Engineering principles

**Purpose:** Engineering principles guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Status

No incident-backed runtime principle is proven yet (see 06). `handoff.md` requires user approval for promotion of proven practices here. The items below record existing authoring rules, not newly promoted runtime principles.

## 1. “A claim needs a confidence label.”

**Reason:** an inferred data flow can otherwise become an accidental implementation requirement.
**Evidence:** `handoff.md`, Standards; declared responsibilities versus missing code in 01.
**Source story:** no product incident; initial repository investigation on 2026-11-12.
**Status:** verified documentation rule.

## 2. “Keep the reason when retiring the rule.”

**Reason:** removing the explanation makes an obsolete workaround easy to recreate.
**Evidence:** `handoff.md`, Keeping it fresh, requires dated supersession and a Retired section.
**Source story:** no incident available; preservation is an explicit handoff requirement.
**Status:** verified documentation rule.

## 3. “Test the artifact that will ship.”

**Reason:** approval of a different build does not establish the deployed build's behavior.
**Evidence:** `git-guidelines.md`, Promotion rules and Release Testing and Approval.
**Source story:** no reconstructed outage; existing release policy (10).
**Status:** verified workflow policy, not a newly promoted runtime practice.

trust the code over any document, including this one
