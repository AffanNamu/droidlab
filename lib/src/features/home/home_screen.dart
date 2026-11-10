import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../../theme/droidlab_theme.dart';
import '../importer/import_apk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          const DroidLabPageHeader(
            title: 'Home',
            subtitle: 'Your Android application engineering studio',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color(0xFF10243B),
                        Color(0xFF171B3A),
                      ],
                    ),
                    border: Border.all(
                      color: DroidLabColors.cyan.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Import. Inspect. Edit. Build.',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Work with APKs and Android source projects in your private workspace.',
                              style: TextStyle(
                                color: DroidLabColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.android_rounded,
                        size: 48,
                        color: DroidLabColors.cyan,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.install_mobile_rounded,
                        title: 'Import APK',
                        subtitle: 'Inspect an app',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ImportApkScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.folder_zip_rounded,
                        title: 'Import Project',
                        subtitle: 'Open source files',
                        onTap: () => _showNotReady(context, 'Project import'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  'Quick tools',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _ToolChip(
                      icon: Icons.code_rounded,
                      label: 'Code Editor',
                    ),
                    _ToolChip(
                      icon: Icons.analytics_outlined,
                      label: 'APK Analyzer',
                    ),
                    _ToolChip(
                      icon: Icons.build_outlined,
                      label: 'Build & Sign',
                    ),
                    _ToolChip(
                      icon: Icons.verified_outlined,
                      label: 'Verify APK',
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  'Engine status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                const EmptyStatePanel(
                  icon: Icons.memory_rounded,
                  title: 'Native engine foundation',
                  description:
                      'Engine readiness will be detected from this device. No tools are marked ready until verified.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showNotReady(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is not available in this foundation build.'),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DroidLabColors.elevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: DroidLabColors.cyan, size: 28),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DroidLabColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: DroidLabColors.cyan),
      label: Text(label),
      backgroundColor: DroidLabColors.surface,
      side: BorderSide.none,
    );
  }
}
