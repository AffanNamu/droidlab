# Architecture

## Goals
DroidLab is an offline-first Flutter application with a Kotlin Android engine. The UI must not implement APK parsing, signing, installation, or filesystem trust decisions itself.

## Runtime layers
1. Presentation (Flutter): screens, responsive layouts, editor interaction, accessibility.
2. Application: Riverpod controllers, workflows, validation orchestration, job lifecycle.
3. Domain: project, artifact, engine capability, build, signing, verification, and installation models.
4. Data: Drift repositories, workspace file operations, import metadata, checkpoints.
5. Platform bridge: Pigeon-generated typed messages.
6. Native engine (Kotlin): Android package discovery, SAF import/export, archive inspection, tool execution, package installation, capability checks, secure storage.

## Suggested source layout
- lib/app, lib/core, lib/domain, lib/data, lib/application, lib/features
- pigeons/droidlab_api.dart
- android/app/src/main/kotlin/com/droidlab/app/{bridge,engine,installation,storage,security}
- docs/ADR

## Key boundaries
- Flutter sends typed requests and renders progress; Kotlin owns Android-specific work.
- All long-running operations use persistent job IDs and structured events.
- Original imports are immutable. Work happens in derived project directories.
- Every generated artifact records its source project, input hash, toolchain versions, build configuration, signing certificate fingerprint, and verification result.
- The package installer is invoked only after successful output validation and explicit user action.
- No backend is required for core workflows.

## Job state machine
QUEUED -> VALIDATING -> RUNNING -> SUCCEEDED | FAILED | CANCELLED

Persist transitions. Cancellation is cooperative and only reported after the engine confirms it. Process death must leave recoverable job metadata rather than a false success.

## Import pipeline
1. Obtain content through Android Storage Access Framework or an explicit installed-package selection.
2. Copy bytes into a generated app-private workspace path.
3. Enforce size and archive limits; validate format and archive paths.
4. Compute SHA-256 and record provenance.
5. Keep the original immutable; create a working copy for edits.

## Build pipeline
validate -> decode/assemble -> compile resources -> package -> zipalign -> sign -> verify -> stage for install/export

Do not combine signing and verification into one opaque operation. Do not expose Install for an unverified artifact.

## Installation
Use Android PackageInstaller sessions from Kotlin. Handle user-action-required status, pending approval, success, failure codes, and cancellation. Never silently install or bypass platform confirmation.

## Local persistence
Drift/SQLite stores metadata, jobs, projects, file indexes, checkpoints, engine capability snapshots, and build records. Project content lives in app-private directories. Database records must not store private key passwords or raw signing secrets.

## Source-project builds
An imported Gradle project is not assumed buildable. Inspect wrapper, plugin, JDK, SDK, build-tools, ABI, storage, and memory requirements before execution. Build only in a constrained workspace with a controlled process runner. Never execute project build scripts during import or indexing.
