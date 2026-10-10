import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_material_delivery_repository.dart';
import '../../domain/entities/material_delivery.dart';
import '../../domain/repositories/material_delivery_repository.dart';

final materialDeliveryRepositoryProvider = Provider<MaterialDeliveryRepository>(
  (ref) {
    return MockMaterialDeliveryRepository();
  },
);

final projectMaterialDeliveriesProvider =
    FutureProvider.family<List<MaterialDelivery>, String>((ref, projectId) {
      return ref
          .watch(materialDeliveryRepositoryProvider)
          .getDeliveries(projectId: projectId);
    });

final materialDeliveryActionsProvider = Provider<MaterialDeliveryActions>((
  ref,
) {
  return MaterialDeliveryActions(ref);
});

class MaterialDeliveryActions {
  MaterialDeliveryActions(this._ref);

  final Ref _ref;

  Future<MaterialDelivery> createDelivery(MaterialDelivery delivery) async {
    final created = await _ref
        .read(materialDeliveryRepositoryProvider)
        .createDelivery(delivery);
    _ref.invalidate(projectMaterialDeliveriesProvider(delivery.projectId));
    return created;
  }

  Future<MaterialDelivery> updateDelivery(MaterialDelivery delivery) async {
    final updated = await _ref
        .read(materialDeliveryRepositoryProvider)
        .updateDelivery(delivery);
    _ref.invalidate(projectMaterialDeliveriesProvider(delivery.projectId));
    return updated;
  }
}
