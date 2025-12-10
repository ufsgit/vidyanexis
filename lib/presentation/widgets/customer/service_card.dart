import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_service.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';

class ServiceCard extends StatelessWidget {
  final String category;
  final String taskId;
  final String title;
  final String serviceno;
  final String date;
  final String posted;
  final String status;
  final String servicename;
  final String customerId;
  final int serviceTypeId;
  final String serviceTypeName;
  final int serviceStatusId;
  final String description;
  final String amount;

  const ServiceCard({
    super.key,
    required this.category,
    required this.taskId,
    required this.title,
    required this.serviceno,
    required this.date,
    required this.posted,
    required this.status,
    required this.servicename,
    required this.customerId,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.serviceStatusId,
    required this.description,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    Color statusColor = status == "Completed"
        ? Colors.green
        : status == "Pending"
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  category == "1"
                      ? 'assets/images/Task type=Site Visit.png'
                      : category == "2"
                          ? 'assets/images/Task type=Installation.png'
                          : category == "3"
                              ? 'assets/images/Task type=Service.png'
                              : 'assets/images/Task type=AMC.png',
                  height: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Image.asset(
                  'assets/images/task-02.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            AppStyles.isWebScreen(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap service name with Expanded and handle text overflow
                      Expanded(
                        flex: 3,
                        child: Text(
                          servicename,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2, // Allow up to 2 lines
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis if still too long
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Action buttons and date info
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (settingsprovider.menuIsEditMap[14] == 1)
                              IconButton(
                                onPressed: () {
                                  customerDetailsProvider.customerId =
                                      customerId;
                                  customerDetailsProvider
                                      .setServiceEditDropDown(
                                          serviceTypeId,
                                          serviceTypeName,
                                          serviceStatusId,
                                          status);
                                  customerDetailsProvider
                                      .taskDescriptionController
                                      .text = description.toString();
                                  customerDetailsProvider.serviceController
                                      .text = servicename.toString();
                                  customerDetailsProvider
                                      .serviceAmountController
                                      .text = amount.toString();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return ServiceCreationWidget(
                                          taskId: taskId,
                                          isEdit: true,
                                          customerId: customerId);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            if (settingsprovider.menuIsDeleteMap[14] == 1)
                              IconButton(
                                  onPressed: () {
                                    showConfirmationDialog(
                                      isLoading: customerDetailsProvider
                                          .isDeleteLoading,
                                      context: context,
                                      title: 'Confirm Deletion',
                                      content:
                                          'Are you sure you want to delete this complaint?',
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      onConfirm: () {
                                        customerDetailsProvider.deleteService(
                                            taskId, customerId, context);
                                        Navigator.of(context).pop();
                                      },
                                      confirmButtonText: 'Delete',
                                      confirmButtonColor: Colors.red,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppColors.textRed,
                                  )),
                            Flexible(
                              child: Text(
                                posted != 'null' && posted.isNotEmpty
                                    ? 'Posted On : ${DateFormat('MMM dd, yyyy').format(DateTime.parse(posted))}'
                                    : 'Posted On : ',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.navigate_next_outlined,
                              color: Colors.grey,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name with proper text wrapping for mobile
                      Text(
                        servicename,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3, // Allow up to 3 lines on mobile
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Action buttons row for mobile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (settingsprovider.menuIsEditMap[14] == 1)
                                IconButton(
                                  onPressed: () {
                                    customerDetailsProvider.customerId =
                                        customerId;
                                    customerDetailsProvider
                                        .setServiceEditDropDown(
                                            serviceTypeId,
                                            serviceTypeName,
                                            serviceStatusId,
                                            status);
                                    customerDetailsProvider
                                        .taskDescriptionController
                                        .text = description.toString();
                                    customerDetailsProvider.serviceController
                                        .text = servicename.toString();
                                    customerDetailsProvider
                                        .serviceAmountController
                                        .text = amount.toString();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return ServiceCreationWidget(
                                            taskId: taskId,
                                            isEdit: true,
                                            customerId: customerId);
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              if (settingsprovider.menuIsDeleteMap[14] == 1)
                                IconButton(
                                    onPressed: () {
                                      showConfirmationDialog(
                                        isLoading: customerDetailsProvider
                                            .isDeleteLoading,
                                        context: context,
                                        title: 'Confirm Deletion',
                                        content:
                                            'Are you sure you want to delete this complaint?',
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                        },
                                        onConfirm: () {
                                          customerDetailsProvider.deleteService(
                                              taskId, customerId, context);
                                          Navigator.of(context).pop();
                                        },
                                        confirmButtonText: 'Delete',
                                        confirmButtonColor: Colors.red,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: AppColors.textRed,
                                    )),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  posted != 'null' && posted.isNotEmpty
                                      ? 'Posted On : ${DateFormat('MMM dd, yyyy').format(DateTime.parse(posted))}'
                                      : 'Posted On : ',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.navigate_next_outlined,
                                color: Colors.grey,
                                size: 30,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
