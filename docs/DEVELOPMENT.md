# Development setup

## Prerequisites
- Flutter stable SDK (pin the selected version in CI once the scaffold is generated).
- Android SDK platform/build-tools suitable for the development host.
- JDK version required by the selected Android Gradle Plugin.
- Android device or emulator on API 26 for minimum-version testing.
- A current Android device/emulator for modern platform behavior.

## Initial setup
The repository scaffold is being created. Once pubspec.yaml, platform files, and wrapper scripts are committed:

```bash
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## Working agreement
- Keep main buildable.
- Commit in small, descriptive units: feat:, fix:, test:, docs:, chore:.
- Do not add credentials, signing keys, local.properties, SDK paths, generated secrets, or user APKs to Git.
- Every engine integration needs a license review and an Android compatibility test.
- Record failed compatibility experiments; do not hide them.

## Physical-device verification
A successful CI build does not replace package installation and engine tests on a real Android device. Capture device/API/ABI, test inputs, results, and logs with secrets redacted.
