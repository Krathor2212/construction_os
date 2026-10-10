import '../entities/material_wastage.dart';

abstract interface class MaterialWastageRepository {
  Future<List<MaterialWastage>> getWastage({required String projectId});
  Future<MaterialWastage> createWastage(MaterialWastage wastage);
}
