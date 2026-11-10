import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform/droidlab_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/droidlab/droidlab/bridge/DroidLabApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.droidlab.droidlab.bridge',
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
}

class ExtractedPackageDto {
  late String packageName;
  late String baseApkPath;
  late List<String> splitApkPaths;
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
  ExtractedPackageDto extractInstalledApp(
    String packageName,
    String destinationPath,
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
