import '../entities/material_requirement_procurement.dart';

abstract interface class MaterialRequirementProcurementRepository {
  Future<List<MaterialRequirementProcurement>> getProcurements(
    String materialRequirementId,
  );

  Future<MaterialRequirementProcurement>
      createProcurement(MaterialRequirementProcurement procurement);

  Future<MaterialRequirementProcurement>
      updateProcurement(MaterialRequirementProcurement procurement);

  Future<void> deleteProcurement(String id);
}