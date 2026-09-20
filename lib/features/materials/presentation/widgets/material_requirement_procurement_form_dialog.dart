import 'package:flutter/material.dart';

import '../../domain/entities/material_requirement_procurement.dart';

class MaterialRequirementProcurementFormDialog
    extends StatefulWidget {
  const MaterialRequirementProcurementFormDialog({
    super.key,
    required this.materialRequirementId,
    this.procurement,
  });

  final String materialRequirementId;
  final MaterialRequirementProcurement? procurement;

  @override
  State<MaterialRequirementProcurementFormDialog> createState() =>
      _MaterialRequirementProcurementFormDialogState();
}

class _MaterialRequirementProcurementFormDialogState
    extends State<MaterialRequirementProcurementFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _purchaseOrderIdController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.procurement != null;

  @override
  void initState() {
    super.initState();

    final procurement = widget.procurement;

    _purchaseOrderIdController = TextEditingController(
      text: procurement?.purchaseOrderId ?? '',
    );

    _quantityController = TextEditingController(
      text: procurement?.quantity.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: procurement?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _purchaseOrderIdController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    if (quantity == null || quantity <= 0) {
      return;
    }

    final procurement = MaterialRequirementProcurement(
      id: widget.procurement?.id ??
          'requirement-procurement-${DateTime.now().microsecondsSinceEpoch}',
      materialRequirementId: widget.materialRequirementId,
      purchaseOrderId:
          _purchaseOrderIdController.text.trim(),
      quantity: quantity,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(procurement);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit Procurement'
            : 'Add Procurement',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _purchaseOrderIdController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Order ID',
                  hintText: 'e.g. purchase-order-001',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter a purchase order ID.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity =
                      double.tryParse(value?.trim() ?? '');

                  if (quantity == null) {
                    return 'Enter a valid quantity.';
                  }

                  if (quantity <= 0) {
                    return 'Quantity must be greater than zero.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
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
            _isEditing ? 'Save' : 'Add',
          ),
        ),
      ],
    );
  }
}