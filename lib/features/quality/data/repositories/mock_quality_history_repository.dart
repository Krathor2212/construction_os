import '../../domain/entities/quality_history_entry.dart';
import '../../domain/repositories/corrective_action_repository.dart';
import '../../domain/repositories/defect_repository.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../../domain/repositories/punch_list_repository.dart';
import '../../domain/repositories/quality_history_repository.dart';
import '../../domain/repositories/reinspection_repository.dart';
import '../../domain/entities/corrective_action.dart';
import '../../domain/entities/defect.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/entities/punch_list_item.dart';
import '../../domain/entities/reinspection.dart';

class MockQualityHistoryRepository implements QualityHistoryRepository {
  const MockQualityHistoryRepository({
    required this.inspectionRepository,
    required this.defectRepository,
    required this.punchListRepository,
    required this.correctiveActionRepository,
    required this.reinspectionRepository,
  });

  final InspectionRepository inspectionRepository;
  final DefectRepository defectRepository;
  final PunchListRepository punchListRepository;
  final CorrectiveActionRepository correctiveActionRepository;
  final ReinspectionRepository reinspectionRepository;

  @override
  Future<List<QualityHistoryEntry>> getHistory({
    required String projectId,
  }) async {
    final results = await Future.wait([
      inspectionRepository.getInspections(projectId: projectId),
      defectRepository.getDefects(projectId: projectId),
      punchListRepository.getItems(projectId: projectId),
      correctiveActionRepository.getActions(projectId: projectId),
      reinspectionRepository.getReinspections(projectId: projectId),
    ]);

    return [
      ...results[0].cast<Inspection>().map(_inspectionEntry),
      ...results[1].cast<Defect>().map(_defectEntry),
      ...results[2].cast<PunchListItem>().map(_punchListEntry),
      ...results[3].cast<CorrectiveAction>().map(_correctiveActionEntry),
      ...results[4].cast<Reinspection>().map(_reinspectionEntry),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  QualityHistoryEntry _inspectionEntry(Inspection inspection) {
    return QualityHistoryEntry(
      id: inspection.id,
      projectId: inspection.projectId,
      type: QualityHistoryType.inspection,
      date: inspection.date,
      title: 'Inspection: ${_inspectionResult(inspection.result)}',
      summary: inspection.notes,
      status: _inspectionResult(inspection.result),
    );
  }

  QualityHistoryEntry _defectEntry(Defect defect) {
    return QualityHistoryEntry(
      id: defect.id,
      projectId: defect.projectId,
      type: QualityHistoryType.defect,
      date: defect.reportedDate,
      title: defect.title,
      summary: defect.description,
      status: _defectStatus(defect.status),
    );
  }

  QualityHistoryEntry _punchListEntry(PunchListItem item) {
    return QualityHistoryEntry(
      id: item.id,
      projectId: item.projectId,
      type: QualityHistoryType.punchList,
      date: item.reportedDate,
      title: item.title,
      summary: item.description,
      status: _punchListStatus(item.status),
    );
  }

  QualityHistoryEntry _correctiveActionEntry(CorrectiveAction action) {
    return QualityHistoryEntry(
      id: action.id,
      projectId: action.projectId,
      type: QualityHistoryType.correctiveAction,
      date: action.createdDate,
      title: action.title,
      summary: '${action.description} Due ${_formatDate(action.dueDate)}.',
      status: _correctiveActionStatus(action.status),
    );
  }

  QualityHistoryEntry _reinspectionEntry(Reinspection reinspection) {
    return QualityHistoryEntry(
      id: reinspection.id,
      projectId: reinspection.projectId,
      type: QualityHistoryType.reinspection,
      date: reinspection.date,
      title: 'Reinspection: ${_reinspectionResult(reinspection.result)}',
      summary: reinspection.notes,
      status: _reinspectionResult(reinspection.result),
    );
  }

  String _inspectionResult(InspectionResult result) => switch (result) {
        InspectionResult.passed => 'Passed',
        InspectionResult.failed => 'Failed',
        InspectionResult.requiresAttention => 'Requires attention',
      };

  String _defectStatus(DefectStatus status) => switch (status) {
        DefectStatus.open => 'Open',
        DefectStatus.inProgress => 'In progress',
        DefectStatus.resolved => 'Resolved',
      };

  String _punchListStatus(PunchListStatus status) => switch (status) {
        PunchListStatus.open => 'Open',
        PunchListStatus.inProgress => 'In progress',
        PunchListStatus.completed => 'Completed',
      };

  String _correctiveActionStatus(CorrectiveActionStatus status) =>
      switch (status) {
        CorrectiveActionStatus.open => 'Open',
        CorrectiveActionStatus.inProgress => 'In progress',
        CorrectiveActionStatus.completed => 'Completed',
      };

  String _reinspectionResult(ReinspectionResult result) => switch (result) {
        ReinspectionResult.passed => 'Passed',
        ReinspectionResult.failed => 'Failed',
        ReinspectionResult.requiresAttention => 'Requires attention',
      };

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
