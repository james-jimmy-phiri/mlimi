import 'package:flutter/material.dart';
import 'package:mlimi/models/app_notification.dart';
import 'package:mlimi/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _setError(null);
    try {
      _notifications = await _service.getNotifications();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(int id) async {
    // Optimistic UI update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final oldNotification = _notifications[index];
      _notifications[index] = AppNotification(
        id: oldNotification.id,
        event: oldNotification.event,
        message: oldNotification.message,
        isRead: true,
        createdAt: oldNotification.createdAt,
      );
      notifyListeners();

      try {
        await _service.markAsRead(id);
      } catch (e) {
        // Revert on error
        _notifications[index] = oldNotification;
        _setError('Failed to mark as read');
      }
    }
  }
}
