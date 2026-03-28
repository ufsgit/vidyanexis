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
import 'package:vidyanexis/utils/csv_function.dart';

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

  @override
  void initState() {
    super.initState();
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
      appBar: CustomAppBar(
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              customerProvider.setFilter(false);
              leadReportProvider.setFilter(false);
              searchProvider.stopSearch();
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: 'Leads Report',
        onSearchTap: () {
          searchProvider.startSearch();
          leadReportProvider.toggleFilter();
          // leadReportProvider.selectDateFilterOption(null);
          // leadReportProvider.removeStatus();
          leadReportProvider.getSearchLeadReports('', '', '', '', context);
          print(leadReportProvider.isFilter);
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
          searchController.clear();
          searchProvider.stopSearch();
          leadReportProvider.toggleFilter();
          // leadReportProvider.selectDateFilterOption(null);
          // leadReportProvider.removeStatus();
          leadReportProvider.getSearchLeadReports('', '', '', '', context);
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
        onExcelTap: () {
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
                    ? leadReportProvider.leadReportData
                    : leadReportProvider.leadReportData.where((lead) =>
                        leadReportProvider.selectedLeadIds
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
        },
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadReportProvider.isFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Wrap(
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadReportProvider.selectedStatus != null &&
                                    leadReportProvider.selectedStatus != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Status: '),
                          DropdownButton<int>(
                            value: leadReportProvider.selectedStatus,
                            hint: const Text('All'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'All',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...provider.followUpData
                                  .map((status) => DropdownMenuItem<int>(
                                        value: status.statusId,
                                        child: Text(
                                          status.statusName ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )),
                            ],
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadReportProvider.setStatus(newValue);

                                String status = leadReportProvider
                                    .selectedStatus
                                    .toString();

                                String fromDate =
                                    leadReportProvider.formattedFromDate;
                                String toDate =
                                    leadReportProvider.formattedToDate;

                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');

                                leadReportProvider.getSearchLeadReports(
                                    searchController.text,
                                    fromDate,
                                    toDate,
                                    status,
                                    context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        onClickTopButton(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: leadReportProvider.fromDate != null ||
                                      leadReportProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (leadReportProvider.fromDate == null &&
                                leadReportProvider.toDate == null)
                              const Text('Next Follow-Up Date: All'),
                            if (leadReportProvider.fromDate != null &&
                                leadReportProvider.toDate != null)
                              Text(
                                  'Date : ${leadReportProvider.formattedFromDate} - ${leadReportProvider.formattedToDate}'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Colors.black45,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadReportProvider.selectedUser != null &&
                                    leadReportProvider.selectedUser != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Assigned Staff: '),
                          DropdownButton<int>(
                            value: leadReportProvider.selectedUser,
                            hint: const Text('All'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'All',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...provider.searchUserDetails
                                  .map((user) => DropdownMenuItem<int>(
                                        value: user.userDetailsId,
                                        child: Text(
                                          user.userDetailsName ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )),
                            ],
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadReportProvider.setUserFilterStatus(
                                    newValue); // Update the status in the provider
                                String status = leadReportProvider
                                    .selectedStatus
                                    .toString();

                                String fromDate =
                                    leadReportProvider.formattedFromDate;
                                String toDate =
                                    leadReportProvider.formattedToDate;

                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');

                                leadReportProvider.getSearchLeadReports(
                                    searchController.text,
                                    fromDate,
                                    toDate,
                                    status,
                                    context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadReportProvider.selectedEnquiryFor !=
                                        null &&
                                    leadReportProvider.selectedEnquiryFor != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Enquiry For: '),
                          DropdownButton<int>(
                            value: provider.enquiryForList.any((element) =>
                                    element.enquiryForId ==
                                    leadReportProvider.selectedEnquiryFor)
                                ? leadReportProvider.selectedEnquiryFor
                                : null,
                            hint: const Text('All'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'All',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...provider.enquiryForList
                                  .map((enquiry) => DropdownMenuItem<int>(
                                        value: enquiry.enquiryForId,
                                        child: Text(
                                          enquiry.enquiryForName ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )),
                            ],
                            onChanged: (int? newValue) {
                              leadReportProvider
                                  .setEnquiryForFilter(newValue ?? 0);

                              leadReportProvider.getSearchLeadReports(
                                  searchController.text,
                                  leadReportProvider.formattedFromDate,
                                  leadReportProvider.formattedToDate,
                                  leadReportProvider.selectedStatus.toString(),
                                  context);
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadReportProvider.selectedEnquirySource !=
                                        null &&
                                    leadReportProvider.selectedEnquirySource !=
                                        0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Enquiry Source: '),
                          DropdownButton<int>(
                            value: provider.enquiryData.any((element) =>
                                    element.enquirySourceId ==
                                    leadReportProvider.selectedEnquirySource)
                                ? leadReportProvider.selectedEnquirySource
                                : null,
                            hint: const Text('All'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'All',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...provider.enquiryData
                                  .map((source) => DropdownMenuItem<int>(
                                        value: source.enquirySourceId,
                                        child: Text(
                                          source.enquirySourceName ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      )),
                            ],
                            onChanged: (int? newValue) {
                              leadReportProvider
                                  .setEnquirySourceFilter(newValue ?? 0);

                              leadReportProvider.getSearchLeadReports(
                                  searchController.text,
                                  leadReportProvider.formattedFromDate,
                                  leadReportProvider.formattedToDate,
                                  leadReportProvider.selectedStatus.toString(),
                                  context);
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (leadReportProvider.fromDate != null ||
                        leadReportProvider.toDate != null ||
                        (leadReportProvider.selectedStatus != null &&
                            leadReportProvider.selectedStatus != 0) ||
                        (leadReportProvider.selectedUser != null &&
                            leadReportProvider.selectedUser != 0) ||
                        (leadReportProvider.selectedEnquiryFor != null &&
                            leadReportProvider.selectedEnquiryFor != 0) ||
                        (leadReportProvider.selectedEnquirySource != null &&
                            leadReportProvider.selectedEnquirySource != 0))
                      ElevatedButton(
                        onPressed: () {
                          leadReportProvider.selectDateFilterOption(null);
                          leadReportProvider.removeStatus();
                          leadReportProvider.getSearchLeadReports(
                              '', '', '', '', context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: !leadReportProvider.hasFetched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Select a date range to view reports',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => onClickTopButton(context),
                            icon: const Icon(Icons.date_range),
                            label: const Text('Choose Date'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : leadReportProvider.leadReportData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_outlined,
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No reports found for the selected range',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  leadReportProvider
                                      .selectDateFilterOption(null);
                                  leadReportProvider.removeStatus();
                                  leadReportProvider.getSearchLeadReports(
                                      '', '', '', '', context);
                                },
                                child: const Text('Clear All Filters'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 2,
                                    color: AppColors.grey,
                                  );
                                },
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount:
                                    leadReportProvider.leadReportData.length,
                                itemBuilder: (context, index) {
                                  var lead =
                                      leadReportProvider.leadReportData[index];

                                  return InkWell(
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                          color: AppColors.whiteColor),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    height: 42,
                                                    width: 3,
                                                    decoration: BoxDecoration(
                                                        color: getAvatarColor(
                                                            lead.statusName),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16))),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CustomerDetailPageMobile(
                                                              customerId: lead
                                                                  .customerId,
                                                              fromLead: false,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        lead.customerName,
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors
                                                              .textBlack,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      lead.contactNumber,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColors
                                                                  .textGrey3),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () async {
                          leadReportProvider.formatDate();
                          String status =
                              leadReportProvider.selectedStatus.toString();

                          String fromDate =
                              leadReportProvider.formattedFromDate;
                          String toDate = leadReportProvider.formattedToDate;

                          await leadReportProvider.getSearchLeadReports(
                              searchController.text,
                              fromDate,
                              toDate,
                              status,
                              context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
