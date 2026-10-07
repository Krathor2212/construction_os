import '../entities/inspection.dart';

abstract interface class InspectionRepository {
  Future<List<Inspection>> getInspections({required String projectId});
  Future<Inspection> createInspection(Inspection inspection);
}
