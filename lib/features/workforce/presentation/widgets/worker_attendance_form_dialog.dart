import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/worker_attendance.dart';

class WorkerAttendanceFormDialog
    extends ConsumerStatefulWidget {
  const WorkerAttendanceFormDialog({
    super.key,
    required this.workerId,
    this.attendance,
  });

  final String workerId;
  final WorkerAttendance? attendance;

  @override
  ConsumerState<WorkerAttendanceFormDialog> createState() =>
      _WorkerAttendanceFormDialogState();
}

class _WorkerAttendanceFormDialogState
    extends ConsumerState<WorkerAttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  AttendanceStatus _status = AttendanceStatus.present;

  String? _projectId;

  late final TextEditingController _hoursController;
  late final TextEditingController _overtimeController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    final attendance = widget.attendance;

    _selectedDate =
        attendance?.date ?? DateTime.now();

    _status =
        attendance?.status ?? AttendanceStatus.present;

    _projectId = attendance?.projectId;

    _hoursController = TextEditingController(
      text: attendance?.hoursWorked.toString() ?? '8',
    );

    _overtimeController = TextEditingController(
      text: attendance?.overtimeHours.toString() ?? '0',
    );

    _notesController = TextEditingController(
      text: attendance?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _overtimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  void _onStatusChanged(AttendanceStatus? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _status = value;

      if (_status == AttendanceStatus.absent ||
          _status == AttendanceStatus.leave) {
        _hoursController.text = '0';
        _overtimeController.text = '0';
      } else if (_status == AttendanceStatus.halfDay) {
        _hoursController.text = '4';
        _overtimeController.text = '0';
      } else if (_status == AttendanceStatus.present &&
          _hoursController.text.trim() == '0') {
        _hoursController.text = '8';
      }
    });
  }

  void _onProjectChanged(String? value) {
    setState(() {
      _projectId = value;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hoursWorked = double.tryParse(
      _hoursController.text.trim(),
    );

    final overtimeHours = double.tryParse(
      _overtimeController.text.trim(),
    );

    if (hoursWorked == null ||
        overtimeHours == null) {
      return;
    }

    final attendance = WorkerAttendance(
      id: widget.attendance?.id ??
          'worker-attendance-${DateTime.now().millisecondsSinceEpoch}',
      workerId: widget.workerId,
      date: _selectedDate,
      status: _status,
      projectId: _projectId,
      phaseId: null,
      hoursWorked: hoursWorked,
      overtimeHours: overtimeHours,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(attendance);
  }

  String _formatStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.attendance == null
            ? 'Add Attendance'
            : 'Edit Attendance',
      ),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AttendanceStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: AttendanceStatus.values.map(
                (status) {
                  return DropdownMenuItem<AttendanceStatus>(
                    value: status,
                    child: Text(
                      _formatStatus(status),
                    ),
                  );
                },
              ).toList(),
              onChanged: _onStatusChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hours Worked',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final hours = double.tryParse(
                  value?.trim() ?? '',
                );

                if (hours == null ||
                    hours < 0 ||
                    hours > 24) {
                  return 'Enter hours between 0 and 24';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _overtimeController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Overtime Hours',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final overtime = double.tryParse(
                  value?.trim() ?? '',
                );

                if (overtime == null ||
                    overtime < 0 ||
                    overtime > 24) {
                  return 'Enter overtime between 0 and 24';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _projectId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'project-001',
                  child: Text('Residential Villa'),
                ),
                DropdownMenuItem(
                  value: 'project-002',
                  child: Text('Commercial Building'),
                ),
              ],
              onChanged: _onProjectChanged,
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}