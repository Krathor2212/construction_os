class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.dailyWage = 0,
    this.overtimeRate = 0,
    this.isActive = true,
    this.notes,
  });

  final String id;
  final String name;
  final WorkerRole role;
  final String phone;

  /// Normal wage for a full working day.
  final double dailyWage;

  /// Overtime payment per hour for this particular worker.
  final double overtimeRate;

  final bool isActive;
  final String? notes;
}

enum WorkerRole {
  mason,
  helper,
  carpenter,
  electrician,
  plumber,
  painter,
  welder,
  supervisor,
  siteEngineer,
  other,
}