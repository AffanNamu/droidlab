import 'package:droidlab/src/domain/jobs/job_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JobStatus transitions', () {
    test('allows a job to move from queued to running to succeeded', () {
      expect(
        JobStatus.queued.transitionTo(JobStatus.validating),
        JobStatus.validating,
      );
      expect(
        JobStatus.running.transitionTo(JobStatus.succeeded),
        JobStatus.succeeded,
      );
    });

    test('allows cancellation before completion', () {
      expect(
        JobStatus.queued.transitionTo(JobStatus.cancelled),
        JobStatus.cancelled,
      );
      expect(
        JobStatus.running.transitionTo(JobStatus.cancelled),
        JobStatus.cancelled,
      );
    });

    test('rejects impossible transitions', () {
      expect(
        () => JobStatus.queued.transitionTo(JobStatus.succeeded),
        throwsStateError,
      );
      expect(
        () => JobStatus.succeeded.transitionTo(JobStatus.running),
        throwsStateError,
      );
    });

    test('marks only final states as terminal', () {
      expect(JobStatus.queued.isTerminal, isFalse);
      expect(JobStatus.running.isTerminal, isFalse);
      expect(JobStatus.succeeded.isTerminal, isTrue);
      expect(JobStatus.failed.isTerminal, isTrue);
      expect(JobStatus.cancelled.isTerminal, isTrue);
    });
  });

  group('JobSnapshot', () {
    test('preserves identity and records progress on transition', () {
      final createdAt = DateTime.utc(2026, 11, 10);
      final job = JobSnapshot(
        id: 'job-1',
        kind: 'apk-import',
        status: JobStatus.queued,
        createdAt: createdAt,
      );

      final next = job.transitionTo(
        JobStatus.validating,
        at: createdAt.add(const Duration(seconds: 1)),
        nextProgress: 0.25,
        nextMessage: 'Checking archive',
      );

      expect(next.id, 'job-1');
      expect(next.kind, 'apk-import');
      expect(next.status, JobStatus.validating);
      expect(next.progress, 0.25);
      expect(next.message, 'Checking archive');
      expect(job.status, JobStatus.queued);
    });

    test('rejects progress outside zero to one', () {
      final job = JobSnapshot(
        id: 'job-2',
        kind: 'apk-build',
        status: JobStatus.queued,
        createdAt: DateTime.utc(2026, 11, 10),
      );

      expect(
        () => job.transitionTo(
          JobStatus.validating,
          nextProgress: 1.5,
        ),
        throwsRangeError,
      );
    });
  });
}
