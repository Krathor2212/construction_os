import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_worker_allocation_repository.dart';
import '../../domain/entities/worker_allocation.dart';
import '../../domain/repositories/worker_allocation_repository.dart';

final workerAllocationRepositoryProvider =
    Provider<WorkerAllocationRepository>((ref) {
  return MockWorkerAllocationRepository();
});

final workerAllocationsProvider =
    FutureProvider.family<
        List<WorkerAllocation>,
        String>(
  (ref, workerId) async {
    final repository = ref.watch(
      workerAllocationRepositoryProvider,
    );

    return repository.getAllocations(
      workerId: workerId,
    );
  },
);

final workerAllocationsByDateRangeProvider =
    FutureProvider.family<
        List<WorkerAllocation>,
        WorkerAllocationDateRange>(
  (ref, range) async {
    final repository = ref.watch(
      workerAllocationRepositoryProvider,
    );

    return repository.getAllocations(
      workerId: range.workerId,
      startDate: range.startDate,
      endDate: range.endDate,
    );
  },
);

final projectWorkerAllocationsProvider =
    FutureProvider.family<
        List<WorkerAllocation>,
        String>(
  (ref, projectId) async {
    final repository = ref.watch(
      workerAllocationRepositoryProvider,
    );

    return repository.getProjectAllocations(
      projectId,
    );
  },
);

final workerAllocationProvider =
    FutureProvider.family<
        WorkerAllocation,
        String>(
  (ref, allocationId) async {
    final repository = ref.watch(
      workerAllocationRepositoryProvider,
    );

    return repository.getAllocation(
      allocationId,
    );
  },
);

class WorkerAllocationDateRange {
  const WorkerAllocationDateRange({
    required this.workerId,
    this.startDate,
    this.endDate,
  });

  final String workerId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is WorkerAllocationDateRange &&
        other.workerId == workerId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
        workerId,
        startDate,
        endDate,
      );
}