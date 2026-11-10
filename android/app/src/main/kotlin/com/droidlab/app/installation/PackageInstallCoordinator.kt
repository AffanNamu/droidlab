package com.droidlab.app.installation

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import android.provider.Settings
import java.io.File
import java.io.IOException

class InstallPermissionRequiredException : IllegalStateException(
    "Allow DroidLab to install apps from this source in Android settings."
)

data class InstallSessionResult(
    val sessionId: Int,
    val packageName: String,
    val apkCount: Int
)

/**
 * Creates Android PackageInstaller sessions for one APK or a complete split set.
 * Android remains responsible for package verification and user confirmation.
 */
class PackageInstallCoordinator(
    private val context: Context
) {
    private val packageInstaller: PackageInstaller
        get() = context.packageManager.packageInstaller

    fun canRequestInstallPackages(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            context.packageManager.canRequestPackageInstalls()
    }

    fun createInstallPermissionIntent(): Intent {
        return Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:${context.packageName}")
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

    fun startInstall(apkFiles: List<File>, jobId: String): InstallSessionResult {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            throw UnsupportedOperationException(
                "DroidLab requires Android 8.0 (API 26) or newer."
            )
        }
        if (!canRequestInstallPackages()) {
            throw InstallPermissionRequiredException()
        }
        if (apkFiles.isEmpty()) {
            throw IllegalArgumentException("Select at least one APK file.")
        }
        if (apkFiles.any { !it.isFile || !it.canRead() || it.length() == 0L }) {
            throw IOException("An APK file is missing, empty, or unreadable.")
        }

        val packageNames = apkFiles.map { apkFile ->
            @Suppress("DEPRECATION")
            context.packageManager.getPackageArchiveInfo(apkFile.absolutePath, 0)
                ?.packageName
                ?: throw IllegalArgumentException(
                    "The selected file is not a readable Android APK: ${apkFile.name}"
                )
        }.toSet()

        if (packageNames.size != 1) {
            throw IllegalArgumentException(
                "All APKs in one install session must belong to the same package."
            )
        }

        val packageName = packageNames.single()
        val params = PackageInstaller.SessionParams(
            PackageInstaller.SessionParams.MODE_FULL_INSTALL
        ).apply {
            setAppPackageName(packageName)
            setSize(apkFiles.sumOf(File::length))
        }

        val sessionId = packageInstaller.createSession(params)
        try {
            packageInstaller.openSession(sessionId).use { session ->
                apkFiles.forEachIndexed { index, apkFile ->
                    val entryName = if (index == 0) {
                        "base.apk"
                    } else {
                        "split_$index.apk"
                    }
                    apkFile.inputStream().use { input ->
                        session.openWrite(entryName, 0, apkFile.length()).use { output ->
                            input.copyTo(output)
                            session.fsync(output)
                        }
                    }
                }

                val callbackIntent = Intent(
                    context,
                    InstallStatusReceiver::class.java
                ).setAction(ACTION_INSTALL_STATUS)
                    .putExtra(EXTRA_JOB_ID, jobId)

                val mutabilityFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_MUTABLE
                } else {
                    0
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    sessionId,
                    callbackIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or mutabilityFlag
                )
                session.commit(pendingIntent.intentSender)
            }
        } catch (error: Exception) {
            runCatching { packageInstaller.abandonSession(sessionId) }
            throw error
        }

        return InstallSessionResult(
            sessionId = sessionId,
            packageName = packageName,
            apkCount = apkFiles.size
        )
    }

    companion object {
        const val ACTION_INSTALL_STATUS =
            "com.droidlab.app.action.INSTALL_STATUS"
        const val EXTRA_JOB_ID = "com.droidlab.app.extra.JOB_ID"
    }
}
