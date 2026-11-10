import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final DroidLabHostApi _api = DroidLabHostApi();
  late Future<List<ProjectSummaryDto>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _api.listProjects();
  }

  void _refresh() {
    setState(() => _projectsFuture = _api.listProjects());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: DroidLabPageHeader(
                  title: 'Projects',
                  subtitle: 'Your imported APKs and Android source projects',
                ),
              ),
              IconButton(
                tooltip: 'Refresh projects',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 10),
            ],
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not load projects: ${snapshot.error}'),
                    ),
                  );
                }
                final projects = snapshot.data ?? <ProjectSummaryDto>[];
                if (projects.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: EmptyStatePanel(
                        icon: Icons.folder_open_rounded,
                        title: 'No projects yet',
                        description:
                            'Imported applications and source projects will appear here. Your original APKs stay separate from editable workspace files.',
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Material(
                      color: DroidLabColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ProjectDetailsScreen(project: project),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: DroidLabColors.elevated),
                          ),
                          child: Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: DroidLabColors.elevated,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.android_rounded,
                              color: DroidLabColors.cyan,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  project.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  project.packageName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: DroidLabColors.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'v${project.versionName ?? '—'} · '
                                  '${_formatSize(project.originalSizeBytes)}'
                                  '${project.splitCount > 0 ? ' · ${project.splitCount} splits' : ''}',
                                  style: const TextStyle(
                                    color: DroidLabColors.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: DroidLabColors.mutedText,
                          ),
                        ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
