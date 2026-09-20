import '../entities/worker_allocation.dart';
import '../repositories/worker_allocation_repository.dart';

class ManageWorkerAllocation {
  const ManageWorkerAllocation(
    this.repository,
  );

  final WorkerAllocationRepository repository;

  Future<WorkerAllocation> create(
    WorkerAllocation allocation,
  ) async {
    return repository.createAllocation(
      allocation,
    );
  }

  Future<WorkerAllocation> update(
    WorkerAllocation allocation,
  ) async {
    return repository.updateAllocation(
      allocation,
    );
  }

  Future<void> delete(
    String id,
  ) async {
    await repository.deleteAllocation(id);
  }
}