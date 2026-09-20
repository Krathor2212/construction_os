import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/worker_attendance.dart';
import '../providers/worker_attendance_providers.dart';
import '../widgets/worker_attendance_form_dialog.dart';

class WorkerAttendancePage extends ConsumerWidget {
  const WorkerAttendancePage({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final String workerId;
  final String workerName;

  Future<void> _addAttendance(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final attendance =
        await showDialog<WorkerAttendance>(
      context: context,
      builder: (_) =>
          WorkerAttendanceFormDialog(
        workerId: workerId,
      ),
    );

    if (attendance == null) {
      return;
    }

    final repository = ref.read(
      workerAttendanceRepositoryProvider,
    );

    await repository.createAttendance(
      attendance,
    );

    ref.invalidate(
      workerAttendanceProvider(workerId),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance added.'),
        ),
      );
    }
  }

  Future<void> _editAttendance(
    BuildContext context,
    WidgetRef ref,
    WorkerAttendance attendance,
  ) async {
    final updatedAttendance =
        await showDialog<WorkerAttendance>(
      context: context,
      builder: (_) =>
          WorkerAttendanceFormDialog(
        workerId: workerId,
        attendance: attendance,
      ),
    );

    if (updatedAttendance == null) {
      return;
    }

    final repository = ref.read(
      workerAttendanceRepositoryProvider,
    );

    await repository.updateAttendance(
      updatedAttendance,
    );

    ref.invalidate(
      workerAttendanceProvider(workerId),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance updated.'),
        ),
      );
    }
  }

  Future<void> _deleteAttendance(
    BuildContext context,
    WidgetRef ref,
    WorkerAttendance attendance,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Attendance'),
          content: const Text(
            'Are you sure you want to delete this attendance record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final repository = ref.read(
      workerAttendanceRepositoryProvider,
    );

    await repository.deleteAttendance(
      attendance.id,
    );

    ref.invalidate(
      workerAttendanceProvider(workerId),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance deleted.'),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final attendanceAsync = ref.watch(
      workerAttendanceProvider(workerId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$workerName Attendance'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            workerAttendanceProvider(workerId),
          );

          await ref.read(
            workerAttendanceProvider(workerId).future,
          );
        },
        child: attendanceAsync.when(
          loading: () => ListView(
            children: const [
              SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Unable to load attendance.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
          data: (attendance) {
            if (attendance.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.event_available_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No attendance records yet.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Record attendance for this worker.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ),
                ],
              );
            }

            final sortedAttendance =
                [...attendance]
                  ..sort(
                    (a, b) => b.date.compareTo(a.date),
                  );

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedAttendance.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record =
                    sortedAttendance[index];

                return _AttendanceCard(
                  attendance: record,
                  onEdit: () => _editAttendance(
                    context,
                    ref,
                    record,
                  ),
                  onDelete: () => _deleteAttendance(
                    context,
                    ref,
                    record,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAttendance(
          context,
          ref,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Attendance'),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.attendance,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkerAttendance attendance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _formatDate(attendance.date),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    _formatStatus(
                      attendance.status,
                    ),
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.schedule_outlined,
                    size: 16,
                  ),
                  label: Text(
                    '${attendance.hoursWorked} hrs',
                  ),
                ),
                if (attendance.overtimeHours > 0)
                  Chip(
                    avatar: const Icon(
                      Icons.more_time_outlined,
                      size: 16,
                    ),
                    label: Text(
                      '${attendance.overtimeHours} OT',
                    ),
                  ),
              ],
            ),
            if (attendance.projectId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Project: ${attendance.projectId}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
            if (attendance.phaseId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Phase: ${attendance.phaseId}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
            if (attendance.notes != null &&
                attendance.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                attendance.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatStatus(
    AttendanceStatus status,
  ) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}