import '../entities/project_contact.dart';

abstract interface class ProjectContactRepository {
  Future<List<ProjectContact>> getContacts(
    String projectId,
  );

  Future<ProjectContact> getContact(
    String id,
  );

  Future<ProjectContact> createContact(
    ProjectContact contact,
  );

  Future<ProjectContact> updateContact(
    ProjectContact contact,
  );

  Future<void> archiveContact(
    String id,
  );
}