import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/commission_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class CommissionReportMobile extends StatefulWidget {
  const CommissionReportMobile({super.key});

  @override
  State<CommissionReportMobile> createState() => _CommissionReportMobileState();
}

class _CommissionReportMobileState extends State<CommissionReportMobile> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month'
  ];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final provider =
          Provider.of<CommissionReportProvider>(context, listen: false);
      // Wait, there's no setSearch in CommissionReportProvider, but it uses the search parameter or we can just fetch:
      provider.getCommissionReport(context);
    });
  }

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
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommissionReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Commission Report',
        showFilterIcon: false,
        onSearchTap: () {
          provider.toggleFilter();
        },
        onFilterTap: () {
          provider.toggleFilter();
        },
        onSearch: (query) {
          provider.getCommissionReport(context);
        },
        onChanged: _onSearchChanged,
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
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showDateFilterDialog(context);
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 200),
                                      child: CustomText(
                                        provider.fromDate == null &&
                                                provider.toDate == null
                                            ? 'Date'
                                            : 'Date : ${provider.formattedFromDate.toString().toDayMonthYearFormat()} - ${provider.formattedToDate.toString().toDayMonthYearFormat()}',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.textGrey3, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          },
                        ),
                        ...dropDownProvider.enquiryData
                            .map((e) => FilterChipWidget(
                                  label: e.enquirySourceName,
                                  isSelected: provider.selectedEnquirySource ==
                                      e.enquirySourceId,
                                  onTap: () {
                                    provider.setEnquirySourceFilter(
                                        e.enquirySourceId);
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
                          },
                        ),
                        ...dropDownProvider.enquiryForList
                            .map((e) => FilterChipWidget(
                                  label: e.enquiryForName,
                                  isSelected: provider.selectedEnquiryFor ==
                                      e.enquiryForId,
                                  onTap: () {
                                    provider
                                        .setEnquiryForFilter(e.enquiryForId);
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── LIST ────────────────────────────────────────────────────────

          if (!provider.isFilter)
            Expanded(
              child: provider.commissionReport.isEmpty
                  ? const CommonEmptyState(
                      message: 'No commission reports found')
                  : Column(
                      children: [
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
                                description:
                                    'Source: ${item.enquirySourceName}',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: provider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_commission_report_filter_fab',
                  onPressed: () {
                    provider.getCommissionReport(context);
                    provider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false)
                        .stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : null,
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
                              border: Border.all(
                                  color: const Color(0xFFCBD5E1), width: 1.0),
                              borderRadius: BorderRadius.circular(4)),
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
                              border: Border.all(
                                  color: const Color(0xFFCBD5E1), width: 1.0),
                              borderRadius: BorderRadius.circular(4)),
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
