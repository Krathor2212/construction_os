import '../entities/project_quotation.dart';

abstract interface class ProjectQuotationRepository {
  Future<List<ProjectQuotation>> getQuotations(
    String projectId,
  );

  Future<ProjectQuotation> getQuotation(
    String id,
  );

  Future<ProjectQuotation> createQuotation(
    ProjectQuotation quotation,
  );

  Future<ProjectQuotation> updateQuotation(
    ProjectQuotation quotation,
  );

  Future<void> archiveQuotation(
    String id,
  );
}