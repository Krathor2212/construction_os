import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_quotation.dart';
import '../providers/project_providers.dart';
import '../widgets/quotation_form_dialog.dart';

class ProjectQuotationsPage extends ConsumerWidget {
  const ProjectQuotationsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  Future<void> _showQuotationForm(
    BuildContext context,
    WidgetRef ref, {
    ProjectQuotation? quotation,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => QuotationFormDialog(
        projectId: projectId,
        quotation: quotation,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        projectQuotationsProvider(projectId),
      );
    }
  }

  Future<void> _archiveQuotation(
    BuildContext context,
    WidgetRef ref,
    ProjectQuotation quotation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Quotation?'),
          content: Text(
            '${quotation.quotationNumber} will be removed from '
            'the active quotation list but retained in project history.',
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
        projectQuotationRepositoryProvider,
      );

      await repository.archiveQuotation(
        quotation.id,
      );

      ref.invalidate(
        projectQuotationsProvider(projectId),
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${quotation.quotationNumber} archived successfully',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to archive quotation: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(
      projectQuotationsProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Quotations'),
      ),
      body: quotationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.xl,
            ),
            child: Text(
              'Unable to load quotations.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (quotations) {
          if (quotations.isEmpty) {
            return const _EmptyQuotationsState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                projectQuotationsProvider(projectId),
              );

              await ref.read(
                projectQuotationsProvider(projectId).future,
              );
            },
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              itemCount: quotations.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final quotation = quotations[index];

                return _QuotationCard(
                  quotation: quotation,
                  onEdit: () {
                    _showQuotationForm(
                      context,
                      ref,
                      quotation: quotation,
                    );
                  },
                  onArchive: () {
                    _archiveQuotation(
                      context,
                      ref,
                      quotation,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showQuotationForm(context, ref);
        },
        icon: const Icon(
          Icons.add_business_outlined,
        ),
        label: const Text('Add Quotation'),
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
    required this.onEdit,
    required this.onArchive,
  });

  final ProjectQuotation quotation;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        quotation.quotationNumber,
                        style: theme
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(
                        height: AppSpacing.xxs,
                      ),
                      Text(
                        quotation.supplierName,
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  status: quotation.status,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'archive':
                        onArchive();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: Icon(
                          Icons.edit_outlined,
                        ),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: Icon(
                          Icons.archive_outlined,
                        ),
                        title: Text('Archive'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Row(
              children: [
                Expanded(
                  child: _QuotationInfo(
                    label: 'Quotation Date',
                    value: _formatDate(
                      quotation.quotationDate,
                    ),
                  ),
                ),
                Expanded(
                  child: _QuotationInfo(
                    label: 'Valid Until',
                    value: quotation.validUntil == null
                        ? 'Not set'
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

            _AmountRow(
              label: 'Subtotal',
              amount: quotation.subtotal,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            _AmountRow(
              label: 'Tax',
              amount: quotation.tax,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            _AmountRow(
              label: 'Discount',
              amount: quotation.discount,
              isNegative: true,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            const Divider(),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme
                      .textTheme
                      .titleMedium,
                ),
                Text(
                  _formatCurrency(
                    quotation.total,
                  ),
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),
              ],
            ),

            if (quotation.notes != null) ...[
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                quotation.notes!,
                style: theme
                    .textTheme
                    .bodySmall,
              ),
            ],
          ],
        ),
      ),
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
}

class _QuotationInfo extends StatelessWidget {
  const _QuotationInfo({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
        const SizedBox(
          height: AppSpacing.xxs,
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
        Text(
          '${isNegative ? '-' : ''}'
          '₹${amount.toStringAsFixed(2)}',
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

  final ProjectQuotationStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _statusLabel(status),
      ),
      visualDensity:
          VisualDensity.compact,
    );
  }

  String _statusLabel(
    ProjectQuotationStatus status,
  ) {
    return switch (status) {
      ProjectQuotationStatus.draft => 'Draft',
      ProjectQuotationStatus.sent => 'Sent',
      ProjectQuotationStatus.accepted =>
        'Accepted',
      ProjectQuotationStatus.rejected =>
        'Rejected',
      ProjectQuotationStatus.expired =>
        'Expired',
    };
  }
}

class _EmptyQuotationsState
    extends StatelessWidget {
  const _EmptyQuotationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_quote_outlined,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No quotations yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Add supplier quotations to compare '
              'construction material costs.',
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