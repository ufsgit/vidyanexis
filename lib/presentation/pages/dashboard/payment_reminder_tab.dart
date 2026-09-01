import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/models/payment_reminder_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';

class PaymentReminderTab extends StatefulWidget {
  const PaymentReminderTab({super.key});

  @override
  State<PaymentReminderTab> createState() => _PaymentReminderTabState();
}

class _PaymentReminderTabState extends State<PaymentReminderTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      dropdownProvider.getUserDetails(context);
      provider.getPaymentReminders(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCustomerDetails(BuildContext context, int customerId) {
    if (AppStyles.isWebScreen(context)) {
      final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      int index = 0;
      if (settingsProvider.menuIsViewMap[12].toString() == '1') {
        index++;
      }
      if (settingsProvider.menuIsViewMap[3].toString() == '1') {
        index++;
      }

      sideProvider.updateSelectedName('Customers');
      sideProvider.setSelectedIndex(index);
      sideProvider.replaceWidgetCustomer(false, customerId.toString());
    } else {
      context.push(
          '${CustomerDetailPageMobile.route}$customerId/true?tab=Payment');
    }
  }

  double _calculateTotalOutstanding(List items) {
    double total = 0;
    for (var item in items) {
      try {
        String amountStr =
            item.balanceAmount.replaceAll(',', '').replaceAll('₹', '').trim();
        total += double.tryParse(amountStr) ?? 0.0;
      } catch (e) {
        // Ignore parsing errors
      }
    }
    return total;
  }

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return '??';
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _getMonthYearHeader(String dateString) {
    if (dateString.isEmpty) return 'Other';
    try {
      DateTime parsedDate;
      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts[0].length == 4) {
          parsedDate = DateTime.parse(dateString);
        } else {
          parsedDate = DateTime(
            int.parse(parts[2].split(' ')[0]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts[2].length == 4) {
          parsedDate = DateTime(
            int.parse(parts[2].split(' ')[0]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          parsedDate = DateTime.parse(dateString);
        }
      } else {
        parsedDate = DateTime.parse(dateString);
      }
      return DateFormat('MMMM, yyyy').format(parsedDate);
    } catch (e) {
      return 'Other';
    }
  }

  Map<String, List<GroupedInvoiceItem>> _getGroupedRemindersReport(
      List<PaymentReminderModel> reminders) {
    final Map<String, Map<int, GroupedInvoiceItem>> tempGroups = {};
    final Map<String, DateTime> monthToFirstDate = {};

    for (var reminder in reminders) {
      final monthStr = _getMonthYearHeader(reminder.reminderDate);

      final balAmt = double.tryParse(reminder.balanceAmount
              .replaceAll(',', '')
              .replaceAll('₹', '')
              .trim()) ??
          0.0;
      final recAmt = double.tryParse(reminder.receiptAmount
              .replaceAll(',', '')
              .replaceAll('₹', '')
              .trim()) ??
          0.0;
      final invAmtRaw = double.tryParse(reminder.totalProjectCost
              .replaceAll(',', '')
              .replaceAll('₹', '')
              .trim()) ??
          0.0;
      final invAmt = invAmtRaw > 0 ? invAmtRaw : (recAmt + balAmt);

      try {
        DateTime parsedDate;
        if (reminder.reminderDate.contains('-')) {
          final parts = reminder.reminderDate.split('-');
          if (parts[0].length == 4) {
            parsedDate = DateTime.parse(reminder.reminderDate);
          } else {
            parsedDate = DateTime(
              int.parse(parts[2].split(' ')[0]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } else {
          parsedDate = DateTime.parse(reminder.reminderDate);
        }
        if (!monthToFirstDate.containsKey(monthStr) ||
            parsedDate.isBefore(monthToFirstDate[monthStr]!)) {
          monthToFirstDate[monthStr] = parsedDate;
        }
      } catch (_) {
        monthToFirstDate.putIfAbsent(monthStr, () => DateTime.now());
      }

      tempGroups.putIfAbsent(monthStr, () => {});
      final monthMap = tempGroups[monthStr]!;

      if (monthMap.containsKey(reminder.customerId)) {
        final existing = monthMap[reminder.customerId]!;
        monthMap[reminder.customerId] = GroupedInvoiceItem(
          customerId: reminder.customerId,
          customerName: existing.customerName.isNotEmpty
              ? existing.customerName
              : reminder.customerName,
          invoiceAmount: existing.invoiceAmount + invAmt,
          recieptAmount: existing.recieptAmount + recAmt,
          balanceAmount: existing.balanceAmount + balAmt,
        );
      } else {
        monthMap[reminder.customerId] = GroupedInvoiceItem(
          customerId: reminder.customerId,
          customerName: reminder.customerName,
          invoiceAmount: invAmt,
          recieptAmount: recAmt,
          balanceAmount: balAmt,
        );
      }
    }

    final Map<String, List<GroupedInvoiceItem>> groupedReport = {};

    final sortedMonths = tempGroups.keys.toList();
    sortedMonths.sort((a, b) {
      final dateA =
          monthToFirstDate[a] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB =
          monthToFirstDate[b] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA); // Newest months first
    });

    for (var month in sortedMonths) {
      groupedReport[month] = tempGroups[month]!.values.toList();
      groupedReport[month]!.sort((a, b) =>
          a.customerName.toLowerCase().compareTo(b.customerName.toLowerCase()));
    }

    return groupedReport;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WarrentyReportProvider, DropDownProvider>(
      builder: (context, provider, dropdownProvider, child) {
        final totalOutstanding =
            _calculateTotalOutstanding(provider.paymentReminderList);

        // Filter the reminders list based on the search query
        final filteredReminders = provider.paymentReminderList.where((item) {
          return item.customerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        final groupedReport = _getGroupedRemindersReport(filteredReminders);

        return Column(
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Outstanding",
                    value:
                        "₹${NumberFormat('#,##,##0.00').format(totalOutstanding)}",
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFF87171),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Pending Reminders",
                    value: provider.paymentReminderList.length.toString(),
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search customer name...",
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textGrey3,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textGrey3, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Premium Project Budgets Report UI Section
            if (provider.isPaymentReminderLoading)
              _buildShimmerLoading()
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppStyles.isWebScreen(context)
                    ? _buildBudgetReport(groupedReport)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 600,
                          child: _buildBudgetReport(groupedReport),
                        ),
                      ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetReport(
      Map<String, List<GroupedInvoiceItem>> groupedReport) {
    if (groupedReport.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          _searchQuery.isEmpty
              ? "No billing records found"
              : "No results for '$_searchQuery'",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey3,
          ),
        ),
      );
    }

    // Flatten all items into a single list
    final List<GroupedInvoiceItem> allItems = [];
    for (var list in groupedReport.values) {
      allItems.addAll(list);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column Headers Row styled like Hubstaff
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "PROJECT/LEAD",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey3,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "PROJECT COST",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey3,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "RECIEIPT",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey3,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "%",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey3,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "REMAINING",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey3,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 8),

        // List of project budget items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allItems.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, itemIndex) {
            final item = allItems[itemIndex];

            // Calculate percentage safely
            double pct = 0.0;
            if (item.invoiceAmount > 0) {
              pct = (item.recieptAmount / item.invoiceAmount);
              if (pct > 1.0) pct = 1.0;
              if (pct < 0.0) pct = 0.0;
            }
            final pctText = "${(pct * 100).toStringAsFixed(0)}%";

            return InkWell(
              onTap: () => _navigateToCustomerDetails(context, item.customerId),
              hoverColor: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Project Column: Avatar + Name
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: getAvatarColor(item.customerName)
                                  .withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(item.customerName),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: getAvatarColor(item.customerName),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.customerName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Budget (Cost) Column with Progress Bar
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          // Budget text
                          Text(
                            "₹${NumberFormat('#,##,##0.00').format(item.invoiceAmount)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Thin progress bar
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  pct >= 1.0
                                      ? Colors.green
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spent (Receipt) Column
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹${NumberFormat('#,##,##0.00').format(item.recieptAmount)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),

                    // Dedicated Percentage Column
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          pctText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ),
                    ),

                    // Remaining Column
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹${NumberFormat('#,##,##0.00').format(item.balanceAmount)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: item.balanceAmount > 0
                              ? AppColors.textRed
                              : AppColors.textGrey3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
          3,
          (index) => Container(
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )),
    );
  }
}

class GroupedInvoiceItem {
  final int customerId;
  final String customerName;
  final double invoiceAmount; // Budget
  final double recieptAmount; // Spent
  final double balanceAmount; // Remaining

  GroupedInvoiceItem({
    required this.customerId,
    required this.customerName,
    required this.invoiceAmount,
    required this.recieptAmount,
    required this.balanceAmount,
  });
}
