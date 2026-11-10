# DroidLab

**Your Android engineering laboratory.** Import. Inspect. Understand. Modify. Build. Sign. Verify. Install.

DroidLab is an offline-first, Android-first application engineering studio. It is designed to let people inspect and modify Android applications they own or are authorized to modify, work with Android source projects, and rebuild and install compatible outputs directly on their device.

## Product principles

- **Local-first:** core workflows run on the Android device. No account, sign-in, Firebase, Google identity, or mandatory backend.
- **User-controlled:** Android's package installer remains the final authority for installation and user approval.
- **Honest compatibility:** every engine capability is detected and reported; unsupported operations are never presented as successful.
- **Safe by default:** imported artifacts are untrusted; originals are immutable; edits are checkpointed; signing secrets are protected.
- **Transparent output:** build, signing, verification, and installation are separate observable stages.
- **Accessible mobile UX:** designed for phone-sized screens, touch, and one-handed navigation.

## Target platform

- Minimum Android version: **Android 8.0 (API 26)**.
- UI: Flutter.
- Native Android processing and package installation: Kotlin.
- Flutter/native contract: Pigeon-generated typed APIs.
- State management: Riverpod.
- Navigation: GoRouter.
- Local metadata: SQLite/Drift.
- Storage: app-private workspace plus Android Storage Access Framework for import/export.

## Main workflows

### APK workflow

1. Import an installed application, a local APK, or a supported split-package set.
2. Inspect package metadata, manifest, permissions, SDK levels, DEX, resources, assets, and native libraries.
3. Reconstruct Java for browsing where supported; edit Smali/DEX and decoded resources for bytecode-level changes.
4. Validate changes and rebuild with compatible tools.
5. Align, sign with a user-controlled key, and verify the output.
6. Install through Android PackageInstaller with system/user confirmation.
7. Export or share the verified artifact.

Decompiled Java is reconstructed output, not the original source. Obfuscation, native code, and framework-specific formats limit reconstruction. Flutter APKs do not yield the original Dart source through ordinary APK decompilation.

### Android source-project workflow

1. Import a project directory or ZIP.
2. Index source, resources, manifests, Gradle files, and dependencies.
3. Edit original Java/Kotlin/XML and project files.
4. Detect JDK, Gradle, Android SDK, build-tools, memory, and device compatibility.
5. Build locally only when the on-device toolchain is verified as compatible.

On-device Gradle builds are a major feasibility risk. The app must not promise arbitrary Android projects will build on every device. Local editing remains useful even when a project cannot be built on-device.

## Signing and installation rules

- An APK signed with a different certificate generally cannot update an installed app signed by the original certificate.
- If the original signing key is unavailable, the user may need to uninstall the original before installing the modified package; this can destroy app data. DroidLab must explain this and require explicit confirmation.
- System, privileged, manufacturer-signed, and protected packages may not be replaceable on a normal device.
- DroidLab does not bypass Android package verification, device security, licensing, or access controls.

## Privacy and connectivity

DroidLab has no account system and no mandatory network service. Core project data stays in the app's private workspace. Network access, if later added for optional update checks or dependency downloads, must be opt-in, documented, and unnecessary for local APK inspection/editing/install workflows.

## Getting started

Install Flutter stable and an Android SDK, clone the repository, then run:

```bash
bash scripts/bootstrap_android.sh
flutter analyze
flutter test
flutter build apk --debug
```

The bootstrap script generates the standard Android platform project. Review the generated Android application ID and Gradle configuration before a release build.

## Repository status

The initial Flutter home screen, product/engineering documentation, and CI workflow are committed. The current home screen is a foundation scaffold: import and tool actions are not functional yet. See [Project status](docs/PROJECT_STATUS.md) for the exact implementation state.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Security](docs/SECURITY.md)
- [Android permissions and distribution](docs/ANDROID_PERMISSIONS.md)
- [Engine compatibility](docs/ENGINE_COMPATIBILITY.md)
- [Roadmap](docs/ROADMAP.md)
- [UI reference specification](docs/UI_REFERENCE.md)
- [Development setup](docs/DEVELOPMENT.md)
- [Project status](docs/PROJECT_STATUS.md)
- [Decision records](docs/ADR/)

## Legal and responsible use

Use DroidLab only with applications and source projects you own or are authorized to analyze and modify. Users are responsible for respecting applicable laws, licenses, intellectual property, privacy, and platform terms.
