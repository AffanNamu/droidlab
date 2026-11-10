import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tools/tools_screen.dart';
import '../features/workspace/workspace_screen.dart';
import '../theme/droidlab_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _projectsRefreshToken = 0;
  int _workspaceRefreshToken = 0;

  List<Widget> get _screens => <Widget>[
        const HomeScreen(),
        ProjectsScreen(key: ValueKey<int>(_projectsRefreshToken)),
        WorkspaceScreen(key: ValueKey<int>(_workspaceRefreshToken)),
        const ToolsScreen(),
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) _projectsRefreshToken++;
            if (index == 2) _workspaceRefreshToken++;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_rounded),
            label: 'Workspace',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DroidLabPageHeader extends StatelessWidget {
  const DroidLabPageHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.code_rounded,
                color: DroidLabColors.cyan,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text.rich(
                const TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Droid',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: 'Lab',
                      style: TextStyle(
                        color: DroidLabColors.cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const Icon(Icons.notifications_none_rounded),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DroidLabColors.mutedText,
                ),
          ),
        ],
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DroidLabColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DroidLabColors.elevated),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: DroidLabColors.cyan, size: 42),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DroidLabColors.mutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
