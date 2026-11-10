import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DroidLabPageHeader(
              title: 'Workspace',
              subtitle: 'Browse and edit files from an opened project',
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: EmptyStatePanel(
                    icon: Icons.code_rounded,
                    title: 'Workspace is empty',
                    description:
                        'Open a project to browse source files, resources, manifests and Smali. The mobile editor will open here.',
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
