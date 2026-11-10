# ADR 0001: Local-first product with no account

- Status: Accepted
- Date: 2026-11-10

## Context
DroidLab's core use case is local Android application engineering. Requiring sign-in or a backend would add friction, undermine offline use, and introduce infrastructure that is not needed for core workflows.

## Decision
No account, registration, Firebase, Google identity, or mandatory backend is part of the core product. Project data, jobs, edits, signing operations, and package installation run locally. Optional network features, if ever proposed, must be nonessential, opt-in, and separately reviewed.

## Consequences
- Local persistence and backup/export are first-class features.
- App updates may be delivered through normal distribution channels without in-app user accounts.
- No cloud build fallback is silently introduced.
- Dependency acquisition and optional update checks need clear network disclosure.
