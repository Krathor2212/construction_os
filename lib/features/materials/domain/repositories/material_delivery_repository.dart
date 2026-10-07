import '../entities/material_delivery.dart';

abstract interface class MaterialDeliveryRepository {
  Future<List<MaterialDelivery>> getDeliveries({required String projectId});
  Future<MaterialDelivery> createDelivery(MaterialDelivery delivery);
  Future<MaterialDelivery> updateDelivery(MaterialDelivery delivery);
}
