import 'package:flutter/material.dart';

import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({
    required this.projectId,
    required this.projectName,
    required this.relativePath,
    super.key,
  });

  final String projectId;
  final String projectName;
  final String relativePath;

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final DroidLabHostApi _api = DroidLabHostApi();
  final TextEditingController _controller = TextEditingController();
  late Future<String> _fileFuture;
  bool _loaded = false;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fileFuture = _api.readWorkspaceFile(
      widget.projectId,
      widget.relativePath,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_loaded || !_dirty || _saving) return;
    setState(() => _saving = true);
    try {
      await _api.writeWorkspaceFile(
        widget.projectId,
        widget.relativePath,
        _controller.text,
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File saved to the project workspace.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save file: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'Your edits have not been saved to the project workspace.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.relativePath.split('/').last;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.projectName,
                style: const TextStyle(
                  color: DroidLabColors.mutedText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Save',
              onPressed: _dirty && !_saving ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
            ),
          ],
        ),
        body: FutureBuilder<String>(
          future: _fileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not open file: ${snapshot.error}'),
                ),
              );
            }
            if (!_loaded) {
              _controller.text = snapshot.data ?? '';
              _loaded = true;
            }
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: DroidLabColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.code_rounded,
                        color: DroidLabColors.cyan,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.relativePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DroidLabColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        _dirty ? 'UNSAVED' : 'SAVED',
                        style: TextStyle(
                          color: _dirty
                              ? DroidLabColors.purple
                              : DroidLabColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.55,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Start editing...',
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) {
                      if (!_dirty) setState(() => _dirty = true);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
