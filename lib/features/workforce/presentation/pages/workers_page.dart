import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/worker.dart';
import '../providers/worker_providers.dart';

class WorkersPage extends ConsumerWidget {
  const WorkersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Labour'),
      ),
      body: workersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load workers'),
        ),
        data: (workers) {
          if (workers.isEmpty) {
            return const _EmptyWorkersState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: workers.length,
            separatorBuilder: (_, _) => const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              return _WorkerCard(
                worker: workers[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Worker'),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.worker,
  });

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    worker.name.isNotEmpty
                        ? worker.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _roleLabel(worker.role),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
                _WorkerStatusChip(
                  isActive: worker.isActive,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _WorkerInfoRow(
              icon: Icons.phone_outlined,
              text: worker.phone,
            ),
            const SizedBox(height: AppSpacing.xs),
            _WorkerInfoRow(
              icon: Icons.payments_outlined,
              text: '₹${worker.dailyWage.toStringAsFixed(0)} / day',
            ),
            if (worker.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                worker.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
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

class _WorkerInfoRow extends StatelessWidget {
  const _WorkerInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _WorkerStatusChip extends StatelessWidget {
  const _WorkerStatusChip({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Unavailable',
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyWorkersState extends StatelessWidget {
  const _EmptyWorkersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No workers yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your labour workforce to start tracking '
              'people, wages and productivity.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}