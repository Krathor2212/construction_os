import '../entities/material_requirement.dart';
import '../entities/material_requirement_procurement.dart';

class ValidateMaterialRequirementProcurementQuantity {
  const ValidateMaterialRequirementProcurementQuantity();

  String? execute({
    required MaterialRequirement requirement,
    required double purchaseOrderItemQuantity,
    required List<MaterialRequirementProcurement>
        existingRequirementProcurements,
    required List<MaterialRequirementProcurement>
        existingPurchaseOrderItemProcurements,
    required double requestedQuantity,
    String? currentProcurementId,
  }) {
    if (requestedQuantity <= 0) {
      return 'Allocated quantity must be greater than zero.';
    }

    final alreadyAllocatedToRequirement =
        existingRequirementProcurements
            .where(
              (procurement) =>
                  procurement.id != currentProcurementId,
            )
            .fold<double>(
              0,
              (total, procurement) => total + procurement.quantity,
            );

    final requirementRemaining =
        requirement.quantity - alreadyAllocatedToRequirement;

    if (requestedQuantity > requirementRemaining) {
      return 'Only $requirementRemaining ${requirement.unit} remain for this material requirement.';
    }

    final alreadyAllocatedToPurchaseOrderItem =
        existingPurchaseOrderItemProcurements
            .where(
              (procurement) =>
                  procurement.id != currentProcurementId,
            )
            .fold<double>(
              0,
              (total, procurement) => total + procurement.quantity,
            );

    final purchaseOrderItemRemaining =
        purchaseOrderItemQuantity -
            alreadyAllocatedToPurchaseOrderItem;

    if (requestedQuantity > purchaseOrderItemRemaining) {
      return 'Only $purchaseOrderItemRemaining ${requirement.unit} remain available on this purchase order item.';
    }

    return null;
  }
}