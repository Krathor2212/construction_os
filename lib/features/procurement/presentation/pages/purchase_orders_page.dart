import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/purchase_order.dart';
import '../providers/purchase_order_providers.dart';
import '../providers/supplier_providers.dart';
import '../widgets/purchase_order_form_dialog.dart';

class PurchaseOrdersPage extends ConsumerWidget {
  const PurchaseOrdersPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(
      purchaseOrdersProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              purchaseOrdersProvider(projectId),
            );
          },
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                purchaseOrdersProvider(projectId),
              );

              await ref.read(
                purchaseOrdersProvider(projectId).future,
              );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final order = orders[index];

                return _PurchaseOrderCard(
                  projectId: projectId,
                  order: order,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrderDialog(
          context,
          ref,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add PO'),
      ),
    );
  }

  Future<void> _showAddOrderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<PurchaseOrder>(
      context: context,
      builder: (context) {
        return PurchaseOrderFormDialog(
          projectId: projectId,
        );
      },
    );

    if (result == null) {
      return;
    }

    final repository = ref.read(
      purchaseOrderRepositoryProvider,
    );

    await repository.createPurchaseOrder(result);

    ref.invalidate(
      purchaseOrdersProvider(projectId),
    );
  }
}

class _PurchaseOrderCard extends ConsumerWidget {
  const _PurchaseOrderCard({
    required this.projectId,
    required this.order,
  });

  final String projectId;
  final PurchaseOrder order;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final supplierAsync = ref.watch(
      supplierProvider(order.supplierId),
    );

    final supplierName = supplierAsync.when(
      loading: () => 'Loading supplier...',
      error: (_, _) => 'Unknown supplier',
      data: (supplier) => supplier.name,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/projects/$projectId/purchase-orders/${order.id}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.poNumber,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                  _StatusChip(
                    status: order.status,
                  ),
                  const SizedBox(
                    width: AppSpacing.xs,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    padding: EdgeInsets.zero,
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          await _showEditOrderDialog(
                            context,
                            ref,
                          );
                          break;

                        case 'archive':
                          await _archiveOrder(
                            context,
                            ref,
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                              ),
                              SizedBox(
                                width: AppSpacing.sm,
                              ),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(
                                Icons.archive_outlined,
                                size: 20,
                              ),
                              SizedBox(
                                width: AppSpacing.sm,
                              ),
                              Text('Archive'),
                            ],
                          ),
                        ),
                      ];
                    },
                    child: const Icon(
                      Icons.more_vert,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                supplierName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Order Date',
                      value: _formatDate(
                        order.orderDate,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Expected Delivery',
                      value:
                          order.expectedDeliveryDate == null
                              ? '—'
                              : _formatDate(
                                  order.expectedDeliveryDate!,
                                ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Row(
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _formatCurrency(
                      order.total,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditOrderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<PurchaseOrder>(
      context: context,
      builder: (context) {
        return PurchaseOrderFormDialog(
          projectId: projectId,
          order: order,
        );
      },
    );

    if (result == null) {
      return;
    }

    final repository = ref.read(
      purchaseOrderRepositoryProvider,
    );

    await repository.updatePurchaseOrder(
      result,
    );

    ref.invalidate(
      purchaseOrdersProvider(projectId),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Purchase order updated',
        ),
      ),
    );
  }

  Future<void> _archiveOrder(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Archive Purchase Order?',
          ),
          content: Text(
            'Are you sure you want to archive '
            '${order.poNumber}? '
            'It will no longer appear in the active purchase order list.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final repository = ref.read(
      purchaseOrderRepositoryProvider,
    );

    await repository.archivePurchaseOrder(
      order.id,
    );

    ref.invalidate(
      purchaseOrdersProvider(projectId),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${order.poNumber} archived',
        ),
      ),
    );
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
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final PurchaseOrderStatus status;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Chip(
      label: Text(
        _statusLabel(status),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Text(
          'No purchase orders found.',
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            const Text(
              'Unable to load purchase orders.',
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            FilledButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

String _statusLabel(
  PurchaseOrderStatus status,
) {
  switch (status) {
    case PurchaseOrderStatus.draft:
      return 'Draft';

    case PurchaseOrderStatus.issued:
      return 'Issued';

    case PurchaseOrderStatus.partiallyReceived:
      return 'Partially Received';

    case PurchaseOrderStatus.received:
      return 'Received';

    case PurchaseOrderStatus.cancelled:
      return 'Cancelled';

    case PurchaseOrderStatus.closed:
      return 'Closed';
  }
}