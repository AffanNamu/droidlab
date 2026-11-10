import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';
import '../editor/code_editor_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final DroidLabHostApi _api = DroidLabHostApi();
  late Future<List<ProjectSummaryDto>> _projectsFuture;
  Future<List<WorkspaceFileDto>>? _filesFuture;
  List<ProjectSummaryDto> _projects = <ProjectSummaryDto>[];
  String? _selectedProjectId;
  String _currentDirectory = '';

  @override
  void initState() {
    super.initState();
    _projectsFuture = _api.listProjects();
  }

  void _selectProject(String? projectId) {
    setState(() {
      _selectedProjectId = projectId;
      _currentDirectory = '';
      _filesFuture = projectId == null
          ? null
          : _api.listWorkspaceFiles(projectId, '');
    });
  }

  void _openDirectory(WorkspaceFileDto file) {
    setState(() {
      _currentDirectory = file.relativePath;
      _filesFuture = _api.listWorkspaceFiles(
        _selectedProjectId!,
        _currentDirectory,
      );
    });
  }

  void _goUp() {
    if (_currentDirectory.isEmpty) return;
    final segments = _currentDirectory.split('/');
    segments.removeLast();
    setState(() {
      _currentDirectory = segments.join('/');
      _filesFuture = _api.listWorkspaceFiles(
        _selectedProjectId!,
        _currentDirectory,
      );
    });
  }

  Future<void> _openFile(WorkspaceFileDto file) async {
    final matches = _projects.where(
      (item) => item.projectId == _selectedProjectId,
    );
    if (matches.isEmpty) return;
    final project = matches.first;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CodeEditorScreen(
          projectId: project.projectId,
          projectName: project.name,
          relativePath: file.relativePath,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _filesFuture = _api.listWorkspaceFiles(
        _selectedProjectId!,
        _currentDirectory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DroidLabPageHeader(
            title: 'Workspace',
            subtitle: 'Browse and edit files from an opened project',
          ),
          Expanded(
            child: FutureBuilder<List<ProjectSummaryDto>>(
              future: _projectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load projects: ${snapshot.error}'),
                  );
                }

                _projects = snapshot.data ?? <ProjectSummaryDto>[];
                if (_projects.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: EmptyStatePanel(
                        icon: Icons.code_rounded,
                        title: 'Workspace is empty',
                        description:
                            'Import an APK or Android source project. Editable files will appear here after the project has been prepared.',
                      ),
                    ),
                  );
                }

                _selectedProjectId ??= _projects.first.projectId;
                _filesFuture ??= _api.listWorkspaceFiles(
                  _selectedProjectId!,
                  _currentDirectory,
                );

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedProjectId,
                        decoration: const InputDecoration(
                          labelText: 'Active project',
                          prefixIcon: Icon(Icons.folder_open_rounded),
                        ),
                        items: _projects.map((project) {
                          return DropdownMenuItem<String>(
                            value: project.projectId,
                            child: Text(
                              project.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _selectProject,
                      ),
                    ),
                    if (_currentDirectory.isNotEmpty)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.arrow_upward_rounded),
                        title: const Text('Parent folder'),
                        subtitle: Text(_currentDirectory),
                        onTap: _goUp,
                      ),
                    Expanded(
                      child: FutureBuilder<List<WorkspaceFileDto>>(
                        future: _filesFuture,
                        builder: (context, filesSnapshot) {
                          if (filesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (filesSnapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Could not read workspace: ${filesSnapshot.error}',
                                ),
                              ),
                            );
                          }

                          final files =
                              filesSnapshot.data ?? <WorkspaceFileDto>[];
                          if (files.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(18),
                              child: Center(
                                child: EmptyStatePanel(
                                  icon: Icons.folder_open_rounded,
                                  title: 'No editable files yet',
                                  description:
                                      'Original APK files are protected separately. Decode or prepare the project to create editable workspace files.',
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                            itemCount: files.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: DroidLabColors.elevated,
                            ),
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return ListTile(
                                leading: Icon(
                                  file.isDirectory
                                      ? Icons.folder_rounded
                                      : _iconForExtension(file.extension),
                                  color: file.isDirectory
                                      ? DroidLabColors.cyan
                                      : DroidLabColors.mutedText,
                                ),
                                title: Text(
                                  file.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: file.isDirectory
                                    ? const Text('Folder')
                                    : Text(
                                        '${file.extension.toUpperCase()} · '
                                        '${_formatSize(file.sizeBytes)}',
                                      ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () {
                                  if (file.isDirectory) {
                                    _openDirectory(file);
                                  } else if (_isTextExtension(file.extension)) {
                                    _openFile(file);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'This file type is not editable in the text editor.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static bool _isTextExtension(String extension) {
    return const <String>{
      'java',
      'kt',
      'kts',
      'dart',
      'smali',
      'xml',
      'json',
      'yaml',
      'yml',
      'gradle',
      'properties',
      'txt',
      'md',
      'pro',
      'html',
      'css',
      'js',
    }.contains(extension);
  }

  static IconData _iconForExtension(String extension) {
    return switch (extension) {
      'java' || 'kt' || 'dart' || 'smali' => Icons.code_rounded,
      'xml' || 'json' || 'yaml' || 'yml' => Icons.data_object_rounded,
      'gradle' || 'kts' || 'properties' => Icons.settings_suggest_rounded,
      'png' || 'jpg' || 'webp' => Icons.image_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }
}
