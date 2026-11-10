# Roadmap

## Milestone 0 — Repository and product foundation
- [x] Product README and principles
- [x] Initial architecture, security, compatibility, and UI specifications
- [x] Flutter package manifest and app entry point
- [x] Shared dark theme and five-tab navigation shell
- [x] Initial Home, Projects, Workspace, Tools, and Settings screens
- [x] Core project, capability, and job domain models
- [x] Initial widget and job-state tests
- [x] Android bootstrap script and Flutter CI workflow
- [ ] Verify CI and commit a complete Android platform scaffold

## Milestone 1 — Local foundation
- [ ] Riverpod feature controllers and GoRouter route model
- [ ] Drift database and migrations
- [ ] App-private workspace manager
- [ ] SAF APK and source ZIP import
- [ ] Immutable originals, hashes, project records
- [ ] Persistent job repository and native job events
- [ ] Engine diagnostics backed by native capability checks
- [ ] Real-device smoke test on API 26 and current Android

## Milestone 2 — APK discovery and inspection
- [ ] Installed app picker: user apps, system apps, updated system apps
- [ ] Base/split APK extraction
- [ ] APK file browser
- [ ] Package metadata and manifest inspection
- [ ] DEX, resource, asset, native library inventory

## Milestone 3 — Reverse engineering
- [ ] Tool license and packaging audit
- [ ] JADX feasibility prototype for Java browsing
- [ ] Apktool resource decode/rebuild prototype
- [ ] Smali disassemble/assemble prototype
- [ ] Multidex and split-package test corpus
- [ ] Explicit unsupported-format reporting

## Milestone 4 — Editing workspace
- [ ] Mobile code editor with syntax highlighting
- [ ] File explorer and tabs
- [ ] Resource/manifest editors
- [ ] Diff viewer and checkpoints
- [ ] Search and safe file operations

## Milestone 5 — Build, sign, verify, install
- [ ] Rebuild pipeline
- [ ] zipalign integration
- [ ] Signing key generation/import and protected storage
- [ ] Signature and artifact verification
- [ ] PackageInstaller single APK flow
- [ ] PackageInstaller split APK flow
- [ ] Signing mismatch and data-loss warnings
- [ ] Export/share

## Milestone 6 — Android source projects
- [ ] Project ZIP/directory import and indexing
- [ ] Gradle/JDK/SDK compatibility report
- [ ] Constrained local build runner feasibility
- [ ] Build logs, cancellation, diagnostics

## Milestone 7 — Release hardening
- [ ] Performance and memory limits
- [ ] Accessibility and responsive layout
- [ ] Fuzz/archive safety tests
- [ ] License notices and third-party attributions
- [ ] Backup/restore
- [ ] Release signing and reproducible CI

## Definition of done
A feature is done only when implementation, tests, error handling, documentation, and supported-device evidence exist. Mock data and reference images do not satisfy functional acceptance.
