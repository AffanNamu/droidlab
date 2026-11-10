import 'dart:typed_data';

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform/droidlab_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/droidlab/app/bridge/DroidLabApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.droidlab.app.bridge',
    ),
  ),
)
class InstalledAppDto {
  late String packageName;
  late String label;
  String? versionName;
  late int versionCode;
  late int apkSizeBytes;
  late bool isSystemApp;
  late bool isUpdatedSystemApp;
  late bool enabled;
  late int firstInstallTime;
  late int lastUpdateTime;
  late int splitCount;
  Uint8List? iconPng;
}

class ExtractedPackageDto {
  late String projectId;
  late String packageName;
  late String workspacePath;
  late String baseApkPath;
  late List<String> splitApkPaths;
}

class ProjectSummaryDto {
  late String projectId;
  late String name;
  late String kind;
  late String packageName;
  String? versionName;
  late int versionCode;
  late int importedAtEpochMillis;
  late int originalSizeBytes;
  late int splitCount;
  late String workspacePath;
}

class WorkspaceFileDto {
  late String name;
  late String relativePath;
  late bool isDirectory;
  late int sizeBytes;
  late String extension;
}

class EngineCapabilityDto {
  late String id;
  late String displayName;
  late String state;
  String? version;
  String? detail;
  String? detectedAbi;
}

class InstallSessionDto {
  late int sessionId;
  late String packageName;
  late int apkCount;
}

class InstallStatusDto {
  late String jobId;
  late int statusCode;
  late String statusMessage;
  late int updatedAtEpochMillis;
}

@HostApi()
abstract class DroidLabHostApi {
  @async
  List<InstalledAppDto> listInstalledApps(String group);

  @async
  ExtractedPackageDto extractInstalledApp(String packageName);

  @async
  ExtractedPackageDto importApkFile(String sourcePath);

  @async
  List<ProjectSummaryDto> listProjects();

  @async
  List<WorkspaceFileDto> listWorkspaceFiles(
    String projectId,
    String relativeDirectory,
  );

  @async
  String readWorkspaceFile(String projectId, String relativePath);

  @async
  bool writeWorkspaceFile(
    String projectId,
    String relativePath,
    String contents,
  );

  @async
  List<EngineCapabilityDto> getEngineCapabilities();

  @async
  bool canRequestInstallPackages();

  @async
  bool openInstallPermissionSettings();

  @async
  InstallSessionDto installApks(
    List<String> apkPaths,
    String jobId,
  );

  @async
  InstallStatusDto? getInstallStatus(String jobId);
}
