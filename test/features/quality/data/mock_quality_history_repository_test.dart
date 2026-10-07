import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/quality/data/repositories/mock_corrective_action_repository.dart';
import 'package:construction_os/features/quality/data/repositories/mock_defect_repository.dart';
import 'package:construction_os/features/quality/data/repositories/mock_inspection_repository.dart';
import 'package:construction_os/features/quality/data/repositories/mock_punch_list_repository.dart';
import 'package:construction_os/features/quality/data/repositories/mock_quality_history_repository.dart';
import 'package:construction_os/features/quality/data/repositories/mock_reinspection_repository.dart';
import 'package:construction_os/features/quality/domain/entities/quality_history_entry.dart';

void main() {
  test('combines project quality records newest first', () async {
    final repository = MockQualityHistoryRepository(
      inspectionRepository: MockInspectionRepository(),
      defectRepository: MockDefectRepository(),
      punchListRepository: MockPunchListRepository(),
      correctiveActionRepository: MockCorrectiveActionRepository(),
      reinspectionRepository: MockReinspectionRepository(),
    );

    final history = await repository.getHistory(projectId: 'project-001');

    expect(history, hasLength(5));
    expect(history.first.type, QualityHistoryType.reinspection);
    expect(history.map((entry) => entry.type), contains(QualityHistoryType.defect));
    expect(history.map((entry) => entry.type), contains(QualityHistoryType.correctiveAction));
  });

  test('excludes records from another project', () async {
    final repository = MockQualityHistoryRepository(
      inspectionRepository: MockInspectionRepository(),
      defectRepository: MockDefectRepository(),
      punchListRepository: MockPunchListRepository(),
      correctiveActionRepository: MockCorrectiveActionRepository(),
      reinspectionRepository: MockReinspectionRepository(),
    );

    final history = await repository.getHistory(projectId: 'project-unknown');

    expect(history, isEmpty);
  });
}
