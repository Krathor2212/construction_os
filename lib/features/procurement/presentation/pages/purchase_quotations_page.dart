import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/purchase_quotation.dart';
import '../providers/purchase_quotation_providers.dart';
import '../providers/supplier_providers.dart';
import '../widgets/purchase_quotation_form_dialog.dart';
import 'package:go_router/go_router.dart';  

class PurchaseQuotationsPage extends ConsumerWidget {
  const PurchaseQuotationsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(
      purchaseQuotationsProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Quotations'),
      ),
      body: quotationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(
              purchaseQuotationsProvider(projectId),
            );
          },
        ),
        data: (quotations) {
          if (quotations.isEmpty) {
            return _EmptyState(
              onAdd: () {
                _showQuotationForm(context, ref);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                purchaseQuotationsProvider(projectId),
              );

              await ref.read(
                purchaseQuotationsProvider(projectId).future,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              itemCount: quotations.length,
              separatorBuilder: (_, _) => const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final quotation = quotations[index];

                return _PurchaseQuotationCard(
                  projectId: projectId,
                  quotation: quotation,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuotationForm(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Quotation'),
      ),
    );
  }

  Future<void> _showQuotationForm(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => PurchaseQuotationFormDialog(
        projectId: projectId,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        purchaseQuotationsProvider(projectId),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase quotation created successfully.',
            ),
          ),
        );
      }
    }
  }
}

class _PurchaseQuotationCard extends ConsumerWidget {
  const _PurchaseQuotationCard({
    required this.projectId,
    required this.quotation,
  });

  final String projectId;
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

    return Card(
        child: InkWell(
      onTap: () {
        context.push(
          '/projects/$projectId/purchase-quotations/${quotation.id}',
        );
      },
      borderRadius: BorderRadius.circular(12),
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
                        .titleMedium,
                  ),
                ),
                _StatusChip(
                  status: quotation.status,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editQuotation(
                        context,
                        ref,
                      );
                    } else if (value == 'archive') {
                      await _archiveQuotation(
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
                      value: 'archive',
                      child: Text('Archive'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.xs,
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
            const Divider(),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              children: [
                Text(
                  'Total',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
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
      ),
    );
  }

  Future<void> _editQuotation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => PurchaseQuotationFormDialog(
        projectId: projectId,
        quotation: quotation,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        purchaseQuotationsProvider(projectId),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase quotation updated successfully.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _archiveQuotation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Archive quotation?',
          ),
          content: Text(
            'Archive ${quotation.quotationNumber}? '
            'It will be removed from active procurement '
            'workflows but retained in history.',
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

    try {
      final repository = ref.read(
        purchaseQuotationRepositoryProvider,
      );

      await repository.archivePurchaseQuotation(
        quotation.id,
      );

      ref.invalidate(
        purchaseQuotationsProvider(projectId),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase quotation archived.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to archive quotation: $error',
            ),
          ),
        );
      }
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.request_quote_outlined,
              size: 56,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No purchase quotations',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Add supplier quotations for this project.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Quotation'),
            ),
          ],
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
              'Unable to load purchase quotations.',
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