import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/sub_contract_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class SubContractReportMobile extends StatefulWidget {
  const SubContractReportMobile({super.key});

  @override
  State<SubContractReportMobile> createState() =>
      _SubContractReportMobileState();
}

class _SubContractReportMobileState extends State<SubContractReportMobile> {
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
          Provider.of<SubContractReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getEnquiryFor(context);
      provider.getSubContractReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubContractReportProvider>(context);

    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Sub Contract Reports',
        onSearchTap: () {
          provider.toggleFilter();
        },
        onFilterTap: () {
          provider.toggleFilter();
        },
        onSearch: (query) {
          provider.setSearch(query);
          provider.getSubContractReport(context);
        },
        searchController: searchController,
        showExcel: true,
        onExcelTap: () {
          exportToExcel(
            headers: [
              'Lead Name',
              'Task Type',
              'Task Status',
              'To User Name',
              'Date',
              'Commission',
            ],
            data: provider.subContractReport.map((item) {
              return {
                'Lead Name': item.customerName,
                'Task Type': item.taskTypeName,
                'Task Status': item.taskStatusName,
                'To User Name': item.toUserName,
                'Date': item.entryDate,
                'Commission': item.commission,
              };
            }).toList(),
            fileName: 'Sub_Contract_Report',
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
                        color: Colors.black),
                    const SizedBox(height: 8),
                    CommonReportDateFilter(
                      fromDate: provider.fromDate?.toString(),
                      toDate: provider.toDate?.toString(),
                      formattedFromDate: provider.formattedFromDate,
                      formattedToDate: provider.formattedToDate,
                      onTap: () => _showDateFilterDialog(context),
                    ),
                    const SizedBox(height: 16),
                    CustomText('Staff',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    const SizedBox(height: 8),
                    Consumer<DropDownProvider>(
                      builder: (context, dropDownProvider, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            FilterChipWidget(
                              label: 'All',
                              isSelected: provider.selectedUserId == 0,
                              onTap: () {
                                provider.setUserId(0);
                                provider.getSubContractReport(context);
                              },
                            ),
                            ...dropDownProvider.searchUserDetails.map((u) =>
                                FilterChipWidget(
                                  label: u.userDetailsName ?? 'Unknown',
                                  isSelected: provider.selectedUserId ==
                                      u.userDetailsId,
                                  onTap: () {
                                    provider.setUserId(u.userDetailsId!);
                                    provider.getSubContractReport(context);
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomText('Enquiry For',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    const SizedBox(height: 8),
                    Consumer<DropDownProvider>(
                      builder: (context, dropDownProvider, child) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            FilterChipWidget(
                              label: 'All',
                              isSelected: provider.selectedEnquiryForId == 0,
                              onTap: () {
                                provider.setEnquiryForId(0);
                                provider.getSubContractReport(context);
                              },
                            ),
                            ...dropDownProvider.enquiryForList.map((e) =>
                                FilterChipWidget(
                                  label: e.enquiryForName ?? 'Unknown',
                                  isSelected: provider.selectedEnquiryForId ==
                                      e.enquiryForId,
                                  onTap: () {
                                    provider.setEnquiryForId(e.enquiryForId!);
                                    provider.getSubContractReport(context);
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              provider.getSubContractReport(context);
                              provider.toggleFilter();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CommonReportResetButton(
                          label: 'Reset All',
                          onReset: () {
                            provider.setSearch('');
                            provider.setUserId(0);
                            provider.setEnquiryForId(0);
                            provider.selectDateFilterOption(null);
                            provider.getSubContractReport(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── LIST ────────────────────────────────────────────────────────

          Expanded(
            child: provider.subContractReport.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.search_off_outlined,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No sub contract reports found',
                          style: TextStyle(
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.subContractReport.length,
                          itemBuilder: (context, index) {
                            final item = provider.subContractReport[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.customerName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item.entryDate,
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Task Type',
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 10)),
                                              Text(item.taskTypeName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Status',
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 10)),
                                              Text(
                                                  item.taskStatusName.isEmpty
                                                      ? 'Pending'
                                                      : item.taskStatusName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      color: Colors.blue)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('To User',
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 10)),
                                              Text(item.toUserName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Commission',
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 10)),
                                              Text('₹${item.commission}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                            const Text('Total Commission',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('₹${provider.totalCommission}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green)),
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
      builder: (context) => Consumer<SubContractReportProvider>(
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
                  provider.getSubContractReport(context);
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
