package com.droidlab.app.installation

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.util.Base64
import android.util.Log

data class InstallStatusSnapshot(
    val jobId: String,
    val statusCode: Int,
    val statusMessage: String,
    val updatedAtEpochMillis: Long
)

/**
 * Receives PackageInstaller results. Pending user confirmation is forwarded to
 * Android's installer UI; each job's final status is persisted for polling.
 */
class InstallStatusReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val jobId = intent.getStringExtra(PackageInstallCoordinator.EXTRA_JOB_ID)
            ?: return
        val status = intent.getIntExtra(
            PackageInstaller.EXTRA_STATUS,
            PackageInstaller.STATUS_FAILURE
        )
        val message = intent.getStringExtra(
            PackageInstaller.EXTRA_STATUS_MESSAGE
        ).orEmpty()

        persistResult(context, jobId, status, message)

        if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            val confirmationIntent = getConfirmationIntent(intent)
            if (confirmationIntent != null) {
                confirmationIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                runCatching { context.startActivity(confirmationIntent) }
                    .onFailure { error ->
                        Log.e(TAG, "Could not open Android install confirmation", error)
                    }
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun getConfirmationIntent(source: Intent): Intent? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            source.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
        } else {
            source.getParcelableExtra(Intent.EXTRA_INTENT)
        }
    }

    private fun persistResult(
        context: Context,
        jobId: String,
        status: Int,
        message: String
    ) {
        val prefix = keyPrefix(jobId)
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putInt("${prefix}status", status)
            .putString("${prefix}message", message)
            .putLong("${prefix}updated_at", System.currentTimeMillis())
            .apply()
    }

    companion object {
        private const val TAG = "DroidLabInstaller"
        private const val PREFERENCES = "droidlab_install_status"

        private fun keyPrefix(jobId: String): String {
            val encoded = Base64.encodeToString(
                jobId.toByteArray(Charsets.UTF_8),
                Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING
            )
            return "job_${encoded}_"
        }

        fun readStatus(
            context: Context,
            jobId: String
        ): InstallStatusSnapshot? {
            val preferences = context.getSharedPreferences(
                PREFERENCES,
                Context.MODE_PRIVATE
            )
            val prefix = keyPrefix(jobId)
            if (!preferences.contains("${prefix}status")) return null

            return InstallStatusSnapshot(
                jobId = jobId,
                statusCode = preferences.getInt(
                    "${prefix}status",
                    PackageInstaller.STATUS_FAILURE
                ),
                statusMessage = preferences.getString(
                    "${prefix}message",
                    ""
                ).orEmpty(),
                updatedAtEpochMillis = preferences.getLong(
                    "${prefix}updated_at",
                    0L
                )
            )
        }
    }
}
