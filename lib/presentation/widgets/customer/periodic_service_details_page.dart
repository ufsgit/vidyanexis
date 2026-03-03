import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/amc_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';

class PeriodicServiceDetailsPage extends StatefulWidget {
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
  State<PeriodicServiceDetailsPage> createState() =>
      _PeriodicServiceDetailsPageState();
}

class _PeriodicServiceDetailsPageState
    extends State<PeriodicServiceDetailsPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.amcReportModeld.description;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
                                widget.amcReportModeld.amcStatusName,
                                style: TextStyle(
                                    color:
                                        widget.amcReportModeld.amcStatusName ==
                                                "Completed"
                                            ? Colors.green
                                            : widget.amcReportModeld
                                                        .amcStatusName ==
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
                                DateTime.parse(widget.amcReportModeld.fromDate
                                    .toString())),
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'To Date',
                            value: DateFormat('MMM dd, yyyy').format(
                                DateTime.parse(
                                    widget.amcReportModeld.toDate.toString())),
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Customer Name',
                            // value: customerDetailsProvider
                            //     .serviceDetails[0].createDate
                            //     .toString(),
                            value: widget.amcReportModeld.customerName,
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Created by',
                            value: widget.amcReportModeld.createdByName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Product Name',
                            value: widget.amcReportModeld.productName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Service Name',
                            value: widget.amcReportModeld.serviceName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Category',
                            value: widget.amcReportModeld.categoryName,
                          ),
                          const SizedBox(height: 16),
                          TaskLabelValue(
                            colorUser: AppColors.grey,
                            label: 'Amount',
                            value: widget.amcReportModeld.amount,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textGrey4,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteController,
                                maxLines: 3,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textBlack,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add a description here...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textGrey3,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.textGrey2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.textGrey2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.appViolet,
                                    ),
                                  ),
                                ),
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
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textGrey3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            customerDetailsProvider.saveAmc(
              description: _noteController.text,
              fromDate: widget.amcReportModeld.fromDate,
              toDate: widget.amcReportModeld.toDate,
              serviceName: widget.amcReportModeld.serviceName,
              productName: widget.amcReportModeld.productName,
              amount: widget.amcReportModeld.amount,
              cusId: widget.amcReportModeld.customerId.toString(),
              amcId: widget.amcReportModeld.amcId.toString(),
              context: context,
              onSuccess: () {
                Provider.of<AMCReportProvider>(context, listen: false)
                    .getSearchAmcReport(context);
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appViolet,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save Description',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
