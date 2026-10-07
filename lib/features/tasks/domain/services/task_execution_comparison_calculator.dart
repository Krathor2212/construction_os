import '../entities/project_task.dart';
import '../entities/task_execution_comparison.dart';

class TaskExecutionComparisonCalculator {
  const TaskExecutionComparisonCalculator();

  TaskExecutionComparison calculate(
    ProjectTask task, {
    DateTime? referenceDate,
  }) {
    final plannedDurationDays = _inclusiveDays(
      task.plannedStartDate,
      task.plannedEndDate,
    );

    if (task.actualEndDate != null) {
      final actualDurationDays = _inclusiveDays(
        task.actualStartDate ?? task.actualEndDate!,
        task.actualEndDate!,
      );
      final varianceDays = _dateOnly(task.actualEndDate!)
          .difference(_dateOnly(task.plannedEndDate))
          .inDays;

      return TaskExecutionComparison(
        plannedDurationDays: plannedDurationDays,
        actualDurationDays: actualDurationDays,
        varianceDays: varianceDays,
        isOverdue: varianceDays > 0,
        varianceLabel: _completedVarianceLabel(varianceDays),
      );
    }

    if (task.status == ProjectTaskStatus.completed || task.progress >= 100) {
      return TaskExecutionComparison(
        plannedDurationDays: plannedDurationDays,
        actualDurationDays: null,
        varianceDays: null,
        isOverdue: false,
        varianceLabel: 'Actual end date missing',
      );
    }

    final today = _dateOnly(referenceDate ?? DateTime.now());
    final plannedEnd = _dateOnly(task.plannedEndDate);
    final actualDurationDays = task.actualStartDate == null
        ? null
        : _inclusiveDays(task.actualStartDate!, today);
    final isOverdue = today.isAfter(plannedEnd) && task.progress < 100;
    final overdueDays = isOverdue ? today.difference(plannedEnd).inDays : null;

    return TaskExecutionComparison(
      plannedDurationDays: plannedDurationDays,
      actualDurationDays: actualDurationDays,
      varianceDays: overdueDays,
      isOverdue: isOverdue,
      varianceLabel: isOverdue
          ? 'Overdue by ${_daysLabel(overdueDays!)}'
          : 'In progress',
    );
  }

  int _inclusiveDays(DateTime start, DateTime end) {
    return _dateOnly(end).difference(_dateOnly(start)).inDays + 1;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _completedVarianceLabel(int varianceDays) {
    if (varianceDays == 0) {
      return 'On schedule';
    }
    if (varianceDays > 0) {
      return '${_daysLabel(varianceDays)} late';
    }
    return '${_daysLabel(varianceDays.abs())} early';
  }

  String _daysLabel(int days) {
    return '$days day${days == 1 ? '' : 's'}';
  }
}
