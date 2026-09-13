import '../entities/project_phase.dart';

abstract interface class ProjectPhaseRepository {
  Future<List<ProjectPhase>> getPhases(String projectId);

  Future<ProjectPhase> getPhase(String id);

  Future<ProjectPhase> createPhase(ProjectPhase phase);

  Future<ProjectPhase> updatePhase(ProjectPhase phase);

  Future<void> deletePhase(String id);
}