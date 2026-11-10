# Build, sign, verify, and install workflow

## Product rule
DroidLab performs the build and installation workflow locally. GitHub is optional for source control and backup; it is never required to build or install an APK. No sign-in or backend is involved.

## Artifact pipeline
1. **Build:** produce a candidate APK from an editable project.
2. **Align:** run the selected zip alignment tool and retain its output as a new artifact.
3. **Sign:** sign with a selected user key or a generated DroidLab key.
4. **Verify:** validate APK structure, signature schemes, signer certificate, package metadata, and alignment. Record tool versions and certificate SHA-256.
5. **Install:** create a PackageInstaller session only for a verified artifact. Android may show its own confirmation UI.
6. **Export:** allow the user to save or share the verified APK using the Storage Access Framework.

Never overwrite the imported original. Each stage writes a new artifact and records provenance.

## Installation states
- Waiting for permission: Android's install-unknown-apps permission has not been granted for DroidLab.
- Preparing session: files are copied into a PackageInstaller session.
- Awaiting user confirmation: Android installer confirmation is displayed.
- Installed: PackageInstaller reports success.
- Failed: PackageInstaller returns a failure status and message.
- Cancelled: user cancels Android's confirmation or the operation is abandoned.

Persist job ID, session ID, package name, artifact hash, status code, status message, and timestamps. Do not report success before PackageInstaller confirms it.

## Signing compatibility
Android package updates require compatible signing identity. If the modified APK is signed with a different key, Android normally rejects it as an update to the installed package. Offer these choices:
- Sign with the original key, if the user owns and provides it.
- Install under a different package ID, if the project can safely support that change.
- Uninstall the existing package and install the newly signed APK only after a prominent data-loss warning and explicit confirmation.

DroidLab cannot recover another developer's private signing key.

## Split APKs
Installed packages may consist of a base APK plus configuration or feature splits. Extract all installed split APK paths together. Rebuild/install the complete compatible set in one PackageInstaller session. Never silently install only the base APK when splits are required.

## System packages
System, privileged, manufacturer-signed, and protected packages may be non-replaceable on stock devices. Report Android's actual PackageInstaller result. Do not claim to bypass platform protections.

## Permission and privacy
- No Google account, Google Sign-In, Firebase, or cloud service is required.
- Android 8.0+ may require the user to allow DroidLab to install unknown apps in Android Settings. This is an Android OS permission, not a Google account setting.
- The user initiates installation; DroidLab does not install in the background.
- Local project files are stored in app-private storage. Automatic Android backup is disabled.
