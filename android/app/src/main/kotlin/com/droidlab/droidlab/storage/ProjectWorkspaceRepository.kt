package com.droidlab.droidlab.storage

import android.content.Context
import com.droidlab.droidlab.engine.ExtractedPackageFiles
import com.droidlab.droidlab.engine.InstalledAppSummary
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.security.MessageDigest

data class LocalProjectSummary(
    val projectId: String,
    val name: String,
    val kind: String,
    val packageName: String,
    val versionName: String?,
    val versionCode: Long,
    val importedAtEpochMillis: Long,
    val originalSizeBytes: Long,
    val splitCount: Int,
    val workspacePath: String
)

/**
 * Small on-disk project catalog used by the first foundation milestone.
 * Project metadata is isolated from immutable original APK bytes.
 */
class ProjectWorkspaceRepository(
    context: Context
) {
    private val projectsDirectory = File(context.filesDir, "projects")

    fun recordInstalledPackage(
        projectId: String,
        app: InstalledAppSummary,
        extracted: ExtractedPackageFiles,
        importedAtEpochMillis: Long = System.currentTimeMillis()
    ): LocalProjectSummary {
        val projectDirectory = safeProjectDirectory(projectId)
        val workspaceDirectory = File(projectDirectory, "workspace")
        val outputsDirectory = File(projectDirectory, "outputs")

        if (!workspaceDirectory.exists() && !workspaceDirectory.mkdirs()) {
            throw IOException("Could not create project workspace.")
        }
        if (!outputsDirectory.exists() && !outputsDirectory.mkdirs()) {
            throw IOException("Could not create project output directory.")
        }

        val totalBytes = extracted.allFiles.sumOf(File::length)
        val metadata = JSONObject()
            .put("projectId", projectId)
            .put("name", app.label)
            .put("kind", "installed_apk")
            .put("packageName", app.packageName)
            .put("versionName", app.versionName ?: JSONObject.NULL)
            .put("versionCode", app.versionCode)
            .put("importedAtEpochMillis", importedAtEpochMillis)
            .put("originalSizeBytes", totalBytes)
            .put("splitCount", extracted.splitApks.size)
            .put("workspacePath", workspaceDirectory.absolutePath)
            .put("originalBaseSha256", sha256(extracted.baseApk))
            .put("originalSplitSha256", extracted.splitApks.map(::sha256))

        val metadataFile = File(projectDirectory, "project.json")
        val temporaryFile = File(projectDirectory, "project.json.tmp")
        temporaryFile.writeText(metadata.toString(2))
        if (!temporaryFile.renameTo(metadataFile)) {
            temporaryFile.delete()
            throw IOException("Could not save project metadata.")
        }

        return LocalProjectSummary(
            projectId = projectId,
            name = app.label,
            kind = "installed_apk",
            packageName = app.packageName,
            versionName = app.versionName,
            versionCode = app.versionCode,
            importedAtEpochMillis = importedAtEpochMillis,
            originalSizeBytes = totalBytes,
            splitCount = extracted.splitApks.size,
            workspacePath = workspaceDirectory.absolutePath
        )
    }

    fun listProjects(): List<LocalProjectSummary> {
        if (!projectsDirectory.exists()) return emptyList()
        return projectsDirectory.listFiles()
            .orEmpty()
            .asSequence()
            .filter(File::isDirectory)
            .mapNotNull { directory ->
                val metadataFile = File(directory, "project.json")
                if (!metadataFile.isFile) return@mapNotNull null
                runCatching {
                    val json = JSONObject(metadataFile.readText())
                    LocalProjectSummary(
                        projectId = json.getString("projectId"),
                        name = json.getString("name"),
                        kind = json.getString("kind"),
                        packageName = json.getString("packageName"),
                        versionName = if (json.isNull("versionName")) {
                            null
                        } else {
                            json.getString("versionName")
                        },
                        versionCode = json.getLong("versionCode"),
                        importedAtEpochMillis = json.getLong("importedAtEpochMillis"),
                        originalSizeBytes = json.getLong("originalSizeBytes"),
                        splitCount = json.getInt("splitCount"),
                        workspacePath = json.getString("workspacePath")
                    )
                }.getOrNull()
            }
            .sortedByDescending(LocalProjectSummary::importedAtEpochMillis)
            .toList()
    }

    private fun safeProjectDirectory(projectId: String): File {
        require(projectId.matches(Regex("[a-fA-F0-9-]{36}"))) {
            "Invalid project identifier."
        }
        val root = projectsDirectory.canonicalFile
        val directory = File(root, projectId).canonicalFile
        require(directory.path.startsWith(root.path + File.separator)) {
            "Project path escapes the workspace."
        }
        if (!directory.exists() && !directory.mkdirs()) {
            throw IOException("Could not create project directory.")
        }
        return directory
    }

    private fun sha256(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input ->
            val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
            while (true) {
                val count = input.read(buffer)
                if (count <= 0) break
                digest.update(buffer, 0, count)
            }
        }
        return digest.digest().joinToString("") { byte ->
            "%02x".format(byte)
        }
    }
}
