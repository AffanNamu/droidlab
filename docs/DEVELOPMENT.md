# Development setup

## Prerequisites
- Flutter stable SDK.
- Android SDK platform/build-tools suitable for the development host.
- JDK version required by the selected Android Gradle Plugin.
- Android device or emulator on API 26 for minimum-version testing.
- A current Android device/emulator for modern platform behavior.

## Initial setup
Clone the repository and run the bootstrap script from the repository root:

```bash
flutter --version
flutter doctor -v
bash scripts/bootstrap_android.sh
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

The bootstrap script generates the standard Android platform project if it is missing. The GitHub Actions workflow performs the same generation in its CI workspace. The intended application ID is `com.droidlab.app`. Confirm the generated Gradle namespace/applicationId match it. Generated platform files are committed by the CI bootstrap job after a successful build.

## Working agreement
- Keep main buildable.
- Commit in small, descriptive units: feat:, fix:, test:, docs:, chore:.
- Do not add credentials, signing keys, local.properties, SDK paths, generated secrets, or user APKs to Git.
- Every engine integration needs a license review and an Android compatibility test.
- Record failed compatibility experiments; do not hide them.

## Physical-device verification
A successful CI build does not replace package installation and engine tests on a real Android device. Capture device/API/ABI, test inputs, results, and logs with secrets redacted.
