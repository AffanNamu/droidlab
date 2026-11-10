import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';

class ImportApkScreen extends StatefulWidget {
  const ImportApkScreen({super.key});

  @override
  State<ImportApkScreen> createState() => _ImportApkScreenState();
}

class _ImportApkScreenState extends State<ImportApkScreen> {
  final DroidLabHostApi _api = DroidLabHostApi();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<InstalledAppDto>> _appsFuture;
  final Set<String> _selectedPackages = <String>{};
  int _selectedTab = 0;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _appsFuture = _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<InstalledAppDto>> _loadApps() {
    if (_selectedTab == 2) {
      return Future<List<InstalledAppDto>>.value(<InstalledAppDto>[]);
    }
    return _api.listInstalledApps(_selectedTab == 0 ? 'user' : 'system');
  }

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
      _selectedPackages.clear();
      _appsFuture = _loadApps();
    });
  }

  Future<void> _pickApkFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['apk'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The selected APK file could not be accessed.')),
      );
      return;
    }

    setState(() => _isImporting = true);
    try {
      final imported = await _api.importApkFile(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported ${imported.packageName} into Projects.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('APK import failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _importSelected() async {
    if (_selectedPackages.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);

    var imported = 0;
    try {
      for (final packageName in _selectedPackages.toList()) {
        await _api.extractInstalledApp(packageName);
        imported++;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported $imported application(s) into the private workspace.',
          ),
        ),
      );
      setState(() {
        _selectedPackages.clear();
        _appsFuture = _loadApps();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Import APK'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(() => _appsFuture = _loadApps()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Select an application',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Choose an installed app or import an APK file into your private workspace.',
                    style: TextStyle(color: DroidLabColors.mutedText),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(
                        value: 0,
                        label: Text('Installed'),
                        icon: Icon(Icons.download_rounded),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text('System'),
                        icon: Icon(Icons.settings_rounded),
                      ),
                      ButtonSegment<int>(
                        value: 2,
                        label: Text('APK Files'),
                        icon: Icon(Icons.folder_outlined),
                      ),
                    ],
                    selected: <int>{_selectedTab},
                    onSelectionChanged: (selection) =>
                        _changeTab(selection.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search app name or package ID',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildAppList()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedTab == 2 && !_isImporting
                    ? _pickApkFile
                    : null,
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('Import from File'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _selectedPackages.isEmpty || _isImporting
                    ? null
                    : _importSelected,
                child: _isImporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Import (${_selectedPackages.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppList() {
    if (_selectedTab == 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'APK, APKS and XAPK file browsing will be connected to Android Storage Access Framework.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DroidLabColors.mutedText),
          ),
        ),
      );
    }

    return FutureBuilder<List<InstalledAppDto>>(
      future: _appsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not read installed applications. ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final query = _searchController.text.trim().toLowerCase();
        final apps = (snapshot.data ?? <InstalledAppDto>[]).where((app) {
          return app.label.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query);
        }).toList();

        if (apps.isEmpty) {
          return const Center(
            child: Text(
              'No matching applications found.',
              style: TextStyle(color: DroidLabColors.mutedText),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          itemCount: apps.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: DroidLabColors.elevated),
          itemBuilder: (context, index) {
            final app = apps[index];
            final selected = _selectedPackages.contains(app.packageName);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 5,
              ),
              leading: _AppIcon(iconBytes: app.iconPng),
              title: Text(
                app.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    app.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'v${app.versionName ?? '—'}  ·  ${_formatSize(app.apkSizeBytes)}'
                    '${app.splitCount > 0 ? '  ·  ${app.splitCount} splits' : ''}'
                    '${app.isUpdatedSystemApp ? '  ·  Updated system app' : ''}',
                    style: const TextStyle(
                      color: DroidLabColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              trailing: Checkbox(
                value: selected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedPackages.add(app.packageName);
                    } else {
                      _selectedPackages.remove(app.packageName);
                    }
                  });
                },
              ),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedPackages.remove(app.packageName);
                  } else {
                    _selectedPackages.add(app.packageName);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  static String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({this.iconBytes});

  final Uint8List? iconBytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: iconBytes == null
            ? const ColoredBox(
                color: DroidLabColors.elevated,
                child: Icon(
                  Icons.android_rounded,
                  color: DroidLabColors.cyan,
                ),
              )
            : Image.memory(iconBytes!, fit: BoxFit.cover),
      ),
    );
  }
}
