import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/payment_reminder_card.dart';

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

  double _calculateTotalOutstanding(List items) {
    double total = 0;
    for (var item in items) {
      try {
        // Handle potential currency symbols or commas
        String amountStr = item.balanceAmount.replaceAll(',', '').replaceAll('₹', '').trim();
        total += double.tryParse(amountStr) ?? 0.0;
      } catch (e) {
        // Ignore parsing errors
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WarrentyReportProvider, DropDownProvider>(
      builder: (context, provider, dropdownProvider, child) {
        final filteredList = provider.paymentReminderList.where((item) {
          return item.customerName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        final totalOutstanding = _calculateTotalOutstanding(provider.paymentReminderList);

        return Column(
          children: [
            // Summary Section
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Outstanding",
                    value: "₹${totalOutstanding.toStringAsFixed(2)}",
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
            const SizedBox(height: 16),

            // List Section
            if (provider.isPaymentReminderLoading)
              _buildShimmerLoading()
            else if (provider.paymentReminderList.isEmpty)
              _buildEmptyState("No Payment Reminders found")
            else if (filteredList.isEmpty)
              _buildEmptyState("No results for '$_searchQuery'")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return PaymentReminderCard(item: filteredList[index]);
                },
              ),
          ],
        );
      },
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
        borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(10),
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
      children: List.generate(3, (index) => Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payments_outlined, size: 64, color: AppColors.textGrey2.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
        ],
      ),
    );
  }
}
