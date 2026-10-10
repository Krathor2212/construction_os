import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/material_forecast.dart';
import '../providers/material_forecast_providers.dart';
import '../providers/material_providers.dart';

class ProjectMaterialForecastPage extends ConsumerWidget {
  const ProjectMaterialForecastPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(projectMaterialForecastProvider(projectId));
    final materials = ref.watch(materialsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Material Forecast')),
      body: forecast.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load forecast: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No material requirements to forecast.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) {
                  final item = items[index];
                  final name = materials.when(
                    loading: () => item.materialId,
                    error: (_, _) => item.materialId,
                    data: (list) =>
                        list
                            .where((m) => m.id == item.materialId)
                            .map((m) => m.name)
                            .firstOrNull ??
                        item.materialId,
                  );
                  return _ForecastCard(name: name, item: item);
                },
              ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.name, required this.item});

  final String name;
  final MaterialForecast item;

  @override
  Widget build(BuildContext context) {
    final covered = item.isCovered;
    return Card(
      child: ListTile(
        leading: Icon(
          covered ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: covered ? Colors.green : Colors.orange,
        ),
        title: Text(name),
        subtitle: Text(
          'Required: ${item.requiredQuantity} ${item.unit}\n'
          'Available: ${item.availableQuantity} ${item.unit} • '
          'Received: ${item.receivedQuantity} ${item.unit}',
        ),
        isThreeLine: true,
        trailing: Text(
          covered ? 'Covered' : 'Short ${item.projectedShortfall} ${item.unit}',
          style: TextStyle(color: covered ? Colors.green : Colors.orange),
        ),
      ),
    );
  }
}
