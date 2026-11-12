# 03 — Code style

**Purpose:** Code style guidance for engineers changing or investigating this ecosystem.

**Confidence note:** verified against API `0a6aa99`, Android `8a1c4f5`, web `c5bf6c2`, and specs `9f671aa` on 2026-11-12, plus the workspace instructions and handoff read that day. Inferences and proposals are labeled; runtime behavior is unverified. The code wins (see 16).

## Current evidence

No application source, formatter, linter, logging library, naming convention, or error-handling pattern exists in the inspected files. Do not prescribe a language or toolchain from the repository names: an invented command would fail before development starts.

## Documentation practices

These rules come from `handoff.md`:

- Explain why a guard or constraint exists beside the relevant step. Without the failure mechanism, later editors may remove the protection.
- Separate verified facts, inferences, and suspicions. Otherwise an architectural guess can become an accidental contract.
- Use real identifiers only after finding them in code. Invented routes and config keys mislead debugging.
- Name secret variables without their values. Values copied into documentation persist in Git history.
- Preserve contributor substance and credit; retire superseded advice with a dated reason. Silent deletion loses the rationale.

## Commits

`glass-squid-specs/git-guidelines.md` requires `scope: Imperative summary`, sentence case, no final period, and a summary of at most 50 characters. Bodies explain why and wrap at 72 characters. Choose the most specific applicable product/feature scope so reviewers can identify the change. Do not add an AI agent as author of commits, tags, releases, or PRs.

The guidelines still contain `code-name` placeholders; see 15 #2 before applying product-prefix examples. This task leaves files uncommitted for review.

**Proposed:** select language tooling and document error/logging conventions when the first implementation is added; no code anti-pattern has yet been proven by an incident (see 06).
