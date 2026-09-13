import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_quotation.dart';
import '../providers/project_providers.dart';

class ProjectQuotationsPage extends ConsumerWidget {
  const ProjectQuotationsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(
      projectQuotationsProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
      ),
      body: quotationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load quotations'),
        ),
        data: (quotations) {
          if (quotations.isEmpty) {
            return const _EmptyQuotationsState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: quotations.length,
            separatorBuilder: (_, _) => const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              return _QuotationCard(
                quotation: quotations[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.request_quote_outlined),
        label: const Text('Add Quotation'),
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  const _QuotationCard({
    required this.quotation,
  });

  final ProjectQuotation quotation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quotation.quotationNumber,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        quotation.supplierName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  status: quotation.status,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _QuotationInfoRow(
              label: 'Quotation Date',
              value: _formatDate(
                quotation.quotationDate,
              ),
            ),
            if (quotation.validUntil != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _QuotationInfoRow(
                label: 'Valid Until',
                value: _formatDate(
                  quotation.validUntil!,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _AmountRow(
              label: 'Subtotal',
              amount: quotation.subtotal,
            ),
            const SizedBox(height: AppSpacing.xs),
            _AmountRow(
              label: 'Tax',
              amount: quotation.tax,
            ),
            const SizedBox(height: AppSpacing.xs),
            _AmountRow(
              label: 'Discount',
              amount: quotation.discount,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _AmountRow(
              label: 'Total',
              amount: quotation.total,
              emphasized: true,
            ),
            if (quotation.notes != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                quotation.notes!,
                style: Theme.of(context).textTheme.bodySmall,
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
}

class _QuotationInfoRow extends StatelessWidget {
  const _QuotationInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  final String label;
  final double amount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: style,
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
      visualDensity: VisualDensity.compact,
    );
  }

  String _statusLabel(ProjectQuotationStatus status) {
    switch (status) {
      case ProjectQuotationStatus.draft:
        return 'Draft';
      case ProjectQuotationStatus.sent:
        return 'Sent';
      case ProjectQuotationStatus.accepted:
        return 'Accepted';
      case ProjectQuotationStatus.rejected:
        return 'Rejected';
      case ProjectQuotationStatus.expired:
        return 'Expired';
    }
  }
}

class _EmptyQuotationsState extends StatelessWidget {
  const _EmptyQuotationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_quote_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No quotations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add supplier quotations to compare costs '
              'and manage project procurement.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}