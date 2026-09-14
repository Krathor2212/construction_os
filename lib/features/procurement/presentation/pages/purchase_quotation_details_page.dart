import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../materials/presentation/providers/material_providers.dart';
import '../../domain/entities/purchase_quotation.dart';
import '../../domain/entities/purchase_quotation_item.dart';
import '../providers/purchase_quotation_item_providers.dart';
import '../providers/purchase_quotation_providers.dart';
import '../providers/supplier_providers.dart';
import '../widgets/purchase_quotation_item_form_dialog.dart';

class PurchaseQuotationDetailsPage extends ConsumerWidget {
  const PurchaseQuotationDetailsPage({
    required this.projectId,
    required this.quotationId,
    super.key,
  });

  final String projectId;
  final String quotationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationAsync = ref.watch(
      purchaseQuotationProvider(quotationId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Details'),
      ),
      body: quotationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              purchaseQuotationProvider(quotationId),
            );
          },
        ),
        data: (quotation) {
          return _QuotationDetails(
            quotation: quotation,
          );
        },
      ),
    );
  }
}

class _QuotationDetails extends ConsumerWidget {
  const _QuotationDetails({
    required this.quotation,
  });

  final PurchaseQuotation quotation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(
      supplierProvider(quotation.supplierId),
    );

    final supplierName = supplierAsync.when(
      loading: () => 'Loading supplier...',
      error: (_, _) => 'Unknown supplier',
      data: (supplier) => supplier.name,
    );

    final itemsAsync = ref.watch(
      purchaseQuotationItemsProvider(quotation.id),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          purchaseQuotationProvider(quotation.id),
        );
        ref.invalidate(
          purchaseQuotationItemsProvider(quotation.id),
        );

        await ref.read(
          purchaseQuotationProvider(quotation.id).future,
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        children: [
          _HeaderCard(
            quotation: quotation,
            supplierName: supplierName,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          _QuotationInformationCard(
            quotation: quotation,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          _LineItemsSection(
            quotationId: quotation.id,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          itemsAsync.when(
            loading: () => const _FinancialLoadingCard(),
            error: (_, _) => _FinancialSummaryCard(
              subtotal: 0,
              tax: 0,
              discount: quotation.discount,
              deliveryCharges: quotation.deliveryCharges,
            ),
            data: (items) {
              return _FinancialSummaryCard(
                subtotal: _calculateSubtotal(items),
                tax: _calculateTax(items),
                discount: quotation.discount,
                deliveryCharges: quotation.deliveryCharges,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.quotation,
    required this.supplierName,
  });

  final PurchaseQuotation quotation;
  final String supplierName;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    quotation.quotationNumber,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                ),
                _StatusChip(
                  status: quotation.status,
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
                  .titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotationInformationCard extends StatelessWidget {
  const _QuotationInformationCard({
    required this.quotation,
  });

  final PurchaseQuotation quotation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quotation Information',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Quotation Date',
                    value: _formatDate(
                      quotation.quotationDate,
                    ),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Valid Until',
                    value: quotation.validUntil == null
                        ? '—'
                        : _formatDate(
                            quotation.validUntil!,
                          ),
                  ),
                ),
              ],
            ),
            if (quotation.paymentTerms != null &&
                quotation.paymentTerms!.trim().isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.md,
              ),
              _InfoItem(
                label: 'Payment Terms',
                value: quotation.paymentTerms!,
              ),
            ],
            if (quotation.deliveryTerms != null &&
                quotation.deliveryTerms!.trim().isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              _InfoItem(
                label: 'Delivery Terms',
                value: quotation.deliveryTerms!,
              ),
            ],
            if (quotation.notes != null &&
                quotation.notes!.trim().isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              _InfoItem(
                label: 'Notes',
                value: quotation.notes!,
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
    required this.quotationId,
  });

  final String quotationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(
      purchaseQuotationItemsProvider(quotationId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: itemsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => _LineItemsError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                purchaseQuotationItemsProvider(
                  quotationId,
                ),
              );
            },
          ),
          data: (items) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Line Items',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        _showItemDialog(
                          context,
                          ref,
                        );
                      },
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
                  height: AppSpacing.md,
                ),
                if (items.isEmpty)
                  const _NoLineItems()
                else
                  Column(
                    children: [
                      for (final item in items) ...[
                        _LineItemTile(
                          item: item,
                          quotationId: quotationId,
                        ),
                        if (item != items.last)
                          const Divider(
                            height: AppSpacing.lg,
                          ),
                      ],
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showItemDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => PurchaseQuotationItemFormDialog(
        quotationId: quotationId,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        purchaseQuotationItemsProvider(
          quotationId,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quotation item added successfully.',
            ),
          ),
        );
      }
    }
  }
}

