import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';

class PeriodicServiceDetailsPage extends StatelessWidget {
  final String customerId;
  final AmcReportModeld amcReportModeld;
  bool showEdit;
  PeriodicServiceDetailsPage({
    super.key,
    required this.customerId,
    this.showEdit = true,
    required this.amcReportModeld,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
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
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Colors.white,
            width: AppStyles.isWebScreen(context)
                ? MediaQuery.of(context).size.width / 2
                : MediaQuery.of(context).size.width,
            height: MediaQuery.sizeOf(context).height / 1.5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        title: Text(
                          'Periodic Service Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGrey3,
                          ),
                        ),
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded: true,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                  width: 120,
                                  child: Text(
                                    'Status',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textGrey4,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )),
                              const SizedBox(width: 12),
                              Text(
                                amcReportModeld.amcStatusName,
                                style: TextStyle(
                                    color: amcReportModeld.amcStatusName ==
                                            "Completed"
                                        ? Colors.green
                                        : amcReportModeld.amcStatusName ==
                                                "Pending"
                                            ? Colors.orange
                                            : Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'From Date',
                            value: DateFormat('MMM dd, yyyy').format(
                                DateTime.parse(
                                    amcReportModeld.fromDate.toString())),
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'To Date',
                            value: DateFormat('MMM dd, yyyy').format(
                                DateTime.parse(
                                    amcReportModeld.toDate.toString())),
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Customer Name',
                            // value: customerDetailsProvider
                            //     .serviceDetails[0].createDate
                            //     .toString(),
                            value: amcReportModeld.customerName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Description',
                            value: amcReportModeld.description,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Created by',
                            value: amcReportModeld.createdByName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Product Name',
                            value: amcReportModeld.productName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Service Name',
                            value: amcReportModeld.serviceName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Amount',
                            value: amcReportModeld.amount,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
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
