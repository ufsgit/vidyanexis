import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/notification_model.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/overdue_task_report_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:provider/provider.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;

  const NotificationWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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

  Color _getNotificationColor() {
    final title = (widget.notification.titleNew ?? widget.notification.title ?? '').toLowerCase();
    final body = (widget.notification.body ?? widget.notification.bodyNew ?? '').toLowerCase();
    if (title.contains('overdue') || body.contains('overdue')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF2563EB);
  }

  IconData _getNotificationIcon() {
    final title = (widget.notification.titleNew ?? widget.notification.title ?? '').toLowerCase();
    final body = (widget.notification.body ?? widget.notification.bodyNew ?? '').toLowerCase();
    if (title.contains('overdue') || body.contains('overdue')) {
      return Icons.alarm_outlined;
    }
    return Icons.notifications_active_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.notification.titleNew?.isNotEmpty == true)
        ? widget.notification.titleNew!
        : (widget.notification.title?.isNotEmpty == true
            ? widget.notification.title!
            : '');
    final body = (widget.notification.body?.isNotEmpty == true)
        ? widget.notification.body!
        : (widget.notification.bodyNew?.isNotEmpty == true
            ? widget.notification.bodyNew!
            : '');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Consumer<SidebarProvider>(builder: (context, provider, child) {
          return InkWell(
            onTap: () {
              final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
              final notifTitle = (widget.notification.titleNew?.isNotEmpty == true)
                  ? widget.notification.titleNew!
                  : (widget.notification.title?.isNotEmpty == true
                      ? widget.notification.title!
                      : '');
              final notifBody = (widget.notification.body?.isNotEmpty == true)
                  ? widget.notification.body!
                  : (widget.notification.bodyNew?.isNotEmpty == true
                      ? widget.notification.bodyNew!
                      : '');

              if (notifTitle.toLowerCase().contains('overdue') ||
                  notifBody.toLowerCase().contains('overdue')) {
                provider.updateSelectedName('Overdue Task');
                provider.setReportPage(const OverdueTaskReportScreen());
                if (widget.notification.notificationId != null) {
                  notifProvider.removeNotification(
                      int.tryParse(widget.notification.notificationId!) ?? 0);
                  notifProvider.markNotificationAsRead(
                      widget.notification.notificationId!);
                } else {
                  notifProvider.markNotificationAsRead('999999');
                }
                context.go(HomePage.route);
                return;
              }
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

              if (widget.notification.menuId != null) {
                provider.setMenuId(0, int.tryParse(widget.notification.menuId!) ?? 0);
              }
              if (widget.notification.notificationId != null) {
                notifProvider.removeNotification(
                    int.tryParse(widget.notification.notificationId!) ?? 0);
              }

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
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getNotificationColor().withOpacity(0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getNotificationColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getNotificationIcon(),
                            color: _getNotificationColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              if (title.isNotEmpty) const SizedBox(height: 4),
                              if (body.isNotEmpty)
                                Text(
                                  body,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (widget.notification.createdAt != null &&
                                  widget
                                      .notification.createdAt!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.notification.createdAt!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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
