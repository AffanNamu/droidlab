import 'package:flutter/material.dart';

import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({required this.project, super.key});

  final ProjectSummaryDto project;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Future<ApkAnalysisDto> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = DroidLabHostApi().inspectApk(
      widget.project.baseApkPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<ApkAnalysisDto>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('APK inspection failed: ${snapshot.error}'),
              ),
            );
          }

          final analysis = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: DroidLabColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DroidLabColors.elevated),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      analysis.applicationName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      analysis.packageName,
                      style: const TextStyle(
                        color: DroidLabColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _InfoPill('Version ${analysis.versionName ?? '—'}'),
                        _InfoPill('Min API ${analysis.minSdk}'),
                        _InfoPill('Target API ${analysis.targetSdk}'),
                        _InfoPill(_formatSize(analysis.fileSizeBytes)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Section(
                title: 'Package structure',
                children: <Widget>[
                  _DetailRow('DEX files', analysis.dexFiles.length.toString()),
                  _DetailRow(
                    'Native libraries',
                    analysis.nativeLibraries.length.toString(),
                  ),
                  _DetailRow(
                    'Assets',
                    analysis.assetFiles.length.toString(),
                  ),
                  _DetailRow(
                    'Android manifest',
                    analysis.hasManifest ? 'Present' : 'Missing',
                  ),
                  _DetailRow(
                    'Resources table',
                    analysis.hasResourcesTable ? 'Present' : 'Missing',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Requested permissions',
                children: analysis.requestedPermissions.isEmpty
                    ? const <Widget>[
                        Text(
                          'No requested permissions were reported.',
                          style: TextStyle(color: DroidLabColors.mutedText),
                        ),
                      ]
                    : analysis.requestedPermissions
                        .map((permission) => _BulletRow(permission))
                        .toList(),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'DEX files',
                children: analysis.dexFiles.isEmpty
                    ? const <Widget>[
                        Text(
                          'No DEX files found.',
                          style: TextStyle(color: DroidLabColors.mutedText),
                        ),
                      ]
                    : analysis.dexFiles
                        .map((file) => _BulletRow(file))
                        .toList(),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Signing information',
                children: <Widget>[
                  Text(
                    analysis.signatureStatus,
                    style: const TextStyle(color: DroidLabColors.mutedText),
                  ),
                  if (analysis.signingCertificateSha256.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final fingerprint
                        in analysis.signingCertificateSha256)
                      SelectableText(
                        fingerprint,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Inspection reads APK metadata and archive entries. It does not yet perform full apksig verification or decode the application.',
                style: TextStyle(
                  color: DroidLabColors.mutedText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          );
        },
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidLabColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DroidLabColors.elevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: DroidLabColors.mutedText),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('• ', style: TextStyle(color: DroidLabColors.cyan)),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DroidLabColors.elevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
