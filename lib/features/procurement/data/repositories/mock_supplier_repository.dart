import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class MockSupplierRepository implements SupplierRepository {
  final List<Supplier> _suppliers = [
    Supplier(
      id: 'supplier-001',
      name: 'Sri Murugan Steels',
      phone: '+91 90000 11223',
      email: 'sales@srimurugansteels.example',
      address: 'Ambattur, Chennai',
      gstNumber: '33ABCDE1234F1Z5',
      contactPerson: 'Murugan',
      notes: 'Steel and reinforcement materials.',
    ),
    Supplier(
      id: 'supplier-002',
      name: 'ABC Cement Suppliers',
      phone: '+91 90000 22334',
      email: 'orders@abccement.example',
      address: 'Koyambedu, Chennai',
      gstNumber: '33BCDEF2345G2Z6',
      contactPerson: 'Sathish',
      notes: 'Cement and construction materials.',
    ),
    Supplier(
      id: 'supplier-003',
      name: 'Chennai Sand & Aggregates',
      phone: '+91 90000 33445',
      address: 'Porur, Chennai',
      contactPerson: 'Ravi',
      notes: 'M-Sand, river sand and aggregates.',
    ),
    Supplier(
      id: 'supplier-004',
      name: 'BuildPro Electricals',
      phone: '+91 90000 44556',
      email: 'sales@buildpro.example',
      address: 'Parrys, Chennai',
      contactPerson: 'Kumar',
      notes: 'Electrical materials and accessories.',
    ),
    Supplier(
      id: 'supplier-005',
      name: 'Metro Plumbing Solutions',
      phone: '+91 90000 55667',
      email: 'orders@metroplumbing.example',
      address: 'Guindy, Chennai',
      contactPerson: 'Praveen',
      notes: 'Pipes, fittings and plumbing materials.',
    ),
    Supplier(
      id: 'supplier-006',
      name: 'Classic Tiles & Flooring',
      phone: '+91 90000 66778',
      address: 'T Nagar, Chennai',
      contactPerson: 'Vignesh',
      notes: 'Flooring, tiles and related materials.',
    ),
    Supplier(
      id: 'supplier-007',
      name: 'Prime Paints & Hardware',
      phone: '+91 90000 77889',
      email: 'sales@primepaints.example',
      address: 'Anna Nagar, Chennai',
      contactPerson: 'Dinesh',
      notes: 'Paints, hardware and finishing materials.',
    ),
    Supplier(
      id: 'supplier-008',
      name: 'WoodCraft Timber Depot',
      phone: '+91 90000 88990',
      address: 'Mogappair, Chennai',
      contactPerson: 'Selvam',
      isActive: false,
      notes: 'Currently unavailable for new orders.',
    ),
  ];

  @override
  Future<List<Supplier>> getSuppliers() async {
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<Supplier> getSupplier(String id) async {
    return _suppliers.firstWhere(
      (supplier) => supplier.id == id,
    );
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    _suppliers.add(supplier);
    return supplier;
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final index = _suppliers.indexWhere(
      (item) => item.id == supplier.id,
    );

    if (index == -1) {
      throw StateError(
        'Supplier not found: ${supplier.id}',
      );
    }

    _suppliers[index] = supplier;
    return supplier;
  }

  @override
  Future<void> deleteSupplier(String id) async {
    _suppliers.removeWhere(
      (supplier) => supplier.id == id,
    );
  }
}