import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_quality_history_repository.dart';
import '../../domain/entities/quality_history_entry.dart';
import '../../domain/repositories/quality_history_repository.dart';
import 'corrective_action_providers.dart';
import 'defect_providers.dart';
import 'inspection_providers.dart';
import 'punch_list_providers.dart';
import 'reinspection_providers.dart';

final qualityHistoryRepositoryProvider =
    Provider<QualityHistoryRepository>((ref) {
  return MockQualityHistoryRepository(
    inspectionRepository: ref.watch(inspectionRepositoryProvider),
    defectRepository: ref.watch(defectRepositoryProvider),
    punchListRepository: ref.watch(punchListRepositoryProvider),
    correctiveActionRepository: ref.watch(correctiveActionRepositoryProvider),
    reinspectionRepository: ref.watch(reinspectionRepositoryProvider),
  );
});

final projectQualityHistoryProvider =
    FutureProvider.family<List<QualityHistoryEntry>, String>((ref, projectId) {
  return ref
      .watch(qualityHistoryRepositoryProvider)
      .getHistory(projectId: projectId);
});
