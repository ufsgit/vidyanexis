import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:vidyanexis/controller/models/notification_model.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/main.dart';

class MicrotecSocket {
  static IO.Socket? socket;
  static Future initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    final String userId = prefs.getString('userId') ?? "";

    if (socket != null && socket!.connected) {
      log('Socket is already initialized and connected');
      return;
    }

    final optionsBuilder = IO.OptionBuilder()
        .enableReconnection()
        .setReconnectionDelay(1)
        .enableForceNew()
        .setPath('/socket.io/');

    if (kIsWeb) {
      // Web: browsers block custom WS headers; use query params and allow polling fallback
      optionsBuilder.setTransports(['websocket', 'polling']).setQuery(
          {'token': token, 'userId': userId});
    } else {
      optionsBuilder.setTransports(['websocket']).setExtraHeaders({
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
        'Connection': 'upgrade',
        'Upgrade': 'websocket',
      });
    }

    final serverUrl = HttpUrls.baseUrl.endsWith('/')
        ? HttpUrls.baseUrl.substring(0, HttpUrls.baseUrl.length - 1)
        : HttpUrls.baseUrl;
    socket = IO.io(serverUrl, optionsBuilder.build());
    socket?.connect();

    socket?.on('error', (error) {
      log('❌ Socket Error: $error');
    });

    socket?.onConnect((_) {
      log('✅ SUCCESS: Socket connected successfully for userId: $userId');

      // Add confirmation listener for registration
      socket?.on('user_registered', (data) {
        log('🎯 User successfully registered: $data');
      });

      socket?.emit("authenticate", {
        "userId": userId,
        "token": token,
      });
      log('🔐 Sent authenticate event for userId: $userId');

      socket?.emit('register_user', {"userId": userId});
      log('📝 Sent register_user event for userId: $userId');

      _listenNotificationList(userId);
      log('👂 Socket connected and listening for real-time notifications');
    });

    // Debug listeners
    socket?.on('connect_error', (error) => log('❌ Connection Error: $error'));
    socket?.on(
        'connect_timeout', (timeout) => log('⏰ Connection Timeout: $timeout'));
    socket?.onConnectError((err) => log('❌ Connect Error: $err'));
    socket?.onError((err) => log('❌ Error: $err'));
    socket?.onDisconnect((_) => log('🔌 Disconnect'));
    socket?.on('connecting', (_) => log('🔄 Connecting...'));
    socket?.on('connect_failed', (_) => log('❌ Connect Failed'));

