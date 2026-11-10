# ADR 0002: Flutter UI and Kotlin Android engine

- Status: Accepted
- Date: 2026-11-10

## Context
Flutter provides a productive, consistent UI layer. Android package discovery, SAF, PackageInstaller, secure storage, and process/runtime details are platform-specific.

## Decision
Use Flutter for presentation and app orchestration, Kotlin for Android-native operations, and Pigeon-generated typed APIs for the boundary. Do not put critical APK/package security logic in Dart or rely on loosely typed string method channels.

## Consequences
- Pigeon schemas are versioned and generated code is committed or reproducibly generated.
- Kotlin operations return structured errors and job identifiers.
- Platform-specific functionality is tested on API 26 and modern Android.
