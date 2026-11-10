import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../../theme/droidlab_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<_SettingInfo> _settings = <_SettingInfo>[
    _SettingInfo(Icons.folder_outlined, 'Workspace', 'Project storage and cleanup'),
    _SettingInfo(Icons.memory_rounded, 'Engines & Tools', 'JADX, Apktool and build tools'),
    _SettingInfo(Icons.key_outlined, 'Build & Signing', 'Build options and signing keys'),
    _SettingInfo(Icons.code_rounded, 'Editor', 'Font, indentation and code preferences'),
    _SettingInfo(Icons.palette_outlined, 'Appearance', 'Theme and accent color'),
    _SettingInfo(Icons.speed_rounded, 'Performance', 'Memory and processing limits'),
    _SettingInfo(Icons.shield_outlined, 'Security & Privacy', 'File safety and data controls'),
    _SettingInfo(Icons.backup_outlined, 'Backups & Restore', 'Back up projects and settings'),
    _SettingInfo(Icons.info_outline_rounded, 'About', 'Version, licenses and changelog'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          const DroidLabPageHeader(
            title: 'Settings',
            subtitle: 'Configure DroidLab, engines, builds and your workspace',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: DroidLabColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DroidLabColors.elevated),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.code_rounded, color: DroidLabColors.cyan, size: 34),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('DroidLab', style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Android Engineering Studio · 0.1.0', style: TextStyle(color: DroidLabColors.mutedText, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.offline_bolt_outlined, color: DroidLabColors.success),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final setting in _settings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: ListTile(
                      tileColor: DroidLabColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: DroidLabColors.elevated),
                      ),
                      leading: Icon(setting.icon, color: DroidLabColors.cyan),
                      title: Text(
                        setting.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        setting.description,
                        style: const TextStyle(color: DroidLabColors.mutedText),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${setting.title} settings are not implemented yet.')),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingInfo {
  const _SettingInfo(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}
