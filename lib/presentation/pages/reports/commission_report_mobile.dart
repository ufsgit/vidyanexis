import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/commission_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class CommissionReportMobile extends StatefulWidget {
  const CommissionReportMobile({super.key});

  @override
  State<CommissionReportMobile> createState() => _CommissionReportMobileState();
}

class _CommissionReportMobileState extends State<CommissionReportMobile> {
  final TextEditingController searchController = TextEditingController();

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month'
  ];

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
    final provider = Provider.of<CommissionReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Commission Report',
        onSearchTap: () {
          provider.toggleFilter();
        },
        onFilterTap: () {
          provider.toggleFilter();
        },
        onSearch: (query) {
          provider.getCommissionReport(context);
        },
        searchController: searchController,
        showExcel: true,
        onExcelTap: () {
          exportToExcel(
            headers: [
              'Lead Name',
              'Mobile no',
              'Enquiry For',
              'Enquiry Source',
              'Total Project Cost',
              'Commission',
              'Status',
              'Date',
              'Assigned To'
            ],
            data: provider.commissionReport.map((item) {
              return {
                'Lead Name': item.customerName,
                'Mobile no': item.contactNumber,
                'Enquiry For': item.enquiryFor,
                'Enquiry Source': item.enquirySourceName,
                'Total Project Cost': item.totalProjectCost,
                'Commission': item.commission,
                'Status': item.statusName,
                'Date': item.entryDate,
                'Assigned To': item.toUserName,
              };
            }).toList(),
            fileName: 'Commission_Report',
          );
        },
      ),
      body: Column(
        children: [
          // ── FILTER PANEL ────────────────────────────────────────────────
          if (provider.isFilter)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CustomText('Date Range',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack),
                    const SizedBox(height: 8),
                    CommonReportDateFilter(
                      fromDate: provider.fromDate?.toString(),
                      toDate: provider.toDate?.toString(),
                      formattedFromDate: provider.formattedFromDate,
                      formattedToDate: provider.formattedToDate,
                      onTap: () => _showDateFilterDialog(context),
                    ),
                    const SizedBox(height: 16),
                    CustomText('Enquiry Source',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          isSelected: provider.selectedEnquirySource == 0 ||
                              provider.selectedEnquirySource == null,
                          onTap: () {
                            provider.setEnquirySourceFilter(0);
                            provider.getCommissionReport(context);
                          },
                        ),
                        ...dropDownProvider.enquiryData.map((e) =>
                            FilterChipWidget(
                              label: e.enquirySourceName,
                              isSelected: provider.selectedEnquirySource ==
                                  e.enquirySourceId,
                              onTap: () {
                                provider.setEnquirySourceFilter(
                                    e.enquirySourceId);
                                provider.getCommissionReport(context);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomText('Enquiry For',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          isSelected: provider.selectedEnquiryFor == 0 ||
                              provider.selectedEnquiryFor == null,
                          onTap: () {
                            provider.setEnquiryForFilter(0);
                            provider.getCommissionReport(context);
                          },
                        ),
                        ...dropDownProvider.enquiryForList.map((e) =>
                            FilterChipWidget(
                              label: e.enquiryForName,
                              isSelected: provider.selectedEnquiryFor ==
                                  e.enquiryForId,
                              onTap: () {
                                provider.setEnquiryForFilter(e.enquiryForId);
                                provider.getCommissionReport(context);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (provider.fromDate != null ||
                        provider.toDate != null ||
                        (provider.selectedEnquirySource != null &&
                            provider.selectedEnquirySource != 0) ||
                        (provider.selectedEnquiryFor != null &&
                            provider.selectedEnquiryFor != 0))
                      SizedBox(
                        width: double.infinity,
                        child: CommonReportResetButton(
                          label: 'Reset All Filters',
                          onReset: () => provider.resetFilters(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textRed,
                            elevation: 0,
                            side: BorderSide(color: AppColors.textRed),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── LIST ────────────────────────────────────────────────────────

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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (!provider.isFilter)
                        CommonReportSummaryBar(
                          totalLabel: 'Total Records',
                          totalCount: provider.commissionReport.length,
                          showingLabel: 'Showing',
                          showingCount: provider.commissionReport.length,
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.commissionReport.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = provider.commissionReport[index];
                            return ReportListItem(
                              title: item.customerName,
                              subtitle: item.contactNumber,
                              description: 'Source: ${item.enquirySourceName}',
                              status: item.statusName,
                              statusColor: Colors.green,
                              bottomLeftIcon: Icons.calendar_today_outlined,
                              bottomLeftText: item.entryDate,
                              bottomRightText: '₹${item.commission}',
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Cost',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('₹${provider.totalProjectCost}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Commission',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text('₹${provider.totalCommission}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CommissionReportProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Choose Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: List.generate(dateButtonTitles.length, (index) {
                    return ChoiceChip(
                      label: Text(dateButtonTitles[index]),
                      selected: provider.selectedDateFilterIndex == index,
                      onSelected: (selected) {
                        provider.selectDateFilterOption(index);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(provider.fromDate != null
                              ? provider.formattedFromDate
                              : 'From'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(provider.toDate != null
                              ? provider.formattedToDate
                              : 'To'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
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
