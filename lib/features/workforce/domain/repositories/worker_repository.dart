import '../entities/worker.dart';

abstract interface class WorkerRepository {
  Future<List<Worker>> getWorkers();

  Future<Worker> getWorker(String id);

  Future<Worker> createWorker(Worker worker);

  Future<Worker> updateWorker(Worker worker);

  Future<void> deleteWorker(String id);
}