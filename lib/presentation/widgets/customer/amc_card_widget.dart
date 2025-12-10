import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class AmcCardWidget extends StatelessWidget {
  final String amcId;
  final String customerId;
  final String category;
  final String title;
  final String productNo;
  final String date;
  final String posted;
  final String status;
  final String servicename;
  final String description;
  final String price;
  final String productName;
  final void Function()? onPressed;

  const AmcCardWidget({
    super.key,
    required this.category,
    required this.title,
    required this.productName,
    required this.productNo,
    required this.date,
    required this.posted,
    required this.status,
    required this.servicename,
    required this.description,
    required this.price,
    required this.onPressed,
    required this.amcId,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final settingsprovider = Provider.of<SettingsProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    Color statusColor = status == "Completed"
        ? Colors.green
        : status == "In Progress"
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: AppColors.textGrey2.withOpacity(.3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(productName,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                // Text('AMC no:$productNo',
                //     style: TextStyle(
                //         fontWeight: FontWeight.w700,
                //         color: AppColors.textBlack)),
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
                // Image.asset(
                //   'assets/images/task-02.png',
                //   width: 16,
                //   height: 16,
                // ),
                // const SizedBox(
                //   width: 5,
                // ),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack)),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(),
                  ),
                ),
                // const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack)),
                    Row(
                      children: [
                        if (settingsprovider.menuIsEditMap[15] == 1)
                          IconButton(
                              onPressed: onPressed,
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.textGrey3,
                              )),
                        if (settingsprovider.menuIsDeleteMap[15] == 1)
                          IconButton(
                              onPressed: () {
                                showConfirmationDialog(
                                  isLoading:
                                      customerDetailsProvider.isDeleteLoading,
                                  context: context,
                                  title: 'Confirm Deletion',
                                  content:
                                      'Are you sure you want to delete this Periodic Service?',
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                  onConfirm: () {
                                    customerDetailsProvider.deleteAMC(
                                        amcId, customerId, context);
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
                        Icon(
                          Icons.calendar_month,
                          color: AppColors.textGrey3,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          date,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack),
                        ),
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
