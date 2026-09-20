import '../../domain/entities/worker_allocation.dart';
import '../../domain/repositories/worker_allocation_repository.dart';

class MockWorkerAllocationRepository
    implements WorkerAllocationRepository {
  final List<WorkerAllocation> _allocations = [
    WorkerAllocation(
      id: 'worker-allocation-001',
      workerId: 'worker-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 20),
      workDescription: 'Foundation masonry work',
      plannedHours: 8,
      notes: 'Focus on north-side foundation wall.',
    ),
    WorkerAllocation(
      id: 'worker-allocation-002',
      workerId: 'worker-002',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 20),
      workDescription: 'Assist foundation masonry',
      plannedHours: 8,
      notes: 'Material handling and site support.',
    ),
    WorkerAllocation(
      id: 'worker-allocation-003',
      workerId: 'worker-003',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 20),
      workDescription: 'Prepare wooden formwork',
      plannedHours: 6,
      notes: 'Prepare shuttering for next concrete pour.',
    ),
    WorkerAllocation(
      id: 'worker-allocation-004',
      workerId: 'worker-004',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 20),
      workDescription: 'Temporary electrical setup',
      plannedHours: 4,
      notes: 'Check power supply near foundation area.',
    ),
    WorkerAllocation(
      id: 'worker-allocation-005',
      workerId: 'worker-005',
      projectId: 'project-001',
      phaseId: 'phase-001',
      date: DateTime(2026, 9, 21),
      workDescription: 'Plumbing sleeve preparation',
      plannedHours: 6,
    ),
    WorkerAllocation(
      id: 'worker-allocation-006',
      workerId: 'worker-006',
      projectId: 'project-001',
      date: DateTime(2026, 9, 21),
      workDescription: 'Site supervision and coordination',
      plannedHours: 8,
      notes: 'Coordinate masonry, electrical and plumbing activities.',
    ),
  ];

  @override
  Future<List<WorkerAllocation>> getAllocations({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _allocations.where((allocation) {
      if (allocation.workerId != workerId) {
        return false;
      }

      if (startDate != null &&
          allocation.date.isBefore(startDate)) {
        return false;
      }

      if (endDate != null &&
          allocation.date.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<List<WorkerAllocation>> getProjectAllocations(
    String projectId,
  ) async {
    return _allocations
        .where(
          (allocation) =>
              allocation.projectId == projectId,
        )
        .toList();
  }

  @override
  Future<WorkerAllocation> getAllocation(
    String id,
  ) async {
    return _allocations.firstWhere(
      (allocation) => allocation.id == id,
      orElse: () {
        throw StateError(
          'Worker allocation $id not found.',
        );
      },
    );
  }

  @override
  Future<WorkerAllocation> createAllocation(
    WorkerAllocation allocation,
  ) async {
    _allocations.add(allocation);
    return allocation;
  }

  @override
  Future<WorkerAllocation> updateAllocation(
    WorkerAllocation allocation,
  ) async {
    final index = _allocations.indexWhere(
      (existing) => existing.id == allocation.id,
    );

    if (index == -1) {
      throw StateError(
        'Worker allocation ${allocation.id} not found.',
      );
    }

    _allocations[index] = allocation;
    return allocation;
  }

  @override
  Future<void> deleteAllocation(
    String id,
  ) async {
    _allocations.removeWhere(
      (allocation) => allocation.id == id,
    );
  }
}