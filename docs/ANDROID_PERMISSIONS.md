# Android permissions and distribution

DroidLab does not require Google Sign-In, Firebase, a Google account, or a backend. Android may still require the user to approve specific OS-level capabilities.

## Package inventory visibility

The Installed Apps and System Apps picker must show a prominent disclosure and obtain consent before it queries the installed-app inventory. Consent is stored locally on the device. Engine diagnostics must check permission declarations without enumerating installed packages before consent.

Android 11 / API 30 and later filters which installed packages an app can see. DroidLab's full Installed Apps and System Apps picker needs broad package visibility to enumerate the device inventory, which may require QUERY_ALL_PACKAGES.

This is a sensitive permission. Google Play restricts it to eligible core use cases and may require a Play Console declaration and review. The Play policy lists limited eligible categories; a developer tool must not assume approval. Before a Play release, reassess whether the full inventory picker qualifies and whether a narrower package visibility declaration can satisfy the user experience.

Fallback options:
- Show only packages visible through targeted manifest queries.
- Let users import APK files through the Android Storage Access Framework.
- Keep full inventory discovery in a separately distributed build if Play policy does not permit broad visibility. Do not disguise or work around the policy.

## User-initiated APK installation

Android 8.0 and later requires the app to handle the user-enabled install-unknown-apps setting when requesting installation of APKs from the app. DroidLab must:
- Explain why the permission is needed.
- Open the Android settings page only after the user chooses Install.
- Check permission again after returning from settings.
- Use PackageInstaller sessions.
- Require direct user action and honor Android confirmation UI.
- Never silently install, self-update, or install in the background.

REQUEST_INSTALL_PACKAGES is also restricted by Google Play policy. Its use must be directly related to the app's core purpose and satisfy the current policy and declaration requirements. Reassess this before publishing through Google Play.

## Local-only storage

The Android manifest sets `android:allowBackup="false"`. Project files, imported APKs, checkpoints, and signing-key material are intended to remain in app-private local storage and are not automatically included in Android cloud backup. Signing-key material must use `noBackupFilesDir` plus Android Keystore encryption.

## Storage

Use Android Storage Access Framework for user-selected APKs, ZIPs, and export destinations. Do not request broad external storage access for normal import/export.

## References
- Android package visibility: https://developer.android.com/training/package-visibility
- Declaring package visibility: https://developer.android.com/training/package-visibility/declaring
- Google Play QUERY_ALL_PACKAGES policy: https://support.google.com/googleplay/android-developer/answer/10158779
- Google Play sensitive permissions policy: https://support.google.com/googleplay/android-developer/answer/16558241
