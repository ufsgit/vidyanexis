import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/socket_io.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/pages/reports/overdue_task_report_screen.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool viewProfile = false;
  bool viewFollowUp = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getFollowUpStatus(context, '1');
      provider.getUserDetails(context);
      MicrotecSocket.getNotifications();
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchOverdueTaskCount(context: context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = AppStyles.isWebScreen(context);
    final leadProvider = Provider.of<LeadsProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody(provider, isWeb, screenWidth),
    );
  }

  Widget _buildBody(
      NotificationProvider provider, bool isWeb, double screenWidth) {
    final items = provider.notificationsList.isNotEmpty
        ? provider.notificationsList
        : provider.notifications;

    if (items.isEmpty) {
      return _buildEmptyState(isWeb);
    }

    if (isWeb) {
      return _buildWebLayout(items, screenWidth);
    } else {
      return _buildMobileLayout(items);
    }
  }

  Widget _buildEmptyState(bool isWeb) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with back button
            Row(
              children: [
                InkWell(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(HomePage.route);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.textGrey4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Notifications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            // Empty state content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: isWeb ? 80 : 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: isWeb ? 18 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isWeb) ...[
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(List<NotificationModel> items, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section for web
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go(HomePage.route);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: AppColors.textGrey4,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Recent Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              Spacer(),
              // Mark All as Read button
              TextButton(
                onPressed: () {
                  MicrotecSocket.readNotification(id: 0);
                },
                child: Text(
                  'Mark All as Read',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Notifications list
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final n = items[index];
                return _NotificationTile(
                  notification: n,
                  isWeb: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<NotificationModel> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section for mobile
          SizedBox(
            height: 24,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go(HomePage.route);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: AppColors.textGrey4,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Recent Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  MicrotecSocket.readNotification(id: 0);
                },
                child: Text(
                  'Mark All as Read',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = items[index];
                return _NotificationTile(
                  notification: n,
                  isWeb: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final NotificationModel notification;
  final bool isWeb;

  const _NotificationTile({
    required this.notification,
    this.isWeb = false,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  final bool _isHovered = false;

  Widget _buildNotificationBody(String message, bool isRead) {
    if (message.contains('for') && message.contains('has been created')) {
      final parts = message.split('for');
      if (parts.length > 1) {
        final before = parts[0]; // e.g. "a new lead "
        final nameAndRest = parts[1].split('has been created');
        final name = nameAndRest.isNotEmpty ? nameAndRest[0].trim() : '';
        final after = nameAndRest.length > 1 ? 'has been created' : '';

        if (name.isNotEmpty) {
          return RichText(
            text: TextSpan(
              style: TextStyle(
                color: isRead ? Colors.grey[600] : Colors.grey[700],
                fontSize: 14,
              ),
              children: [
                TextSpan(text: "$before "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isRead ? Colors.grey[500] : Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextSpan(text: " $after"),
              ],
            ),
          );
        }
      }
    }

    // Default for all other notification types (e.g., Overdue Task Reminder)
    return Text(
      message,
      style: TextStyle(
        color: isRead ? Colors.grey[600] : Colors.grey[700],
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final created = widget.notification.createdAt;
    final createdStr = created != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(created))
        : '';

    if (widget.isWeb) {
      return _buildWebTile(createdStr);
    } else {
      return _buildMobileTile(createdStr);
    }
  }

  Widget _buildWebTile(String createdStr) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isRead = widget.notification.isRead == '1';

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

    return InkWell(
      onTap: () {
        if (title.toLowerCase().contains('overdue') ||
            body.toLowerCase().contains('overdue')) {
          final notifId = widget.notification.notificationId;
          final intId = int.tryParse(notifId ?? '');
          if (intId != null && intId > 0 && intId != 999999) {
            MicrotecSocket.readNotification(id: intId);
          } else {
            Provider.of<NotificationProvider>(context, listen: false)
                .markNotificationAsRead(notifId ?? '999999');
          }
          sideProvider.updateSelectedName('Overdue Task');
          sideProvider.setReportPage(const OverdueTaskReportScreen());
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(HomePage.route);
          }
          return;
        }

        // Mark notification as read when clicked
        MicrotecSocket.readNotification(
            id: int.tryParse(widget.notification.notificationId ?? '0'));

        final customerId =
            int.tryParse(widget.notification.customerId?.toString() ?? '0') ??
                0;
        final taskId =
            int.tryParse(widget.notification.masterId?.toString() ?? '0') ?? 0;
        final followupId =
            int.tryParse(widget.notification.followupId?.toString() ?? '0') ??
                0;
        final redirectId =
            int.tryParse(widget.notification.redirectId?.toString() ?? '0') ??
                0;

        // final customerId = 21869;
        // final taskId = 13;
        // final redirectId = 1;
        print("customerId: $customerId");
        print("taskId: $taskId");
        print("followupId: $followupId");
        print("redirectId: $redirectId");

        leadProvider.setCutomerId(customerId);
        customerDetailsProvider.setCustomerId(customerId);

        if (redirectId == 3) {
          //task
          customerDetailsProvider.getTaskDetails(taskId.toString(), context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskDetailsWidget(
                taskId: taskId.toString(),
                customerId: customerId.toString(),
                showEdit: false,
              );
            },
          );
        } else if (redirectId == 1) {
          //lead
          customerDetailsProvider.fetchLeadDetails(
              customerId.toString(), context);
          sideProvider.name = 'Lead /';
          context.push('/customerDetails/$customerId/false');
        } else if (redirectId == 2) {
          //followup
          customerDetailsProvider.fetchLeadDetails(
              customerId.toString(), context);
          sideProvider.name = 'Lead /';
          context.push('/customerDetails/$customerId/false');
        } else if (redirectId == 4) {
          //task update status
          customerDetailsProvider.getTaskDetails(taskId.toString(), context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskDetailsWidget(
                taskId: taskId.toString(),
                customerId: customerId.toString(),
                showEdit: false,
              );
            },
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? (isRead ? Colors.grey[100] : Colors.grey[50])
              : (isRead ? Colors.grey[50] : Colors.transparent),
          borderRadius: BorderRadius.circular(4),
          border:
              isRead ? Border.all(color: Colors.grey[300]!, width: 1) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey[200] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.notifications,
                color: isRead ? Colors.grey[600] : Colors.blue[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and timestamp row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w600,
                            fontSize: 16,
                            color: isRead ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ),
                      if (createdStr.isNotEmpty)
                        Text(
                          _formatTimeForWeb(createdStr),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildNotificationBody(body, isRead),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTile(String createdStr) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isRead = widget.notification.isRead == '1';

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

    return Card(
      elevation: isRead ? 1 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: isRead
            ? BorderSide(color: Colors.grey[300]!, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (title.toLowerCase().contains('overdue') ||
              body.toLowerCase().contains('overdue')) {
            final notifId = widget.notification.notificationId;
            final intId = int.tryParse(notifId ?? '');
            if (intId != null && intId > 0 && intId != 999999) {
              MicrotecSocket.readNotification(id: intId);
            } else {
              Provider.of<NotificationProvider>(context, listen: false)
                  .markNotificationAsRead(notifId ?? '999999');
            }
            sideProvider.updateSelectedName('Overdue Task');
            sideProvider.setReportPage(const OverdueTaskReportScreen());
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(HomePage.route);
            }
            return;
          }

          // Mark notification as read when clicked
          MicrotecSocket.readNotification(
              id: int.tryParse(widget.notification.notificationId ?? '0'));

          final customerId =
              int.tryParse(widget.notification.customerId?.toString() ?? '0') ??
                  0;
          final taskId =
              int.tryParse(widget.notification.masterId?.toString() ?? '0') ??
                  0;
          final followupId =
              int.tryParse(widget.notification.followupId?.toString() ?? '0') ??
                  0;
          final redirectId =
              int.tryParse(widget.notification.redirectId?.toString() ?? '0') ??
                  0;

          // final customerId = 21869;
          // final taskId = 13;
          // final redirectId = 1;
          print("customerId: $customerId");
          print("taskId: $taskId");
          print("followupId: $followupId");
          print("redirectId: $redirectId");

          leadProvider.setCutomerId(customerId);
          customerDetailsProvider.setCustomerId(customerId);

          if (redirectId == 3) {
            //task
            customerDetailsProvider.getTaskDetails(taskId.toString(), context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TaskDetailsPagePhone(
                  taskId: taskId.toString(),
                  customerId: customerId.toString(),
                  taskMasterId: taskId.toString(),
                );
              },
            );
          } else if (redirectId == 1) {
            //lead
            customerDetailsProvider.fetchLeadDetails(
                customerId.toString(), context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailPageMobile(
                  fromLead: false,
                  customerId: customerId,
                ),
              ),
            );
          } else if (redirectId == 2) {
            //followup
            customerDetailsProvider.fetchLeadDetails(
                customerId.toString(), context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailPageMobile(
                  fromLead: false,
                  customerId: customerId,
                ),
              ),
            );
          } else if (redirectId == 4) {
            //task update status
            customerDetailsProvider.getTaskDetails(taskId.toString(), context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TaskDetailsPagePhone(
                  taskId: taskId.toString(),
                  customerId: customerId.toString(),
                  taskMasterId: taskId.toString(),
                );
              },
            );
          }
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: isRead ? Colors.grey[200] : Colors.blue[50],
            child: Icon(
              Icons.notifications,
              color: isRead ? Colors.grey[600] : Colors.blue[600],
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
              fontSize: 16,
              color: isRead ? Colors.grey[600] : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (body.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildNotificationBody(body, isRead),
              ],
              if (createdStr.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  createdStr,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeForWeb(String createdStr) {
    try {
      final dateTime = DateTime.parse(createdStr.replaceAll(' ', 'T'));
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return createdStr;
    }
  }
}
