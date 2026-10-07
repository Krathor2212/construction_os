import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/quality_history_entry.dart';
import '../providers/quality_history_providers.dart';

class ProjectQualityHistoryPage extends ConsumerWidget {
  const ProjectQualityHistoryPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(projectQualityHistoryProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Quality History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load quality history: $error')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No quality history recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: entries.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _HistoryCard(entry: entries[index]),
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final QualityHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context, entry.type);
    return Card(
      child: ListTile(
        leading: Icon(_typeIcon(entry.type), color: color),
        title: Text(entry.title),
        subtitle: Text(
          '${_typeLabel(entry.type)} • ${entry.status}\n'
          '${_formatDate(entry.date)}\n${entry.summary}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

IconData _typeIcon(QualityHistoryType type) => switch (type) {
      QualityHistoryType.inspection => Icons.fact_check_outlined,
      QualityHistoryType.defect => Icons.report_problem_outlined,
      QualityHistoryType.punchList => Icons.checklist_outlined,
      QualityHistoryType.correctiveAction => Icons.build_circle_outlined,
      QualityHistoryType.reinspection => Icons.fact_check_outlined,
    };

Color _typeColor(BuildContext context, QualityHistoryType type) =>
    switch (type) {
      QualityHistoryType.inspection => Colors.blue,
      QualityHistoryType.defect => Theme.of(context).colorScheme.error,
      QualityHistoryType.punchList => Colors.orange,
      QualityHistoryType.correctiveAction => Colors.deepOrange,
      QualityHistoryType.reinspection => Colors.green,
    };

String _typeLabel(QualityHistoryType type) => switch (type) {
      QualityHistoryType.inspection => 'Inspection',
      QualityHistoryType.defect => 'Defect',
      QualityHistoryType.punchList => 'Punch list',
      QualityHistoryType.correctiveAction => 'Corrective action',
      QualityHistoryType.reinspection => 'Reinspection',
    };

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
