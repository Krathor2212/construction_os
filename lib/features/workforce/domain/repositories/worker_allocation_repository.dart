import '../entities/worker_allocation.dart';

abstract interface class WorkerAllocationRepository {
  Future<List<WorkerAllocation>> getAllocations({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<WorkerAllocation>> getProjectAllocations(
    String projectId,
  );

  Future<WorkerAllocation> getAllocation(
    String id,
  );

  Future<WorkerAllocation> createAllocation(
    WorkerAllocation allocation,
  );

  Future<WorkerAllocation> updateAllocation(
    WorkerAllocation allocation,
  );

  Future<void> deleteAllocation(
    String id,
  );
}