package com.droidlab.app.engine

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import java.io.File
import java.io.IOException
import java.security.MessageDigest
import java.util.zip.ZipFile

data class ApkAnalysis(
    val packageName: String,
    val applicationName: String,
    val versionName: String?,
    val versionCode: Long,
    val minSdk: Int,
    val targetSdk: Int,
    val fileSizeBytes: Long,
    val requestedPermissions: List<String>,
    val dexFiles: List<String>,
    val nativeLibraries: List<String>,
    val assetFiles: List<String>,
    val hasManifest: Boolean,
    val hasResourcesTable: Boolean,
    val signatureStatus: String,
    val signingCertificateSha256: List<String>
)

/**
 * Performs bounded metadata and ZIP inventory inspection. It does not extract
 * entries or claim to cryptographically verify APK signing schemes.
 */
class ApkInspector(
    private val context: Context
) {
    fun inspect(file: File): ApkAnalysis {
        val apk = file.canonicalFile
        if (!apk.isFile || !apk.canRead() || apk.length() <= 0L) {
            throw IOException("APK file is missing, empty, or unreadable.")
        }
        if (apk.length() > MAX_APK_BYTES) {
            throw IllegalArgumentException("APK exceeds the supported inspection size.")
        }

        val packageInfo = readPackageInfo(apk)
            ?: throw IllegalArgumentException("Android PackageManager could not parse this APK.")
        val applicationInfo = packageInfo.applicationInfo
            ?: throw IllegalArgumentException("APK application metadata is missing.")
        applicationInfo.sourceDir = apk.absolutePath
        applicationInfo.publicSourceDir = apk.absolutePath

        val dexFiles = mutableListOf<String>()
        val nativeLibraries = mutableListOf<String>()
        val assetFiles = mutableListOf<String>()
        var hasManifest = false
        var hasResourcesTable = false
        var entryCount = 0
        var declaredUncompressedBytes = 0L

        ZipFile(apk).use { zip ->
            val entries = zip.entries()
            while (entries.hasMoreElements()) {
                val entry = entries.nextElement()
                entryCount++
                if (entryCount > MAX_ZIP_ENTRIES) {
                    throw IllegalArgumentException("APK contains too many archive entries.")
                }
                validateEntryName(entry.name)
                if (entry.size > 0L) {
                    declaredUncompressedBytes += entry.size
                    if (declaredUncompressedBytes > MAX_DECLARED_UNCOMPRESSED_BYTES) {
                        throw IllegalArgumentException(
                            "APK declares an excessive uncompressed archive size."
                        )
                    }
                }

                when {
                    entry.name == "AndroidManifest.xml" -> hasManifest = true
                    entry.name == "resources.arsc" -> hasResourcesTable = true
                    DEX_ENTRY.matches(entry.name) -> dexFiles.add(entry.name)
                    entry.name.startsWith("lib/") &&
                        entry.name.endsWith(".so") -> nativeLibraries.add(entry.name)
                    entry.name.startsWith("assets/") -> assetFiles.add(entry.name)
                }
            }
        }

        val certificates = readCertificateFingerprints(packageInfo)
        val label = context.packageManager.getApplicationLabel(applicationInfo)
            .toString()

        return ApkAnalysis(
            packageName = packageInfo.packageName,
            applicationName = label,
            versionName = packageInfo.versionName,
            versionCode = packageInfo.longVersionCodeCompat(),
            minSdk = applicationInfo.minSdkVersion,
            targetSdk = applicationInfo.targetSdkVersion,
            fileSizeBytes = apk.length(),
            requestedPermissions = packageInfo.requestedPermissions?.toList()
                .orEmpty()
                .sorted(),
            dexFiles = dexFiles.sorted(),
            nativeLibraries = nativeLibraries.sorted(),
            assetFiles = assetFiles.sorted(),
            hasManifest = hasManifest,
            hasResourcesTable = hasResourcesTable,
            signatureStatus = if (certificates.isEmpty()) {
                "No signing certificate metadata was returned."
            } else {
                "Certificate metadata found; full APK signature verification is pending."
            },
            signingCertificateSha256 = certificates
        )
    }

    private fun validateEntryName(name: String) {
        if (name.isBlank() || name.startsWith("/") || name.contains('\\')) {
            throw IllegalArgumentException("APK contains an unsafe archive entry path.")
        }
        if (name.split('/').any { it == "." || it == ".." }) {
            throw IllegalArgumentException("APK contains a path traversal entry.")
        }
    }

    @Suppress("DEPRECATION")
    private fun readPackageInfo(file: File): PackageInfo? {
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            PackageManager.GET_SIGNATURES
        }
        return context.packageManager.getPackageArchiveInfo(file.absolutePath, flags)
    }

    @Suppress("DEPRECATION")
    private fun readCertificateFingerprints(packageInfo: PackageInfo): List<String> {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.signingInfo?.apkContentsSigners
        } else {
            packageInfo.signatures
        }
        return signatures.orEmpty().map { signature ->
            MessageDigest.getInstance("SHA-256")
                .digest(signature.toByteArray())
                .joinToString("") { byte -> "%02X".format(byte) }
        }.sorted()
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
        private const val MAX_ZIP_ENTRIES = 100_000
        private const val MAX_DECLARED_UNCOMPRESSED_BYTES =
            8L * 1024L * 1024L * 1024L
        private val DEX_ENTRY = Regex("classes(\\d*)\\.dex")
    }
}
