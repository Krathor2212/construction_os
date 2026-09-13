import '../../domain/entities/project_quotation.dart';
import '../../domain/repositories/project_quotation_repository.dart';

class MockProjectQuotationRepository
    implements ProjectQuotationRepository {
  final List<ProjectQuotation> _quotations = [
    ProjectQuotation(
      id: 'quotation-001',
      projectId: 'project-001',
      quotationNumber: 'QT-2026-001',
      supplierName: 'Sri Murugan Steels',
      quotationDate: DateTime(2026, 8, 5),
      validUntil: DateTime(2026, 8, 20),
      subtotal: 485000,
      tax: 87300,
      discount: 10000,
      status: ProjectQuotationStatus.accepted,
      notes: 'Steel requirement for structural work.',
    ),
    ProjectQuotation(
      id: 'quotation-002',
      projectId: 'project-001',
      quotationNumber: 'QT-2026-002',
      supplierName: 'ABC Cement Suppliers',
      quotationDate: DateTime(2026, 8, 8),
      validUntil: DateTime(2026, 8, 23),
      subtotal: 215000,
      tax: 38700,
      discount: 5000,
      status: ProjectQuotationStatus.sent,
      notes: 'Cement supply quotation.',
    ),
    ProjectQuotation(
      id: 'quotation-003',
      projectId: 'project-002',
      quotationNumber: 'QT-2026-003',
      supplierName: 'Commercial Building Materials',
      quotationDate: DateTime(2026, 9, 1),
      validUntil: DateTime(2026, 9, 15),
      subtotal: 750000,
      tax: 135000,
      discount: 15000,
      status: ProjectQuotationStatus.draft,
    ),
  ];

  @override
  Future<List<ProjectQuotation>> getQuotations(
    String projectId,
  ) async {
    return List.unmodifiable(
      _quotations.where(
        (quotation) => quotation.projectId == projectId,
      ),
    );
  }

  @override
  Future<ProjectQuotation> getQuotation(String id) async {
    return _quotations.firstWhere(
      (quotation) => quotation.id == id,
    );
  }

  @override
  Future<ProjectQuotation> createQuotation(
    ProjectQuotation quotation,
  ) async {
    _quotations.add(quotation);
    return quotation;
  }

  @override
  Future<ProjectQuotation> updateQuotation(
    ProjectQuotation quotation,
  ) async {
    final index = _quotations.indexWhere(
      (item) => item.id == quotation.id,
    );

    if (index == -1) {
      throw StateError(
        'Quotation not found: ${quotation.id}',
      );
    }

    _quotations[index] = quotation;
    return quotation;
  }

  @override
  Future<void> deleteQuotation(String id) async {
    _quotations.removeWhere(
      (quotation) => quotation.id == id,
    );
  }
}