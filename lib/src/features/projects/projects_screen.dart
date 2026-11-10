import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DroidLabPageHeader(
              title: 'Projects',
              subtitle: 'Your imported APKs and Android source projects',
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: EmptyStatePanel(
                    icon: Icons.folder_open_rounded,
                    title: 'No projects yet',
                    description:
                        'Imported applications and source projects will appear here. Your originals stay in the private DroidLab workspace.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
