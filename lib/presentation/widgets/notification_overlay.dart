import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/presentation/widgets/notification_widget.dart';
import 'package:provider/provider.dart';

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key});

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
