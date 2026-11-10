enum JobStatus {
  queued,
  validating,
  running,
  succeeded,
  failed,
  cancelled;

  bool get isTerminal =>
      this == JobStatus.succeeded ||
      this == JobStatus.failed ||
      this == JobStatus.cancelled;

  bool canTransitionTo(JobStatus next) {
    return switch (this) {
      JobStatus.queued =>
        next == JobStatus.validating || next == JobStatus.cancelled,
      JobStatus.validating =>
        next == JobStatus.running ||
            next == JobStatus.failed ||
            next == JobStatus.cancelled,
      JobStatus.running =>
        next == JobStatus.succeeded ||
            next == JobStatus.failed ||
            next == JobStatus.cancelled,
      JobStatus.succeeded || JobStatus.failed || JobStatus.cancelled => false,
    };
  }

  JobStatus transitionTo(JobStatus next) {
    if (!canTransitionTo(next)) {
      throw StateError('Invalid job transition: $name -> ${next.name}');
    }
    return next;
  }
}

class JobSnapshot {
  const JobSnapshot({
    required this.id,
    required this.kind,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.progress,
    this.message,
    this.errorCode,
  });

  final String id;
  final String kind;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? progress;
  final String? message;
  final String? errorCode;

  JobSnapshot transitionTo(
    JobStatus next, {
    DateTime? at,
    double? nextProgress,
    String? nextMessage,
    String? nextErrorCode,
  }) {
    status.transitionTo(next);
    if (nextProgress != null &&
        (nextProgress < 0 || nextProgress > 1)) {
      throw RangeError.range(nextProgress, 0, 1, 'nextProgress');
    }
    return JobSnapshot(
      id: id,
      kind: kind,
      status: next,
      createdAt: createdAt,
      updatedAt: at ?? DateTime.now(),
      progress: nextProgress ?? progress,
      message: nextMessage ?? message,
      errorCode: nextErrorCode,
    );
  }
}
