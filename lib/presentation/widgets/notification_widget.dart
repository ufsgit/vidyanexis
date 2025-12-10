import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/notification_model.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/pages/home/customer_page.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page.dart';
import 'package:vidyanexis/presentation/widgets/notification_overlay.dart';
import 'package:provider/provider.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;

  const NotificationWidget({
    Key? key,
    required this.notification,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final notificationProvider =
      Provider.of<NotificationProvider>(navigatorKey.currentState!.context);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Color _getNotificationColor() {
  //   switch (widget.notification.type) {
  //     case 'success':
  //       return Colors.green;
  //     case 'error':
  //       return Colors.red;
  //     case 'warning':
  //       return Colors.orange;
  //     default:
  //       return Colors.blue;
  //   }
  // }

  // IconData _getNotificationIcon() {
  //   switch (widget.notification.type) {
  //     case 'success':
  //       return Icons.check_circle;
  //     case 'error':
  //       return Icons.error;
  //     case 'warning':
  //       return Icons.warning;
  //     default:
  //       return Icons.info;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Consumer<SidebarProvider>(builder: (context, provider, child) {
          return InkWell(
            onTap: () {
              final addl = widget.notification.additionalData;
              int? customerId;
              if (addl is Map) {
                final map = Map.of(addl);
                final dynamic raw = map["Customer_Id"] ??
                    map['customer_id'] ??
                    map['CustomerId'];
                if (raw is int) {
                  customerId = raw;
                } else if (raw is String) {
                  customerId = int.tryParse(raw);
                }
              }

              provider.setMenuId(0, int.parse(widget.notification.menuId!));
              notificationProvider.removeNotification(
                  int.parse(widget.notification.notificationId!));

              // provider.replaceWidget(true, '');
              // provider.replaceWidgetCustomer(true, '');
              // context.go(HomePage.route);
              //
              // Future.delayed(Duration(seconds: 1), () {
              //   // CustomerPage.callFunction(customerId); // Call getData from LeadPage
              //
              //
              // });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      // color: _getNotificationColor(),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.all(8),
                        //   decoration: BoxDecoration(
                        //     // color: _getNotificationColor().withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),
                        //   child: Icon(
                        //     _getNotificationIcon(),
                        //     color: _getNotificationColor(),
                        //     size: 20,
                        //   ),
                        // ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.notification.title!.isNotEmpty)
                                Text(
                                  widget.notification.title ?? "NA",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              if (widget.notification.title!.isNotEmpty)
                                const SizedBox(height: 4),
                              Text(
                                widget.notification.body ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.notification.createdAt!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDismiss,
                          icon: const Icon(Icons.close),
                          iconSize: 18,
                          color: Colors.grey,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
