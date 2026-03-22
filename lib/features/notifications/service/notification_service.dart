import '../../../../core/services/api_service.dart';
import '../model/notification_model.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService({required ApiService apiService})
      : _apiService = apiService;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _apiService.get(
        '/v1/notifications',
        queryParameters: {'userId': userId},
      );

      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount(String userId, List<String> screens) async {
    try {
      final response = await _apiService.get(
        '/v1/notifications/count',
        queryParameters: {
          'userId': userId,
          'screens': screens,
        },
      );
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0; // Fallback to 0 if count fails
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _apiService.post(
        '/v1/notifications',
        data: {
          'notificationId': notificationId,
          'userId': userId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete(
        '/v1/notifications',
        queryParameters: {'notificationId': notificationId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> broadcastNotification(String subject, String message) async {
    try {
      await _apiService.post(
        '/v1/notifications/broadcast',
        data: {
          'subject': subject,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
