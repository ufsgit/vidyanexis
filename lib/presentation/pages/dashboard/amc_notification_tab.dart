import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';

import 'package:vidyanexis/controller/drop_down_provider.dart';

class AmcNotificationTab extends StatefulWidget {
  const AmcNotificationTab({super.key});

  @override
  State<AmcNotificationTab> createState() => _AmcNotificationTabState();
}

class _AmcNotificationTabState extends State<AmcNotificationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      dropdownProvider.getUserDetails(context);
      // Initialize filters if needed, maybe clear them first
      provider.getAmcNotification(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WarrentyReportProvider, DropDownProvider>(
      builder: (context, provider, dropdownProvider, child) {
        return Column(
          children: [
            // Filter Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildUserFilter(provider, dropdownProvider),
                    const SizedBox(width: 8),
                    // Date Filter
                    InkWell(
                      onTap: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDateRange: provider.fromDate != null &&
                                  provider.toDate != null
                              ? DateTimeRange(
                                  start: provider.fromDate!,
                                  end: provider.toDate!)
                              : null,
                        );
                        if (picked != null) {
                          provider.setFromDate(picked.start);
                          provider.setToDate(picked.end);
                          provider.getAmcNotification(context);
                        } else {
                          // Clear filter? Or keep previous?
                          // If user cancels, keep previous.
                          // To clear, maybe we need a clear button.
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: AppColors.textGrey3),
                            const SizedBox(width: 8),
                            Text(
                              provider.fromDate != null &&
                                      provider.toDate != null
                                  ? '${DateFormat('dd/MM/yyyy').format(provider.fromDate!)} - ${DateFormat('dd/MM/yyyy').format(provider.toDate!)}'
                                  : 'Select Date Range',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                              ),
                            ),
                            if (provider.fromDate != null) ...[
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  provider.selectDateFilterOption(
                                      null); // Clear dates
                                  provider.getAmcNotification(context);
                                },
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List Section
            // List Section
            if (provider.isAmcNotificationLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.amcNotificationList.isEmpty)
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Text('No AMC notifications found'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: provider.amcNotificationList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = provider.amcNotificationList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.customerName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatDate(item.serviceDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (item.amcProductName.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                "Product Name : ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              Text(
                                item.amcProductName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (item.serviceName.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                "Service Name : ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              Text(
                                item.serviceName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (item.staffName.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                "Staff Name : ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              Text(
                                item.staffName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserFilter(
      WarrentyReportProvider provider, DropDownProvider dropdownProvider) {
    if (dropdownProvider.searchUserDetails.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 4), // Adjusted vertical padding
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: provider.selectedUser ?? 0,
          hint: Text(
            'All Users',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textBlack,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.textGrey3),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          items: [
            const DropdownMenuItem<int>(
              value: 0,
              child: Text('All Users'),
            ),
            ...dropdownProvider.searchUserDetails.map((user) {
              return DropdownMenuItem<int>(
                value: user.userDetailsId,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.userDetailsName,
                      overflow: TextOverflow.ellipsis,
                    )),
              );
            }).toList(),
          ],
          onChanged: (value) {
            provider.setUserFilterStatus(value ?? 0);
            provider.getAmcNotification(context);
          },
          isDense: true,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'No Date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
