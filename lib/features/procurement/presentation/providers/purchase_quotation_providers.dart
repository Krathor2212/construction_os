import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_purchase_quotation_repository.dart';
import '../../domain/entities/purchase_quotation.dart';
import '../../domain/repositories/purchase_quotation_repository.dart';

final purchaseQuotationRepositoryProvider =
    Provider<PurchaseQuotationRepository>((ref) {
  return MockPurchaseQuotationRepository();
});

final purchaseQuotationsProvider =
    FutureProvider.family<
        List<PurchaseQuotation>,
        String>(
  (ref, projectId) async {
    final repository = ref.watch(
      purchaseQuotationRepositoryProvider,
    );

    return repository.getPurchaseQuotations(
      projectId,
    );
  },
);

final purchaseQuotationProvider =
    FutureProvider.family<
        PurchaseQuotation,
        String>(
  (ref, quotationId) async {
    final repository = ref.watch(
      purchaseQuotationRepositoryProvider,
    );

    return repository.getPurchaseQuotation(
      quotationId,
    );
  },
);