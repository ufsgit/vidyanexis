import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/pdf_function.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class LeadReportMobile extends StatefulWidget {
  const LeadReportMobile(this.fromDashBoard, {super.key});

  final bool fromDashBoard;

  @override
  State<LeadReportMobile> createState() => _leadReportMobile();
}

class _leadReportMobile extends State<LeadReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  bool viewProfile = false;
  bool viewFollowUp = false;
  bool isEdit = false;
  Timer? _debounce;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final leadReportProvider = Provider.of<LeadReportProvider>(context, listen: false);
      leadReportProvider.getSearchLeadReports(
        searchController.text,
        leadReportProvider.fromDateS,
        leadReportProvider.toDateS,
        leadReportProvider.status,
        context,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final leadReportProvider =
          Provider.of<LeadReportProvider>(context, listen: false);
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');

      provider.getEnquirySource(context);
      provider.getEnquiryFor(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '1');
      provider.getAllFollowUpStatus(context, '1');
      leadReportProvider.getSearchLeadReports('', '', '', '', context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Color getAvatarColor(String name) {
      final colors = [
        Colors.blue.withOpacity(.75),
        Colors.purple.withOpacity(.75),
        Colors.orange.withOpacity(.75),
        Colors.teal.withOpacity(.75),
        Colors.pink.withOpacity(.75),
        Colors.indigo.withOpacity(.75),
        Colors.green.withOpacity(.75),
        Colors.deepOrange.withOpacity(.75),
        Colors.cyan.withOpacity(.75),
        Colors.brown.withOpacity(.75),
      ];
      final nameHash = name.hashCode.abs();
      return colors[nameHash % colors.length];
    }

    final leadReportProvider = Provider.of<LeadReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    // final customerDetailsProvider =
    //     Provider.of<CustomerDetailsProvider>(context);

    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 60;
    const searchSectionHeight = 80;
    const paginationHeight = 60;
    const tableHeaderHeight = 50;
    const paddingSafety = 40;
    final availableHeight = screenHeight -
        headerHeight -
        searchSectionHeight -
        paginationHeight -
        tableHeaderHeight -
        paddingSafety;
    final rowHeight = availableHeight / 20;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Leads Report',
        onSearchTap: () {
          searchProvider.startSearch();
          if (!leadReportProvider.isFilter) {
            leadReportProvider.toggleFilter();
          }
          leadReportProvider.getSearchLeadReports(
            searchController.text,
            leadReportProvider.fromDateS,
            leadReportProvider.toDateS,
            leadReportProvider.status,
            context,
          );
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          leadReportProvider.toggleFilter();
        },
        onClearTap: () {
          // searchController.clear();
          searchProvider.stopSearch();
          // leadReportProvider.removeStatus();
          // leadReportProvider.selectDateFilterOption(null);
          if (leadReportProvider.isFilter) {
            leadReportProvider.toggleFilter();
          }
          // leadReportProvider.getSearchLeadReports('', '', '', '', context);
        },
        onSearch: (query) {
          String query = searchController.text;
          // leadReportProvider.selectDateFilterOption(null);
          // leadReportProvider.removeStatus();
          print(query);
          leadReportProvider.getSearchLeadReports(query, '', '', '', context);
        },
        searchController: searchController,
        showExcel: true,
        showPdf: true,
        showTransfer: true,
        onTransferTap: () {
          _showTransferDialog(context);
        },
        onExcelTap: () async {
          final allLeads =
              await leadReportProvider.fetchAllLeadsForExport(context);
          if (allLeads.isNotEmpty) {
            exportToExcel(
              headers: [
                'Customer Name',
                'Mobile no',
                'Remark',
                'Assigned To',
                'Next Follow-up Date',
                'Status'
              ],
              data: (leadReportProvider.selectedLeadIds.isEmpty
                      ? allLeads
                      : allLeads.where((lead) => leadReportProvider
                          .selectedLeadIds
                          .contains(lead.customerId)))
                  .map((task) {
                return {
                  'Customer Name': task.customerName,
                  'Mobile no': task.contactNumber,
                  'Remark': task.remark,
                  'Assigned To': task.toUserName,
                  'Next Follow-up Date': task.nextFollowUpDate.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(task.nextFollowUpDate))
                      : '',
                  'Status': task.statusName,
                };
              }).toList(),
              fileName: 'Lead_Report',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data found')),
            );
          }
        },
        onPdfTap: () async {
          final allLeads =
              await leadReportProvider.fetchAllLeadsForExport(context);
          if (allLeads.isNotEmpty) {
            exportToPDF(
              headers: [
                'Customer Name',
                'Mobile no',
                'Remark',
                'Assigned To',
                'Next Follow-up Date',
                'Status'
              ],
              data: (leadReportProvider.selectedLeadIds.isEmpty
                      ? allLeads
                      : allLeads.where((lead) => leadReportProvider
                          .selectedLeadIds
                          .contains(lead.customerId)))
                  .map((task) {
                return {
                  'Customer Name': task.customerName,
                  'Mobile no': task.contactNumber,
                  'Remark': task.remark,
                  'Assigned To': task.toUserName,
                  'Next Follow-up Date': task.nextFollowUpDate.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(task.nextFollowUpDate))
                      : '',
                  'Status': task.statusName,
                };
              }).toList(),
              fileName: 'Lead_Report',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data found')),
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: leadReportProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_filter_fab',
                  onPressed: () async {
                    leadReportProvider.getSearchLeadReports(
                      searchController.text,
                      leadReportProvider.fromDateS,
                      leadReportProvider.toDateS,
                      leadReportProvider.status,
                      context,
                    );
                    searchProvider.stopSearch();
                    leadReportProvider.setFilter(false);
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
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadReportProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomText(
                        'Status',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                leadReportProvider.selectedStatus == 0 ||
                                    leadReportProvider.selectedStatus == null,
                            onTap: () {
                              leadReportProvider.setStatus(0);
                            },
                          ),
                          ...provider.followUpData.map((status) {
                            return FilterChipWidget(
                              label: status.statusName ?? 'Unknown',
                              isSelected: leadReportProvider.selectedStatus ==
                                  status.statusId,
                              onTap: () {
                                leadReportProvider
                                    .setStatus(status.statusId ?? 0);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        'Date Range',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: leadReportProvider.selectedDateFilterIndex != null
                                    ? AppColors.primaryBlue.withOpacity(0.1)
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: leadReportProvider.selectedDateFilterIndex != null
                                      ? AppColors.primaryBlue
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: leadReportProvider.selectedDateFilterIndex != null
                                        ? AppColors.primaryBlue
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    leadReportProvider.selectedDateFilterIndex != null
                                        ? dateButtonTitles[leadReportProvider.selectedDateFilterIndex!]
                                        : 'Select Date Range',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: leadReportProvider.selectedDateFilterIndex != null
                                          ? AppColors.primaryBlue
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (leadReportProvider.fromDate != null || leadReportProvider.toDate != null)
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.05),
                                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: Text(
                                  "${leadReportProvider.formattedFromDate} - ${leadReportProvider.formattedToDate}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        'Assigned Staff',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: leadReportProvider.selectedUser == 0 ||
                                leadReportProvider.selectedUser == null,
                            onTap: () {
                              leadReportProvider.setUserFilterStatus(0);
                            },
                          ),
                          ...provider.searchUserDetails.map((user) {
                            return FilterChipWidget(
                              label: user.userDetailsName ?? 'Unknown',
                              isSelected: leadReportProvider.selectedUser ==
                                  user.userDetailsId,
                              onTap: () {
                                leadReportProvider.setUserFilterStatus(
                                    user.userDetailsId ?? 0);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        'Enquiry For',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: leadReportProvider.selectedEnquiryFor ==
                                    0 ||
                                leadReportProvider.selectedEnquiryFor == null,
                            onTap: () {
                              leadReportProvider.setEnquiryForFilter(0);
                            },
                          ),
                          ...provider.enquiryForList.map((enquiry) {
                            return FilterChipWidget(
                              label: enquiry.enquiryForName ?? 'Unknown',
                              isSelected:
                                  leadReportProvider.selectedEnquiryFor ==
                                      enquiry.enquiryForId,
                              onTap: () {
                                leadReportProvider.setEnquiryForFilter(
                                    enquiry.enquiryForId ?? 0);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        'Enquiry Source',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                leadReportProvider.selectedEnquirySource == 0 ||
                                    leadReportProvider.selectedEnquirySource ==
                                        null,
                            onTap: () {
                              leadReportProvider.setEnquirySourceFilter(0);
                            },
                          ),
                          ...provider.enquiryData.map((source) {
                            return FilterChipWidget(
                              label: source.enquirySourceName ?? 'Unknown',
                              isSelected:
                                  leadReportProvider.selectedEnquirySource ==
                                      source.enquirySourceId,
                              onTap: () {
                                leadReportProvider.setEnquirySourceFilter(
                                    source.enquirySourceId ?? 0);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (leadReportProvider.fromDate != null ||
                          leadReportProvider.toDate != null ||
                          (leadReportProvider.selectedStatus != null &&
                              leadReportProvider.selectedStatus != 0) ||
                          (leadReportProvider.selectedUser != null &&
                              leadReportProvider.selectedUser != 0) ||
                          (leadReportProvider.selectedEnquiryFor != null &&
                              leadReportProvider.selectedEnquiryFor != 0) ||
                          (leadReportProvider.selectedEnquirySource != null &&
                              leadReportProvider.selectedEnquirySource != 0) ||
                          searchController.text.isNotEmpty)
                        Column(
                          children: [
                            // SizedBox(
                            //   width: double.infinity,
                            //   child: CustomElevatedButton(
                            //     buttonText: 'Apply Filters',
                            //     onPressed: () {
                            //       leadReportProvider.getSearchLeadReports(
                            //         searchController.text,
                            //         leadReportProvider.fromDateS,
                            //         leadReportProvider.toDateS,
                            //         leadReportProvider.status,
                            //         context,
                            //       );
                            //       leadReportProvider.toggleFilter();
                            //     },
                            //     textColor: AppColors.whiteColor,
                            //     borderColor: AppColors.primaryBlue,
                            //     backgroundColor: AppColors.primaryBlue,
                            //   ),
                            // ),
                            // const SizedBox(height: 12),
                            // if (leadReportProvider.fromDate != null ||
                            //     leadReportProvider.toDate != null ||
                            //     (leadReportProvider.selectedStatus != null &&
                            //         leadReportProvider.selectedStatus != 0) ||
                            //     (leadReportProvider.selectedUser != null &&
                            //         leadReportProvider.selectedUser != 0) ||
                            //     (leadReportProvider.selectedEnquiryFor !=
                            //             null &&
                            //         leadReportProvider.selectedEnquiryFor !=
                            //             0) ||
                            //     (leadReportProvider.selectedEnquirySource !=
                            //             null &&
                            //         leadReportProvider.selectedEnquirySource !=
                            //             0))
                            SizedBox(
                              width: double.infinity,
                              child: CommonReportResetButton(
                                label: 'Reset',
                                onReset: () {
                                  leadReportProvider
                                      .selectDateFilterOption(null);
                                  leadReportProvider.removeStatus();
                                  searchController.clear();
                                  leadReportProvider.getSearchLeadReports(
                                      '', '', '', '', context);
                                  searchProvider.stopSearch();
                                  leadReportProvider.setFilter(false);
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            if (!leadReportProvider.isFilter)
              Expanded(
                child: Column(
                  children: [
                    if (leadReportProvider.leadReportData.isNotEmpty)
                      CommonReportSummaryBar(
                        totalLabel: 'Total Leads',
                        totalCount: leadReportProvider.totalSize,
                        showingLabel: 'Showing',
                        showingCount: leadReportProvider.leadReportData.length,
                      ),
                    Expanded(
                      child: leadReportProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : leadReportProvider.leadReportData.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 100),
                                      Icon(Icons.search_off_outlined,
                                          size: 80, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No lead reports found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      if (leadReportProvider.fromDate != null ||
                                          leadReportProvider.toDate != null ||
                                          (leadReportProvider.selectedStatus !=
                                                  null &&
                                              leadReportProvider
                                                      .selectedStatus !=
                                                  0) ||
                                          (leadReportProvider.selectedUser !=
                                                  null &&
                                              leadReportProvider.selectedUser !=
                                                  0) ||
                                          (leadReportProvider
                                                      .selectedEnquiryFor !=
                                                  null &&
                                              leadReportProvider
                                                      .selectedEnquiryFor !=
                                                  0) ||
                                          (leadReportProvider
                                                      .selectedEnquirySource !=
                                                  null &&
                                              leadReportProvider
                                                      .selectedEnquirySource !=
                                                  0))
                                        ElevatedButton(
                                          onPressed: () {
                                            leadReportProvider
                                                .selectDateFilterOption(null);
                                            leadReportProvider.removeStatus();
                                            leadReportProvider
                                                .getSearchLeadReports(
                                                    '', '', '', '', context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                AppColors.primaryBlue,
                                            elevation: 0,
                                            side: BorderSide(
                                                color: AppColors.primaryBlue),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child:
                                              const Text('Clear All Filters'),
                                        ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: leadReportProvider
                                                  .areAllLeadsSelected,
                                              onChanged: (value) {
                                                leadReportProvider
                                                    .toggleAllLeadsSelection(
                                                        value ?? false);
                                              },
                                              activeColor:
                                                  AppColors.primaryBlue,
                                            ),
                                            const CustomText(
                                              'Select All Leads',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            const Spacer(),
                                            CustomText(
                                              '${leadReportProvider.selectedLeadIds.length} Selected',
                                              fontSize: 14,
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                                height: 1,
                                                color: AppColors.grey
                                                    .withOpacity(0.5)),
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: leadReportProvider
                                            .leadReportData.length,
                                        itemBuilder: (context, index) {
                                          var item = leadReportProvider
                                              .leadReportData[index];

                                          return Row(
                                            children: [
                                              const SizedBox(width: 8),
                                              Checkbox(
                                                value: leadReportProvider
                                                    .isLeadSelected(
                                                        item.customerId),
                                                onChanged: (value) {
                                                  leadReportProvider
                                                      .toggleLeadSelection(
                                                          item.customerId);
                                                },
                                                activeColor:
                                                    AppColors.primaryBlue,
                                              ),
                                              Expanded(
                                                child: ReportListItem(
                                                  title: item.customerName,
                                                  subtitle: item.contactNumber,
                                                  onSubtitleTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerDetailPageMobile(
                                                          customerId:
                                                              item.customerId,
                                                          fromLead: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  status: item.statusName,
                                                  statusColor: getAvatarColor(
                                                      item.statusName),
                                                  description:
                                                      item.remark.isEmpty
                                                          ? 'No remark provided'
                                                          : item.remark,
                                                  bottomLeftIcon:
                                                      Icons.person_outline,
                                                  bottomLeftText:
                                                      item.toUserName,
                                                  bottomRightText: item
                                                          .nextFollowUpDate
                                                          .isNotEmpty
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(item
                                                                  .nextFollowUpDate))
                                                      : '',
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LeadReportProvider>(
        builder: (context, leadReportProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            leadReportProvider.setDateFilter(title);
                            leadReportProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              leadReportProvider.selectedDateFilterIndex ==
                                      index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: leadReportProvider.selectedDateFilterIndex ==
                                    index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                leadReportProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadReportProvider.fromDate != null
                                  ? '${leadReportProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                leadReportProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadReportProvider.toDate != null
                                  ? '${leadReportProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () async {
                                leadReportProvider.formatDate();
                                leadReportProvider.getSearchLeadReports(
                                  searchController.text,
                                  leadReportProvider.formattedFromDate,
                                  leadReportProvider.formattedToDate,
                                  leadReportProvider.status,
                                  context,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                leadReportProvider.selectDateFilterOption(null);
                                leadReportProvider.getSearchLeadReports(
                                  searchController.text,
                                  '',
                                  '',
                                  leadReportProvider.selectedStatus.toString(),
                                  context,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.textRed.withOpacity(0.1),
                                foregroundColor: AppColors.textRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Clear'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTransferDialog(BuildContext parentContext) {
    final leadReportProvider =
        Provider.of<LeadReportProvider>(parentContext, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(parentContext, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(parentContext, listen: false);

    if (leadReportProvider.selectedLeadIds.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text('Please select leads to transfer')),
      );
      return;
    }

    // Reset providers
    settingsProvider.selectedBranchId = null;
    settingsProvider.selectedDepartmentId = null;
    dropDownProvider.selectedStatusId = null;
    dropDownProvider.filteredStaffData = [];

    final statusController = TextEditingController();
    final branchController = TextEditingController();
    final departmentController = TextEditingController();
    final remarkController = TextEditingController();

    // Config for distribution
    Map<int, int> assignments = {}; // UserId -> Count
    Map<int, TextEditingController> assignmentControllers = {};

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          int totalSelected = leadReportProvider.selectedLeadIds.length;
          int assignedTotal =
              assignments.values.fold(0, (sum, count) => sum + count);
          int balance = totalSelected - assignedTotal;

          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Consumer2<DropDownProvider, SettingsProvider>(
                  builder:
                      (context, dropDownProvider, settingsProvider, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Leads',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status
                        CommonDropdown<int>(
                          hintText: 'Follow-up Status*',
                          items: dropDownProvider.followUpData
                              .map((status) => DropdownItem<int>(
                                    id: status.statusId ?? 0,
                                    name: status.statusName ?? '',
                                  ))
                              .toList(),
                          controller: statusController,
                          onItemSelected: (selectedId) {
                            dropDownProvider.setSelectedStatusId(selectedId);
                            final selectedItem =
                                dropDownProvider.followUpData.firstWhere(
                              (status) => status.statusId == selectedId,
                            );
                            statusController.text =
                                selectedItem.statusName ?? '';
                          },
                          selectedValue: dropDownProvider.selectedStatusId,
                        ),
                        const SizedBox(height: 12),

                        // Branch
                        CommonDropdown<int>(
                          hintText: 'Branch*',
                          selectedValue: settingsProvider.selectedBranchId,
                          items: settingsProvider.branchModel
                              .map((source) => DropdownItem<int>(
                                    id: source.branchId ?? 0,
                                    name: source.branchName ?? '',
                                  ))
                              .toList(),
                          controller: branchController,
                          onItemSelected: (selectedId) {
                            settingsProvider.selectedBranchId = selectedId;
                            final selectedBranch = settingsProvider.branchModel
                                .firstWhere((b) => b.branchId == selectedId);
                            branchController.text =
                                selectedBranch.branchName ?? '';

                            // Reset department and staff
                            settingsProvider.selectedDepartmentId = null;
                            departmentController.clear();
                            dropDownProvider.filteredStaffData = [];
                            assignments.clear();
                            assignmentControllers.clear();

                            settingsProvider.searchDepartment(
                              selectedId.toString(),
                              context,
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Department
                        CommonDropdown<int>(
                          hintText: 'Department*',
                          selectedValue: settingsProvider.selectedDepartmentId,
                          items: settingsProvider.departmentModel
                              .map((source) => DropdownItem<int>(
                                    id: source.departmentId,
                                    name: source.departmentName,
                                  ))
                              .toList(),
                          controller: departmentController,
                          onItemSelected: (selectedId) {
                            settingsProvider.selectedDepartmentId = selectedId;
                            final selectedDept =
                                settingsProvider.departmentModel.firstWhere(
                                    (d) => d.departmentId == selectedId);
                            departmentController.text =
                                selectedDept.departmentName;

                            setState(() {
                              assignments.clear();
                              assignmentControllers.clear();
                            });

                            dropDownProvider.filterStaffByBranchAndDepartment(
                              branchId: settingsProvider.selectedBranchId,
                              departmentId: selectedId,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Count Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: $totalSelected",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("Balance: $balance",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: balance < 0
                                        ? Colors.red
                                        : Colors.black)),
                          ],
                        ),
                        const Divider(),

                        // Staff List
                        if (dropDownProvider.filteredStaffData.isNotEmpty)
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8)),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount:
                                  dropDownProvider.filteredStaffData.length,
                              separatorBuilder: (c, i) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final staff =
                                    dropDownProvider.filteredStaffData[index];
                                final userId = staff.userDetailsId;

                                if (!assignmentControllers
                                    .containsKey(userId)) {
                                  assignmentControllers[userId] =
                                      TextEditingController();
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(staff.userDetailsName,
                                              style: const TextStyle(
                                                  fontSize: 13))),
                                      Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                            height: 30,
                                            child: TextField(
                                              controller:
                                                  assignmentControllers[userId],
                                              keyboardType:
                                                  TextInputType.number,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 0),
                                              ),
                                              onChanged: (val) {
                                                int count =
                                                    int.tryParse(val) ?? 0;
                                                setState(() {
                                                  assignments[userId] = count;
                                                });
                                              },
                                            ),
                                          )),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Select Branch/Dept to see staff",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Remarks
                        CustomTextField(
                          height: 70,
                          controller: remarkController,
                          hintText: 'Remarks',
                          labelText: '',
                          minLines: 2,
                          keyboardType: TextInputType.multiline,
                        ),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (dropDownProvider.selectedStatusId == null) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text('Please select Status')),
                                  );
                                  return;
                                }

                                int assigned = assignments.values
                                    .fold(0, (sum, count) => sum + count);
                                if (assigned == 0) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text('Please assign leads')),
                                  );
                                  return;
                                }

                                if (assigned > totalSelected) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Assigned count exceeds selected')),
                                  );
                                  return;
                                }

                                Navigator.pop(dialogContext);

                                Map<int, String> userNames = {};
                                for (var staff
                                    in dropDownProvider.filteredStaffData) {
                                  userNames[staff.userDetailsId] =
                                      staff.userDetailsName;
                                }

                                leadReportProvider.transferLeadsMultiUser(
                                  context: parentContext,
                                  statusId: dropDownProvider.selectedStatusId!,
                                  statusName: statusController.text,
                                  assignments: assignments,
                                  userNames: userNames,
                                  remark: remarkController.text,
                                  nextFollowUpDate:
                                      "0", // Pass "0" as requested
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Transfer'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        });
      },
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
