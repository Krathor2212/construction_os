import '../../domain/entities/defect.dart';
import '../../domain/repositories/defect_repository.dart';

class MockDefectRepository implements DefectRepository {
  final List<Defect> _defects = [
    Defect(
      id: 'defect-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      taskId: 'task-001',
      title: 'Uneven excavation edge',
      description: 'The north edge needs trimming before PCC work begins.',
      location: 'North foundation edge',
      reportedDate: DateTime(2026, 9, 25),
      severity: DefectSeverity.medium,
      status: DefectStatus.open,
    ),
  ];

  @override
  Future<List<Defect>> getDefects({required String projectId}) async {
    return _defects
        .where((defect) => defect.projectId == projectId)
        .toList()
      ..sort((a, b) => b.reportedDate.compareTo(a.reportedDate));
  }

  @override
  Future<Defect> createDefect(Defect defect) async {
    _defects.add(defect);
    return defect;
  }

  @override
  Future<Defect> updateDefect(Defect defect) async {
    final index = _defects.indexWhere((item) => item.id == defect.id);
    if (index == -1) {
      throw StateError('Defect ${defect.id} not found.');
    }
    _defects[index] = defect;
    return defect;
  }
}
