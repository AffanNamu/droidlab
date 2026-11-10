import 'package:flutter/material.dart';

import '../../navigation/app_shell.dart';
import '../../theme/droidlab_theme.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const List<_ToolInfo> _tools = <_ToolInfo>[
    _ToolInfo(
      Icons.android_rounded,
      'APK Analyzer',
      'Inspect package metadata and archive structure',
      'In progress',
    ),
    _ToolInfo(
      Icons.data_object_rounded,
      'Decompiler',
      'Reconstruct code for browsing',
      'Not connected',
    ),
    _ToolInfo(
      Icons.layers_rounded,
      'Apktool',
      'Decode resources and Smali',
      'Not connected',
    ),
    _ToolInfo(
      Icons.description_outlined,
      'Manifest Editor',
      'Inspect and edit manifest entries',
      'Planned',
    ),
    _ToolInfo(
      Icons.code_rounded,
      'Smali Editor',
      'Edit DEX-level instructions',
      'Planned',
    ),
    _ToolInfo(
      Icons.palette_outlined,
      'Resource Editor',
      'Browse layouts and assets',
      'Planned',
    ),
    _ToolInfo(
      Icons.build_outlined,
      'Build & Compile',
      'Rebuild supported projects',
      'Not connected',
    ),
    _ToolInfo(
      Icons.key_rounded,
      'APK Signer',
      'Manage signing keys securely',
      'Not connected',
    ),
    _ToolInfo(
      Icons.verified_outlined,
      'APK Verifier',
      'Verify signatures and integrity',
      'Not connected',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          const DroidLabPageHeader(
            title: 'Tools',
            subtitle: 'Utilities for analyzing, editing and building Android apps',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) {
                final tool = _tools[index];
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: DroidLabColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DroidLabColors.elevated),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(tool.icon, color: DroidLabColors.cyan, size: 28),
                      const Spacer(),
                      Text(
                        tool.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tool.description,
                        style: const TextStyle(
                          color: DroidLabColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tool.status,
                        style: TextStyle(
                          color: tool.status == 'In progress'
                              ? DroidLabColors.cyan
                              : DroidLabColors.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolInfo {
  const _ToolInfo(this.icon, this.name, this.description, this.status);

  final IconData icon;
  final String name;
  final String description;
  final String status;
}