class _LineItemTile extends ConsumerWidget {
  const _LineItemTile({
    required this.item,
    required this.quotationId,
  });

  final PurchaseQuotationItem item;
  final String quotationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialAsync = ref.watch(
      materialProvider(item.materialId),
    );

    final materialName = materialAsync.when(
      loading: () => item.description,
      error: (_, _) => item.description,
      data: (material) => material.name,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  materialName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall,
                ),
              ),
              Text(
                _formatCurrency(item.total),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await _editItem(
                      context,
                      ref,
                    );
                  } else if (value == 'delete') {
                    await _deleteItem(
                      context,
                      ref,
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _DetailText(
                label: 'Quantity',
                value:
                    '${_formatNumber(item.quantity)} ${item.unit}',
              ),
              _DetailText(
                label: 'Unit Rate',
                value: _formatCurrency(
                  item.unitRate,
                ),
              ),
              _DetailText(
                label: 'Tax',
                value:
                    '${_formatNumber(item.taxRate)}%',
              ),
            ],
          ),
          if (item.notes != null &&
              item.notes!.trim().isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              item.notes!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editItem(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => PurchaseQuotationItemFormDialog(
        quotationId: quotationId,
        item: item,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        purchaseQuotationItemsProvider(
          quotationId,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quotation item updated successfully.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete quotation item?',
          ),
          content: Text(
            'Delete ${item.description} from this quotation?',
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final repository = ref.read(
        purchaseQuotationItemRepositoryProvider,
      );

      await repository.deleteItem(
        item.id,
      );

      ref.invalidate(
        purchaseQuotationItemsProvider(
          quotationId,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quotation item deleted.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to delete quotation item: $error',
            ),
          ),
        );
      }
    }
  }
}

class _FinancialSummaryCard extends StatelessWidget {
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

  double get total =>
      subtotal +
      tax +
      deliveryCharges -
      discount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            _AmountRow(
              label: 'Subtotal',
              amount: subtotal,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Tax',
              amount: tax,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Discount',
              amount: discount,
              isNegative: true,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Delivery Charges',
              amount: deliveryCharges,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            const Divider(),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              children: [
                Text(
                  'Grand Total',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                const Spacer(),
                Text(
                  _formatCurrency(total),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialLoadingCard extends StatelessWidget {
  const _FinancialLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isNegative = false,
  });

  final String label;
  final double amount;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
        Text(
          isNegative
              ? '-${_formatCurrency(amount)}'
              : _formatCurrency(amount),
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }
}

class _DetailText extends StatelessWidget {
  const _DetailText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(context)
          .textTheme
          .bodySmall,
    );
  }
}

class _NoLineItems extends StatelessWidget {
  const _NoLineItems();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 40,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              'No line items',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Add materials quoted by the supplier.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemsError extends StatelessWidget {
  const _LineItemsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unable to load line items.',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
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
  Widget build(BuildContext context) {
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

  final PurchaseQuotationStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _statusLabel(status),
      ),
      visualDensity: VisualDensity.compact,
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
  Widget build(BuildContext context) {
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
              'Unable to load quotation.',
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

double _calculateSubtotal(
  List<PurchaseQuotationItem> items,
) {
  return items.fold(
    0,
    (sum, item) => sum + item.subtotal,
  );
}

double _calculateTax(
  List<PurchaseQuotationItem> items,
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

String _formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}

String _statusLabel(
  PurchaseQuotationStatus status,
) {
  switch (status) {
    case PurchaseQuotationStatus.draft:
      return 'Draft';

    case PurchaseQuotationStatus.received:
      return 'Received';

    case PurchaseQuotationStatus.underReview:
      return 'Under Review';

    case PurchaseQuotationStatus.accepted:
      return 'Accepted';

    case PurchaseQuotationStatus.rejected:
      return 'Rejected';

    case PurchaseQuotationStatus.expired:
      return 'Expired';
  }
}