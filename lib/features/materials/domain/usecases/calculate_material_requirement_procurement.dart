import '../entities/material_requirement.dart';
import '../entities/material_requirement_procurement.dart';

class MaterialRequirementProcurementSummary {
  const MaterialRequirementProcurementSummary({
    required this.requiredQuantity,
    required this.procuredQuantity,
    required this.remainingQuantity,
  });

  final double requiredQuantity;
  final double procuredQuantity;
  final double remainingQuantity;

  double get procurementPercentage {
    if (requiredQuantity <= 0) {
      return 0;
    }

    final percentage = procuredQuantity / requiredQuantity;

    if (percentage > 1) {
      return 1;
    }

    if (percentage < 0) {
      return 0;
    }

    return percentage;
  }
}

class CalculateMaterialRequirementProcurement {
  const CalculateMaterialRequirementProcurement();

  MaterialRequirementProcurementSummary execute({
    required MaterialRequirement requirement,
    required List<MaterialRequirementProcurement> procurements,
  }) {
    final procuredQuantity = procurements.fold<double>(
      0,
      (total, procurement) => total + procurement.quantity,
    );

    final remainingQuantity = (requirement.quantity - procuredQuantity)
    .clamp(0.0, double.infinity)
    .toDouble();

    return MaterialRequirementProcurementSummary(
      requiredQuantity: requirement.quantity,
      procuredQuantity: procuredQuantity,
      remainingQuantity: remainingQuantity,
    );
  }
}