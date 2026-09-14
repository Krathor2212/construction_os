import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../materials/domain/entities/material.dart' as domain;
import '../../../materials/presentation/providers/material_providers.dart';
import '../../domain/entities/purchase_quotation_item.dart';
import '../providers/purchase_quotation_item_providers.dart';

class PurchaseQuotationItemFormDialog extends ConsumerStatefulWidget {
  const PurchaseQuotationItemFormDialog({
    required this.quotationId,
    this.item,
    super.key,
  });

  final String quotationId;
  final PurchaseQuotationItem? item;

  @override
  ConsumerState<PurchaseQuotationItemFormDialog> createState() =>
      _PurchaseQuotationItemFormDialogState();
}

class _PurchaseQuotationItemFormDialogState
    extends ConsumerState<PurchaseQuotationItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _quantityController;
  late final TextEditingController _unitRateController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _notesController;

  String? _selectedMaterialId;
  String? _selectedUnit;
  bool _isSaving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _selectedMaterialId = item?.materialId;
    _selectedUnit = item?.unit;

    _quantityController = TextEditingController(
      text: item == null ? '' : _formatNumber(item.quantity),
    );

    _unitRateController = TextEditingController(
      text: item == null ? '' : _formatNumber(item.unitRate),
    );

    _taxRateController = TextEditingController(
      text: item == null ? '0' : _formatNumber(item.taxRate),
    );

    _notesController = TextEditingController(
      text: item?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitRateController.dispose();
    _taxRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider);

    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit Quotation Item'
            : 'Add Quotation Item',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                materialsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(
                      AppSpacing.md,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) => _MaterialError(
                    message: error.toString(),
                  ),
                  data: (materials) {
                    final activeMaterials = materials
                        .where(
                          (material) => material.isActive,
                        )
                        .toList();

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedMaterialId,
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        border: OutlineInputBorder(),
                      ),
                      items: activeMaterials
                          .map(
                            (material) => DropdownMenuItem<String>(
                              value: material.id,
                              child: Text(
                                material.name,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedMaterialId = value;

                                final selectedMaterial =
                                    activeMaterials.firstWhere(
                                  (material) =>
                                      material.id == value,
                                );

                                _selectedUnit = _unitLabel(
                                  selectedMaterial.unit,
                                );
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select a material';
                        }

                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_isSaving,
                        validator: _validatePositiveNumber,
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedUnit ?? '—',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                TextFormField(
                  controller: _unitRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Unit Rate',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isSaving,
                  validator: _validatePositiveNumber,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                TextFormField(
                  controller: _taxRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Tax Rate',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isSaving,
                  validator: _validateTaxRate,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                TextFormField(
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  enabled: !_isSaving,
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
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving
              ? null
              : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _isEditing ? 'Update' : 'Add',
                ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMaterialId == null) {
      return;
    }

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final unitRate = double.tryParse(
      _unitRateController.text.trim(),
    );

    final taxRate = double.tryParse(
      _taxRateController.text.trim(),
    );

    if (quantity == null ||
        unitRate == null ||
        taxRate == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(
        purchaseQuotationItemRepositoryProvider,
      );

      final item = widget.item;

      if (item == null) {
        final newItem = PurchaseQuotationItem(
          id: 'purchase-item-${DateTime.now().millisecondsSinceEpoch}',
          quotationId: widget.quotationId,
          materialId: _selectedMaterialId!,
          description: _materialDescription(),
          quantity: quantity,
          unit: _selectedUnit ?? '',
          unitRate: unitRate,
          taxRate: taxRate,
          notes: _nullableText(
            _notesController.text,
          ),
        );

        await repository.createItem(newItem);
      } else {
        final updatedItem = PurchaseQuotationItem(
          id: item.id,
          quotationId: item.quotationId,
          materialId: _selectedMaterialId!,
          description: _materialDescription(
            fallback: item.description,
          ),
          quantity: quantity,
          unit: _selectedUnit ?? item.unit,
          unitRate: unitRate,
          taxRate: taxRate,
          notes: _nullableText(
            _notesController.text,
          ),
        );

        await repository.updateItem(updatedItem);
      }

      ref.invalidate(
        purchaseQuotationItemsProvider(
          widget.quotationId,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to save quotation item: $error',
            ),
          ),
        );
      }
    }
  }

  String _materialDescription({
    String? fallback,
  }) {
    final materialsAsync = ref.read(
      materialsProvider,
    );

    return materialsAsync.maybeWhen(
      data: (materials) {
        for (final material in materials) {
          if (material.id == _selectedMaterialId) {
            return material.name;
          }
        }

        return fallback ?? 'Material';
      },
      orElse: () => fallback ?? 'Material',
    );
  }
}

class _MaterialError extends StatelessWidget {
  const _MaterialError({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Material',
        border: OutlineInputBorder(),
        errorText: 'Unable to load materials',
      ),
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

String? _validatePositiveNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }

  final number = double.tryParse(
    value.trim(),
  );

  if (number == null) {
    return 'Enter a valid number';
  }

  if (number <= 0) {
    return 'Must be greater than 0';
  }

  return null;
}

String? _validateTaxRate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }

  final number = double.tryParse(
    value.trim(),
  );

  if (number == null) {
    return 'Enter a valid number';
  }

  if (number < 0 || number > 100) {
    return 'Enter 0–100';
  }

  return null;
}

String? _nullableText(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return null;
  }

  return text;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}

String _unitLabel(domain.MaterialUnit unit) {
  switch (unit) {
    case domain.MaterialUnit.kg:
      return 'kg';

    case domain.MaterialUnit.tonne:
      return 'tonne';

    case domain.MaterialUnit.bag:
      return 'bag';

    case domain.MaterialUnit.piece:
      return 'piece';

    case domain.MaterialUnit.cubicMeter:
      return 'm³';

    case domain.MaterialUnit.squareMeter:
      return 'm²';

    case domain.MaterialUnit.liter:
      return 'liter';

    case domain.MaterialUnit.meter:
      return 'meter';

    case domain.MaterialUnit.box:
      return 'box';

    case domain.MaterialUnit.set:
      return 'set';

    case domain.MaterialUnit.other:
      return 'other';
  }
}