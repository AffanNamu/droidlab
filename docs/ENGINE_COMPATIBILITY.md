# Engine compatibility and feasibility

This is a living evidence register. A tool is not supported merely because its library exists or a UI control has been drawn.

## Compatibility labels
- Unverified: not yet built or tested in DroidLab.
- Prototype: a narrow proof of concept exists but is not release-ready.
- Verified: tested on named Android versions/devices with reproducible evidence.
- Unsupported: known incompatible or outside the product boundary.

## Initial evidence register

| Capability | Initial status | Validation required |
|---|---|---|
| Installed package discovery | Unverified | Package visibility on API 26 and current Android |
| APK extraction from installed package | Unverified | Base APK and split APK paths; permissions and storage |
| APK metadata inspection | Unverified | Package name, version, SDKs, manifest, signatures |
| ZIP/archive safety | Unverified | Traversal, symlink, duplicate paths, bombs, limits |
| JADX Java reconstruction | Unverified | Android runtime, dependency/license, memory, ABI |
| Apktool resource decode/rebuild | Unverified | Runtime compatibility, aapt/aapt2, framework resources |
| Smali assemble/disassemble | Unverified | DEX versions, multidex, Android runtime |
| zipalign/apksigner | Unverified | Bundling, executable/runtime compatibility, signatures |
| PackageInstaller APK install | Unverified | API 26, user approval, unknown-source settings |
| PackageInstaller split install | Unverified | Split completeness, session commit, failure handling |
| On-device JDK/Gradle builds | High risk / unverified | JDK, Gradle, SDK, memory, storage |
| Flutter project reconstruction | Unsupported as original-source recovery | APK does not contain ordinary recoverable original Dart source |

## Required device matrix
At minimum test Android 8 / API 26, a current Android release, a low-memory device, a higher-memory device, and ARM64 as the primary ABI. Evaluate other ABIs separately.

Record exact device model, Android build, ABI, available RAM/storage, tool versions, sample hashes, operation duration, exit status, and output verification.

## Feasibility gates
1. Package discovery and extraction: discover installed apps, distinguish system/user/updated-system packages, and copy base/split APKs safely.
2. Inspection: parse a known APK corpus and compare metadata against PackageManager / apkanalyzer.
3. Decode/rebuild: decode and rebuild an authorized sample without edits, then validate structure and behavior.
4. Smali edit: make a harmless change to a test app, assemble, align, sign, verify, and install.
5. Installation: test new install, same-certificate update, different-certificate rejection, split installs, and user cancellation.
6. Source builds: prove one minimal Gradle project can build locally before expanding claims.

## Release rule
Any capability without reproducible device evidence remains experimental or unavailable in the UI. Never show an all-ready status using placeholder data.
