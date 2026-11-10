# ADR 0003: Capability reporting must be evidence-based

- Status: Accepted
- Date: 2026-11-10

## Context
A visually complete tool dashboard can imply capabilities that are not actually installed or compatible on a given Android device.

## Decision
Every engine reports installed/version/ABI/compatibility/readiness details from native checks. The UI must distinguish ready, missing, incompatible, experimental, and unsupported. No hardcoded all-ready status.

## Consequences
- Capability diagnostics are part of the foundation milestone.
- Engine integration acceptance requires device evidence.
- Failed or partial engine operations remain visible in job history.
