import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_supplier_repository.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return MockSupplierRepository();
});

final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);

  return repository.getSuppliers();
});

final supplierProvider = FutureProvider.family<Supplier, String>(
  (ref, supplierId) async {
    final repository = ref.watch(supplierRepositoryProvider);

    return repository.getSupplier(supplierId);
  },
);