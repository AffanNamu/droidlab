enum CapabilityState {
  ready,
  missing,
  incompatible,
  experimental,
  unsupported,
}

class EngineCapability {
  const EngineCapability({
    required this.id,
    required this.displayName,
    required this.state,
    this.version,
    this.detail,
    this.detectedAbi,
  });

  final String id;
  final String displayName;
  final CapabilityState state;
  final String? version;
  final String? detail;
  final String? detectedAbi;

  bool get isUsable =>
      state == CapabilityState.ready ||
      state == CapabilityState.experimental;
}
