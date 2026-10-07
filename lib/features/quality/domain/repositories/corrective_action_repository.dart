import '../entities/corrective_action.dart';

abstract interface class CorrectiveActionRepository {
  Future<List<CorrectiveAction>> getActions({required String projectId});
  Future<CorrectiveAction> createAction(CorrectiveAction action);
  Future<CorrectiveAction> updateAction(CorrectiveAction action);
}
