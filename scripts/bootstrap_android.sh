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
  preserve_dir="$(mktemp -d)"
  template_dir="$(mktemp -d)"
  trap 'rm -rf "$preserve_dir" "$template_dir"' EXIT

  if [[ -d android/app/src/main/kotlin/com/droidlab/app ]]; then
    cp -R android/app/src/main/kotlin/com/droidlab/app "$preserve_dir/kotlin"
  fi
  if [[ -f android/app/src/main/AndroidManifest.xml ]]; then
    cp android/app/src/main/AndroidManifest.xml "$preserve_dir/AndroidManifest.xml"
  fi

  flutter create --platforms=android --org=com.droidlab --project-name=app "$template_dir"
  rm -rf android
  cp -R "$template_dir/android" ./android

  if [[ -d "$preserve_dir/kotlin" ]]; then
    rm -rf android/app/src/main/kotlin/com/droidlab/app
    mkdir -p android/app/src/main/kotlin/com/droidlab
    cp -R "$preserve_dir/kotlin" android/app/src/main/kotlin/com/droidlab/app
  fi
  if [[ -f "$preserve_dir/AndroidManifest.xml" ]]; then
    cp "$preserve_dir/AndroidManifest.xml" android/app/src/main/AndroidManifest.xml
  fi
  if [[ -f android/app/build.gradle.kts ]]; then
    sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 26/' android/app/build.gradle.kts
  elif [[ -f android/app/build.gradle ]]; then
    sed -i 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 26/' android/app/build.gradle
  fi
else
  echo "Android Gradle project already exists; leaving generated files unchanged."
fi

flutter pub get
dart run pigeon --input pigeons/droidlab_api.dart
dart format lib pigeons
echo "Android platform and typed bridge bootstrap complete. Review the generated application ID and Gradle configuration before release."
