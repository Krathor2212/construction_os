class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.contactPerson,
    this.isActive = true,
    this.notes,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? contactPerson;
  final bool isActive;
  final String? notes;
}