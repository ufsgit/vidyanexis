import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/socket_io.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigationHelper {
  static void navigate(
    BuildContext context, {
    required String? notificationId,
    required String? customerIdStr,
    required String? masterIdStr,
    required String? followupIdStr,
    required String? redirectIdStr,
    bool isWeb = false,
  }) {
    final int customerId = int.tryParse(customerIdStr ?? '0') ?? 0;
    final int taskId = int.tryParse(masterIdStr ?? '0') ?? 0;
    // final int followupId = int.tryParse(followupIdStr ?? '0') ?? 0;
    final int redirectId = int.tryParse(redirectIdStr ?? '0') ?? 0;

    print("--- Notification Redirection ---");
    print("customerId: $customerId");
    print("taskId: $taskId");
    print("redirectId: $redirectId");

    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final sideProvider = Provider.of<SidebarProvider>(context, listen: false);

    // Mark as read
    if (notificationId != null) {
      MicrotecSocket.readNotification(id: int.tryParse(notificationId));
    }

    leadProvider.setCutomerId(customerId);
    customerDetailsProvider.setCustomerId(customerId);

    if (redirectId == 3 || redirectId == 4) {
      // task
      customerDetailsProvider.getTaskDetails(taskId.toString(), context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          if (isWeb) {
            return TaskDetailsWidget(
              taskId: taskId.toString(),
              customerId: customerId.toString(),
              showEdit: false,
            );
          } else {
            return TaskDetailsPagePhone(
              taskId: taskId.toString(),
              customerId: customerId.toString(),
              taskMasterId: taskId.toString(),
            );
          }
        },
      );
    } else if (redirectId == 1 || redirectId == 2) {
      // lead or followup
      customerDetailsProvider.fetchLeadDetails(customerId.toString(), context);
      sideProvider.name = 'Lead /';
      if (isWeb) {
        context.push('/customerDetails/$customerId/false');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailPageMobile(
              fromLead: false,
              customerId: customerId,
            ),
          ),
        );
      }
    }
  }
}
