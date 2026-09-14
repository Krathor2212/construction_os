import '../../domain/entities/project_contact.dart';
import '../../domain/repositories/project_contact_repository.dart';

class MockProjectContactRepository implements ProjectContactRepository {
  final List<ProjectContact> _contacts = [
    ProjectContact(
      id: 'contact-001',
      projectId: 'project-001',
      name: 'Rajesh Kumar',
      role: ProjectContactRole.client,
      phone: '+91 98765 43210',
      email: 'rajesh@example.com',
    ),
    ProjectContact(
      id: 'contact-002',
      projectId: 'project-001',
      name: 'Arun',
      role: ProjectContactRole.siteEngineer,
      phone: '+91 98765 12345',
      company: 'SuGoRa Construction',
    ),
    ProjectContact(
      id: 'contact-003',
      projectId: 'project-001',
      name: 'XYZ Architects',
      role: ProjectContactRole.architect,
      phone: '+91 91234 56789',
      email: 'office@xyzarchitects.example',
    ),
    ProjectContact(
      id: 'contact-004',
      projectId: 'project-001',
      name: 'ABC Structural Consultants',
      role: ProjectContactRole.structuralEngineer,
      phone: '+91 99887 66554',
    ),
    ProjectContact(
      id: 'contact-005',
      projectId: 'project-001',
      name: 'Sri Murugan Steels',
      role: ProjectContactRole.supplier,
      phone: '+91 90000 11223',
    ),
    ProjectContact(
      id: 'contact-006',
      projectId: 'project-002',
      name: 'Commercial Client',
      role: ProjectContactRole.client,
      phone: '+91 95555 44444',
    ),
  ];

  @override
  Future<List<ProjectContact>> getContacts(
    String projectId,
  ) async {
    return List.unmodifiable(
      _contacts.where(
        (contact) =>
            contact.projectId == projectId &&
            !contact.isArchived,
      ),
    );
  }

  @override
  Future<ProjectContact> getContact(String id) async {
    return _contacts.firstWhere(
      (contact) => contact.id == id,
    );
  }

  @override
  Future<ProjectContact> createContact(
    ProjectContact contact,
  ) async {
    _contacts.add(contact);
    return contact;
  }

  @override
  Future<ProjectContact> updateContact(
    ProjectContact contact,
  ) async {
    final index = _contacts.indexWhere(
      (item) => item.id == contact.id,
    );

    if (index == -1) {
      throw StateError('Contact not found: ${contact.id}');
    }

    _contacts[index] = contact;
    return contact;
  }

  @override
    Future<void> archiveContact(String id) async {
      final index = _contacts.indexWhere(
        (contact) => contact.id == id,
      );

      if (index == -1) {
        throw StateError('Contact not found: $id');
      }

      final contact = _contacts[index];

      _contacts[index] = ProjectContact(
        id: contact.id,
        projectId: contact.projectId,
        name: contact.name,
        role: contact.role,
        phone: contact.phone,
        email: contact.email,
        company: contact.company,
        notes: contact.notes,
        isArchived: true,
      );
    }
}