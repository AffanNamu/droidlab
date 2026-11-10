# UI reference specification

The approved visual direction is a premium, dark, mobile-first engineering studio. The generated reference images in the conversation are design guidance; they are not yet stored as repository assets. If original image files become available in the development workspace, add them under docs/design/references/ with descriptive names and a note that they are generated design references.

## Visual system
- Background: #090D16
- Secondary surface: #101827
- Elevated panel: #172235
- Cyan accent: #38BDF8
- Purple accent: #8B5CF6
- Primary text: #F8FAFC
- Muted text: #94A3B8
- Success: #22C55E
- Error: #EF4444

Use gradients sparingly for primary actions. Cards should have subtle borders, rounded corners, strong contrast, and consistent touch targets. Avoid dense desktop IDE layouts squeezed onto phone screens.

## Main navigation
1. Home
2. Projects
3. Workspace
4. Tools
5. Settings

## Screen references
- Home: brand header, Import APK and Import Project primary actions, quick tools, recent projects, truthful engine status.
- Code Editor: collapsible file explorer, tabs, line numbers, syntax highlighting, search, editing toolbar, build action. On narrow screens the file explorer is a drawer/sheet, not a permanent split pane.
- Tools: categorized Analyze, Edit, Build, Utilities. Each tool opens a dedicated workflow and reflects actual engine availability.
- Settings: workspace, engines, build/signing, editor, appearance, performance, security/privacy, backup/restore, about.
- Import APK: Installed Apps, System Apps, APK Files. Display app icon/name, package ID, version, size, selection state. Distinguish ordinary user apps, factory system apps, and updated system apps.
- Build & Install Center: build, sign, verify, install, export, share. Never enable Install until verification passes.

## Interaction requirements
- Search and filters work on actual device/project data.
- Selection supports multiple packages where the underlying workflow supports split sets.
- Empty, loading, permission-denied, unsupported, and error states are designed explicitly.
- Engine readiness must be derived from native capability checks.
- Installation always explains Android's confirmation step.
- Destructive actions require clear confirmation and impact explanation.
