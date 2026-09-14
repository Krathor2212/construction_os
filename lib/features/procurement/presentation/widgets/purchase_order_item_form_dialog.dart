import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/purchase_order_item.dart';

class PurchaseOrderItemFormDialog extends StatefulWidget {
  const PurchaseOrderItemFormDialog({
    super.key,
    required this.purchaseOrderId,
    this.item,
  });

  final String purchaseOrderId;
  final PurchaseOrderItem? item;

  bool get isEditing => item != null;

  @override
  State<PurchaseOrderItemFormDialog> createState() =>
      _PurchaseOrderItemFormDialogState();
}

class _PurchaseOrderItemFormDialogState
    extends State<PurchaseOrderItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _materialIdController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _unitRateController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _materialIdController = TextEditingController(
      text: item?.materialId ?? '',
    );

    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    _quantityController = TextEditingController(
      text: item == null ? '' : item.quantity.toString(),
    );

    _unitController = TextEditingController(
      text: item?.unit ?? '',
    );

    _unitRateController = TextEditingController(
      text: item == null ? '' : item.unitRate.toString(),
    );

    _taxRateController = TextEditingController(
      text: item == null ? '0' : item.taxRate.toString(),
    );

    _notesController = TextEditingController(
      text: item?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _materialIdController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitRateController.dispose();
    _taxRateController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing
            ? 'Edit PO Item'
            : 'Add PO Item',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _materialIdController,
                  label: 'Material ID',
                  hint: 'Example: material-002',
                  validator: _requiredValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Example: TMT Steel 12mm',
                  validator: _requiredValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _quantityController,
                  label: 'Quantity',
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _unitController,
                  label: 'Unit',
                  hint: 'Example: kg',
                  validator: _requiredValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _unitRateController,
                  label: 'Unit Rate',
                  validator: _positiveNumberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _taxRateController,
                  label: 'Tax Rate',
                  suffixText: '%',
                  validator: _taxRateValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
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
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.isEditing
                ? 'Save Changes'
                : 'Add Item',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = PurchaseOrderItem(
      id: widget.item?.id ??
          'purchase-order-item-'
              '${DateTime.now().microsecondsSinceEpoch}',
      purchaseOrderId:
          widget.item?.purchaseOrderId ??
              widget.purchaseOrderId,
      materialId: _materialIdController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: double.parse(
        _quantityController.text.trim(),
      ),
      unit: _unitController.text.trim(),
      unitRate: double.parse(
        _unitRateController.text.trim(),
      ),
      taxRate: double.parse(
        _taxRateController.text.trim(),
      ),
      notes: _optionalValue(
        _notesController.text,
      ),
    );

    Navigator.of(context).pop(item);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a value';
    }

    final number = double.tryParse(
      value.trim(),
    );

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number <= 0) {
      return 'Value must be greater than 0';
    }

    return null;
  }

  String? _taxRateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter tax rate';
    }

    final number = double.tryParse(
      value.trim(),
    );

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0 || number > 100) {
      return 'Tax rate must be between 0 and 100';
    }

    return null;
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }
}