import '../../../../core/services/api_service.dart';
import '../model/subscription_model.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService({required ApiService apiService})
      : _apiService = apiService;

  Future<List<SubscriptionContainerModel>> getSubscriptions(String userId) async {
    try {
      final response = await _apiService.get(
        '/v1/dashboard/subscriptions',
        queryParameters: {
          'user_id': userId,
          'pageNumber': 0,
          'pageSize': 100,
        },
      );

      final dynamic rawData = response.data;
      if (rawData is List) {
        return rawData.map((e) => SubscriptionContainerModel.fromJson(e)).toList();
      } else if (rawData is Map) {
        final subscriptionsData = rawData['subscriptions'];
        if (subscriptionsData is List) {
          return subscriptionsData.map((e) => SubscriptionContainerModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }



  Future<void> deleteSubscription(String id) async {
    try {
      await _apiService.post(
        '/v1/subscription',
        data: {
          'subscriptionData': {'_id': id},
          'type': 'delete',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
