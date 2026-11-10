package com.droidlab.droidlab.storage

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.os.Build
import com.droidlab.droidlab.engine.ExtractedPackageFiles
import com.droidlab.droidlab.engine.InstalledAppSummary
import java.io.File
import java.io.IOException
import java.util.UUID

class ApkFileImportRepository(
    private val context: Context,
    private val projectRepository: ProjectWorkspaceRepository
) {
    fun importApk(sourcePath: String): Pair<LocalProjectSummary, ExtractedPackageFiles> {
        val source = File(sourcePath).canonicalFile
        if (!source.isFile || !source.canRead()) {
            throw IOException("The selected APK file cannot be read.")
        }
        if (!source.name.endsWith(".apk", ignoreCase = true)) {
            throw IllegalArgumentException("Select a single APK file.")
        }
        if (source.length() <= 0L || source.length() > MAX_APK_BYTES) {
            throw IllegalArgumentException("APK file size is outside the supported import limit.")
        }

        val packageInfo = readArchivePackageInfo(source)
            ?: throw IllegalArgumentException("The selected file is not a valid APK.")
        if (!packageInfo.splitNames.isNullOrEmpty()) {
            throw IllegalArgumentException(
                "This is a split APK part. Import the complete APKS/XAPK set instead."
            )
        }
        val applicationInfo = packageInfo.applicationInfo
            ?: throw IllegalArgumentException("APK application metadata is missing.")
        applicationInfo.sourceDir = source.absolutePath
        applicationInfo.publicSourceDir = source.absolutePath

        val projectId = UUID.randomUUID().toString()
        val originalDirectory = File(
            context.filesDir,
            "projects/$projectId/original"
        )
        if (!originalDirectory.exists() && !originalDirectory.mkdirs()) {
            throw IOException("Could not create the private APK workspace.")
        }

        val copiedApk = File(originalDirectory, "base.apk")
        source.inputStream().use { input ->
            copiedApk.outputStream().use { output -> input.copyTo(output) }
        }

        val extracted = ExtractedPackageFiles(
            packageName = packageInfo.packageName,
            baseApk = copiedApk,
            splitApks = emptyList()
        )
        val appSummary = InstalledAppSummary(
            packageName = packageInfo.packageName,
            label = context.packageManager.getApplicationLabel(applicationInfo)
                .toString(),
            versionName = packageInfo.versionName,
            versionCode = packageInfo.longVersionCodeCompat(),
            apkSizeBytes = copiedApk.length(),
            isSystemApp = false,
            isUpdatedSystemApp = false,
            enabled = true,
            firstInstallTime = 0L,
            lastUpdateTime = 0L,
            splitCount = 0,
            iconPng = null
        )
        val project = projectRepository.recordInstalledPackage(
            projectId = projectId,
            app = appSummary,
            extracted = extracted,
            kind = "apk_file"
        )
        return project to extracted
    }

    @Suppress("DEPRECATION")
    private fun readArchivePackageInfo(file: File): PackageInfo? {
        return context.packageManager.getPackageArchiveInfo(
            file.absolutePath,
            0
        )
    }

    @Suppress("DEPRECATION")
    private fun PackageInfo.longVersionCodeCompat(): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            longVersionCode
        } else {
            versionCode.toLong()
        }
    }

    companion object {
        private const val MAX_APK_BYTES = 2L * 1024L * 1024L * 1024L
    }
}
