import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_inspection_repository.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/repositories/inspection_repository.dart';

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  return MockInspectionRepository();
});

final projectInspectionsProvider =
    FutureProvider.family<List<Inspection>, String>((ref, projectId) async {
  return ref
      .watch(inspectionRepositoryProvider)
      .getInspections(projectId: projectId);
});

final inspectionActionsProvider = Provider<InspectionActions>((ref) {
  return InspectionActions(ref);
});

class InspectionActions {
  InspectionActions(this._ref);

  final Ref _ref;

  Future<Inspection> createInspection(Inspection inspection) async {
    final created = await _ref
        .read(inspectionRepositoryProvider)
        .createInspection(inspection);
    _ref.invalidate(projectInspectionsProvider(inspection.projectId));
    return created;
  }
}
