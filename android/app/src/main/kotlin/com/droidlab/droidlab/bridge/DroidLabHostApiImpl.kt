package com.droidlab.droidlab.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import com.droidlab.droidlab.engine.InstalledAppGroup
import com.droidlab.droidlab.engine.InstalledAppRepository
import com.droidlab.droidlab.installation.InstallStatusReceiver
import com.droidlab.droidlab.installation.PackageInstallCoordinator
import java.io.File

/**
 * Android implementation of the generated Pigeon host API.
 * Paths crossing this boundary must remain inside DroidLab's private files area.
 */
class DroidLabHostApiImpl(
    private val context: Context
) : DroidLabHostApi {

    private val appRepository = InstalledAppRepository(context)
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
            }
        }
    }

    override suspend fun extractInstalledApp(
        packageName: String,
        destinationPath: String
    ): ExtractedPackageDto {
        val destination = requirePrivatePath(destinationPath)
        val extracted = appRepository.extractPackage(
            packageName = packageName,
            destinationDirectory = destination
        )
        return ExtractedPackageDto().apply {
            this.packageName = extracted.packageName
            baseApkPath = extracted.baseApk.absolutePath
            splitApkPaths = extracted.splitApks.map(File::getAbsolutePath)
        }
    }

    override suspend fun getEngineCapabilities(): List<EngineCapabilityDto> {
        val canQueryPackages = runCatching {
            appRepository.listInstalledApps(InstalledAppGroup.ALL)
        }.isSuccess

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
                ready = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O,
                detail = if (installCoordinator.canRequestInstallPackages()) {
                    "Android install permission is enabled."
                } else {
                    "User approval in Android settings is required before installing APKs."
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
        val intent = installCoordinator.createInstallPermissionIntent()
        context.startActivity(intent)
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
            throw SecurityException("The requested file is outside DroidLab's private workspace.")
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
