import 'package:flutter/material.dart';
import 'package:techtify/controller/models/notification_model.dart';
import 'package:techtify/controller/notification_provider.dart';
import 'package:techtify/presentation/widgets/notification_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.notifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 20,
          right: 20,
          child: SizedBox(
            width: 320,
            child: Column(
              children: provider.notifications.map((notification) {
                return NotificationWidget(
                  notification: notification,
                  onDismiss: () => provider.removeNotification(
                      int.parse(notification.notificationId!)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
