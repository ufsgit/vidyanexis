import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/reports/customer_outstanding_report_mobile.dart';

class CustomerOutstandingSummaryTab extends StatelessWidget {
  const CustomerOutstandingSummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        if (!dashProvider.isCustomerOutstandingSummaryLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = dashProvider.customerOutstandingSummary;
        if (data == null) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('No customer outstanding data available'),
            ),
          );
        }

        // Format currency helper
        String formatCurrency(String value) {
          final double parsed = double.tryParse(value) ?? 0.0;
          return NumberFormat.currency(locale: 'en_IN', symbol: '₹')
              .format(parsed);
        }

        void navigateToReport() {
          final sideProvider =
              Provider.of<SidebarProvider>(context, listen: false);
          if (AppStyles.isWebScreen(context)) {
            final settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);
            int index = 0;
            // non-report options:
            if (settingsProvider.menuIsViewMap[12].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[3].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[4].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[120].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[35].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[29].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[2].toString() == '1') index++;
            if (settingsProvider.menuIsViewMap[36].toString() == '1') index++;
            if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
              index++;

            // reports options:
            final reportTitles = [
              if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
                'Expense Reports',
              if (settingsProvider.menuIsViewMap[7].toString() == '1')
                'Task Reports',
              if (settingsProvider.menuIsViewMap[89].toString() == '1')
                'Task Summary Reports',
              if (settingsProvider.menuIsViewMap[123].toString() == '1')
                'Customer Task Month Report',
              if (settingsProvider.menuIsViewMap[8].toString() == '1')
                'Complaint Reports',
              if (settingsProvider.menuIsViewMap[9].toString() == '1')
                'Periodic service Reports',
              if (settingsProvider.menuIsViewMap[112].toString() == '1')
                'Out Of Warranty Reports',
              if (settingsProvider.menuIsViewMap[117].toString() == '1')
                'Upcoming Warranty Reports',
              if (settingsProvider.menuIsViewMap[10].toString() == '1')
                'Conversion Reports',
              if (settingsProvider.menuIsViewMap[11].toString() == '1')
                'Invoice Reports',
              if (settingsProvider.menuIsViewMap[25].toString() == '1')
                'Work Reports',
              if (settingsProvider.menuIsViewMap[80].toString() == '1')
                'Stock Reports',
              if (settingsProvider.menuIsViewMap[121].toString() == '1')
                'Stock Use Reports',
              if (settingsProvider.menuIsViewMap[122].toString() == '1')
                'Stock Return Reports',
              if (settingsProvider.menuIsViewMap[24].toString() == '1')
                'Time Track Reports',
              if (settingsProvider.menuIsViewMap[119].toString() == '1')
                'Enquiry Source Reports',
              if (settingsProvider.menuIsViewMap[26].toString() == '1')
                'Attendance Reports',
              if (settingsProvider.menuIsViewMap[96].toString() == '1')
                'Check-in Reports',
              if (settingsProvider.menuIsViewMap[115].toString() == '1')
                'Followup Reports',
              if (settingsProvider.menuIsViewMap[118].toString() == '1')
                'Quotation Reports',
              if (settingsProvider.menuIsViewMap[56].toString() == '1')
                'Lead Reports',
              if (settingsProvider.menuIsViewMap[113].toString() == '1')
                'Commission Reports',
              if (settingsProvider.menuIsViewMap[114].toString() == '1')
                'Sub Contract Reports',
              if (settingsProvider.menuIsViewMap[97].toString() == '1')
                'Solar Lead Reports',
              if (settingsProvider.menuIsViewMap[98].toString() == '1')
                'Sales Pipeline',
              if (settingsProvider.menuIsViewMap[99].toString() == '1')
                'Balance Reports',
              if (settingsProvider.menuIsViewMap[72].toString() == '1')
                'Payment Reports',
              if (settingsProvider.menuIsViewMap[88].toString() == '1')
                'Receipt Reports',
              if (settingsProvider.menuIsViewMap[73].toString() == '1')
                'Upcoming Payment Reports',
              if (settingsProvider.menuIsViewMap[74].toString() == '1')
                'Total Outstanding Reports',
              if (settingsProvider.menuIsViewMap[75].toString() == '1')
                'Outstanding Reports',
              if (settingsProvider.menuIsViewMap[152].toString() == '1' ||
                  kDebugMode)
                'Customer Outstanding Reports',
              if (settingsProvider.menuIsViewMap[144].toString() == '1')
                'Sales Reports',
            ];

            final reportIndex =
                reportTitles.indexOf('Customer Outstanding Reports');
            if (reportIndex != -1) {
              index += reportIndex;
            }

            sideProvider.updateSelectedName('Customer Outstanding Reports');
            sideProvider.replaceWidget(true, '');
            sideProvider.replaceWidgetCustomer(true, '');
            context.go(HomePage.route);
            sideProvider.setSelectedIndex(index);
          } else {
            sideProvider.setReportPage(const CustomerOutstandingReportMobile());
          }
        }

        final items = [
          _CardData(
            title: 'Total Customers',
            value: data.totalCustomers.toString(),
            icon: Icons.people_alt_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _CardData(
            title: 'Total Project Cost',
            value: formatCurrency(data.totalProjectCost),
            icon: Icons.business_center_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _CardData(
            title: 'Total Received',
            value: formatCurrency(data.totalReceived),
            icon: Icons.monetization_on_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _CardData(
            title: 'Total Balance',
            value: formatCurrency(data.totalBalance),
            icon: Icons.account_balance_wallet_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFF97316), Color(0xFFEA580C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = AppStyles.isWebScreen(context) ? 4 : 2;
            final double spacing = 16.0;
            final double availableWidth =
                constraints.maxWidth - (spacing * (crossAxisCount - 1));
            final double itemWidth = availableWidth / crossAxisCount;
            final double itemHeight = 135.0;
            final double aspectRatio = itemWidth / itemHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _OutstandingCard(
                  title: item.title,
                  value: item.value,
                  icon: item.icon,
                  gradient: item.gradient,
                  onTap: navigateToReport,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CardData {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  _CardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });
}

class _OutstandingCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _OutstandingCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_OutstandingCard> createState() => _OutstandingCardState();
}

class _OutstandingCardState extends State<_OutstandingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
