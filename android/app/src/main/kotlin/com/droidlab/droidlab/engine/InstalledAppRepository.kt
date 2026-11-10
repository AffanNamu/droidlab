package com.droidlab.droidlab.engine

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Build
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException

enum class InstalledAppGroup {
    USER,
    SYSTEM,
    ALL
}

data class InstalledAppSummary(
    val packageName: String,
    val label: String,
    val versionName: String?,
    val versionCode: Long,
    val apkSizeBytes: Long,
    val isSystemApp: Boolean,
    val isUpdatedSystemApp: Boolean,
    val enabled: Boolean,
    val firstInstallTime: Long,
    val lastUpdateTime: Long,
    val splitCount: Int,
    val iconPng: ByteArray?
)

data class ExtractedPackageFiles(
    val packageName: String,
    val baseApk: File,
    val splitApks: List<File>
) {
    val allFiles: List<File>
        get() = listOf(baseApk) + splitApks
}

/**
 * Reads installed package metadata and copies package APK files into a caller-owned
 * app-private workspace. It never modifies or uninstalls the source application.
 */
class InstalledAppRepository(
    private val context: Context
) {
    private val packageManager: PackageManager
        get() = context.packageManager

    @Suppress("DEPRECATION")
    fun listInstalledApps(group: InstalledAppGroup): List<InstalledAppSummary> {
        val installed = packageManager.getInstalledApplications(
            PackageManager.GET_META_DATA
        )

        return installed.asSequence()
            .filterNot { it.packageName == context.packageName }
            .mapNotNull { applicationInfo ->
                val flags = applicationInfo.flags
                val isSystem = flags and ApplicationInfo.FLAG_SYSTEM != 0
                val isUpdatedSystem =
                    flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0

                val include = when (group) {
                    InstalledAppGroup.USER -> !isSystem
                    InstalledAppGroup.SYSTEM -> isSystem
                    InstalledAppGroup.ALL -> true
                }
                if (!include) return@mapNotNull null

                val packageInfo = getPackageInfo(applicationInfo.packageName)
                    ?: return@mapNotNull null
                val baseApk = applicationInfo.sourceDir?.let(::File)
                val splitApks = applicationInfo.splitSourceDirs.orEmpty()
                    .map(::File)
                val totalSize = (listOfNotNull(baseApk) + splitApks)
                    .sumOf { file -> file.takeIf { it.isFile }?.length() ?: 0L }

                InstalledAppSummary(
                    packageName = applicationInfo.packageName,
                    label = packageManager.getApplicationLabel(applicationInfo)
                        .toString(),
                    versionName = packageInfo.versionName,
                    versionCode = packageInfo.longVersionCodeCompat(),
                    apkSizeBytes = totalSize,
                    isSystemApp = isSystem,
                    isUpdatedSystemApp = isUpdatedSystem,
                    enabled = applicationInfo.enabled,
                    firstInstallTime = packageInfo.firstInstallTime,
                    lastUpdateTime = packageInfo.lastUpdateTime,
                    splitCount = splitApks.size,
                    iconPng = renderIconPng(applicationInfo)
                )
            }
            .sortedBy { it.label.lowercase() }
            .toList()
    }

    fun extractPackage(
        packageName: String,
        destinationDirectory: File
    ): ExtractedPackageFiles {
        val applicationInfo = packageManager.getApplicationInfoCompat(packageName)
            ?: throw IllegalArgumentException("Package is not visible or installed")

        val baseSource = applicationInfo.sourceDir?.let(::File)
            ?: throw IOException("Installed package has no base APK path")
        val splitSources = applicationInfo.splitSourceDirs.orEmpty().map(::File)

        if (!baseSource.isFile) {
            throw IOException("Base APK is not readable")
        }
        if (splitSources.any { !it.isFile }) {
            throw IOException("One or more split APK files are not readable")
        }

        if (!destinationDirectory.exists() && !destinationDirectory.mkdirs()) {
            throw IOException("Could not create the private package workspace")
        }
        val root = destinationDirectory.canonicalFile
        if (!root.isDirectory) {
            throw IOException("Package workspace is not a directory")
        }

        val baseOutput = File(root, "base.apk")
        baseSource.inputStream().use { input ->
            baseOutput.outputStream().use { output -> input.copyTo(output) }
        }

        val splitOutputs = splitSources.mapIndexed { index, source ->
            val outputFile = File(root, "split_$index.apk")
            source.inputStream().use { input ->
                outputFile.outputStream().use { output -> input.copyTo(output) }
            }
            outputFile
        }

        return ExtractedPackageFiles(
            packageName = packageName,
            baseApk = baseOutput,
            splitApks = splitOutputs
        )
    }

    private fun renderIconPng(applicationInfo: ApplicationInfo): ByteArray? {
        return runCatching {
            val drawable = packageManager.getApplicationIcon(applicationInfo)
            val size = 64
            val bitmap = Bitmap.createBitmap(
                size,
                size,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)

            ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                bitmap.recycle()
                output.toByteArray()
            }
        }.getOrNull()
    }

    @Suppress("DEPRECATION")
    private fun getPackageInfo(packageName: String): PackageInfo? {
        return try {
            packageManager.getPackageInfo(packageName, 0)
        } catch (_: PackageManager.NameNotFoundException) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun PackageManager.getApplicationInfoCompat(
        packageName: String
    ): ApplicationInfo? {
        return try {
            getApplicationInfo(packageName, 0)
        } catch (_: PackageManager.NameNotFoundException) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun PackageInfo.longVersionCodeCompat(): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            longVersionCode
        } else {
            versionCode.toLong()
        }
    }
}
