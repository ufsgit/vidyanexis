import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/leads_report_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_report_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/http/loader.dart';

import 'package:vidyanexis/presentation/widgets/home/add_followup_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class LeadPageReport extends StatefulWidget {
  final bool fromDashBoard;

  const LeadPageReport({super.key, this.fromDashBoard = false});

  @override
  State<LeadPageReport> createState() => _LeadsPageReportState();
}

class _LeadsPageReportState extends State<LeadPageReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  bool viewProfile = false;
  bool viewFollowUp = false;
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadReportProvider =
          Provider.of<LeadReportProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');

      provider.getEnquirySource(context);
      provider.getEnquiryFor(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '1');
      provider.getAllFollowUpStatus(context, '1');
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      leadReportProvider.getSearchLeadReports('', '', '', '', context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final leadReportProvider = Provider.of<LeadReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    return AppStyles.isWebScreen(context)
        ? Scaffold(
            key: _scaffoldKey,
            appBar: !AppStyles.isWebScreen(context)
                ? AppBar(
                    surfaceTintColor: AppColors.scaffoldColor,
                    backgroundColor: AppColors.whiteColor,
                    title: const Text(
                      'Leads Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            body: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (widget.fromDashBoard)
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Image.asset(
                                  'assets/images/ArrowRight.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            if (widget.fromDashBoard)
                              const SizedBox(
                                width: 8,
                              ),
                            const Text(
                              'Leads Report',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFF152D70),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Flexible(child: Container()),
                            Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: searchController,
                                onSubmitted: (query) {
                                  leadReportProvider
                                      .selectDateFilterOption(null);
                                  leadReportProvider.removeStatus();
                                  print(query);
                                  leadReportProvider.getSearchLeadReports(
                                      query, '', '', '', context);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search here....',
                                  prefixIcon: const Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  suffixIcon: TextButton(
                                    onPressed: () {
                                      String query = searchController.text;
                                      leadReportProvider
                                          .selectDateFilterOption(null);
                                      leadReportProvider.removeStatus();
                                      print(query);
                                      leadReportProvider.getSearchLeadReports(
                                          query, '', '', '', context);
                                    },
                                    child: const Text('Search'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (!widget.fromDashBoard)
                              OutlinedButton.icon(
                                onPressed: () {
                                  leadReportProvider.toggleFilter();
                                  print(leadReportProvider.isFilter);
                                },
                                icon: const Icon(Icons.filter_list),
                                label: Text(
                                    MediaQuery.of(context).size.width > 860
                                        ? 'Filter'
                                        : ''),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: leadReportProvider.isFilter
                                      ? Colors.white
                                      : AppColors
                                          .primaryBlue, // Change foreground color
                                  backgroundColor: leadReportProvider.isFilter
                                      ? const Color(0xFF5499D9)
                                      : Colors.white, // Change background color
                                  side: BorderSide(
                                      color: leadReportProvider.isFilter
                                          ? const Color(0xFF5499D9)
                                          : AppColors
                                              .primaryBlue), // Change border color
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showTransferDialog(context);
                              },
                              icon: const Icon(Icons.compare_arrows),
                              label: Text(
                                  MediaQuery.of(context).size.width > 860
                                      ? 'Transfer'
                                      : ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                exportToExcel(
                                  headers: [
                                    ''
                                        'Customer Name',
                                    'Mobile no',
                                    'Remark',
                                    'Assigned To',
                                    'Next Follow-up Date',
                                    'Status'
                                  ],
                                  data: (leadReportProvider
                                              .selectedLeadIds.isEmpty
                                          ? leadReportProvider.leadReportData
                                          : leadReportProvider.leadReportData
                                              .where((lead) =>
                                                  leadReportProvider
                                                      .selectedLeadIds
                                                      .contains(
                                                          lead.customerId)))
                                      .map((task) {
                                    return {
                                      'Customer Name': task.customerName,
                                      'Mobile no': task.contactNumber,
                                      'Remark': task.remark,
                                      'Assigned To': task.toUserName,
                                      'Next Follow-up Date':
                                          task.nextFollowUpDate!.isNotEmpty
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(DateTime.parse(
                                                      task.nextFollowUpDate!))
                                              : '',
                                      'Status': task.statusName,
                                    };
                                  }).toList(),
                                  fileName: 'Lead_Report',
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: Text(
                                  MediaQuery.of(context).size.width > 860
                                      ? 'Export To Excel'
                                      : ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (leadReportProvider.isFilter)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: leadReportProvider.selectedStatus !=
                                            null
                                        ? AppColors.primaryBlue
                                        : Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Text('Status: '),
                                  DropdownButton<int>(
                                    value: leadReportProvider.selectedStatus,
                                    hint: const Text('All'),
                                    items: provider.followUpData
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.statusId,
                                              child: Text(
                                                status.statusName ?? '',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        leadReportProvider.setStatus(
                                            newValue); // Update the status in the provider
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
                                      color: leadReportProvider.fromDate !=
                                                  null ||
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        leadReportProvider.selectedUser != null
                                            ? AppColors.primaryBlue
                                            : Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Text('Assigned Staff: '),
                                  DropdownButton<int>(
                                    value: provider.searchUserDetails.any(
                                            (element) =>
                                                element.userDetailsId ==
                                                leadReportProvider.selectedUser)
                                        ? leadReportProvider.selectedUser
                                        : null,
                                    hint: const Text('All'),
                                    items: provider.searchUserDetails
                                        .map((user) => DropdownMenuItem<int>(
                                              value: user.userDetailsId!,
                                              child: Text(
                                                user.userDetailsName ?? '',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        leadReportProvider.setUserFilterStatus(
                                            newValue); // Update the status in the provider
                                      } else {
                                        leadReportProvider
                                            .selectDateFilterOption(null);
                                        leadReportProvider.removeStatus();
                                        leadReportProvider.getSearchLeadReports(
                                            '', '', '', '', context);
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        leadReportProvider.selectedEnquiryFor !=
                                                null
                                            ? AppColors.primaryBlue
                                            : Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Text('Enquiry For: '),
                                  DropdownButton<int>(
                                    value: provider.enquiryForList.any(
                                            (element) =>
                                                element.enquiryForId ==
                                                leadReportProvider
                                                    .selectedEnquiryFor)
                                        ? leadReportProvider.selectedEnquiryFor
                                        : null,
                                    hint: const Text('All'),
                                    items: provider.enquiryForList
                                        .map((enquiry) => DropdownMenuItem<int>(
                                              value: enquiry.enquiryForId!,
                                              child: Text(
                                                enquiry.enquiryForName ?? '',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        leadReportProvider.setEnquiryForFilter(
                                            newValue); // Update the status in the provider
                                        leadReportProvider.getSearchLeadReports(
                                            leadReportProvider.search,
                                            leadReportProvider.fromDateS,
                                            leadReportProvider.toDateS,
                                            leadReportProvider.status,
                                            context);
                                      } else {
                                        leadReportProvider
                                            .selectDateFilterOption(null);
                                        leadReportProvider.removeStatus();
                                        leadReportProvider.getSearchLeadReports(
                                            '', '', '', '', context);
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: leadReportProvider
                                                .selectedEnquirySource !=
                                            null
                                        ? AppColors.primaryBlue
                                        : Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Text('Enquiry Source: '),
                                  DropdownButton<int>(
                                    value: provider.enquiryData.any((element) =>
                                            element.enquirySourceId ==
                                            leadReportProvider
                                                .selectedEnquirySource)
                                        ? leadReportProvider
                                            .selectedEnquirySource
                                        : null,
                                    hint: const Text('All'),
                                    items: provider.enquiryData
                                        .map((source) => DropdownMenuItem<int>(
                                              value: source.enquirySourceId!,
                                              child: Text(
                                                source.enquirySourceName ?? '',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        leadReportProvider
                                            .setEnquirySourceFilter(newValue);
                                        leadReportProvider.getSearchLeadReports(
                                            leadReportProvider.search,
                                            leadReportProvider.fromDateS,
                                            leadReportProvider.toDateS,
                                            leadReportProvider.status,
                                            context);
                                      } else {
                                        leadReportProvider
                                            .selectDateFilterOption(null);
                                        leadReportProvider.removeStatus();
                                        leadReportProvider.getSearchLeadReports(
                                            '', '', '', '', context);
                                      }
                                    },
                                    underline: Container(),
                                    isDense: true,
                                    iconSize: 18,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                // Apply the selected filters (You can use values from the provider)
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
                                    '', fromDate, toDate, status, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                side: BorderSide(color: AppColors.primaryBlue),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (leadReportProvider.fromDate != null ||
                                leadReportProvider.toDate != null ||
                                leadReportProvider.selectedStatus != null ||
                                leadReportProvider.selectedUser != null ||
                                leadReportProvider.selectedEnquiryFor != null ||
                                leadReportProvider.selectedEnquirySource !=
                                    null)
                              ElevatedButton(
                                onPressed: () {
                                  leadReportProvider
                                      .selectDateFilterOption(null);
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
                    ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.grey[50], // Match bg
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Checkbox(
                                  value: leadReportProvider.areAllLeadsSelected,
                                  onChanged: (value) {
                                    leadReportProvider.toggleAllLeadsSelection(
                                        value ?? false);
                                  },
                                  activeColor: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  child: Text('No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              TableWidget(
                                  flex: 1,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  title: 'Lead name',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  width: 130,
                                  title: 'Mobile no',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 2,
                                  title: 'Remark',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Assigned Staff',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  width: 130,
                                  title: 'Follow-Up',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  width: 200,
                                  title: 'Next Follow-up Date',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  title: 'Status',
                                  color: Color(0xFF607185)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < 0 ||
                            index >= leadReportProvider.leadReportData.length) {
                          return null; // Return null to indicate end of list, though childCount handles it
                        }
                        var lead = leadReportProvider.leadReportData[index];
                        return Container(
                          color: Colors.grey[50], // Match bg
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            color: Colors.white, // Continuation of card
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : const Color(0xFFF6F7F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // Alternate row colors
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Checkbox(
                                      value: leadReportProvider
                                          .isLeadSelected(lead.customerId),
                                      onChanged: (value) {
                                        leadReportProvider.toggleLeadSelection(
                                            lead.customerId);
                                      },
                                      activeColor: AppColors.primaryBlue,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 16.0),
                                      child: Text(
                                          ((index + 1) +
                                                  leadReportProvider
                                                      .startLimit -
                                                  1)
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                  TableWidget(
                                    flex: 1,
                                    data: InkWell(
                                      onTap: () {
                                        setState(() {
                                          viewProfile = true;
                                        });
                                        leadReportProvider
                                            .setCutomerId(lead.customerId);
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE9EDF1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                1700
                                            ? Row(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Ensures the Row takes only as much space as needed
                                                children: [
                                                  // Front image (before text)
                                                  Image.asset(
                                                    'assets/images/lead_profile.png', // Replace with your image asset or NetworkImage
                                                    width:
                                                        15, // You can adjust the size of the image
                                                    height:
                                                        15, // You can adjust the size of the image
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          8), // Space between the image and text
                                                  Text(
                                                    lead.customerName.length >
                                                            15
                                                        ? '${lead.customerName.substring(0, 15)}...'
                                                        : lead.customerName,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          8), // Space between the text and back image
                                                  // Back image (after text)
                                                  Image.asset(
                                                    'assets/images/forward.png', // Replace with your image asset or NetworkImage
                                                    width:
                                                        12, // Adjust the size of the image
                                                    height:
                                                        12, // Adjust the size of the image
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                lead.customerName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  TableWidget(
                                      width: 130, title: lead.contactNumber),
                                  TableWidget(
                                    flex: 2,
                                    title: lead.remark.trim(),
                                  ),
                                  TableWidget(flex: 1, title: lead.toUserName),
                                  TableWidget(
                                    width: 130,
                                    data: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          viewProfile = false;
                                          viewFollowUp = true;
                                        });

                                        // Show loader while fetching details
                                        Loader.showLoader(context);

                                        try {
                                          // Fetch full details to populate Branch, Dept, etc.
                                          await Provider.of<
                                                      LeadDetailsProvider>(
                                                  context,
                                                  listen: false)
                                              .fetchLeadDetails(
                                                  lead.customerId.toString(),
                                                  context);

                                          // Stop Loader
                                          Loader.stopLoader(context);

                                          // Update LeadReportProvider (for local view state if needed)
                                          leadReportProvider
                                              .setCutomerId(lead.customerId);
                                          leadReportProvider.statusController
                                              .text = lead.statusName;
                                          leadReportProvider
                                              .assignToFollowUpController
                                              .text = lead.toUserName;
                                          leadReportProvider
                                                  .nextFollowUpDateController
                                                  .text =
                                              lead.nextFollowUpDate.isNotEmpty
                                                  ? _formatDateSafely(
                                                      lead.nextFollowUpDate)
                                                  : '';

                                          // Update LeadsProvider and DropDownProvider for AddFollowupDrawerWidget
                                          // Overwrite fields that fetchLeadDetails might have set incorrectly for this context
                                          final leadsProvider =
                                              Provider.of<LeadsProvider>(
                                                  context,
                                                  listen: false);
                                          final dropDownProvider =
                                              Provider.of<DropDownProvider>(
                                                  context,
                                                  listen: false);
                                          final settingsProvider =
                                              Provider.of<SettingsProvider>(
                                                  context,
                                                  listen: false);

                                          leadsProvider
                                              .setCutomerId(lead.customerId);

                                          // Populate the staff list based on the fetched branch/dept
                                          dropDownProvider
                                              .filterStaffByBranchAndDepartment(
                                            branchId: settingsProvider
                                                .selectedBranchId,
                                            departmentId: settingsProvider
                                                .selectedDepartmentId,
                                          );

                                          // Ensure Status is correct (fetchLeadDetails sets followUpStatusController, drawer uses statusController)
                                          leadsProvider.statusController.text =
                                              lead.statusName;
                                          dropDownProvider.selectedStatusId =
                                              int.tryParse(
                                                  lead.statusId.toString());

                                          // Ensure Assigned Staff is correct (drawer uses searchUserController)
                                          leadsProvider.searchUserController
                                              .text = lead.toUserName;
                                          dropDownProvider.selectedUserId =
                                              int.tryParse(
                                                  lead.toUserId.toString());

                                          // Ensure Next Follow Up Date
                                          leadsProvider
                                                  .nextFollowUpDateController
                                                  .text =
                                              lead.nextFollowUpDate.isNotEmpty
                                                  ? _formatDateSafely(
                                                      lead.nextFollowUpDate)
                                                  : '';

                                          // Ensure Remarks
                                          leadsProvider.messageController.text =
                                              lead.remark;

                                          // Branch and Department are already handled by fetchLeadDetails,
                                          // but we can double check/force if needed.
                                          // fetchLeadDetails uses the API response which should be accurate.
                                        } catch (e) {
                                          Loader.stopLoader(context);
                                          print('Error updating providers: $e');
                                        }

                                        if (context.mounted) {
                                          Scaffold.of(context).openEndDrawer();
                                        }
                                      },
                                      child: Image.asset(
                                        lead.lateFollowUp == '0'
                                            ? 'assets/images/followup_yes.png'
                                            : 'assets/images/followup_no.png',
                                        color: lead.lateFollowUp == '0'
                                            ? Colors.green
                                            : Colors.red,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                  TableWidget(
                                      width: 200,
                                      title: (lead.nextFollowUpDate.isNotEmpty)
                                          ? _formatDateSafely(
                                              lead.nextFollowUpDate)
                                          : ''),
                                  TableWidget(
                                    width: 150,
                                    data: Container(
                                      padding: lead.statusName.isNotEmpty
                                          ? const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4)
                                          : const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: StatusUtils.getStatusColor(
                                            int.tryParse(lead.statusId) ?? 0),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.black45, width: 0.1),
                                      ),
                                      child: Text(
                                        lead.statusName,
                                        style: TextStyle(
                                          color: StatusUtils.getStatusTextColor(
                                              int.tryParse(lead.statusId) ?? 0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: leadReportProvider.leadReportData.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: Container(
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildPaginationControls(context),
            endDrawer: viewProfile
                ? LeadDetailsWidget(
                    onEditPressed: () async {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 0), () {
                        setState(() {
                          isEdit = true;
                          viewProfile = false;
                          viewFollowUp = false;
                        });

                        _scaffoldKey.currentState?.openEndDrawer();
                      });
                    },
                    onFollowUpPressed: () async {
                      Navigator.pop(context);

                      Future.delayed(const Duration(milliseconds: 0), () {
                        setState(() {
                          viewProfile = false;
                          viewFollowUp = true;
                        });

                        _scaffoldKey.currentState?.openEndDrawer();
                      });
                    },
                    customerId: leadReportProvider.customerId.toString(),
                  )
                : viewFollowUp
                    ? const AddFollowupDrawerWidget()
                    : NewLeadDrawerWidget(
                        isEdit: isEdit,
                      ),
          )
        : LeadReportMobile(widget.fromDashBoard);
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
                        onPressed: () {
                          Navigator.pop(context);

                          leadReportProvider.formatDate();

                          print(leadReportProvider.formattedFromDate);
                          print(leadReportProvider.formattedToDate);
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

  String _formatDateSafely(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  Widget _buildPaginationControls(BuildContext context) {
    return Consumer<LeadReportProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 0) return const SizedBox.shrink();

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Tasks: ${provider.totalSize}',
                  style: const TextStyle(
                    color: Color(0xFF6C7C93),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(provider.totalPages, (index) {
                    int page = index + 1;
                    // Logic to show limited pages if many (simple version for now: max 5 pages or smart check)
                    // If pages > 7, show 1, 2, ..., current-1, current, current+1, ..., last
                    if (provider.totalPages > 7) {
                      if (index > 1 &&
                          index < provider.totalPages - 2 &&
                          (page < provider.pageIndex - 1 ||
                              page > provider.pageIndex + 1)) {
                        if (page == provider.pageIndex - 2 ||
                            page == provider.pageIndex + 2) {
                          return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('...'));
                        }
                        return const SizedBox.shrink();
                      }
                    }

                    bool isSelected = page == provider.pageIndex;
                    return InkWell(
                      onTap: () {
                        provider.goToPage(page);
                        // Use stored filters from provider
                        provider.getSearchLeadReports(
                            provider.search,
                            provider.fromDateS,
                            provider.toDateS,
                            provider.status,
                            context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : const Color(0xFFEaeaeb),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
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
    dropDownProvider.selectedStatusId = null; // Set to null using setter
    dropDownProvider.filteredStaffData = []; // Clear staff list

    // Local controllers for display text (optional if not used for submit)
    final statusController = TextEditingController();
    final branchController = TextEditingController();
    final departmentController = TextEditingController();
    final remarkController = TextEditingController();
    final nextFollowUpDateController = TextEditingController();

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: SizedBox(
              width: MediaQuery.of(context).size.width > 900
                  ? 800
                  : MediaQuery.of(context).size.width * 0.9,
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
                        const SizedBox(height: 24),

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
                        const SizedBox(height: 16),

                        // Branch & Department
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CommonDropdown<int>(
                                  hintText: 'Branch*',
                                  selectedValue:
                                      settingsProvider.selectedBranchId,
                                  items: settingsProvider.branchModel
                                      .map((source) => DropdownItem<int>(
                                            id: source.branchId ?? 0,
                                            name: source.branchName ?? '',
                                          ))
                                      .toList(),
                                  controller: branchController,
                                  onItemSelected: (selectedId) {
                                    settingsProvider.selectedBranchId =
                                        selectedId;
                                    final selectedBranch = settingsProvider
                                        .branchModel
                                        .firstWhere((branch) =>
                                            branch.branchId == selectedId);
                                    branchController.text =
                                        selectedBranch.branchName ?? '';
                                    settingsProvider.setSelectedDepartmentId(0);
                                    departmentController.clear();

                                    // Clear assignments when branch changes
                                    setState(() {
                                      assignments.clear();
                                      assignmentControllers.clear();
                                    });

                                    dropDownProvider
                                        .filterStaffByBranchAndDepartment(
                                      branchId: selectedId,
                                      departmentId: null,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CommonDropdown<int>(
                                  key: ValueKey(
                                      settingsProvider.selectedBranchId),
                                  hintText: 'Department*',
                                  selectedValue:
                                      settingsProvider.selectedDepartmentId,
                                  items: settingsProvider.departmentModel
                                      .map((source) => DropdownItem<int>(
                                            id: source.departmentId,
                                            name: source.departmentName ?? '',
                                          ))
                                      .toList(),
                                  controller: departmentController,
                                  onItemSelected: (selectedId) {
                                    settingsProvider.selectedDepartmentId =
                                        selectedId;
                                    final selectedDepartment = settingsProvider
                                        .departmentModel
                                        .firstWhere((dept) =>
                                            dept.departmentId == selectedId);
                                    departmentController.text =
                                        selectedDepartment.departmentName ?? '';

                                    // Clear assignments when department changes
                                    setState(() {
                                      assignments.clear();
                                      assignmentControllers.clear();
                                    });

                                    dropDownProvider
                                        .filterStaffByBranchAndDepartment(
                                      branchId:
                                          settingsProvider.selectedBranchId,
                                      departmentId: selectedId,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Count Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Selected Lead : $totalSelected",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Balance Selected lead : $balance",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: balance < 0
                                        ? Colors.red
                                        : Colors.black)),
                          ],
                        ),
                        const Divider(),

                        // Staff Table Header
                        Container(
                          color: const Color(0xFFF3F4F6),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 40,
                                  child: Text("No",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  flex: 3,
                                  child: const Text("Staff",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              // Expanded(flex: 2, child: const Text("Currently Assigned", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                  flex: 2,
                                  child: const Text("New Assign",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),

                        // Staff List
                        if (dropDownProvider.filteredStaffData.isNotEmpty)
                          Container(
                            height: 200, // Limit height
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300)),
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
                                      SizedBox(
                                          width: 40,
                                          child: Text("${index + 1}")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(staff.userDetailsName)),
                                      // Expanded(flex: 2, child: Text("0")), // Placeholder
                                      Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            height: 35,
                                            child: TextField(
                                              controller:
                                                  assignmentControllers[userId],
                                              keyboardType:
                                                  TextInputType.number,
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
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                                child: Text(
                                    "Select Branch/Department to see staff")),
                          ),

                        const SizedBox(height: 16),

                        // Remarks
                        CustomTextField(
                          height: 90,
                          controller: remarkController,
                          hintText: 'Remarks',
                          labelText: '',
                          minLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),

                        // Next Follow-up Date (Always show or conditional? Existing had it. Logic in drawer uses isFollowupRequiredNew)
                        if (dropDownProvider.isFollowupRequiredNew())
                          CustomTextField(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                nextFollowUpDateController.text =
                                    DateFormat('dd MMM yyyy').format(picked);
                              }
                            },
                            readOnly: true,
                            height: 54,
                            controller: nextFollowUpDateController,
                            hintText: 'Next Follow-up Date*',
                            suffixIcon: const Icon(Icons.calendar_today),
                            labelText: '',
                          ),

                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomElevatedButton(
                              buttonText: 'Cancel',
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              backgroundColor: AppColors.whiteColor,
                              borderColor: const Color(
                                  0xFFFFB800), // Yellow color from image roughly
                              textColor: const Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 8),
                            CustomElevatedButton(
                              buttonText: 'Transfer',
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
                                        content: Text(
                                            'Please assign leads to at least one staff member')),
                                  );
                                  return;
                                }

                                if (assigned > totalSelected) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Assigned count exceeds selected leads')),
                                  );
                                  return;
                                }

                                Navigator.pop(dialogContext); // Close dialog

                                // Create map of userIds to Names for the API call
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
                                      nextFollowUpDateController.text,
                                );
                              },
                              backgroundColor:
                                  const Color(0xFFFFB800), // Yellow filled
                              borderColor: const Color(0xFFFFB800),
                              textColor: AppColors.whiteColor,
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
}
