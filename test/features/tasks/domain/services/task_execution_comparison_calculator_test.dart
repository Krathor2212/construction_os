import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/features/tasks/domain/entities/project_task.dart';
import 'package:construction_os/features/tasks/domain/services/task_execution_comparison_calculator.dart';

void main() {
  const calculator = TaskExecutionComparisonCalculator();

  ProjectTask task({
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    double progress = 0,
  }) {
    return ProjectTask(
      id: 'task-1',
      projectId: 'project-1',
      phaseId: 'phase-1',
      name: 'Foundation excavation',
      plannedStartDate: DateTime(2026, 9, 22),
      plannedEndDate: DateTime(2026, 9, 24),
      actualStartDate: actualStartDate,
      actualEndDate: actualEndDate,
      status: actualEndDate == null
          ? ProjectTaskStatus.inProgress
          : ProjectTaskStatus.completed,
      priority: ProjectTaskPriority.high,
      progress: progress,
    );
  }

  test('calculates planned and actual duration with late variance', () {
    final result = calculator.calculate(
      task(
        actualStartDate: DateTime(2026, 9, 22),
        actualEndDate: DateTime(2026, 9, 27),
        progress: 100,
      ),
    );

    expect(result.plannedDurationDays, 3);
    expect(result.actualDurationDays, 6);
    expect(result.varianceDays, 3);
    expect(result.varianceLabel, '3 days late');
    expect(result.isOverdue, isTrue);
  });

  test('reports an in-progress task as overdue after planned end', () {
    final result = calculator.calculate(
      task(actualStartDate: DateTime(2026, 9, 22), progress: 60),
      referenceDate: DateTime(2026, 9, 27),
    );

    expect(result.actualDurationDays, 6);
    expect(result.varianceDays, 3);
    expect(result.varianceLabel, 'Overdue by 3 days');
    expect(result.isOverdue, isTrue);
  });

  test(
    'reports a completed task ending on its planned date as on schedule',
    () {
      final result = calculator.calculate(
        task(
          actualStartDate: DateTime(2026, 9, 23),
          actualEndDate: DateTime(2026, 9, 24),
          progress: 100,
        ),
      );

      expect(result.actualDurationDays, 2);
      expect(result.varianceDays, 0);
      expect(result.varianceLabel, 'On schedule');
      expect(result.isOverdue, isFalse);
    },
  );

  test('does not label a completed task without an end date in progress', () {
    final result = calculator.calculate(task(progress: 100));

    expect(result.varianceLabel, 'Actual end date missing');
    expect(result.varianceDays, isNull);
    expect(result.isOverdue, isFalse);
  });
}
