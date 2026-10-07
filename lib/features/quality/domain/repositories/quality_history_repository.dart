import '../entities/quality_history_entry.dart';

abstract interface class QualityHistoryRepository {
  Future<List<QualityHistoryEntry>> getHistory({required String projectId});
}
