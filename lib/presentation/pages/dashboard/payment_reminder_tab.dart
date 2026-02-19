import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

class PaymentReminderTab extends StatefulWidget {
  const PaymentReminderTab({super.key});

  @override
  State<PaymentReminderTab> createState() => _PaymentReminderTabState();
}

class _PaymentReminderTabState extends State<PaymentReminderTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      // Initialize filters if needed
      // Fetch users for filter if not already fetched
      dropdownProvider.getUserDetails(context);

      provider.getPaymentReminders(context);
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
                    // User Filter
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
                          provider.getPaymentReminders(context);
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
                                  provider.getPaymentReminders(context);
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
            if (provider.isPaymentReminderLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.paymentReminderList.isEmpty)
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Text('No Payment Reminders found'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: provider.paymentReminderList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = provider.paymentReminderList[index];
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.customerName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "Reminder Date : ",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(item.reminderDate),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Balance Amount",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textGrey3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.balanceAmount,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ])
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
            DropdownMenuItem<int>(
              value: 0,
              child: Text('All Users'),
            ),
            ...dropdownProvider.searchUserDetails.map((user) {
              return DropdownMenuItem<int>(
                value: user.userDetailsId,
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.userDetailsName,
                      overflow: TextOverflow.ellipsis,
                    )),
              );
            }).toList(),
          ],
          onChanged: (value) {
            provider.setUserFilterStatus(value ?? 0);
            provider.getPaymentReminders(context);
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
