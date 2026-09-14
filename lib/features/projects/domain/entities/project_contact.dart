class ProjectContact {
  const ProjectContact({
    required this.id,
    required this.projectId,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.company,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String name;
  final ProjectContactRole role;

  final String? phone;
  final String? email;
  final String? company;
  final String? notes;

  /// Archived contacts are retained for project history
  /// but excluded from the active contact list.
  final bool isArchived;
}

enum ProjectContactRole {
  client,
  architect,
  structuralEngineer,
  siteEngineer,
  contractor,
  supplier,
  subcontractor,
  other,
}