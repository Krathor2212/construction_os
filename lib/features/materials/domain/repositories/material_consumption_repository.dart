import '../entities/material_consumption.dart';

abstract interface class MaterialConsumptionRepository {
  Future<List<MaterialConsumption>> getConsumptions({
    required String projectId,
  });
  Future<MaterialConsumption> createConsumption(
    MaterialConsumption consumption,
  );
}
