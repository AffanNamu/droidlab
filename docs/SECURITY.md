# Security

## Threat model
All imported APKs, ZIPs, source projects, manifests, resource files, scripts, and metadata are untrusted. Malicious content may attempt path traversal, resource exhaustion, parser exploitation, credential theft, or execution of untrusted code.

## Mandatory controls
- Keep original imports immutable and hash them with SHA-256.
- Reject absolute paths, traversal segments, duplicate normalized paths, unsafe symlinks, and archive entries escaping the workspace.
- Enforce compressed/uncompressed size, entry-count, nesting, and per-file limits.
- Never auto-install, execute, or run imported content.
- Never run Gradle tasks or project scripts merely because a project was imported.
- Run tools in a dedicated workspace with bounded memory, CPU/time, output size, and cancellation.
- Avoid shell interpolation. Prefer direct process argument arrays and allowlisted executable paths.
- Redact passwords, private key material, tokens, and sensitive paths from logs.
- Store signing keys using Android Keystore-backed encryption where feasible; never store plaintext passwords.
- Require explicit confirmation before destructive operations, especially uninstalling an app that may contain user data.
- Use SAF for user-selected files; avoid broad storage permissions.
- Validate outputs before exposing Install or Share actions.

## Signing
- Private signing material must not be included in crash reports, logs, exports, or project backups by default.
- Show certificate SHA-256 fingerprint and alias before signing.
- Clearly distinguish debug keys, generated user keys, and imported keys.
- Explain that a different signing certificate generally prevents in-place update of an installed package.
- Never attempt to extract or bypass another application's private signing key.

## Installation
- Use Android PackageInstaller APIs and honor platform user confirmation.
- Do not request device-admin, root, accessibility, or package-install privileges beyond the documented user-enabled unknown-source permission flow.
- Do not claim system apps can be replaced on stock devices.
- Verify package identity, signature, and APK integrity before creating an install session.

## Privacy
- No account, sign-in, Firebase, analytics, or mandatory cloud service.
- Local metadata remains in app-private storage.
- Optional network functionality must be separately documented and opt-in.
- Provide a clear workspace cleanup action with preview and confirmation.

## Responsible use
DroidLab is for apps and source projects the user owns or is authorized to modify. It must not provide workflows to bypass third-party licensing, payment, access controls, or security protections.
