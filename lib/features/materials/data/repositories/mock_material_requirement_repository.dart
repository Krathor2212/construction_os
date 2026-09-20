import '../../domain/entities/material_requirement.dart';
import '../../domain/repositories/material_requirement_repository.dart';

class MockMaterialRequirementRepository
    implements MaterialRequirementRepository {
  final List<MaterialRequirement> _requirements = [
    MaterialRequirement(
      id: 'material-requirement-001',
      projectId: 'project-001',
      phaseId: 'phase-001',
      materialId: 'material-001',
      quantity: 500,
      unit: 'bag',
      requiredByDate: DateTime(2026, 9, 30),
      notes: 'OPC cement required for foundation and structural work.',
      status: MaterialRequirementStatus.partiallyProcured,
    ),
    MaterialRequirement(
      id: 'material-requirement-002',
      projectId: 'project-001',
      phaseId: 'phase-001',
      materialId: 'material-002',
      quantity: 2500,
      unit: 'kg',
      requiredByDate: DateTime(2026, 10, 5),
      notes: 'TMT Steel 12mm for reinforcement.',
      status: MaterialRequirementStatus.planned,
    ),
    MaterialRequirement(
      id: 'material-requirement-003',
      projectId: 'project-001',
      phaseId: 'phase-001',
      materialId: 'material-003',
      quantity: 30,
      unit: 'cubicMeter',
      requiredByDate: DateTime(2026, 9, 28),
      notes: 'River sand for foundation work.',
      status: MaterialRequirementStatus.planned,
    ),
    MaterialRequirement(
      id: 'material-requirement-004',
      projectId: 'project-001',
      phaseId: 'phase-001',
      materialId: 'material-005',
      quantity: 40,
      unit: 'cubicMeter',
      requiredByDate: DateTime(2026, 10, 2),
      notes: '20mm aggregate for concrete.',
      status: MaterialRequirementStatus.planned,
    ),
    MaterialRequirement(
      id: 'material-requirement-005',
      projectId: 'project-002',
      phaseId: null,
      materialId: 'material-001',
      quantity: 1000,
      unit: 'bag',
      requiredByDate: DateTime(2026, 11, 15),
      notes: 'Initial cement requirement for commercial building.',
      status: MaterialRequirementStatus.planned,
    ),
  ];

  @override
  Future<List<MaterialRequirement>> getRequirements(
    String projectId,
  ) async {
    return _requirements
        .where(
          (requirement) =>
              requirement.projectId == projectId &&
              !requirement.isArchived,
        )
        .toList();
  }

  @override
  Future<MaterialRequirement> getRequirement(
    String id,
  ) async {
    return _requirements.firstWhere(
      (requirement) => requirement.id == id,
    );
  }

  @override
  Future<MaterialRequirement> createRequirement(
    MaterialRequirement requirement,
  ) async {
    _requirements.add(requirement);
    return requirement;
  }

  @override
  Future<MaterialRequirement> updateRequirement(
    MaterialRequirement requirement,
  ) async {
    final index = _requirements.indexWhere(
      (existing) => existing.id == requirement.id,
    );

    if (index == -1) {
      throw StateError(
        'Material requirement not found.',
      );
    }

    _requirements[index] = requirement;
    return requirement;
  }

  @override
  Future<void> archiveRequirement(
    String id,
  ) async {
    final index = _requirements.indexWhere(
      (requirement) => requirement.id == id,
    );

    if (index == -1) {
      throw StateError(
        'Material requirement not found.',
      );
    }

    final existing = _requirements[index];

    _requirements[index] = MaterialRequirement(
      id: existing.id,
      projectId: existing.projectId,
      phaseId: existing.phaseId,
      materialId: existing.materialId,
      quantity: existing.quantity,
      unit: existing.unit,
      requiredByDate: existing.requiredByDate,
      notes: existing.notes,
      status: existing.status,
      isArchived: true,
    );
  }
}