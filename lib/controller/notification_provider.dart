import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/notification_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  List<NotificationModel> _notificationsList = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<NotificationModel> get notificationsList => _notificationsList;
  bool get isLoading => _isLoading;
  int _totalCount = 0;
  int _overdueTaskCount = 0;

  int get totalCount => _totalCount;
  int get overdueTaskCount => _overdueTaskCount;

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      final notifId = int.tryParse(notification.notificationId ?? '');
      if (notifId != null) {
        removeNotification(notifId);
      }
    });
  }

  void removeNotification(int id) {
    _notifications.removeWhere((notification) =>
        (int.tryParse(notification.notificationId ?? '') ?? 0) == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void setNotifications(List<NotificationModel> notifications, int totalCount) {
    _notificationsList = List.from(notifications);
    _sortNotificationsByDate();
    _syncOverdueTaskNotification();
    _recalculateTotalCount(baseSocketCount: totalCount);
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
    _recalculateTotalCount();
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
      if (notificationId == '999999' ||
          (notification.title?.toLowerCase().contains('overdue') ?? false) ||
          (notification.titleNew?.toLowerCase().contains('overdue') ?? false)) {
        _overdueTaskCount = 0;
      }
      _recalculateTotalCount();
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
    _overdueTaskCount = 0;
    _totalCount = 0;
    notifyListeners();
    print('Marked all notifications as read');
  }

  void refreshTotalCount() {
    _recalculateTotalCount();
    notifyListeners();
  }

  void _recalculateTotalCount({int? baseSocketCount}) {
    final nonOverdueUnreadCount = _notificationsList.where((n) {
      if (n.isRead == '1') return false;
      final isOverdue = n.notificationId == '999999' ||
          (n.title?.toLowerCase().contains('overdue') ?? false) ||
          (n.titleNew?.toLowerCase().contains('overdue') ?? false);
      return !isOverdue;
    }).length;

    final effectiveSocketCount =
        (baseSocketCount != null && baseSocketCount > 0)
            ? baseSocketCount
            : nonOverdueUnreadCount;

    if (_overdueTaskCount > 0) {
      _totalCount = _overdueTaskCount + effectiveSocketCount;
    } else {
      _totalCount = effectiveSocketCount;
    }
  }

  void _syncOverdueTaskNotification() {
    if (_overdueTaskCount <= 0) {
      _notificationsList.removeWhere((n) =>
          n.notificationId == '999999' ||
          (n.title?.toLowerCase().contains('overdue') ?? false) ||
          (n.titleNew?.toLowerCase().contains('overdue') ?? false));
      return;
    }

    final existingIndex = _notificationsList.indexWhere(
      (n) =>
          n.notificationId == '999999' ||
          (n.title?.toLowerCase().contains('overdue') ?? false) ||
          (n.titleNew?.toLowerCase().contains('overdue') ?? false),
    );

    final overdueNotification = NotificationModel(
      notificationId: '999999',
      title: 'Overdue Tasks',
      titleNew: 'Overdue Tasks',
      body:
          'You have $_overdueTaskCount overdue task${_overdueTaskCount > 1 ? "s" : ""} pending',
      bodyNew:
          'You have $_overdueTaskCount overdue task${_overdueTaskCount > 1 ? "s" : ""} pending',
      createdAt: DateTime.now().toIso8601String(),
      isRead: '0',
      redirectId: '3',
    );

    if (existingIndex != -1) {
      _notificationsList[existingIndex] = overdueNotification;
    } else {
      _notificationsList.insert(0, overdueNotification);
    }
  }

  void setOverdueTaskCount(int count, {bool showPopup = true}) {
    _overdueTaskCount = count;
    _syncOverdueTaskNotification();
    _recalculateTotalCount();

    if (showPopup && count > 0) {
      // Remove any existing overdue popup first so it doesn't duplicate
      _notifications.removeWhere((n) =>
          n.notificationId == '999999' ||
          (n.title?.toLowerCase().contains('overdue') ?? false) ||
          (n.titleNew?.toLowerCase().contains('overdue') ?? false));

      final overduePopup = NotificationModel(
        notificationId: '999999',
        title: 'Overdue Task Reminder',
        titleNew: 'Overdue Task Reminder',
        body:
            'You have $count overdue task${count > 1 ? "s" : ""} pending. Click to view.',
        bodyNew:
            'You have $count overdue task${count > 1 ? "s" : ""} pending. Click to view.',
        createdAt: DateTime.now().toIso8601String(),
        isRead: '0',
        redirectId: '3',
      );

      _notifications.add(overduePopup);

      // Auto dismiss after 8 seconds if not clicked
      Future.delayed(const Duration(seconds: 8), () {
        removeNotification(999999);
      });
    }

    notifyListeners();
  }

  Future<void> fetchOverdueTaskCount({BuildContext? context}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        return;
      }
      final userId = prefs.getString('userId') ?? '';

      final Map<String, dynamic> queryParams = {};
      if (userId.isNotEmpty && userId != '0') {
        queryParams['User_Id'] = userId;
        queryParams['To_User'] = userId;
      }

      Response? response;
      try {
        response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getOverdueTaskCount,
          bodyData: queryParams.isNotEmpty ? queryParams : null,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error in GET getOverdueTaskCount with queryParams: $e');
        }
      }

      if (response == null || response.statusCode != 200) {
        try {
          response = await HttpRequest.httpGetRequest(
            endPoint: HttpUrls.getOverdueTaskCount,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error in GET getOverdueTaskCount without queryParams: $e');
          }
        }
      }

      if (response == null || response.statusCode != 200) {
        try {
          response = await HttpRequest.httpPostRequest(
            endPoint: HttpUrls.getOverdueTaskCount,
            bodyData: queryParams.isNotEmpty ? queryParams : null,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error in POST getOverdueTaskCount: $e');
          }
        }
      }

      if (response != null && response.statusCode == 200) {
        final parsedCount = _parseOverdueCount(response.data);
        setOverdueTaskCount(parsedCount);
        if (kDebugMode) {
          print('Overdue task count fetched successfully: $parsedCount');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in fetchOverdueTaskCount: $e');
      }
    }
  }

  int _parseOverdueCount(dynamic data) {
    if (data == null) return 0;
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) return int.tryParse(data.trim()) ?? 0;
    if (data is List) {
      if (data.isEmpty) return 0;
      final first = data[0];
      if (first is int) return first;
      if (first is num) return first.toInt();
      if (first is String) return int.tryParse(first.trim()) ?? 0;
      if (first is Map) {
        final count = _parseOverdueCount(first);
        if (count > 0) return count;
      }
      return data.length;
    }
    if (data is Map) {
      const keys = [
        'Overdue_Task_Count',
        'overdue_task_count',
        'Overdue_Tasks_Count',
        'overdue_tasks_count',
        'Overdue_Count',
        'overdue_count',
        'OverdueCount',
        'overdueCount',
        'Total_Count',
        'total_count',
        'TotalCount',
        'totalCount',
        'Count',
        'count',
        'Data_Count',
        'data_count',
        'Total',
        'total',
        'Task_Count',
        'task_count',
        'data',
        'Data',
        'results',
        'result',
      ];
      for (final key in keys) {
        if (data.containsKey(key)) {
          final val = data[key];
          if (val is int) return val;
          if (val is num) return val.toInt();
          if (val is String) {
            final p = int.tryParse(val.trim());
            if (p != null) return p;
          }
          if (val is List) {
            if (val.isEmpty) return 0;
            if (val[0] is Map) {
              final p = _parseOverdueCount(val[0]);
              if (p > 0) return p;
            }
            return val.length;
          }
          if (val is Map) {
            final p = _parseOverdueCount(val);
            if (p > 0) return p;
          }
        }
      }
      for (final v in data.values) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) {
          final p = int.tryParse(v.trim());
          if (p != null) return p;
        }
      }
    }
    return 0;
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
    _overdueTaskCount = 0;
    _totalCount = 0;
    notifyListeners();
  }

  int get unreadCount {
    return _notificationsList.where((n) => n.isRead == '0').length;
  }

  List<NotificationModel> get unreadNotifications {
    return _notificationsList.where((n) => n.isRead == '0').toList();
  }
}
