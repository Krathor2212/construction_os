import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material_forecast.dart';
import '../../domain/services/material_forecast_calculator.dart';
import 'material_requirement_providers.dart';
import 'material_stock_providers.dart';

final projectMaterialForecastProvider =
    FutureProvider.family<List<MaterialForecast>, String>((
      ref,
      projectId,
    ) async {
      final requirements = await ref.watch(
        materialRequirementsProvider(projectId).future,
      );
      final inventory = await ref.watch(
        projectMaterialInventoryProvider(projectId).future,
      );
      return MaterialForecastCalculator().calculate(
        requirements: requirements,
        inventory: inventory,
      );
    });