    await Future.delayed(const Duration(seconds: 4), () {
      if (socket?.connected == false) {
        log('❌ Socket failed to connect after timeout');
      }
    });
  }

  static void _listenNotificationList(String userId) {
    log('🎧 Setting up notification listeners for userId: $userId');

    // Prevent duplicate listeners on reconnect
    socket?.off("notification");
    socket?.off('user-$userId');
    socket?.off("all_notification");
    socket?.off("user_notification");

    // 🚨 CRITICAL: Listen to ALL events to debug what's being received
    socket?.onAny((event, data) {
      log('🌐 [ALL EVENTS] Received event: "$event" with data: $data');
      log('🌐 [ALL EVENTS] Event type: ${event.runtimeType}, Data type: ${data.runtimeType}');
    });

    socket?.on('all_notification', (data) {
      log('📢 [all_notification] Received data: $data');
    });

    socket?.on('user_notification', (data) {
      log('🔔 [user_notification] Received data: $data');

      try {
        final context = navigatorKey.currentState?.context;
        if (context == null) {
          return;
        }

        final provider =
            Provider.of<NotificationProvider>(context, listen: false);

        if (data is Map<String, dynamic>) {
          // Check if it's the expected format with Total_Count and transformedResults
          if (data.containsKey('Total_Count') &&
              data.containsKey('transformedResults')) {
            final totalCount = data['Total_Count'] as int? ?? 0;
            final transformedResults =
                data['transformedResults'] as List<dynamic>?;

            log('📊 Total Count: $totalCount');
            log('📋 Transformed Results count: ${transformedResults?.length ?? 0}');

            if (transformedResults != null) {
              print('🔔 [user_notification] ALL NOTIFICATIONS FROM SOCKET: $transformedResults');
              final notifications = transformedResults.map((item) {
                log('📄 Processing notification item: $item');
                return NotificationModel.fromJson(item, {});
              }).toList();

              // Update both notifications and total count
              provider.setNotifications(notifications, totalCount);
              log('✅ Provider updated with ${notifications.length} notifications');
            }
          }
          // Handle the current format that backend is sending (single notification)
          else if (data.containsKey('notification')) {
            socket?.emit('get_user_notifications', {'userId': userId});

            // Optionally, add the single notification to the current list
            final notificationData =
                data['notification'] as Map<String, dynamic>?;
            if (notificationData != null) {
              final singleNotification =
                  NotificationModel.fromJson(notificationData, {});
              // Note: You might want to add this to the provider as well
              // provider.addNotificationFromSocket(singleNotification);
              log('✅ Parsed single notification from socket');
            }
          }
        } else {
          log('❌ Data is not Map<String, dynamic>: ${data.runtimeType}');
        }
      } catch (e, stackTrace) {
        log('❌ Error processing user_notification: $e');
        log('📍 Stack trace: $stackTrace');
      }
    });

    // Listen to backend's direct emits: io.to(`user-${userId}`).emit('notification', ...)
    socket?.on('notification', (payload) {
      try {
        // Automatically re-register user to get fresh notifications
        log('🔄 Auto re-registering user for fresh notifications...');
        socket?.emit('register_user', {"userId": userId});
        log('📡 register_user event sent for userId: $userId');

        final context = navigatorKey.currentState?.context;
        if (context != null) {
          final provider =
              Provider.of<NotificationProvider>(context, listen: false);

          socket?.emit('get_user_notifications', {'userId': userId});
          log('📡 Requested updated notification list from backend');
        }
      } catch (e) {
        log('❌ Error processing notification event: $e');
      }
    });

    // Listen to specific user events
    socket?.on('user-$userId', (data) {
      log('👤 [user-$userId] Received data: $data');
    });

    // Listen for lead-related events (add these if backend sends them)
    socket?.on('lead_created', (data) {
      log('🎯 [lead_created] Lead created event: $data');
    });

    socket?.on('lead_assigned', (data) {
      log('👥 [lead_assigned] Lead assigned event: $data');
    });

    // Listen for any event that might contain "lead" in the name
    socket?.onAny((event, data) {
      if (event.toString().toLowerCase().contains('lead')) {
        log('🔍 [LEAD EVENT] Found lead-related event: "$event" with data: $data');
      }
    });

    log('🎧 All notification listeners set up successfully');
  }

  static void readNotification({int? id}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userId = preferences.getString('userId') ?? "";

    log('📖 readNotification called with id: $id, userId: $userId');

    socket?.emit(
        "read_notification", {"notification_id": id ?? 0, "user_id": userId});
    log('📡 Socket event emitted: read_notification with notification_id: ${id ?? 0}, user_id: $userId');

    // Also mark as read in the provider
    final context = navigatorKey.currentState?.context;
    if (context != null) {
      try {
        final provider =
            Provider.of<NotificationProvider>(context, listen: false);

        if (id == 0) {
          provider.markAllNotificationsAsRead();
          log('✅ Marked all notifications as read in provider');
        } else if (id != null) {
          provider.markNotificationAsRead(id.toString());
          log('✅ Marked notification $id as read in provider');
        }
      } catch (e) {
        log('❌ Error updating notification provider: $e');
      }
    } else {
      log('❌ Context is null, unable to update notification provider');
    }
  }

  static void getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? "";
    log('📡 Requesting user notifications for userId: $userId');
    socket?.emit('get_user_notifications', {'userId': userId});
  }

  static void sendNotification({int? id}) async {
    log('📤 sendNotification called with id: $id');
    socket?.emit("notification");
    log('📡 Socket event emitted: notification');
  }

  // Add a test method to check if socket is working
  static void testSocket() {
    log('🧪 Testing socket connection...');
    socket?.emit('test_event', {
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Test from Flutter'
    });
    log('📡 Test event sent');
  }

  // Disconnect socket
  static void disconnect() {
    log('🔌 Disconnecting socket...');
    socket?.disconnect();
    socket = null;
    log('✅ Socket disconnected and nullified');
  }
}
