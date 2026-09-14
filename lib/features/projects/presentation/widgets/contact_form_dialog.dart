import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/project_contact.dart';
import '../providers/project_providers.dart';

class ContactFormDialog extends ConsumerStatefulWidget {
  const ContactFormDialog({
    required this.projectId,
    this.contact,
    super.key,
  });

  final String projectId;
  final ProjectContact? contact;

  bool get isEditing => contact != null;

  @override
  ConsumerState<ContactFormDialog> createState() =>
      _ContactFormDialogState();
}

class _ContactFormDialogState
    extends ConsumerState<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  late final TextEditingController _notesController;

  late ProjectContactRole _role;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final contact = widget.contact;

    _nameController = TextEditingController(
      text: contact?.name ?? '',
    );

    _phoneController = TextEditingController(
      text: contact?.phone ?? '',
    );

    _emailController = TextEditingController(
      text: contact?.email ?? '',
    );

    _companyController = TextEditingController(
      text: contact?.company ?? '',
    );

    _notesController = TextEditingController(
      text: contact?.notes ?? '',
    );

    _role = contact?.role ?? ProjectContactRole.client;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _roleLabel(ProjectContactRole role) {
    return switch (role) {
      ProjectContactRole.client => 'Client',
      ProjectContactRole.architect => 'Architect',
      ProjectContactRole.structuralEngineer =>
        'Structural Engineer',
      ProjectContactRole.siteEngineer => 'Site Engineer',
      ProjectContactRole.contractor => 'Contractor',
      ProjectContactRole.supplier => 'Supplier',
      ProjectContactRole.subcontractor => 'Subcontractor',
      ProjectContactRole.other => 'Other',
    };
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final existingContact = widget.contact;

      final contact = ProjectContact(
        id: existingContact?.id ??
            'contact-${DateTime.now().millisecondsSinceEpoch}',
        projectId: widget.projectId,
        name: _nameController.text.trim(),
        role: _role,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isArchived: existingContact?.isArchived ?? false,
      );

      final repository = ref.read(
        projectContactRepositoryProvider,
      );

      if (widget.isEditing) {
        await repository.updateContact(contact);
      } else {
        await repository.createContact(contact);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update contact: $error'
                : 'Unable to create contact: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit Contact'
        : 'Add Contact';

    final saveLabel = widget.isEditing
        ? 'Update Contact'
        : 'Save Contact';

    return AlertDialog(
      title: Text(title),
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
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Rajesh Kumar',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter a name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                DropdownButtonFormField<ProjectContactRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                    ),
                  ),
                  items: ProjectContactRole.values.map(
                    (role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          _roleLabel(role),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _role = value;
                      });
                    }
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+91 98765 43210',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _companyController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'Optional',
                    prefixIcon: Icon(
                      Icons.business_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                TextFormField(
                  controller: _notesController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional contact notes',
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              _isSaving ? null : _saveContact,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            _isSaving ? 'Saving...' : saveLabel,
          ),
        ),
      ],
    );
  }
}