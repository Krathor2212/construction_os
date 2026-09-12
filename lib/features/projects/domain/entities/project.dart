class Project {
  const Project({
    required this.id,
    required this.name,
    required this.clientId,
    required this.siteAddress,
    required this.status,
    required this.startDate,
    this.expectedEndDate,
    this.budget = 0,
  });

  final String id;
  final String name;
  final String clientId;
  final String siteAddress;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? expectedEndDate;
  final double budget;
}

enum ProjectStatus { planning, active, onHold, completed, cancelled }
