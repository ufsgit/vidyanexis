import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/commission_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/commission_report_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

class CommissionReportPage extends StatefulWidget {
  const CommissionReportPage({super.key});

  @override
  State<CommissionReportPage> createState() => _CommissionReportPageState();
}

class _CommissionReportPageState extends State<CommissionReportPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<CommissionReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      dropDownProvider.getEnquirySource(context);
      dropDownProvider.getEnquiryFor(context);
      provider.getCommissionReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const CommissionReportMobile();
    }

    final provider = Provider.of<CommissionReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Commission Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 400,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Icon(Icons.search,
                              color: Colors.grey, size: 20),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search here....',
                                border: InputBorder.none,
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              onSubmitted: (val) =>
                                  provider.getCommissionReport(context),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              onPressed: () =>
                                  provider.getCommissionReport(context),
                              child: const Text('Search',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomFilterButton(
                      onPressed: () => provider.toggleFilter(),
                      isFilter: provider.isFilter,
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'Lead Name',
                            'Mobile no',
                            'Registration Date',
                            'Source',
                            'Total Project Cost',
                            'Commission',
                          ],
                          data: provider.commissionReport.map((item) {
                            return {
                              'Lead Name': item.customerName,
                              'Mobile no': item.contactNumber,
                              'Registration Date': item.entryDate,
                              'Source': item.enquirySourceName,
                              'Total Project Cost': item.totalProjectCost,
                              'Commission': item.commission,
                            };
                          }).toList(),
                          fileName: 'Commission_Report',
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ],
                ),
                if (provider.isFilter) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CommonReportDateFilter(
                        fromDate: provider.fromDate?.toString(),
                        toDate: provider.toDate?.toString(),
                        formattedFromDate: provider.formattedFromDate,
                        formattedToDate: provider.formattedToDate,
                        onTap: () => _onClickDateRange(context),
                      ),
                      const SizedBox(width: 16),
                      _buildDropdownFilter(
                        'Enquiry Source',
                        (dropDownProvider.enquiryData.any((e) =>
                                e.enquirySourceId ==
                                provider.selectedEnquirySource)
                            ? provider.selectedEnquirySource
                            : 0) as int,
                        [
                          const DropdownMenuItem(
                              value: 0, child: Text('All Sources')),
                          ...dropDownProvider.enquiryData
                              .map((e) => DropdownMenuItem(
                                    value: e.enquirySourceId,
                                    child: Text(e.enquirySourceName),
                                  )),
                        ],
                        (val) {
                          provider.setEnquirySourceFilter(val);
                          provider.getCommissionReport(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildDropdownFilter(
                        'Enquiry For',
                        (dropDownProvider.enquiryForList.any((e) =>
                                e.enquiryForId == provider.selectedEnquiryFor)
                            ? provider.selectedEnquiryFor
                            : 0) as int,
                        [
                          const DropdownMenuItem(
                              value: 0, child: Text('All Enquiry For')),
                          ...dropDownProvider.enquiryForList
                              .map((e) => DropdownMenuItem(
                                    value: e.enquiryForId,
                                    child: Text(e.enquiryForName),
                                  )),
                        ],
                        (val) {
                          provider.setEnquiryForFilter(val);
                          provider.getCommissionReport(context);
                        },
                      ),
                      const Spacer(),
                      CommonReportResetButton(
                        onReset: () => provider.resetFilters(context),
                        label: 'Clear All',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Table section
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: SizedBox(
                  width: 1500,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTableHeader('No.', width: 60),
                            _buildTableHeader('Lead Name', width: 280),
                            _buildTableHeader('Mobile Number', width: 160),
                            _buildTableHeader('Reg. Date', width: 180),
                            _buildTableHeader('Enquiry For', width: 240),
                            _buildTableHeader('Source', width: 160),
                            _buildTableHeader('Status',
                                width: 140, center: true),
                            _buildTableHeader('Total Cost', width: 140),
                            _buildTableHeader('Commission', width: 140),
                          ],
                        ),
                      ),
                      // Table Body
                      Expanded(
                        child: provider.commissionReport.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 80),
                                    Icon(Icons.search_off_outlined,
                                        size: 80, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No commission reports found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: provider.commissionReport.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: Colors.grey[100]),
                                itemBuilder: (context, index) {
                                  final item = provider.commissionReport[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 60,
                                            child: Text('${index + 1}',
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                          width: 280,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CustomerDetailsScreen(
                                                    customerId: item.customerId
                                                        .toString(),
                                                    report: 'true',
                                                  ),
                                                ),
                                              );
                                            },
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors
                                                      .primaryBlue
                                                      .withOpacity(0.1),
                                                  child: Icon(Icons.person,
                                                      size: 16,
                                                      color: AppColors
                                                          .primaryBlue),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(
                                                    item.customerName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(Icons.chevron_right,
                                                    size: 18,
                                                    color:
                                                        AppColors.primaryBlue),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 160,
                                            child: Text(item.contactNumber,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                            width: 180,
                                            child: Text(item.entryDate,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                            width: 240,
                                            child: Text(
                                                item.enquiryFor.isEmpty
                                                    ? '-'
                                                    : item.enquiryFor,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                            width: 160,
                                            child: Text(
                                                item.enquirySourceName.isEmpty
                                                    ? '-'
                                                    : item.enquirySourceName,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                          width: 140,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.statusName.isEmpty
                                                    ? 'Pending'
                                                    : item.statusName,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 140,
                                            child: Text(
                                                '₹${item.totalProjectCost}',
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            '₹${item.commission}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      // Table Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border:
                              Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 60),
                            const SizedBox(
                                width: 280,
                                child: Text('TOTAL',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 160), // Phone spacing
                            const SizedBox(width: 180), // Date spacing
                            const SizedBox(width: 240), // Enquiry For spacing
                            const SizedBox(width: 160), // Source spacing
                            const SizedBox(width: 140), // Status spacing
                            SizedBox(
                                width: 140,
                                child: Text('₹${provider.totalProjectCost}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            SizedBox(
                                width: 140,
                                child: Text('₹${provider.totalCommission}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title,
      {int? flex, double? width, bool center = false}) {
    final child = Text(
      title.toUpperCase(),
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: child)
        : SizedBox(
            width: width,
            child: center ? Center(child: child) : child,
          );
  }

  Widget _buildFilterItem(BuildContext context, String label, String value,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('$label: ',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label, int value,
      List<DropdownMenuItem<int>> items, Function(int?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          DropdownButton<int>(
            value: value,
            underline: const SizedBox(),
            items: items,
            onChanged: onChanged,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _onClickDateRange(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CommissionReportProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Select Date Range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 5; i++)
                      ActionChip(
                        label: Text([
                          'Yesterday',
                          'Today',
                          'Tomorrow',
                          'This Week',
                          'This Month'
                        ][i]),
                        onPressed: () => provider.selectDateFilterOption(i),
                        backgroundColor: provider.selectedDateFilterIndex == i
                            ? AppColors.primaryBlue
                            : null,
                        labelStyle: TextStyle(
                            color: provider.selectedDateFilterIndex == i
                                ? Colors.white
                                : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.selectDate(context, true),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(provider.fromDate != null
                            ? provider.formattedFromDate
                            : 'From Date'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.selectDate(context, false),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(provider.toDate != null
                            ? provider.formattedToDate
                            : 'To Date'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  provider.getCommissionReport(context);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
