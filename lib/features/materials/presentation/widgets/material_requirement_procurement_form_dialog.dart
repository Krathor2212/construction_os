import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../procurement/presentation/providers/purchase_order_item_providers.dart';
import '../../../procurement/presentation/providers/purchase_order_providers.dart';
import '../../domain/entities/material_requirement_procurement.dart';
import '../../domain/usecases/validate_material_requirement_procurement_quantity.dart';
import '../providers/material_requirement_procurement_providers.dart';
import '../providers/material_requirement_providers.dart';

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
  String? _purchaseOrderItemId;

  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _purchaseOrderId = widget.procurement?.purchaseOrderId;
    _purchaseOrderItemId = widget.procurement?.purchaseOrderItemId;

    _quantityController = TextEditingController(
      text: widget.procurement?.quantity.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: widget.procurement?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPurchaseOrderChanged(String? value) {
    setState(() {
      _purchaseOrderId = value;
      _purchaseOrderItemId = null;
    });
  }

  void _onPurchaseOrderItemChanged(String? value) {
    setState(() {
      _purchaseOrderItemId = value;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_purchaseOrderId == null ||
          _purchaseOrderItemId == null) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a purchase order and item.',
            ),
          ),
        );

        return;
      }

      final quantity = double.tryParse(
        _quantityController.text.trim(),
      );

      if (quantity == null || quantity <= 0) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter a valid quantity.',
            ),
          ),
        );

        return;
      }

      final purchaseOrderItems = await ref.read(
        purchaseOrderItemsProvider(
          _purchaseOrderId!,
        ).future,
      );

      final selectedItem = purchaseOrderItems
          .where(
            (item) => item.id == _purchaseOrderItemId,
          )
          .firstOrNull;

      if (selectedItem == null) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected purchase order item was not found.',
            ),
          ),
        );

        return;
      }

      final requirementProcurements = await ref.read(
        materialRequirementProcurementsProvider(
          widget.materialRequirementId,
        ).future,
      );

      final purchaseOrderItemProcurements = await ref.read(
        materialRequirementProcurementsByPurchaseOrderItemProvider(
          _purchaseOrderItemId!,
        ).future,
      );

      final requirement = await ref.read(
        materialRequirementProvider(
          widget.materialRequirementId,
        ).future,
      );

      final validationError =
          const ValidateMaterialRequirementProcurementQuantity()
              .execute(
        requirement: requirement,
        purchaseOrderItemQuantity: selectedItem.quantity,
        existingRequirementProcurements:
            requirementProcurements,
        existingPurchaseOrderItemProcurements:
            purchaseOrderItemProcurements,
        requestedQuantity: quantity,
        currentProcurementId: widget.procurement?.id,
      );

      if (validationError != null) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
          ),
        );

        return;
      }

      final repository = ref.read(
        materialRequirementProcurementRepositoryProvider,
      );

      final procurement = MaterialRequirementProcurement(
        id: widget.procurement?.id ??
            'requirement-procurement-${DateTime.now().millisecondsSinceEpoch}',
        materialRequirementId:
            widget.materialRequirementId,
        purchaseOrderId: _purchaseOrderId!,
        purchaseOrderItemId: _purchaseOrderItemId!,
        quantity: quantity,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      late final MaterialRequirementProcurement savedProcurement;

      if (widget.procurement == null) {
        savedProcurement =
            await repository.createProcurement(
          procurement,
        );
      } else {
        savedProcurement =
            await repository.updateProcurement(
          procurement,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(savedProcurement);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save procurement: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseOrdersAsync = ref.watch(
      purchaseOrdersProvider(widget.projectId),
    );

    final purchaseOrderItemsAsync =
        _purchaseOrderId == null
            ? null
            : ref.watch(
                purchaseOrderItemsProvider(
                  _purchaseOrderId!,
                ),
              );

    return AlertDialog(
      title: Text(
        widget.procurement == null
            ? 'Add Procurement Allocation'
            : 'Edit Procurement Allocation',
      ),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            purchaseOrdersAsync.when(
              loading: () =>
                  const LinearProgressIndicator(),
              error: (error, stackTrace) => Text(
                'Failed to load purchase orders: $error',
              ),
              data: (orders) {
                return DropdownButtonFormField<String>(
                  initialValue: _purchaseOrderId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Order',
                    border: OutlineInputBorder(),
                  ),
                  items: orders.map((order) {
                    return DropdownMenuItem<String>(
                      value: order.id,
                      child: Text(
                        order.id,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: _onPurchaseOrderChanged,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Select a purchase order';
                    }

                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            if (_purchaseOrderId != null)
              purchaseOrderItemsAsync!.when(
                loading: () =>
                    const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(
                  'Failed to load purchase order items: $error',
                ),
                data: (items) {
                  return DropdownButtonFormField<String>(
                    initialValue: _purchaseOrderItemId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order Item',
                      border: OutlineInputBorder(),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.id,
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            '${item.description} — '
                            '${item.quantity} ${item.unit}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged:
                        _onPurchaseOrderItemChanged,
                    validator: (value) {
                      if (_purchaseOrderId != null &&
                          (value == null ||
                              value.isEmpty)) {
                        return 'Select a purchase order item';
                      }

                      return null;
                    },
                  );
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Allocated Quantity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final quantity = double.tryParse(
                  value?.trim() ?? '',
                );

                if (quantity == null ||
                    quantity <= 0) {
                  return 'Enter a valid quantity';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}