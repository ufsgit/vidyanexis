import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';

class AmcWidget extends StatelessWidget {
  final String customerName;
  final String customerStatus;
  final String entryDate;
  final String productName;
  final String service;
  final String amount;
  final String description;
  final void Function()? onPressed;

  const AmcWidget({
    super.key,
    required this.entryDate,
    required this.productName,
    required this.service,
    required this.amount,
    required this.description,
    required this.customerName,
    required this.customerStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Periodic Service Details',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (settingsprovider.menuIsEditMap[15] == 1)
                    IconButton(
                        onPressed: onPressed, icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close)),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customerDetailsProvider.amcList.isNotEmpty
              ? Container(
                  color: Colors.white,
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 2.5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              isAssignee: true,
                              label: 'Customer',
                              value: customerName,
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.statusColor,
                              isAssignee: true,
                              label: 'Status',
                              value: customerStatus,
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Date',
                              value: DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(entryDate)),
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Product name',
                              value: productName,
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Service',
                              value: service,
                              labelFontSize: 14,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                              labelFontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              label: 'Amount',
                              value: amount,
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              label: 'Description',
                              value: description,
                              labelFontSize: 14,
                              labelFontWeight: FontWeight.w500,
                              valueFontSize: 14,
                              valueFontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      // If the date is not empty and valid
      if (date.isNotEmpty) {
        DateTime parsedDate =
            DateTime.parse(date); // Parse the string into DateTime
        return DateFormat('dd MMM yyyy')
            .format(parsedDate); // Format into dd MMM yyyy format
      } else {
        return ''; // Return empty string if no date is provided
      }
    } catch (e) {
      return ''; // Return empty string in case of invalid date format
    }
  }
}
