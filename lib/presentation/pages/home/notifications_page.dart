import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/socket_io.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/add_followup_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/notification_overlay.dart';
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
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: Color(0xFF152D70),
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
                child: Image.asset(
                  'assets/images/ArrowRight.png',
                  width: 24,
                  height: 24,
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
                child: Image.asset(
                  'assets/images/ArrowRight.png',
                  width: 24,
                  height: 24,
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
  bool _isHovered = false;

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
    final isRead = widget.notification.isRead == '1';

    return InkWell(
      onTap: () {
        // Mark notification as read when clicked
        MicrotecSocket.readNotification(
            id: int.tryParse(widget.notification.notificationId ?? '0'));

        // final customerId =
        //     int.tryParse(widget.notification.customerId?.toString() ?? '0') ??
        //         0;
        // final taskId =
        //     int.tryParse(widget.notification.masterId?.toString() ?? '0') ?? 0;

        final customerId = 21869;
        final taskId = 13;
        final redirectId = 1;
        print("customerId: $customerId");
        print("taskId: $taskId");
        print("redirectId: $redirectId");

        leadProvider.setCutomerId(customerId);

        if (redirectId == 1) {
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
        } else if (redirectId == 2) {
          //lead
          leadDetailsProvider.fetchLeadDetails(customerId.toString(), context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NewLeadDrawerWidget(
                isEdit: true,
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
          borderRadius: BorderRadius.circular(8),
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
                borderRadius: BorderRadius.circular(8),
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
                          widget.notification.titleNew ?? '',
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
                  const SizedBox(height: 4),
                  if ((widget.notification.body ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        MicrotecSocket.readNotification(
                            id: int.tryParse(
                                widget.notification.notificationId ?? '0'));
                      },
                      child: Builder(
                        builder: (context) {
                          final message = widget.notification.body ?? '';
                          final parts = message.split('for');
                          String before = '';
                          String name = '';
                          String after = '';

                          if (parts.length > 1) {
                            before = parts[0]; // "a new lead "
                            final nameAndRest =
                                parts[1].split('has been created');
                            if (nameAndRest.isNotEmpty) {
                              name = nameAndRest[0].trim(); // "ravi"
                            }
                            if (nameAndRest.length > 1) {
                              after = 'has been created';
                            }
                          }

                          return RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isRead
                                    ? Colors.grey[600]
                                    : Colors.grey[700],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: before + " "), // normal text
                                WidgetSpan(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerDetailsScreen(
                                                    customerId: widget
                                                            .notification
                                                            .customerId
                                                            ?.toString() ??
                                                        "0",
                                                    report: "true",
                                                  )));
                                      print(widget.notification.toJson());
                                      print(
                                          "-CustomerId ${widget.notification.customerId}");
                                      // leadProvider.statusController.clear();
                                      // leadProvider.assignToFollowUpController
                                      //     .clear();
                                      // leadProvider.messageController.clear();
                                      // leadProvider.nextFollowUpDateController
                                      //     .clear();

                                      // final dropDownProvider =
                                      //     Provider.of<DropDownProvider>(context,
                                      //         listen: false);
                                      // dropDownProvider.selectedStatusId = null;
                                      // dropDownProvider.selectedUserId = null;

                                      // leadProvider.setCutomerId(int.parse(
                                      //     widget.notification.customerId ??
                                      //         ''));

                                      // // Extract customer name from message
                                      // final message =
                                      //     widget.notification.body ?? '';
                                      // // Assuming format: "a new lead for NAME has been created"
                                      // final parts = message.split('for');
                                      // String customerName = '';
                                      // if (parts.length > 1) {
                                      //   customerName = parts[1]
                                      //       .replaceAll('has been created', '')
                                      //       .trim();
                                      // }

                                      // showDialog(
                                      //   barrierDismissible: false,
                                      //   context: context,
                                      //   builder: (BuildContext context) =>
                                      //       AddFollowupDialog(
                                      //     customerName: customerName,
                                      //   ),
                                      // );
                                    },
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: isRead
                                            ? Colors.grey[500]
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: " " + after), // rest of message
                              ],
                            ),
                          );
                        },
                      ),
                    )
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
    final isRead = widget.notification.isRead == '1';

    return Card(
      elevation: isRead ? 1 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead
            ? BorderSide(color: Colors.grey[300]!, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // Mark notification as read when clicked
          MicrotecSocket.readNotification(
              id: int.tryParse(widget.notification.notificationId ?? '0'));

          // final customerId =
          //     int.tryParse(widget.notification.customerId?.toString() ?? '0') ??
          //         0;
          // final taskId =
          //     int.tryParse(widget.notification.masterId?.toString() ?? '0') ?? 0;

          final customerId = 21869;
          final taskId = 13;
          final redirectId = 2;
          print("customerId: $customerId");
          print("taskId: $taskId");
          print("redirectId: $redirectId");

          leadProvider.setCutomerId(customerId);

          if (redirectId == 1) {
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
          } else if (redirectId == 2) {
            //lead
            leadDetailsProvider.fetchLeadDetails(
                customerId.toString(), context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return NewLeadDrawerMobileWidget(
                  isEdit: true,
                  customerId: customerId.toString(),
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
            widget.notification.title ?? '',
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
              fontSize: 16,
              color: isRead ? Colors.grey[600] : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((widget.notification.body ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    // Mark notification as read when body is clicked
                    MicrotecSocket.readNotification(
                        id: int.tryParse(
                            widget.notification.notificationId ?? '0'));

                    leadProvider.statusController.clear();
                    leadProvider.assignToFollowUpController.clear();
                    leadProvider.messageController.clear();
                    leadProvider.nextFollowUpDateController.clear();

                    final dropDownProvider =
                        Provider.of<DropDownProvider>(context, listen: false);
                    dropDownProvider.selectedStatusId = null;
                    dropDownProvider.selectedUserId = null;

                    leadProvider.setCutomerId(
                        int.parse(widget.notification.customerId ?? ''));

                    // Extract customer name from message
                    final message = widget.notification.body ?? '';
                    // Assuming format: "a new lead for NAME has been created"
                    final parts = message.split('for');
                    String customerName = '';
                    if (parts.length > 1) {
                      customerName =
                          parts[1].replaceAll('has been created', '').trim();
                    }

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => AddFollowupDialog(
                        customerName: customerName,
                      ),
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      final message = widget.notification.body ?? '';
                      final parts = message.split('for');
                      String before = '';
                      String name = '';
                      String after = '';

                      if (parts.length > 1) {
                        before = parts[0]; // "a new lead "
                        final nameAndRest = parts[1].split('has been created');
                        if (nameAndRest.isNotEmpty) {
                          name = nameAndRest[0].trim(); // "ravi"
                        }
                        if (nameAndRest.length > 1) {
                          after = 'has been created';
                        }
                      }

                      return RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: isRead ? Colors.grey[600] : Colors.grey[700],
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(text: before + " "), // normal text
                            WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  leadProvider.statusController.clear();
                                  leadProvider.assignToFollowUpController
                                      .clear();
                                  leadProvider.messageController.clear();
                                  leadProvider.nextFollowUpDateController
                                      .clear();

                                  final dropDownProvider =
                                      Provider.of<DropDownProvider>(context,
                                          listen: false);
                                  dropDownProvider.selectedStatusId = null;
                                  dropDownProvider.selectedUserId = null;

                                  leadProvider.setCutomerId(int.parse(
                                      widget.notification.customerId ?? ''));

                                  // Extract customer name from message
                                  final message =
                                      widget.notification.body ?? '';
                                  // Assuming format: "a new lead for NAME has been created"
                                  final parts = message.split('for');
                                  String customerName = '';
                                  if (parts.length > 1) {
                                    customerName = parts[1]
                                        .replaceAll('has been created', '')
                                        .trim();
                                  }

                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AddFollowupDialog(
                                      customerName: customerName,
                                    ),
                                  );
                                },
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color:
                                        isRead ? Colors.grey[500] : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(text: " " + after), // rest of message
                          ],
                        ),
                      );
                    },
                  ),
                )
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
