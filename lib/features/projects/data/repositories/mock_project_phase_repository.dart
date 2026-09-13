import '../../domain/entities/project_phase.dart';
import '../../domain/repositories/project_phase_repository.dart';

class MockProjectPhaseRepository implements ProjectPhaseRepository {
  final List<ProjectPhase> _phases = [
    ProjectPhase(
      id: 'phase-001',
      projectId: 'project-001',
      name: 'Planning & Approvals',
      plannedStartDate: DateTime(2026, 7, 20),
      plannedEndDate: DateTime(2026, 7, 31),
      actualStartDate: DateTime(2026, 7, 20),
      actualEndDate: DateTime(2026, 7, 31),
      status: ProjectPhaseStatus.completed,
      progress: 100,
    ),
    ProjectPhase(
      id: 'phase-002',
      projectId: 'project-001',
      name: 'Foundation',
      plannedStartDate: DateTime(2026, 8, 1),
      plannedEndDate: DateTime(2026, 8, 25),
      actualStartDate: DateTime(2026, 8, 1),
      status: ProjectPhaseStatus.completed,
      progress: 100,
    ),
    ProjectPhase(
      id: 'phase-003',
      projectId: 'project-001',
      name: 'Structure',
      plannedStartDate: DateTime(2026, 8, 26),
      plannedEndDate: DateTime(2026, 10, 15),
      actualStartDate: DateTime(2026, 8, 26),
      status: ProjectPhaseStatus.inProgress,
      progress: 45,
    ),
    ProjectPhase(
      id: 'phase-004',
      projectId: 'project-001',
      name: 'Brickwork',
      plannedStartDate: DateTime(2026, 10, 16),
      plannedEndDate: DateTime(2026, 11, 20),
      status: ProjectPhaseStatus.notStarted,
      progress: 0,
    ),
    ProjectPhase(
      id: 'phase-005',
      projectId: 'project-001',
      name: 'Electrical & Plumbing',
      plannedStartDate: DateTime(2026, 11, 1),
      plannedEndDate: DateTime(2026, 12, 10),
      status: ProjectPhaseStatus.notStarted,
      progress: 0,
    ),
    ProjectPhase(
      id: 'phase-006',
      projectId: 'project-001',
      name: 'Finishing',
      plannedStartDate: DateTime(2026, 12, 1),
      plannedEndDate: DateTime(2027, 1, 25),
      status: ProjectPhaseStatus.notStarted,
      progress: 0,
    ),
    ProjectPhase(
      id: 'phase-007',
      projectId: 'project-001',
      name: 'Handover',
      plannedStartDate: DateTime(2027, 1, 26),
      plannedEndDate: DateTime(2027, 2, 1),
      status: ProjectPhaseStatus.notStarted,
      progress: 0,
    ),
  ];

  @override
  Future<List<ProjectPhase>> getPhases(String projectId) async {
    return List.unmodifiable(
      _phases.where(
        (phase) => phase.projectId == projectId,
      ),
    );
  }

  @override
  Future<ProjectPhase> getPhase(String id) async {
    return _phases.firstWhere(
      (phase) => phase.id == id,
    );
  }

  @override
  Future<ProjectPhase> createPhase(ProjectPhase phase) async {
    _phases.add(phase);
    return phase;
  }

  @override
  Future<ProjectPhase> updatePhase(ProjectPhase phase) async {
    final index = _phases.indexWhere(
      (item) => item.id == phase.id,
    );

    if (index == -1) {
      throw StateError('Project phase not found: ${phase.id}');
    }

    _phases[index] = phase;
    return phase;
  }

  @override
  Future<void> deletePhase(String id) async {
    _phases.removeWhere(
      (phase) => phase.id == id,
    );
  }
}