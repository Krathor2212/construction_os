import '../../domain/entities/worker.dart';
import '../../domain/repositories/worker_repository.dart';

class MockWorkerRepository implements WorkerRepository {
  final List<Worker> _workers = [
    Worker(
      id: 'worker-001',
      name: 'Ramesh',
      role: WorkerRole.mason,
      phone: '+91 98765 10001',
      dailyWage: 900,
      notes: 'Experienced in concrete and block work.',
    ),
    Worker(
      id: 'worker-002',
      name: 'Suresh',
      role: WorkerRole.helper,
      phone: '+91 98765 10002',
      dailyWage: 650,
    ),
    Worker(
      id: 'worker-003',
      name: 'Manoj',
      role: WorkerRole.carpenter,
      phone: '+91 98765 10003',
      dailyWage: 1000,
    ),
    Worker(
      id: 'worker-004',
      name: 'Karthik',
      role: WorkerRole.electrician,
      phone: '+91 98765 10004',
      dailyWage: 1100,
    ),
    Worker(
      id: 'worker-005',
      name: 'Prakash',
      role: WorkerRole.plumber,
      phone: '+91 98765 10005',
      dailyWage: 1050,
    ),
    Worker(
      id: 'worker-006',
      name: 'Arun',
      role: WorkerRole.supervisor,
      phone: '+91 98765 10006',
      dailyWage: 1500,
      notes: 'Site supervisor.',
    ),
    Worker(
      id: 'worker-007',
      name: 'Vijay',
      role: WorkerRole.painter,
      phone: '+91 98765 10007',
      dailyWage: 850,
      isActive: false,
      notes: 'Currently unavailable.',
    ),
  ];

  @override
  Future<List<Worker>> getWorkers() async {
    return List.unmodifiable(_workers);
  }

  @override
  Future<Worker> getWorker(String id) async {
    return _workers.firstWhere(
      (worker) => worker.id == id,
    );
  }

  @override
  Future<Worker> createWorker(Worker worker) async {
    _workers.add(worker);
    return worker;
  }

  @override
  Future<Worker> updateWorker(Worker worker) async {
    final index = _workers.indexWhere(
      (item) => item.id == worker.id,
    );

    if (index == -1) {
      throw StateError(
        'Worker not found: ${worker.id}',
      );
    }

    _workers[index] = worker;
    return worker;
  }

  @override
  Future<void> deleteWorker(String id) async {
    _workers.removeWhere(
      (worker) => worker.id == id,
    );
  }
}