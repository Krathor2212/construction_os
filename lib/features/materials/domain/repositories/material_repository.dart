import '../entities/material.dart';

abstract interface class MaterialRepository {
  Future<List<Material>> getMaterials();

  Future<Material> getMaterial(String id);

  Future<Material> createMaterial(Material material);

  Future<Material> updateMaterial(Material material);

  Future<void> deleteMaterial(String id);
}