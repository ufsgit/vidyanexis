import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vidyanexis/routes/routes.dart';
import 'package:vidyanexis/utils/notification_navigation_helper.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle notification tap
        print('Notification Clicked Payload: ${notificationResponse.payload}');
        if (notificationResponse.payload != null) {
          try {
            final Map<String, dynamic> data =
                jsonDecode(notificationResponse.payload!);
            _navigateWithData(data);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      },
    );

    // Create High Importance Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // // Get FCM token
    // String? token = await _firebaseMessaging.getToken();
    // print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show it to users using the created channel.
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              // other properties...
            ),
          ),
          payload: jsonEncode(message.data), // Pass JSON string as payload
        );
      }
    });

    // Handle when notification is clicked
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // Check if the app was opened from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    print('--- Notification Clicked (FCM) ---');
    print('Data: ${message.data}');
    print('MessageId: ${message.messageId}');
    _navigateWithData(message.data);
  }

  void _navigateWithData(Map<String, dynamic> data) async {
    print('--- Navigating with data ---');
    print('Data for navigation: $data');

    // Give the app a moment to settle if it's just booting or resuming
    await Future.delayed(const Duration(seconds: 1));

    // Wait for context to be available if it's null
    BuildContext? context = appRouter.configuration.navigatorKey.currentContext;

    print('Initial context: $context');

    int retryCount = 0;
    while (context == null && retryCount < 10) {
      print('Context is null, retrying ($retryCount/10)...');
      await Future.delayed(const Duration(milliseconds: 500));
      context = appRouter.configuration.navigatorKey.currentContext;
      retryCount++;
    }

    if (context != null) {
      print('Context found, calling NotificationNavigationHelper.navigate');
      NotificationNavigationHelper.navigate(
        context,
        notificationId:
            (data['Notification_Id'] ?? data['notification_id'] ?? data['id'])
                ?.toString(),
        customerIdStr: (data['Customer_Id'] ?? data['customer_id'])?.toString(),
        masterIdStr:
            (data['Task_Master_Id'] ?? data['Master_Id'] ?? data['master_id'])
                ?.toString(),
        followupIdStr: (data['Followup_Id'] ?? data['followup_id'])?.toString(),
        redirectIdStr:
            (data['Notification_Type_Id'] ?? data['notification_type_id'])
                ?.toString(),
        isWeb: false,
      );
    } else {
      print('CRITICAL: No context available for navigation after 5 seconds');
    }
  }
}

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}
