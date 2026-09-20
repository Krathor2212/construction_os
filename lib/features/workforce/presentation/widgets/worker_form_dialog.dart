import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/worker.dart';

class WorkerFormDialog extends StatefulWidget {
  const WorkerFormDialog({
    super.key,
    this.worker,
  });

  final Worker? worker;

  bool get isEditing => worker != null;

  @override
  State<WorkerFormDialog> createState() => _WorkerFormDialogState();
}

class _WorkerFormDialogState extends State<WorkerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dailyWageController;
  late final TextEditingController _overtimeRateController;
  late final TextEditingController _notesController;

  late WorkerRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    final worker = widget.worker;

    _nameController = TextEditingController(
      text: worker?.name ?? '',
    );

    _phoneController = TextEditingController(
      text: worker?.phone ?? '',
    );

    _dailyWageController = TextEditingController(
      text: worker != null
          ? worker.dailyWage.toStringAsFixed(0)
          : '',
    );

    _overtimeRateController = TextEditingController(
      text: worker != null
          ? worker.overtimeRate.toStringAsFixed(0)
          : '',
    );

    _notesController = TextEditingController(
      text: worker?.notes ?? '',
    );

    _selectedRole = worker?.role ?? WorkerRole.mason;
    _isActive = worker?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dailyWageController.dispose();
    _overtimeRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    final dailyWage =
        double.parse(_dailyWageController.text.trim());

    final overtimeRate =
        double.parse(_overtimeRateController.text.trim());

    final notes = _notesController.text.trim();

    final worker = Worker(
      id: widget.worker?.id ??
          'worker-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      role: _selectedRole,
      phone: phone,
      dailyWage: dailyWage,
      overtimeRate: overtimeRate,
      isActive: _isActive,
      notes: notes.isEmpty ? null : notes,
    );

    Navigator.of(context).pop(worker);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit Worker' : 'Add Worker',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Worker name',
                    hintText: 'Enter worker name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter worker name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<WorkerRole>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(
                      Icons.work_outline,
                    ),
                  ),
                  items: WorkerRole.values.map((role) {
                    return DropdownMenuItem<WorkerRole>(
                      value: role,
                      child: Text(_roleLabel(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter phone number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _dailyWageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Daily wage',
                    hintText: 'e.g. 900',
                    prefixIcon: Icon(
                      Icons.payments_outlined,
                    ),
                    prefixText: '₹ ',
                  ),
                  validator: _validateMoney,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _overtimeRateController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Overtime rate / hour',
                    hintText: 'e.g. 150',
                    prefixIcon: Icon(
                      Icons.more_time_outlined,
                    ),
                    prefixText: '₹ ',
                  ),
                  validator: _validateMoney,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active worker'),
                  subtitle: Text(
                    _isActive
                        ? 'Available for work'
                        : 'Currently unavailable',
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                    ),
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
          onPressed: _save,
          child: Text(
            widget.isEditing ? 'Save Changes' : 'Add Worker',
          ),
        ),
      ],
    );
  }

  String? _validateMoney(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an amount';
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

  String _roleLabel(WorkerRole role) {
    switch (role) {
      case WorkerRole.mason:
        return 'Mason';
      case WorkerRole.helper:
        return 'Helper';
      case WorkerRole.carpenter:
        return 'Carpenter';
      case WorkerRole.electrician:
        return 'Electrician';
      case WorkerRole.plumber:
        return 'Plumber';
      case WorkerRole.painter:
        return 'Painter';
      case WorkerRole.welder:
        return 'Welder';
      case WorkerRole.supervisor:
        return 'Supervisor';
      case WorkerRole.siteEngineer:
        return 'Site Engineer';
      case WorkerRole.other:
        return 'Other';
    }
  }
}