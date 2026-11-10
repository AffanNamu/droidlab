package com.droidlab.droidlab.installation

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.util.Log

/**
 * Receives the result of a PackageInstaller session. Pending user confirmation is
 * forwarded to Android's installer UI; final status is persisted for the app UI.
 */
class InstallStatusReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val jobId = intent.getStringExtra(PackageInstallCoordinator.EXTRA_JOB_ID)
            ?: "unknown"
        val status = intent.getIntExtra(
            PackageInstaller.EXTRA_STATUS,
            PackageInstaller.STATUS_FAILURE
        )
        val message = intent.getStringExtra(
            PackageInstaller.EXTRA_STATUS_MESSAGE
        ).orEmpty()

        if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            val confirmationIntent = getConfirmationIntent(intent)
            if (confirmationIntent != null) {
                confirmationIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                runCatching { context.startActivity(confirmationIntent) }
                    .onFailure { error ->
                        Log.e(TAG, "Could not open Android install confirmation", error)
                        persistResult(context, jobId, status, message)
                    }
            } else {
                persistResult(context, jobId, status, message)
            }
            return
        }

        persistResult(context, jobId, status, message)
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
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_JOB_ID, jobId)
            .putInt(KEY_STATUS, status)
            .putString(KEY_MESSAGE, message)
            .putLong(KEY_UPDATED_AT, System.currentTimeMillis())
            .apply()
    }

    companion object {
        private const val TAG = "DroidLabInstaller"
        private const val PREFERENCES = "droidlab_install_status"
        private const val KEY_JOB_ID = "job_id"
        private const val KEY_STATUS = "status"
        private const val KEY_MESSAGE = "message"
        private const val KEY_UPDATED_AT = "updated_at"
    }
}
