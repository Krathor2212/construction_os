import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../materials/presentation/providers/material_providers.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../providers/purchase_order_item_providers.dart';
import '../providers/purchase_order_providers.dart';
import '../providers/supplier_providers.dart';
import '../widgets/purchase_order_item_form_dialog.dart';

class PurchaseOrderDetailsPage extends ConsumerWidget {
  const PurchaseOrderDetailsPage({
    super.key,
    required this.projectId,
    required this.orderId,
  });

  final String projectId;
  final String orderId;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final orderAsync = ref.watch(
      purchaseOrderProvider(orderId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order Details'),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              purchaseOrderProvider(orderId),
            );
          },
        ),
        data: (order) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              purchaseOrderProvider(orderId),
            );

            ref.invalidate(
              purchaseOrderItemsProvider(orderId),
            );

            await ref.read(
              purchaseOrderProvider(orderId).future,
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            children: [
              _OrderHeaderCard(
                order: order,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              _OrderInformationCard(
                order: order,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              _LineItemsSection(
                order: order,
                onAddItem: () => _showAddItemDialog(
                  context,
                  ref,
                  order.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    WidgetRef ref,
    String purchaseOrderId,
  ) async {
    final result = await showDialog<PurchaseOrderItem>(
      context: context,
      builder: (context) {
        return PurchaseOrderItemFormDialog(
          purchaseOrderId: purchaseOrderId,
        );
      },
    );

    if (result == null) {
      return;
    }

    final repository = ref.read(
      purchaseOrderItemRepositoryProvider,
    );

    await repository.createItem(
      result,
    );

    ref.invalidate(
      purchaseOrderItemsProvider(
        purchaseOrderId,
      ),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Purchase order item added',
        ),
      ),
    );
  }
}

class _OrderHeaderCard extends ConsumerWidget {
  const _OrderHeaderCard({
    required this.order,
  });

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
      data: (supplier) => supplier.name,
      loading: () => 'Loading supplier...',
      error: (_, _) => 'Unknown supplier',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.poNumber,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _StatusChip(
                  status: order.status,
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(
                  width: AppSpacing.xs,
                ),
                Expanded(
                  child: Text(
                    supplierName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderInformationCard extends StatelessWidget {
  const _OrderInformationCard({
    required this.order,
  });

  final PurchaseOrder order;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            _InfoRow(
              label: 'Order Date',
              value: _formatDate(
                order.orderDate,
              ),
            ),
            _InfoRow(
              label: 'Expected Delivery',
              value:
                  order.expectedDeliveryDate == null
                      ? 'Not specified'
                      : _formatDate(
                          order.expectedDeliveryDate!,
                        ),
            ),
            _InfoRow(
              label: 'Payment Terms',
              value: _displayValue(
                order.paymentTerms,
              ),
            ),
            _InfoRow(
              label: 'Delivery Terms',
              value: _displayValue(
                order.deliveryTerms,
              ),
            ),
            if (order.notes != null &&
                order.notes!.trim().isNotEmpty) ...[
              const Divider(
                height: AppSpacing.lg,
              ),
              Text(
                'Notes',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                order.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineItemsSection extends ConsumerWidget {
  const _LineItemsSection({
    required this.order,
    required this.onAddItem,
  });

  final PurchaseOrder order;
  final VoidCallback onAddItem;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final itemsAsync = ref.watch(
      purchaseOrderItemsProvider(
        order.id,
      ),
    );

    return itemsAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(
            AppSpacing.xl,
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Unable to load line items.',
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                error.toString(),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        final subtotal = _calculateSubtotal(
          items,
        );

        final tax = _calculateTax(
          items,
        );

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Line Items',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Add Item',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(
                    AppSpacing.lg,
                  ),
                  child: Center(
                    child: Text(
                      'No line items added yet.',
                    ),
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: _LineItemCard(
                    item: item,
                  ),
                ),
              ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _FinancialSummaryCard(
              subtotal: subtotal,
              tax: tax,
              discount: order.discount,
              deliveryCharges:
                  order.deliveryCharges,
            ),
          ],
        );
      },
    );
  }
}

class _LineItemCard extends ConsumerWidget {
  const _LineItemCard({
    required this.item,
  });

  final PurchaseOrderItem item;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final materialAsync = ref.watch(
      materialProvider(
        item.materialId,
      ),
    );

    final materialName = materialAsync.when(
      data: (material) => material.name,
      loading: () => item.description,
      error: (_, _) => item.description,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    materialName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  _formatCurrency(
                    item.total,
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              item.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xs,
              children: [
                _DetailLabel(
                  label: 'Quantity',
                  value:
                      '${_formatNumber(item.quantity)} '
                      '${item.unit}',
                ),
                _DetailLabel(
                  label: 'Unit Rate',
                  value: _formatCurrency(
                    item.unitRate,
                  ),
                ),
                _DetailLabel(
                  label: 'Tax',
                  value:
                      '${_formatNumber(item.taxRate)}%',
                ),
                _DetailLabel(
                  label: 'Subtotal',
                  value: _formatCurrency(
                    item.subtotal,
                  ),
                ),
              ],
            ),
            if (item.notes != null &&
                item.notes!.trim().isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                item.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinancialSummaryCard
    extends StatelessWidget {
  const _FinancialSummaryCard({
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.deliveryCharges,
  });

  final double subtotal;
  final double tax;
  final double discount;
  final double deliveryCharges;

  @override
  Widget build(
    BuildContext context,
  ) {
    final grandTotal =
        subtotal +
        tax +
        deliveryCharges -
        discount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            _AmountRow(
              label: 'Subtotal',
              amount: subtotal,
            ),
            _AmountRow(
              label: 'Tax',
              amount: tax,
            ),
            _AmountRow(
              label: 'Discount',
              amount: discount,
            ),
            _AmountRow(
              label: 'Delivery Charges',
              amount: deliveryCharges,
            ),
            const Divider(
              height: AppSpacing.lg,
            ),
            _AmountRow(
              label: 'Grand Total',
              amount: grandTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(
    BuildContext context,
  ) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
          fontWeight: isTotal
              ? FontWeight.w700
              : FontWeight.w500,
        );

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textStyle,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class _DetailLabel extends StatelessWidget {
  const _DetailLabel({
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
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
      visualDensity:
          VisualDensity.compact,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
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
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
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

double _calculateSubtotal(
  List<PurchaseOrderItem> items,
) {
  return items.fold(
    0,
    (sum, item) => sum + item.subtotal,
  );
}

double _calculateTax(
  List<PurchaseOrderItem> items,
) {
  return items.fold(
    0,
    (sum, item) => sum + item.tax,
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatCurrency(double value) {
  return '₹${value.toStringAsFixed(2)}';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}

String _displayValue(String? value) {
  if (value == null ||
      value.trim().isEmpty) {
    return 'Not specified';
  }

  return value;
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
