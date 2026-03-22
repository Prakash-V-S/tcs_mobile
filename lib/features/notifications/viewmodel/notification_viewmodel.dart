import 'package:flutter/material.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service;
  String? _userId;
  String? _userRole;
  List<String> _screens = [];

  NotificationViewModel({required NotificationService service}) : _service = service;

  String? get userRole => _userRole;
  bool get isAdmin => _userRole?.toLowerCase() == 'admin';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  List<NotificationModel> get subscriptionNotifications =>
      _notifications.where((n) => n.isSubscription).toList();

  List<NotificationModel> get generalNotifications =>
      _notifications.where((n) => !n.isSubscription).toList();

  void setUserId(String userId, List<String> screens, {String? role}) {
    _userId = userId;
    _screens = screens;
    _userRole = role;
    fetchUnreadCount();
  }

  Future<void> fetchNotifications() async {
    if (_userId == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(_userId!);
      await fetchUnreadCount();
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    if (_userId == null) return;
    try {
      _unreadCount = await _service.getUnreadCount(_userId!, _screens);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;
    try {
      await _service.markAsRead(notificationId, _userId!);
      
      // Update local state to show as read immediately
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = NotificationModel(
          id: n.id,
          userId: n.userId,
          createdDateTime: n.createdDateTime,
          eventType: n.eventType,
          eventCode: n.eventCode,
          subject: n.subject,
          message: n.message,
          readFlag: true,
          module: n.module,
          isDeleted: n.isDeleted,
        );
      }
      await fetchUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null || _notifications.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Assuming we can mark all as read for this user
      // If the backend doesn't have a single endpoint, we might need to iterate or implement it there.
      // Based on NotificationService, we'll assume a single call or provide a loop if needed.
      // For now, let's implement the local logic and service call.
      
      // We'll call the service for each unread notification if there's no bulk endpoint
      final unreadIds = _notifications
          .where((n) => !n.readFlag)
          .map((n) => n.id)
          .toList();
      
      for (final id in unreadIds) {
        await _service.markAsRead(id, _userId!);
      }

      // Update all locally
      _notifications = _notifications.map((n) {
        if (!n.readFlag) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            createdDateTime: n.createdDateTime,
            eventType: n.eventType,
            eventCode: n.eventCode,
            subject: n.subject,
            message: n.message,
            readFlag: true,
            module: n.module,
            isDeleted: n.isDeleted,
          );
        }
        return n;
      }).toList();

      await fetchUnreadCount();
    } catch (e) {
      _errorMessage = 'Failed to mark all as read: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      await fetchUnreadCount();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  Future<bool> broadcastNotification(String subject, String message) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.broadcastNotification(subject, message);
      await fetchNotifications();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send notification: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
