import 'package:flutter/material.dart';

import '../../platform/droidlab_api.g.dart';
import '../../theme/droidlab_theme.dart';

class EngineStatusCard extends StatefulWidget {
  const EngineStatusCard({super.key});

  @override
  State<EngineStatusCard> createState() => _EngineStatusCardState();
}

class _EngineStatusCardState extends State<EngineStatusCard> {
  late Future<List<EngineCapabilityDto>> _capabilitiesFuture;

  @override
  void initState() {
    super.initState();
    _capabilitiesFuture = DroidLabHostApi().getEngineCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EngineCapabilityDto>>(
      future: _capabilitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StatusContainer(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Checking device capabilities...'),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return const _StatusContainer(
            child: Text(
              'Engine status is unavailable. Check the Android platform bridge.',
              style: TextStyle(color: DroidLabColors.mutedText),
            ),
          );
        }

        final capabilities = snapshot.data ?? <EngineCapabilityDto>[];
        if (capabilities.isEmpty) {
          return const _StatusContainer(
            child: Text(
              'No engine capabilities were reported by this device.',
              style: TextStyle(color: DroidLabColors.mutedText),
            ),
          );
        }

        return _StatusContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final capability in capabilities)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _iconForState(capability.state),
                        color: _colorForState(capability.state),
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              capability.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (capability.detail != null)
                              Text(
                                capability.detail!,
                                style: const TextStyle(
                                  color: DroidLabColors.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        capability.state.toUpperCase(),
                        style: TextStyle(
                          color: _colorForState(capability.state),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static IconData _iconForState(String state) {
    return switch (state) {
      'ready' => Icons.check_circle_rounded,
      'experimental' => Icons.science_rounded,
      'unsupported' => Icons.block_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  static Color _colorForState(String state) {
    return switch (state) {
      'ready' => DroidLabColors.success,
      'experimental' => DroidLabColors.purple,
      'unsupported' => DroidLabColors.error,
      _ => DroidLabColors.mutedText,
    };
  }
}

class _StatusContainer extends StatelessWidget {
  const _StatusContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidLabColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DroidLabColors.elevated),
      ),
      child: child,
    );
  }
}
