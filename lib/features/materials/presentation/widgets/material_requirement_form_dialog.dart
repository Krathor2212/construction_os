import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/material_requirement.dart';
import '../providers/material_providers.dart';

class MaterialRequirementFormDialog extends ConsumerStatefulWidget {
  const MaterialRequirementFormDialog({
    super.key,
    required this.projectId,
    this.requirement,
  });

  final String projectId;
  final MaterialRequirement? requirement;

  @override
  ConsumerState<MaterialRequirementFormDialog> createState() =>
      _MaterialRequirementFormDialogState();
}

class _MaterialRequirementFormDialogState
    extends ConsumerState<MaterialRequirementFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _materialId;

  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _phaseController;
  late final TextEditingController _notesController;

  DateTime? _requiredByDate;
  late MaterialRequirementStatus _status;

  bool get _isEditing => widget.requirement != null;

  @override
  void initState() {
    super.initState();

    final requirement = widget.requirement;

    _materialId = requirement?.materialId;

    _quantityController = TextEditingController(
      text: requirement == null ? '' : requirement.quantity.toString(),
    );

    _unitController = TextEditingController(
      text: requirement?.unit ?? '',
    );

    _phaseController = TextEditingController(
      text: requirement?.phaseId ?? '',
    );

    _notesController = TextEditingController(
      text: requirement?.notes ?? '',
    );

    _requiredByDate = requirement?.requiredByDate;

    _status =
        requirement?.status ?? MaterialRequirementStatus.planned;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    _phaseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectRequiredByDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _requiredByDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _requiredByDate = selectedDate;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_materialId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a material.'),
        ),
      );
      return;
    }

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be greater than zero.'),
        ),
      );
      return;
    }

    final phaseValue = _phaseController.text.trim();

    final requirement = MaterialRequirement(
      id: widget.requirement?.id ??
          'material-requirement-'
              '${DateTime.now().microsecondsSinceEpoch}',
      projectId: widget.projectId,
      phaseId: phaseValue.isEmpty ? null : phaseValue,
      materialId: _materialId!,
      quantity: quantity,
      unit: _unitController.text.trim(),
      requiredByDate: _requiredByDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: _status,
      isArchived: widget.requirement?.isArchived ?? false,
    );

    Navigator.of(context).pop(requirement);
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider);

    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit Material Requirement'
            : 'Add Material Requirement',
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
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Text(
                    'Unable to load materials: $error',
                  ),
                  data: (materials) {
                    final activeMaterials = materials
                        .where((material) => material.isActive)
                        .toList();

                    return DropdownButtonFormField<String>(
                      initialValue: _materialId,
                      decoration: const InputDecoration(
                        labelText: 'Material',
                      ),
                      items: activeMaterials.map((material) {
                        return DropdownMenuItem<String>(
                          value: material.id,
                          child: Text(material.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _materialId = value;

                          if (value == null) {
                            return;
                          }

                          final selectedMaterial =
                              activeMaterials.firstWhere(
                            (material) => material.id == value,
                          );

                          _unitController.text = _formatUnit(
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Required Quantity',
                  ),
                  validator: (value) {
                    final quantity = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (quantity == null || quantity <= 0) {
                      return 'Enter a valid quantity';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a unit';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phaseController,
                  decoration: const InputDecoration(
                    labelText: 'Phase ID',
                    hintText: 'Example: phase-001',
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Required By'),
                  subtitle: Text(
                    _requiredByDate == null
                        ? 'Not specified'
                        : _formatDate(_requiredByDate!),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                  onTap: _selectRequiredByDate,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MaterialRequirementStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items:
                      MaterialRequirementStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_formatStatus(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
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
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  String _formatUnit(domain.MaterialUnit unit) {
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
        return 'cubicMeter';
      case domain.MaterialUnit.squareMeter:
        return 'squareMeter';
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

  String _formatStatus(MaterialRequirementStatus status) {
    switch (status) {
      case MaterialRequirementStatus.planned:
        return 'Planned';
      case MaterialRequirementStatus.partiallyProcured:
        return 'Partially Procured';
      case MaterialRequirementStatus.procured:
        return 'Procured';
      case MaterialRequirementStatus.completed:
        return 'Completed';
      case MaterialRequirementStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}