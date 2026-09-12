import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Control Center'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Captain',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Here is your construction overview for today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              _SummaryGrid(
                children: const [
                  _SummaryCard(
                    title: 'Active Projects',
                    value: '0',
                    icon: Icons.business_outlined,
                  ),
                  _SummaryCard(
                    title: 'Pending Payments',
                    value: '₹0',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _SummaryCard(
                    title: 'Material Alerts',
                    value: '0',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _SummaryCard(
                    title: 'Workers Today',
                    value: '0',
                    icon: Icons.groups_outlined,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Needs Attention',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),

              const _EmptyAttentionCard(),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Active Projects',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),

              const _EmptyProjectsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
        ? 2
        : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: width >= 600 ? 1.8 : 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAttentionCard extends StatelessWidget {
  const _EmptyAttentionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'No issues requiring attention right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjectsCard extends StatelessWidget {
  const _EmptyProjectsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.domain_add_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No projects yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Create your first project to start managing '
                'construction operations.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/projects');
                },
                icon: const Icon(Icons.add),
                label: const Text('View Projects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
