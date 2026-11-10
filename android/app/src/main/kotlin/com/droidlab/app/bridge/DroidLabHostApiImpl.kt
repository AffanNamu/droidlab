package com.droidlab.app.bridge

import android.content.Context
import android.os.Build
import android.content.pm.PackageManager
import com.droidlab.app.engine.InstalledAppGroup
import com.droidlab.app.engine.InstalledAppRepository
import com.droidlab.app.installation.InstallStatusReceiver
import com.droidlab.app.installation.PackageInstallCoordinator
import com.droidlab.app.storage.ApkFileImportRepository
import com.droidlab.app.storage.ProjectWorkspaceRepository
import java.io.File
import java.util.UUID

/**
 * Android implementation of the generated Pigeon host API.
 * Import destinations are generated inside DroidLab's private files directory.
 */
class DroidLabHostApiImpl(
    private val context: Context
) : DroidLabHostApi {

    private val appRepository = InstalledAppRepository(context)
    private val projectRepository = ProjectWorkspaceRepository(context)
    private val apkFileImportRepository = ApkFileImportRepository(
        context,
        projectRepository
    )
    private val installCoordinator = PackageInstallCoordinator(context)

    override suspend fun listInstalledApps(group: String): List<InstalledAppDto> {
        val filter = when (group.lowercase()) {
            "user", "installed" -> InstalledAppGroup.USER
            "system" -> InstalledAppGroup.SYSTEM
            "all" -> InstalledAppGroup.ALL
            else -> throw IllegalArgumentException("Unknown installed-app group.")
        }

        return appRepository.listInstalledApps(filter).map { app ->
            InstalledAppDto().apply {
                packageName = app.packageName
                label = app.label
                versionName = app.versionName
                versionCode = app.versionCode
                apkSizeBytes = app.apkSizeBytes
                isSystemApp = app.isSystemApp
                isUpdatedSystemApp = app.isUpdatedSystemApp
                enabled = app.enabled
                firstInstallTime = app.firstInstallTime
                lastUpdateTime = app.lastUpdateTime
                splitCount = app.splitCount
                iconPng = app.iconPng
            }
        }
    }

    override suspend fun extractInstalledApp(
        packageName: String
    ): ExtractedPackageDto {
        val app = appRepository.listInstalledApps(InstalledAppGroup.ALL)
            .firstOrNull { it.packageName == packageName }
            ?: throw IllegalArgumentException("The selected application is no longer available.")

        val projectId = UUID.randomUUID().toString()
        val originalDirectory = File(
            context.filesDir,
            "projects/$projectId/original"
        )
        val extracted = appRepository.extractPackage(
            packageName = packageName,
            destinationDirectory = originalDirectory
        )
        val project = projectRepository.recordInstalledPackage(
            projectId = projectId,
            app = app,
            extracted = extracted
        )

        return ExtractedPackageDto().apply {
            this.projectId = project.projectId
            this.packageName = project.packageName
            workspacePath = project.workspacePath
            baseApkPath = extracted.baseApk.absolutePath
            splitApkPaths = extracted.splitApks.map(File::getAbsolutePath)
        }
    }

    override suspend fun importApkFile(sourcePath: String): ExtractedPackageDto {
        val (project, extracted) = apkFileImportRepository.importApk(sourcePath)
        return ExtractedPackageDto().apply {
            projectId = project.projectId
            packageName = project.packageName
            workspacePath = project.workspacePath
            baseApkPath = extracted.baseApk.absolutePath
            splitApkPaths = extracted.splitApks.map(File::getAbsolutePath)
        }
    }

    override suspend fun listProjects(): List<ProjectSummaryDto> {
        return projectRepository.listProjects().map { project ->
            ProjectSummaryDto().apply {
                projectId = project.projectId
                name = project.name
                kind = project.kind
                packageName = project.packageName
                versionName = project.versionName
                versionCode = project.versionCode
                importedAtEpochMillis = project.importedAtEpochMillis
                originalSizeBytes = project.originalSizeBytes
                splitCount = project.splitCount
                workspacePath = project.workspacePath
            }
        }
    }

    override suspend fun listWorkspaceFiles(
        projectId: String,
        relativeDirectory: String
    ): List<WorkspaceFileDto> {
        return projectRepository.listWorkspaceFiles(
            projectId,
            relativeDirectory
        ).map { file ->
            WorkspaceFileDto().apply {
                name = file.name
                relativePath = file.relativePath
                isDirectory = file.isDirectory
                sizeBytes = file.sizeBytes
                extension = file.extension
            }
        }
    }

    override suspend fun readWorkspaceFile(
        projectId: String,
        relativePath: String
    ): String {
        return projectRepository.readWorkspaceFile(projectId, relativePath)
    }

    override suspend fun writeWorkspaceFile(
        projectId: String,
        relativePath: String,
        contents: String
    ): Boolean {
        projectRepository.writeWorkspaceFile(
            projectId,
            relativePath,
            contents
        )
        return true
    }

    override suspend fun getEngineCapabilities(): List<EngineCapabilityDto> {
        val canQueryPackages = runCatching {
            context.packageManager.getInstalledApplications(
                PackageManager.GET_META_DATA
            )
        }.isSuccess
        val installPermissionGranted = installCoordinator.canRequestInstallPackages()
        val installerSupported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

        return listOf(
            capability(
                id = "package-discovery",
                name = "Installed app discovery",
                ready = canQueryPackages,
                detail = if (canQueryPackages) {
                    "Android PackageManager is responding."
                } else {
                    "Package visibility is unavailable or restricted."
                }
            ),
            capability(
                id = "package-installer",
                name = "Android package installer",
                ready = installerSupported && installPermissionGranted,
                detail = when {
                    !installerSupported ->
                        "Android 8.0 or newer is required."
                    !installPermissionGranted ->
                        "User approval in Android settings is required before installing APKs."
                    else -> "Android PackageInstaller is available."
                }
            ),
            capability(
                id = "jadx",
                name = "JADX Java reconstruction",
                ready = false,
                detail = "Not integrated. Compatibility testing is pending."
            ),
            capability(
                id = "apktool",
                name = "Apktool resource engine",
                ready = false,
                detail = "Not integrated. Compatibility testing is pending."
            ),
            capability(
                id = "smali",
                name = "Smali assembler",
                ready = false,
                detail = "Not integrated. Compatibility testing is pending."
            ),
            capability(
                id = "local-gradle",
                name = "On-device Gradle build engine",
                ready = false,
                detail = "Not integrated. Device feasibility testing is pending."
            )
        )
    }

    override suspend fun canRequestInstallPackages(): Boolean {
        return installCoordinator.canRequestInstallPackages()
    }

    override suspend fun openInstallPermissionSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        context.startActivity(installCoordinator.createInstallPermissionIntent())
        return true
    }

    override suspend fun installApks(
        apkPaths: List<String>,
        jobId: String
    ): InstallSessionDto {
        if (jobId.isBlank()) {
            throw IllegalArgumentException("An install job ID is required.")
        }
        val files = apkPaths.map(::requirePrivatePath)
        val session = installCoordinator.startInstall(files, jobId)
        return InstallSessionDto().apply {
            sessionId = session.sessionId
            packageName = session.packageName
            apkCount = session.apkCount
        }
    }

    override suspend fun getInstallStatus(jobId: String): InstallStatusDto? {
        if (jobId.isBlank()) return null
        val status = InstallStatusReceiver.readStatus(context, jobId) ?: return null
        return InstallStatusDto().apply {
            this.jobId = status.jobId
            statusCode = status.statusCode
            statusMessage = status.statusMessage
            updatedAtEpochMillis = status.updatedAtEpochMillis
        }
    }

    private fun requirePrivatePath(path: String): File {
        if (path.isBlank()) {
            throw IllegalArgumentException("A workspace path is required.")
        }
        val root = context.filesDir.canonicalFile
        val candidate = File(path).canonicalFile
        val rootPrefix = root.path + File.separator
        if (!candidate.path.startsWith(rootPrefix)) {
            throw SecurityException(
                "The requested file is outside DroidLab's private workspace."
            )
        }
        return candidate
    }

    private fun capability(
        id: String,
        name: String,
        ready: Boolean,
        detail: String
    ): EngineCapabilityDto {
        return EngineCapabilityDto().apply {
            this.id = id
            displayName = name
            state = if (ready) "ready" else "missing"
            this.detail = detail
        }
    }
}
