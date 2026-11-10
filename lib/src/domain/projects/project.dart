enum ProjectKind {
  apk,
  splitApkSet,
  androidSource,
}

class DroidLabProject {
  const DroidLabProject({
    required this.id,
    required this.name,
    required this.kind,
    required this.createdAt,
    required this.workspacePath,
    this.packageName,
    this.versionName,
    this.originalSha256,
  });

  final String id;
  final String name;
  final ProjectKind kind;
  final DateTime createdAt;
  final String workspacePath;
  final String? packageName;
  final String? versionName;
  final String? originalSha256;
}
