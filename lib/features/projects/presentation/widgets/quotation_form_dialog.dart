import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_quotation.dart';
import '../providers/project_providers.dart';

class QuotationFormDialog extends ConsumerStatefulWidget {
  const QuotationFormDialog({
    required this.projectId,
    this.quotation,
    super.key,
  });

  final String projectId;
  final ProjectQuotation? quotation;

  bool get isEditing => quotation != null;

  @override
  ConsumerState<QuotationFormDialog> createState() =>
      _QuotationFormDialogState();
}

class _QuotationFormDialogState
    extends ConsumerState<QuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _supplierController;
  late final TextEditingController _subtotalController;
  late final TextEditingController _taxController;
  late final TextEditingController _discountController;
  late final TextEditingController _notesController;

  late DateTime _quotationDate;
  DateTime? _validUntil;
  late ProjectQuotationStatus _status;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final quotation = widget.quotation;

    _numberController = TextEditingController(
      text: quotation?.quotationNumber ?? '',
    );

    _supplierController = TextEditingController(
      text: quotation?.supplierName ?? '',
    );

    _subtotalController = TextEditingController(
      text: quotation?.subtotal.toStringAsFixed(2) ?? '0',
    );

    _taxController = TextEditingController(
      text: quotation?.tax.toStringAsFixed(2) ?? '0',
    );

    _discountController = TextEditingController(
      text: quotation?.discount.toStringAsFixed(2) ?? '0',
    );

    _notesController = TextEditingController(
      text: quotation?.notes ?? '',
    );

    _quotationDate =
        quotation?.quotationDate ?? DateTime.now();

    _validUntil = quotation?.validUntil;

    _status =
        quotation?.status ??
        ProjectQuotationStatus.draft;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _supplierController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _statusLabel(ProjectQuotationStatus status) {
    return switch (status) {
      ProjectQuotationStatus.draft => 'Draft',
      ProjectQuotationStatus.sent => 'Sent',
      ProjectQuotationStatus.accepted => 'Accepted',
      ProjectQuotationStatus.rejected => 'Rejected',
      ProjectQuotationStatus.expired => 'Expired',
    };
  }

  Future<void> _selectQuotationDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _quotationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _quotationDate = selected;
    });
  }

  Future<void> _selectValidUntil() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _validUntil ??
          _quotationDate.add(
            const Duration(days: 15),
          ),
      firstDate: _quotationDate,
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _validUntil = selected;
    });
  }

  double _parseAmount(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  Future<void> _saveQuotation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subtotal =
        _parseAmount(_subtotalController.text);

    final tax =
        _parseAmount(_taxController.text);

    final discount =
        _parseAmount(_discountController.text);

    if (discount > subtotal + tax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Discount cannot be greater than the quotation value.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final existingQuotation = widget.quotation;

      final quotation = ProjectQuotation(
        id: existingQuotation?.id ??
            'quotation-${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        quotationNumber:
            _numberController.text.trim(),
        supplierName:
            _supplierController.text.trim(),
        quotationDate: _quotationDate,
        validUntil: _validUntil,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        status: _status,
        isArchived:
            existingQuotation?.isArchived ?? false,
      );

      final repository = ref.read(
        projectQuotationRepositoryProvider,
      );

      if (widget.isEditing) {
        await repository.updateQuotation(
          quotation,
        );
      } else {
        await repository.createQuotation(
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

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update quotation: $error'
                : 'Unable to create quotation: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit Quotation'
        : 'Add Quotation';

    final saveLabel = widget.isEditing
        ? 'Update Quotation'
        : 'Save Quotation';

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _numberController,
                  textCapitalization:
                      TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Quotation Number',
                    hintText: 'e.g. QT-2026-004',
                    prefixIcon: Icon(
                      Icons.receipt_long_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a quotation number';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _supplierController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    hintText: 'e.g. Sri Murugan Steels',
                    prefixIcon: Icon(
                      Icons.business_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a supplier name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                DropdownButtonFormField<
                    ProjectQuotationStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                    ),
                  ),
                  items:
                      ProjectQuotationStatus.values
                          .map(
                    (status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          _statusLabel(status),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                  title: const Text(
                    'Quotation Date',
                  ),
                  subtitle: Text(
                    _formatDate(_quotationDate),
                  ),
                  trailing: TextButton(
                    onPressed:
                        _selectQuotationDate,
                    child: const Text('Change'),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.event_outlined,
                  ),
                  title: const Text(
                    'Valid Until',
                  ),
                  subtitle: Text(
                    _validUntil == null
                        ? 'Not set'
                        : _formatDate(_validUntil!),
                  ),
                  trailing: TextButton(
                    onPressed: _selectValidUntil,
                    child: const Text('Change'),
                  ),
                ),

                const Divider(),

                TextFormField(
                  controller: _subtotalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Subtotal',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    prefixIcon: Icon(
                      Icons.calculate_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter subtotal';
                    }

                    final amount =
                        double.tryParse(
                      value.trim(),
                    );

                    if (amount == null ||
                        amount < 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _taxController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Tax',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    prefixIcon: Icon(
                      Icons.percent_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter tax';
                    }

                    final amount =
                        double.tryParse(
                      value.trim(),
                    );

                    if (amount == null ||
                        amount < 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _discountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    hintText: '0.00',
                    prefixText: '₹ ',
                    prefixIcon: Icon(
                      Icons.discount_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter discount';
                    }

                    final amount =
                        double.tryParse(
                      value.trim(),
                    );

                    if (amount == null ||
                        amount < 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _notesController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText:
                        'Optional quotation notes',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              _isSaving ? null : _saveQuotation,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            _isSaving
                ? 'Saving...'
                : saveLabel,
          ),
        ),
      ],
    );
  }
}