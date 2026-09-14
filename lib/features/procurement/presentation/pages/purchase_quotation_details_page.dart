import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/purchase_quotation.dart';
import '../providers/purchase_quotation_providers.dart';
import '../providers/supplier_providers.dart';

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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          purchaseQuotationProvider(quotation.id),
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
          _FinancialSummaryCard(
            quotation: quotation,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          const _LineItemsPlaceholder(),
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
            const SizedBox(
              height: AppSpacing.md,
            ),
            _OptionalInfoItem(
              label: 'Payment Terms',
              value: quotation.paymentTerms,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _OptionalInfoItem(
              label: 'Delivery Terms',
              value: quotation.deliveryTerms,
            ),
            if (quotation.notes != null &&
                quotation.notes!.trim().isNotEmpty) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              _OptionalInfoItem(
                label: 'Notes',
                value: quotation.notes,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({
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
              amount: quotation.subtotal,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Tax',
              amount: quotation.tax,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Discount',
              amount: quotation.discount,
              isNegative: true,
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _AmountRow(
              label: 'Delivery Charges',
              amount: quotation.deliveryCharges,
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
                  _formatCurrency(
                    quotation.total,
                  ),
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

class _LineItemsPlaceholder extends StatelessWidget {
  const _LineItemsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'Quotation Line Items',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Material-wise quotation items will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _OptionalInfoItem extends StatelessWidget {
  const _OptionalInfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

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
          text,
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
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
