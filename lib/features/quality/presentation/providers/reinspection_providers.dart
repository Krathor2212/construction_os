import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_reinspection_repository.dart';
import '../../domain/entities/reinspection.dart';
import '../../domain/repositories/reinspection_repository.dart';

final reinspectionRepositoryProvider =
    Provider<ReinspectionRepository>((ref) {
  return MockReinspectionRepository();
});

final projectReinspectionsProvider =
    FutureProvider.family<List<Reinspection>, String>((ref, projectId) {
  return ref
      .watch(reinspectionRepositoryProvider)
      .getReinspections(projectId: projectId);
});

final reinspectionActionsProvider = Provider<ReinspectionActions>((ref) {
  return ReinspectionActions(ref);
});

class ReinspectionActions {
  ReinspectionActions(this._ref);

  final Ref _ref;

  Future<Reinspection> createReinspection(
    Reinspection reinspection,
  ) async {
    final created = await _ref
        .read(reinspectionRepositoryProvider)
        .createReinspection(reinspection);
    _ref.invalidate(projectReinspectionsProvider(reinspection.projectId));
    return created;
  }
}
