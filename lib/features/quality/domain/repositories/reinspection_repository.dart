import '../entities/reinspection.dart';

abstract interface class ReinspectionRepository {
  Future<List<Reinspection>> getReinspections({required String projectId});
  Future<Reinspection> createReinspection(Reinspection reinspection);
}
