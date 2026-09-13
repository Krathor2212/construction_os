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
  });

  final String id;
  final String projectId;
  final String name;
  final ProjectContactRole role;

  final String? phone;
  final String? email;
  final String? company;
  final String? notes;
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