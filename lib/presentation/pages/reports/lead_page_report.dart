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
import 'package:vidyanexis/presentation/widgets/home/add_followup_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

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
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');

      provider.getEnquirySource(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '1');
      provider.getAllFollowUpStatus(context, '1');
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
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  color: Colors.grey[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
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
                                  // leadReportProvider.selectDateFilterOption(null);
                                  // leadReportProvider.removeStatus();
                                  // leadReportProvider.getSearchLeadReports(
                                  //     '', '', '', '', context);
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
                      if (leadReportProvider.isFilter)
                        Container(
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
                                      color:
                                          leadReportProvider.selectedStatus !=
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
                                          .map(
                                              (status) => DropdownMenuItem<int>(
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
                                                leadReportProvider.toDate !=
                                                    null
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
                                      color: leadReportProvider.selectedUser !=
                                              null
                                          ? AppColors.primaryBlue
                                          : Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Text('Assigned Staff: '),
                                    DropdownButton<int>(
                                      value: leadReportProvider.selectedUser,
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
                                  side:
                                      BorderSide(color: AppColors.primaryBlue),
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
                                  leadReportProvider.selectedUser != null)
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Header Row (Table Column Titles)
                                Container(
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
                                          value: leadReportProvider
                                              .areAllLeadsSelected,
                                          onChanged: (value) {
                                            leadReportProvider
                                                .toggleAllLeadsSelection(
                                                    value ?? false);
                                          },
                                          activeColor: AppColors.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 70,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 25.0),
                                          child: Text('No',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF607185))),
                                        ),
                                      ),
                                      TableWidget(
                                          flex: 1,
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
                                          title: 'Status',
                                          color: Color(0xFF607185)),
                                    ],
                                  ),
                                ),
                                // Data Rows
                                ListView.builder(
                                  shrinkWrap:
                                      true, // To avoid scrolling issues when inside a parent widget
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable scrolling here, as parent scroll handles it
                                  itemCount: leadReportProvider
                                      .leadReportData.length, // Number of leads
                                  itemBuilder: (context, index) {
                                    var lead = leadReportProvider
                                        .leadReportData[index];
                                    return Container(
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
                                                  .isLeadSelected(
                                                      lead.customerId),
                                              onChanged: (value) {
                                                leadReportProvider
                                                    .toggleLeadSelection(
                                                        lead.customerId);
                                              },
                                              activeColor:
                                                  AppColors.primaryBlue,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
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
                                                leadReportProvider.setCutomerId(
                                                    lead.customerId);
                                                Scaffold.of(context)
                                                    .openEndDrawer();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE9EDF1),
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
                                                            lead.customerName
                                                                        .length >
                                                                    15
                                                                ? '${lead.customerName.substring(0, 15)}...'
                                                                : lead
                                                                    .customerName,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          TableWidget(
                                              width: 130,
                                              title: lead.contactNumber),
                                          TableWidget(
                                            flex: 2,
                                            title: lead.remark.trim(),
                                          ),
                                          TableWidget(
                                              flex: 1, title: lead.toUserName),
                                          TableWidget(
                                            width: 130,
                                            data: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  viewProfile = false;
                                                  viewFollowUp = true;
                                                });
                                                leadReportProvider.setCutomerId(
                                                    lead.customerId);
                                                leadReportProvider
                                                    .statusController
                                                    .text = lead.statusName;

                                                leadReportProvider
                                                    .assignToFollowUpController
                                                    .text = lead.toUserName;
                                                leadReportProvider
                                                    .nextFollowUpDateController
                                                    .text = lead
                                                        .nextFollowUpDate
                                                        .isNotEmpty
                                                    ? _formatDateSafely(
                                                        lead.nextFollowUpDate)
                                                    : '';
                                                // leadReportProvider.messageController.text =
                                                //     lead.remark;

                                                Scaffold.of(context)
                                                    .openEndDrawer();
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
                                              title: (lead.nextFollowUpDate
                                                      .isNotEmpty)
                                                  ? _formatDateSafely(
                                                      lead.nextFollowUpDate)
                                                  : ''),
                                          TableWidget(
                                            width: 150,
                                            data: Container(
                                              padding: lead
                                                      .statusName.isNotEmpty
                                                  ? const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4)
                                                  : const EdgeInsets.all(0),
                                              decoration: BoxDecoration(
                                                color:
                                                    StatusUtils.getStatusColor(
                                                        int.parse(
                                                            lead.statusId)),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Colors.black45,
                                                    width: 0.1),
                                              ),
                                              child: Text(
                                                lead.statusName,
                                                style: TextStyle(
                                                  color: StatusUtils
                                                      .getStatusTextColor(
                                                          int.parse(
                                                              lead.statusId)),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // if (leadReportProvider.leadData.isEmpty)
                                //   Container(
                                //     height: 400,
                                //     // child: Center(
                                //     //   child: Text(
                                //     //     "No Data",
                                //     //     style: TextStyle(fontWeight: FontWeight.w600),
                                //     //   ),
                                //     // ),
                                //   ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // bottomNavigationBar: _buildPaginationControls(context),
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
}
