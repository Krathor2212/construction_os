import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/supplier.dart';
import '../providers/supplier_providers.dart';

class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: suppliersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load suppliers.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return const _EmptySuppliersState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: suppliers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _SupplierCard(
                supplier: suppliers[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({
    required this.supplier,
  });

  final Supplier supplier;

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
                    supplier.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(
                  isActive: supplier.isActive,
                ),
              ],
            ),
            if (supplier.contactPerson != null) ...[
              const SizedBox(height: 6),
              Text(
                supplier.contactPerson!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.phone_outlined,
              value: supplier.phone,
            ),
            if (supplier.email != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.email_outlined,
                value: supplier.email!,
              ),
            ],
            if (supplier.address != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.location_on_outlined,
                value: supplier.address!,
              ),
            ],
            if (supplier.gstNumber != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.receipt_long_outlined,
                value: 'GST: ${supplier.gstNumber}',
              ),
            ],
            if (supplier.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                supplier.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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

class _EmptySuppliersState extends StatelessWidget {
  const _EmptySuppliersState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No suppliers found.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}