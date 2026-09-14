import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_contact.dart';
import '../providers/project_providers.dart';
import '../widgets/contact_form_dialog.dart';

class ProjectContactsPage extends ConsumerWidget {
  const ProjectContactsPage({
    required this.projectId,
    super.key,
  });

  final String projectId;

  Future<void> _showContactForm(
    BuildContext context,
    WidgetRef ref, {
    ProjectContact? contact,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ContactFormDialog(
        projectId: projectId,
        contact: contact,
      ),
    );

    if (saved == true) {
      ref.invalidate(
        projectContactsProvider(projectId),
      );
    }
  }

  Future<void> _archiveContact(
    BuildContext context,
    WidgetRef ref,
    ProjectContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archive Contact?'),
          content: Text(
            '${contact.name} will be removed from the '
            'active contacts list but retained in project history.',
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
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final repository = ref.read(
        projectContactRepositoryProvider,
      );

      await repository.archiveContact(contact.id);

      ref.invalidate(
        projectContactsProvider(projectId),
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${contact.name} archived successfully',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to archive contact: $error',
          ),
        ),
      );
    }
  }

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
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.xl,
            ),
            child: Text(
              'Unable to load contacts.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (contacts) {
          if (contacts.isEmpty) {
            return const _EmptyContactsState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                projectContactsProvider(projectId),
              );

              await ref.read(
                projectContactsProvider(projectId).future,
              );
            },
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              itemCount: contacts.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(
                height: AppSpacing.sm,
              ),
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return _ContactCard(
                  contact: contact,
                  onEdit: () {
                    _showContactForm(
                      context,
                      ref,
                      contact: contact,
                    );
                  },
                  onArchive: () {
                    _archiveContact(
                      context,
                      ref,
                      contact,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactForm(context, ref);
        },
        icon: const Icon(
          Icons.person_add_outlined,
        ),
        label: const Text('Add Contact'),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onArchive,
  });

  final ProjectContact contact;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(
                        height: AppSpacing.xxs,
                      ),
                      Text(
                        _roleLabel(contact.role),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'archive':
                        onArchive();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.edit_outlined,
                        ),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.archive_outlined,
                        ),
                        title: Text('Archive'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (contact.company != null) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              _ContactInfoRow(
                icon: Icons.business_outlined,
                text: contact.company!,
              ),
            ],
            if (contact.phone != null) ...[
              const SizedBox(
                height: AppSpacing.xs,
              ),
              _ContactInfoRow(
                icon: Icons.phone_outlined,
                text: contact.phone!,
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(
                height: AppSpacing.xs,
              ),
              _ContactInfoRow(
                icon: Icons.email_outlined,
                text: contact.email!,
              ),
            ],
            if (contact.notes != null) ...[
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                contact.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _roleLabel(ProjectContactRole role) {
    return switch (role) {
      ProjectContactRole.client => 'Client',
      ProjectContactRole.architect => 'Architect',
      ProjectContactRole.structuralEngineer =>
        'Structural Engineer',
      ProjectContactRole.siteEngineer =>
        'Site Engineer',
      ProjectContactRole.contractor => 'Contractor',
      ProjectContactRole.supplier => 'Supplier',
      ProjectContactRole.subcontractor =>
        'Subcontractor',
      ProjectContactRole.other => 'Other',
    };
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
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyContactsState
    extends StatelessWidget {
  const _EmptyContactsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              'No contacts yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              'Add clients, engineers, architects, '
              'suppliers and other project contacts.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}