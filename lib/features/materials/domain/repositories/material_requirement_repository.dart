import '../entities/material_requirement.dart';

abstract interface class MaterialRequirementRepository {
  Future<List<MaterialRequirement>> getRequirements(
    String projectId,
  );

  Future<MaterialRequirement> getRequirement(
    String id,
  );

  Future<MaterialRequirement> createRequirement(
    MaterialRequirement requirement,
  );

  Future<MaterialRequirement> updateRequirement(
    MaterialRequirement requirement,
  );

  Future<void> archiveRequirement(
    String id,
  );
}