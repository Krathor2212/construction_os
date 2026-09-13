import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_contact.dart';
import '../providers/project_providers.dart';

class ProjectContactsPage extends ConsumerWidget {
  const ProjectContactsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      projectContactsProvider(projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Contacts'),
      ),
      body: contactsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load contacts'),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return const _EmptyContactsState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: contacts.length,
            separatorBuilder: (_, _) => const SizedBox(
              height: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              return _ContactCard(
                contact: contacts[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Contact'),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
  });

  final ProjectContact contact;

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
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _roleLabel(contact.role),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (contact.company != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _ContactInfoRow(
                icon: Icons.business_outlined,
                text: contact.company!,
              ),
            ],
            if (contact.phone != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _ContactInfoRow(
                icon: Icons.phone_outlined,
                text: contact.phone!,
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _ContactInfoRow(
                icon: Icons.email_outlined,
                text: contact.email!,
              ),
            ],
            if (contact.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                contact.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roleLabel(ProjectContactRole role) {
    switch (role) {
      case ProjectContactRole.client:
        return 'Client';
      case ProjectContactRole.architect:
        return 'Architect';
      case ProjectContactRole.structuralEngineer:
        return 'Structural Engineer';
      case ProjectContactRole.siteEngineer:
        return 'Site Engineer';
      case ProjectContactRole.contractor:
        return 'Contractor';
      case ProjectContactRole.supplier:
        return 'Supplier';
      case ProjectContactRole.subcontractor:
        return 'Subcontractor';
      case ProjectContactRole.other:
        return 'Other';
    }
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
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

class _EmptyContactsState extends StatelessWidget {
  const _EmptyContactsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No contacts yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add clients, engineers, architects, suppliers '
              'and other project contacts.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}