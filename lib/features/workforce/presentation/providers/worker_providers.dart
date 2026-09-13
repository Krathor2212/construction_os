import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_worker_repository.dart';
import '../../domain/entities/worker.dart';
import '../../domain/repositories/worker_repository.dart';

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  return MockWorkerRepository();
});

final workersProvider = FutureProvider<List<Worker>>((ref) async {
  final repository = ref.watch(workerRepositoryProvider);

  return repository.getWorkers();
});

final workerProvider = FutureProvider.family<Worker, String>(
  (ref, workerId) async {
    final repository = ref.watch(workerRepositoryProvider);

    return repository.getWorker(workerId);
  },
);