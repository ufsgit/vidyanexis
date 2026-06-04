import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_outstanding_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class CustomerOutstandingReportMobile extends StatefulWidget {
  const CustomerOutstandingReportMobile({super.key});

  @override
  State<CustomerOutstandingReportMobile> createState() =>
      _CustomerOutstandingReportMobileState();
}

class _CustomerOutstandingReportMobileState
    extends State<CustomerOutstandingReportMobile> {
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
      final provider = Provider.of<CustomerOutstandingReportProvider>(context,
          listen: false);
      provider.setSearch(query);
      provider.getReport(context);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CustomerOutstandingReportProvider>(context,
          listen: false);
      provider.getReport(context);
      Provider.of<DropDownProvider>(context, listen: false)
          .getEnquirySource(context);
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
    final provider = Provider.of<CustomerOutstandingReportProvider>(context);

    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Customer Outstanding Report',
        showFilterIcon: false,
        onSearchTap: () {
          provider.toggleFilter();
        },
        onFilterTap: () {
          provider.toggleFilter();
        },
        onSearch: (query) {
          provider.setSearch(query);
          provider.getReport(context);
        },
        onChanged: _onSearchChanged,
        searchController: searchController,
        showExcel: true,
        onExcelTap: () {
          exportToExcel(
            headers: [
              'Customer Name',
              'Enquiry Source',
              'Phone no',
              'Project Cost',
              'Received',
              'Balance',
            ],
            data: provider.reportData.map((item) {
              return {
                'Customer Name': item.customerName,
                'Enquiry Source': item.enquirySource,
                'Phone no': item.phone,
                'Project Cost': item.projectCost,
                'Received': item.received,
                'Balance': item.balance,
              };
            }).toList(),
            fileName: 'Customer_Outstanding_Report',
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
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 200),
                                      child: CustomText(
                                        provider.fromDate == null && provider.toDate == null
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
                                  Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey3, size: 18),
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
                    Consumer<DropDownProvider>(
                      builder: (context, dropDownProvider, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            FilterChipWidget(
                              label: 'All',
                              isSelected:
                                  provider.selectedEnquirySourceId == null,
                              onTap: () {
                                provider.setEnquirySource(null);
                              },
                            ),
                            ...dropDownProvider.enquiryData.map((e) =>
                                FilterChipWidget(
                                  label: e.enquirySourceName,
                                  isSelected:
                                      provider.selectedEnquirySourceId ==
                                          e.enquirySourceId,
                                  onTap: () {
                                    provider.setEnquirySource(
                                        e.enquirySourceId);
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (provider.fromDate != null ||
                        provider.toDate != null ||
                        provider.selectedEnquirySourceId != null)
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
              child: provider.reportData.isEmpty
                  ? const CommonEmptyState(message: 'No records found')
                  : Column(
                      children: [
                        CommonReportSummaryBar(
                          totalLabel: 'Total Records',
                          totalCount: provider.reportData.length,
                          showingLabel: 'Showing',
                          showingCount: provider.reportData.length,
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.reportData.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = provider.reportData[index];
                              return ReportListItem(
                                title: item.customerName,
                                subtitle: item.phone,
                                status: item.enquirySource,
                                statusColor: AppColors.primaryBlue,
                                description:
                                    'Cost: ₹${item.projectCost} | Recv: ₹${item.received}',
                                bottomRightText: 'Bal: ₹${item.balance}',
                                onTap: () {},
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
                                          fontSize: 14)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total Received',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Text('₹${provider.totalReceived}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total Balance',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  Text('₹${provider.totalBalance}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.red)),
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
                  heroTag: 'apply_customer_outstanding_report_filter_fab',
                  onPressed: () {
                    provider.getReport(context);
                    provider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false).stopSearch();
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
      builder: (context) => Consumer<CustomerOutstandingReportProvider>(
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
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                  provider.getReport(context);
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

  Widget _buildEnquirySourceDropdown(
      BuildContext context, CustomerOutstandingReportProvider provider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: provider.selectedEnquirySourceId != null
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: provider.selectedEnquirySourceId,
              hint: const Text('Source', style: TextStyle(fontSize: 12)),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Sources', style: TextStyle(fontSize: 12)),
                ),
                ...dropDownProvider.enquiryData.map((source) {
                  return DropdownMenuItem<int>(
                    value: source.enquirySourceId,
                    child: Text(source.enquirySourceName,
                        style: const TextStyle(fontSize: 12)),
                  );
                }),
              ],
              onChanged: (value) {
                provider.setEnquirySource(value);
                provider.getReport(context);
              },
              icon: const Icon(Icons.arrow_drop_down_outlined,
                  color: Colors.black45, size: 20),
            ),
          ),
        );
      },
    );
  }
}
