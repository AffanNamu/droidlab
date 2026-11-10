package com.droidlab.droidlab.storage

import android.content.Context
import com.droidlab.droidlab.engine.ExtractedPackageFiles
import com.droidlab.droidlab.engine.InstalledAppSummary
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.nio.file.Files
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

data class LocalWorkspaceFile(
    val name: String,
    val relativePath: String,
    val isDirectory: Boolean,
    val sizeBytes: Long,
    val extension: String
)

/**
 * Local project catalog and guarded workspace file access.
 * The original APK directory is never exposed through editor file APIs.
 */
class ProjectWorkspaceRepository(
    context: Context
) {
    private val projectsDirectory = File(context.filesDir, "projects")

    fun recordInstalledPackage(
        projectId: String,
        app: InstalledAppSummary,
        extracted: ExtractedPackageFiles,
        kind: String = "installed_apk",
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
            .put("kind", kind)
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
            kind = kind,
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

    fun listWorkspaceFiles(
        projectId: String,
        relativeDirectory: String
    ): List<LocalWorkspaceFile> {
        val workspaceRoot = workspaceRoot(projectId)
        val directory = resolveWorkspacePath(
            workspaceRoot,
            relativeDirectory,
            allowRoot = true
        )
        if (!directory.isDirectory) {
            throw IllegalArgumentException("Workspace directory does not exist.")
        }

        return directory.listFiles()
            .orEmpty()
            .asSequence()
            .filterNot { Files.isSymbolicLink(it.toPath()) }
            .filter { isInside(workspaceRoot, it.canonicalFile) }
            .map { file ->
                val relative = workspaceRoot.toPath()
                    .relativize(file.canonicalFile.toPath())
                    .toString()
                    .replace(File.separatorChar, '/')
                LocalWorkspaceFile(
                    name = file.name,
                    relativePath = relative,
                    isDirectory = file.isDirectory,
                    sizeBytes = if (file.isFile) file.length() else 0L,
                    extension = if (file.isFile) {
                        file.extension.lowercase()
                    } else {
                        ""
                    }
                )
            }
            .sortedWith(
                compareBy<LocalWorkspaceFile> { !it.isDirectory }
                    .thenBy { it.name.lowercase() }
            )
            .toList()
    }

    fun readWorkspaceFile(
        projectId: String,
        relativePath: String
    ): String {
        val root = workspaceRoot(projectId)
        val file = resolveWorkspacePath(root, relativePath)
        if (!file.isFile || Files.isSymbolicLink(file.toPath())) {
            throw IllegalArgumentException("The selected workspace file is not a regular file.")
        }
        if (!isTextFile(file)) {
            throw IllegalArgumentException("This file type is not supported by the text editor.")
        }
        if (file.length() > MAX_TEXT_FILE_BYTES) {
            throw IllegalArgumentException("File exceeds the 2 MB editor limit.")
        }
        return file.readText(Charsets.UTF_8)
    }

    fun writeWorkspaceFile(
        projectId: String,
        relativePath: String,
        contents: String
    ) {
        val root = workspaceRoot(projectId)
        val file = resolveWorkspacePath(root, relativePath)
        if (!file.isFile || Files.isSymbolicLink(file.toPath())) {
            throw IllegalArgumentException("Only existing regular workspace files can be edited.")
        }
        if (!isTextFile(file)) {
            throw IllegalArgumentException("This file type is not supported by the text editor.")
        }
        val bytes = contents.toByteArray(Charsets.UTF_8)
        if (bytes.size > MAX_TEXT_FILE_BYTES) {
            throw IllegalArgumentException("Edited file exceeds the 2 MB editor limit.")
        }

        val projectDirectory = safeProjectDirectory(projectId)
        val checkpointRoot = File(projectDirectory, "checkpoints")
        val checkpoint = File(
            checkpointRoot,
            "${relativePath}.${System.currentTimeMillis()}.bak"
        )
        if (!checkpoint.parentFile!!.exists() && !checkpoint.parentFile!!.mkdirs()) {
            throw IOException("Could not create a file checkpoint.")
        }
        file.copyTo(checkpoint, overwrite = false)

        val temporary = File(file.parentFile, "${file.name}.droidlab.tmp")
        temporary.writeBytes(bytes)
        if (!temporary.renameTo(file)) {
            temporary.delete()
            throw IOException("Could not save workspace file.")
        }
    }

    private fun workspaceRoot(projectId: String): File {
        val project = safeProjectDirectory(projectId)
        val root = File(project, "workspace").canonicalFile
        if (!root.exists() || !root.isDirectory) {
            throw IllegalArgumentException("Project workspace is not available.")
        }
        return root
    }

    private fun resolveWorkspacePath(
        root: File,
        relativePath: String,
        allowRoot: Boolean = false
    ): File {
        if (relativePath.isBlank()) {
            if (allowRoot) return root
            throw IllegalArgumentException("A workspace file path is required.")
        }
        require(!relativePath.startsWith("/") && !relativePath.contains('\\')) {
            "Workspace paths must be relative."
        }
        val segments = relativePath.split('/')
        require(segments.none { it.isBlank() || it == "." || it == ".." }) {
            "Invalid workspace path."
        }
        val candidate = File(root, relativePath).canonicalFile
        require(isInside(root, candidate)) {
            "Workspace path escapes the project directory."
        }
        return candidate
    }

    private fun isInside(root: File, candidate: File): Boolean {
        return candidate.path.startsWith(root.path + File.separator)
    }

    private fun isTextFile(file: File): Boolean {
        return file.extension.lowercase() in TEXT_EXTENSIONS
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

    companion object {
        private const val MAX_TEXT_FILE_BYTES = 2 * 1024 * 1024
        private val TEXT_EXTENSIONS = setOf(
            "java",
            "kt",
            "kts",
            "xml",
            "smali",
            "gradle",
            "properties",
            "json",
            "txt",
            "yml",
            "yaml",
            "md",
            "pro",
            "html",
            "css",
            "js",
            "dart"
        )
    }
}
