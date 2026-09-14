import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/purchase_quotation_providers.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/purchase_quotation.dart';

class PurchaseQuotationFormDialog extends ConsumerStatefulWidget {
  const PurchaseQuotationFormDialog({
    required this.projectId,
    this.quotation,
    super.key,
  });

  final String projectId;
  final PurchaseQuotation? quotation;

  @override
  ConsumerState<PurchaseQuotationFormDialog> createState() =>
      _PurchaseQuotationFormDialogState();
}

class _PurchaseQuotationFormDialogState
    extends ConsumerState<PurchaseQuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _quotationNumberController;
  late final TextEditingController _discountController;
  late final TextEditingController _deliveryChargesController;
  late final TextEditingController _paymentTermsController;
  late final TextEditingController _deliveryTermsController;
  late final TextEditingController _notesController;

  String? _supplierId;
  PurchaseQuotationStatus _status = PurchaseQuotationStatus.draft;

  DateTime _quotationDate = DateTime.now();
  DateTime? _validUntil;

  @override
  void initState() {
    super.initState();

    final quotation = widget.quotation;

    _quotationNumberController = TextEditingController(
      text: quotation?.quotationNumber ?? '',
    );

    _discountController = TextEditingController(
      text: quotation == null
          ? '0'
          : quotation.discount.toStringAsFixed(2),
    );

    _deliveryChargesController = TextEditingController(
      text: quotation == null
          ? '0'
          : quotation.deliveryCharges.toStringAsFixed(2),
    );

    _paymentTermsController = TextEditingController(
      text: quotation?.paymentTerms ?? '',
    );

    _deliveryTermsController = TextEditingController(
      text: quotation?.deliveryTerms ?? '',
    );

    _notesController = TextEditingController(
      text: quotation?.notes ?? '',
    );

    _supplierId = quotation?.supplierId;
    _status = quotation?.status ?? PurchaseQuotationStatus.draft;
    _quotationDate = quotation?.quotationDate ?? DateTime.now();
    _validUntil = quotation?.validUntil;
  }

  @override
  void dispose() {
    _quotationNumberController.dispose();
    _discountController.dispose();
    _deliveryChargesController.dispose();
    _paymentTermsController.dispose();
    _deliveryTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return AlertDialog(
      title: Text(
        widget.quotation == null
            ? 'Add Purchase Quotation'
            : 'Edit Purchase Quotation',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                suppliersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stackTrace) => const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Unable to load suppliers.',
                    ),
                  ),
                  data: (suppliers) {
                    return DropdownButtonFormField<String>(
                      initialValue: _supplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                      ),
                      items: suppliers
                          .where((supplier) => supplier.isActive)
                          .map(
                            (supplier) => DropdownMenuItem<String>(
                              value: supplier.id,
                              child: Text(supplier.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _supplierId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select a supplier';
                        }

                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _quotationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Quotation Number',
                    hintText: 'e.g. PQ-2026-004',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Quotation number is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PurchaseQuotationStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: PurchaseQuotationStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _DateField(
                  label: 'Quotation Date',
                  date: _quotationDate,
                  onChanged: (date) {
                    setState(() {
                      _quotationDate = date;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _OptionalDateField(
                  label: 'Valid Until',
                  date: _validUntil,
                  onChanged: (date) {
                    setState(() {
                      _validUntil = date;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    prefixText: '₹ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _deliveryChargesController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Charges',
                    prefixText: '₹ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _paymentTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Terms',
                    hintText: 'e.g. 30 days credit',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _deliveryTermsController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Terms',
                    hintText: 'e.g. Delivery within 3 working days',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            widget.quotation == null ? 'Create' : 'Save',
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final discount = double.tryParse(
          _discountController.text.trim(),
        ) ??
        0;

    final deliveryCharges = double.tryParse(
          _deliveryChargesController.text.trim(),
        ) ??
        0;

    if (discount < 0 || deliveryCharges < 0) {
      return;
    }

    final repository = ref.read(
      purchaseQuotationRepositoryProvider,
    );

    try {
      final existing = widget.quotation;

      final quotation = PurchaseQuotation(
        id: existing?.id ??
            'purchase-quotation-${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        supplierId: _supplierId!,
        quotationNumber:
            _quotationNumberController.text.trim(),
        quotationDate: _quotationDate,
        validUntil: _validUntil,
        subtotal: existing?.subtotal ?? 0,
        tax: existing?.tax ?? 0,
        discount: discount,
        deliveryCharges: deliveryCharges,
        paymentTerms: _optionalText(
          _paymentTermsController.text,
        ),
        deliveryTerms: _optionalText(
          _deliveryTermsController.text,
        ),
        notes: _optionalText(
          _notesController.text,
        ),
        status: _status,
        isArchived: existing?.isArchived ?? false,
      );

      if (existing == null) {
        await repository.createPurchaseQuotation(
          quotation,
        );
      } else {
        await repository.updatePurchaseQuotation(
          quotation,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save quotation: $error',
          ),
        ),
      );
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final amount = double.tryParse(value.trim());

    if (amount == null) {
      return 'Enter a valid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  String? _optionalText(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (selected != null) {
          onChanged(selected);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
        ),
        child: Text(_formatDate(date)),
      ),
    );
  }
}

class _OptionalDateField extends StatelessWidget {
  const _OptionalDateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (selected != null) {
                onChanged(selected);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
              ),
              child: Text(
                date == null ? 'Not specified' : _formatDate(date!),
              ),
            ),
          ),
        ),
        if (date != null)
          IconButton(
            onPressed: () {
              onChanged(null);
            },
            icon: const Icon(Icons.clear),
            tooltip: 'Clear date',
          ),
      ],
    );
  }
}

String _statusLabel(PurchaseQuotationStatus status) {
  return switch (status) {
    PurchaseQuotationStatus.draft => 'Draft',
    PurchaseQuotationStatus.received => 'Received',
    PurchaseQuotationStatus.underReview => 'Under Review',
    PurchaseQuotationStatus.accepted => 'Accepted',
    PurchaseQuotationStatus.rejected => 'Rejected',
    PurchaseQuotationStatus.expired => 'Expired',
  };
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}