import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material.dart' as domain;
import '../providers/material_providers.dart';

class MaterialsPage extends ConsumerWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
      ),
      body: materialsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load materials.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (materials) {
          if (materials.isEmpty) {
            return const _EmptyMaterialsState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _MaterialCard(
                material: materials[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.material,
  });

  final domain.Material material;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    material.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  isActive: material.isActive,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Category',
                    value: _categoryLabel(material.category),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Unit',
                    value: _unitLabel(material.unit),
                  ),
                ),
              ],
            ),
            if (material.description != null) ...[
              const SizedBox(height: 12),
              Text(
                material.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _categoryLabel(domain.MaterialCategory category) {
    switch (category) {
      case domain.MaterialCategory.cement:
        return 'Cement';
      case domain.MaterialCategory.steel:
        return 'Steel';
      case domain.MaterialCategory.sand:
        return 'Sand';
      case domain.MaterialCategory.aggregate:
        return 'Aggregate';
      case domain.MaterialCategory.bricks:
        return 'Bricks';
      case domain.MaterialCategory.blocks:
        return 'Blocks';
      case domain.MaterialCategory.electrical:
        return 'Electrical';
      case domain.MaterialCategory.plumbing:
        return 'Plumbing';
      case domain.MaterialCategory.flooring:
        return 'Flooring';
      case domain.MaterialCategory.paint:
        return 'Paint';
      case domain.MaterialCategory.wood:
        return 'Wood';
      case domain.MaterialCategory.hardware:
        return 'Hardware';
      case domain.MaterialCategory.other:
        return 'Other';
    }
  }

  String _unitLabel(domain.MaterialUnit unit) {
    switch (unit) {
      case domain.MaterialUnit.kg:
        return 'kg';
      case domain.MaterialUnit.tonne:
        return 'tonne';
      case domain.MaterialUnit.bag:
        return 'bag';
      case domain.MaterialUnit.piece:
        return 'piece';
      case domain.MaterialUnit.cubicMeter:
        return 'm³';
      case domain.MaterialUnit.squareMeter:
        return 'm²';
      case domain.MaterialUnit.liter:
        return 'liter';
      case domain.MaterialUnit.meter:
        return 'meter';
      case domain.MaterialUnit.box:
        return 'box';
      case domain.MaterialUnit.set:
        return 'set';
      case domain.MaterialUnit.other:
        return 'other';
    }
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyMaterialsState extends StatelessWidget {
  const _EmptyMaterialsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No materials found.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}