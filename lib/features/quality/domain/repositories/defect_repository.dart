import '../entities/defect.dart';

abstract interface class DefectRepository {
  Future<List<Defect>> getDefects({required String projectId});
  Future<Defect> createDefect(Defect defect);
  Future<Defect> updateDefect(Defect defect);
}
