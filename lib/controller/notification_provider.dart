import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  List<NotificationModel> _notificationsList = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<NotificationModel> get notificationsList => _notificationsList;
  bool get isLoading => _isLoading;
  int _totalCount = 0;

  int get totalCount => _totalCount;
  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      removeNotification(int.parse(notification.notificationId!));
    });
  }

  void removeNotification(int id) {
    _notifications.removeWhere(
        (notification) => int.parse(notification.notificationId!) == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void setNotifications(List<NotificationModel> notifications, int totalCount) {
    _notificationsList = notifications;
    _sortNotificationsByDate();
    _totalCount = totalCount;
    _isLoading = false;
    notifyListeners();
    print('Loaded ${notifications.length} notifications from socket');
  }

  void addNotificationFromSocket(NotificationModel notification) {
    final existingIndex = _notificationsList
        .indexWhere((n) => n.notificationId == notification.notificationId);

    if (existingIndex != -1) {
      _notificationsList[existingIndex] = notification;
      print('Updated existing notification: ${notification.notificationId}');
    } else {
      _notificationsList.insert(0, notification);
      print('Added new notification: ${notification.notificationId}');
    }

    _sortNotificationsByDate();
    notifyListeners();
    addNotification(notification);
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notificationsList
        .indexWhere((n) => n.notificationId == notificationId);

    if (index != -1) {
      final notification = _notificationsList[index];
      final updatedNotification = notification.copyWith(isRead: '1');

      _notificationsList[index] = updatedNotification;
      // Update total count to reflect unread notifications
      _totalCount = _notificationsList.where((n) => n.isRead == '0').length;
      notifyListeners();
      print('Marked notification as read: $notificationId');
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notificationsList.length; i++) {
      if (_notificationsList[i].isRead == '0') {
        final notification = _notificationsList[i];
        final updatedNotification = notification.copyWith(isRead: '1');

        _notificationsList[i] = updatedNotification;
      }
    }
    // Update total count to reflect unread notifications
    _totalCount = _notificationsList.where((n) => n.isRead == '0').length;
    notifyListeners();
    print('Marked all notifications as read');
  }

  void refreshTotalCount() {
    _totalCount = _notificationsList.where((n) => n.isRead == '0').length;
    notifyListeners();
  }

  void _sortNotificationsByDate() {
    _notificationsList.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      try {
        final dateA = DateTime.parse(a.createdAt!);
        final dateB = DateTime.parse(b.createdAt!);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
  }

  void clearNotificationsList() {
    _notificationsList.clear();
    notifyListeners();
  }

  int get unreadCount {
    return _notificationsList.where((n) => n.isRead == '0').length;
  }

  List<NotificationModel> get unreadNotifications {
    return _notificationsList.where((n) => n.isRead == '0').toList();
  }
}
