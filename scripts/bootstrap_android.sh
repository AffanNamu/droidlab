#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter stable and add it to PATH." >&2
  exit 1
fi

if [[ ! -f pubspec.yaml ]]; then
  echo "Run this script from the DroidLab repository root." >&2
  exit 1
fi

if [[ ! -f android/app/build.gradle.kts && ! -f android/app/build.gradle ]]; then
  flutter create --platforms=android --org=com.droidlab --project-name=droidlab .
else
  echo "Android Gradle project already exists; leaving generated files unchanged."
fi

flutter pub get
echo "Android platform bootstrap complete. Review the generated application ID and Android Gradle Plugin before release."
