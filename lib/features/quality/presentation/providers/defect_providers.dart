import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_defect_repository.dart';
import '../../domain/entities/defect.dart';
import '../../domain/repositories/defect_repository.dart';

final defectRepositoryProvider = Provider<DefectRepository>((ref) {
  return MockDefectRepository();
});

final projectDefectsProvider =
    FutureProvider.family<List<Defect>, String>((ref, projectId) async {
  return ref.watch(defectRepositoryProvider).getDefects(projectId: projectId);
});

final defectActionsProvider = Provider<DefectActions>((ref) {
  return DefectActions(ref);
});

class DefectActions {
  DefectActions(this._ref);

  final Ref _ref;

  Future<Defect> createDefect(Defect defect) async {
    final created = await _ref.read(defectRepositoryProvider).createDefect(defect);
    _ref.invalidate(projectDefectsProvider(defect.projectId));
    return created;
  }

  Future<Defect> updateDefect(Defect defect) async {
    final updated = await _ref.read(defectRepositoryProvider).updateDefect(defect);
    _ref.invalidate(projectDefectsProvider(defect.projectId));
    return updated;
  }
}
