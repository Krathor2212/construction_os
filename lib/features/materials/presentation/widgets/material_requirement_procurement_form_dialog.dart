import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material_requirement_procurement.dart';
import '../../../procurement/presentation/providers/purchase_order_providers.dart';

class MaterialRequirementProcurementFormDialog
    extends ConsumerStatefulWidget {
  const MaterialRequirementProcurementFormDialog({
    super.key,
    required this.materialRequirementId,
    required this.projectId,
    this.procurement,
  });

  final String materialRequirementId;
  final String projectId;
  final MaterialRequirementProcurement? procurement;

  @override
  ConsumerState<MaterialRequirementProcurementFormDialog> createState() =>
      _MaterialRequirementProcurementFormDialogState();
}

class _MaterialRequirementProcurementFormDialogState
    extends ConsumerState<MaterialRequirementProcurementFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _purchaseOrderId;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.procurement != null;

  @override
  void initState() {
    super.initState();

    final procurement = widget.procurement;

    _purchaseOrderId = procurement?.purchaseOrderId;

    _quantityController = TextEditingController(
      text: procurement?.quantity.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: procurement?.notes ?? '',
    );
  }

  @override
  void dispose() {
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

    if (_purchaseOrderId == null) {
      return;
    }

    final procurement = MaterialRequirementProcurement(
      id: widget.procurement?.id ??
          'requirement-procurement-${DateTime.now().microsecondsSinceEpoch}',
      materialRequirementId: widget.materialRequirementId,
      purchaseOrderId: _purchaseOrderId!,
      quantity: quantity,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(procurement);
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrdersAsync = ref.watch(
      purchaseOrdersProvider(widget.projectId),
    );

    return AlertDialog(
      title: Text(
        _isEditing ? 'Edit Procurement' : 'Add Procurement',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              purchaseOrdersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Text(
                  'Unable to load purchase orders.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                data: (purchaseOrders) {
                  if (purchaseOrders.isEmpty) {
                    return const Text(
                      'No purchase orders are available for this project.',
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _purchaseOrderId,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order',
                    ),
                    items: purchaseOrders.map((order) {
                      return DropdownMenuItem<String>(
                        value: order.id,
                        child: Text(
                          _purchaseOrderLabel(order),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _purchaseOrderId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select a purchase order.';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(
                    value?.trim() ?? '',
                  );

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

  String _purchaseOrderLabel(dynamic order) {
  return order.id;
  }
}