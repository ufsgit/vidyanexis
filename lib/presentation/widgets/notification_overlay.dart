import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/presentation/widgets/notification_widget.dart';
import 'package:provider/provider.dart';

class NotificationOverlay extends StatelessWidget {
  const NotificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: provider.notifications.map((notification) {
                return NotificationWidget(
                  notification: notification,
                  onDismiss: () => provider.removeNotification(
                      int.tryParse(notification.notificationId ?? '') ?? 0),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
