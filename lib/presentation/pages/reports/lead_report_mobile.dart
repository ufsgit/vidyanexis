import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/customer_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/models/search_leads_model.dart';
import 'package:techtify/controller/reports_provider.dart';
import 'package:techtify/controller/side_bar_provider.dart';
import 'package:techtify/controller/task_report_provider.dart';
import 'package:techtify/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:techtify/presentation/pages/home/customer_details_page.dart';
import 'package:techtify/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:techtify/presentation/widgets/customer/task_details_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:techtify/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:techtify/presentation/widgets/home/table_cell.dart';
import 'package:techtify/utils/csv_function.dart';
import 'package:techtify/utils/extensions.dart';

class LeadReportMobile extends StatefulWidget {
  const LeadReportMobile({super.key});

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
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');

      provider.getEnquirySource(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '1');
      provider.getAllFollowUpStatus(context, '1');
      leadProvider.getSearchLeadReports('', '', '', '', context);
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

    final leadProvider = Provider.of<LeadsProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    // final customerDetailsProvider =
    //     Provider.of<CustomerDetailsProvider>(context);
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
              leadProvider.setFilter(false);
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
          leadProvider.toggleFilter();
          leadProvider.selectDateFilterOption(null);
          leadProvider.removeStatus();
          leadProvider.getSearchLeadReports('', '', '', '', context);
          print(leadProvider.isFilter);
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          leadProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          leadProvider.toggleFilter();
          leadProvider.selectDateFilterOption(null);
          leadProvider.removeStatus();
          leadProvider.getSearchLeadReports('', '', '', '', context);
        },
        onSearch: (query) {
          String query = searchController.text;
          leadProvider.selectDateFilterOption(null);
          leadProvider.removeStatus();
          print(query);
          leadProvider.getSearchLeadReports(query, '', '', '', context);
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
            data: leadProvider.leadReportData.map((task) {
              return {
                'Customer Name': task.customerName,
                'Mobile no': task.contactNumber,
                'Remark': task.remark,
                'Assigned To': task.toUserName,
                'Next Follow-up Date': task.nextFollowUpDate!.isNotEmpty
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(task.nextFollowUpDate!))
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
            if (leadProvider.isFilter)
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
                            color: leadProvider.selectedStatus != null &&
                                    leadProvider.selectedStatus != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Status: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedStatus,
                            hint: const Text('All'),
                            items: provider.followUpData
                                .map((status) => DropdownMenuItem<int>(
                                      value: status.statusId,
                                      child: Text(
                                        status.statusName ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setStatus(newValue);

                                String status =
                                    leadProvider.selectedStatus.toString();

                                String fromDate =
                                    leadProvider.formattedFromDate;
                                String toDate = leadProvider.formattedToDate;

                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');

                                leadProvider.getSearchLeadReports(
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
                              color: leadProvider.fromDate != null ||
                                      leadProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (leadProvider.fromDate == null &&
                                leadProvider.toDate == null)
                              const Text('Next Follow-Up Date: All'),
                            if (leadProvider.fromDate != null &&
                                leadProvider.toDate != null)
                              Text(
                                  'Date : ${leadProvider.formattedFromDate} - ${leadProvider.formattedToDate}'),
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
                            color: leadProvider.selectedUser != null
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Assigned Staff: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedUser,
                            hint: const Text('All'),
                            items: provider.searchUserDetails
                                .map((user) => DropdownMenuItem<int>(
                                      value: user.userDetailsId!,
                                      child: Text(
                                        user.userDetailsName ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setUserFilterStatus(
                                    newValue); // Update the status in the provider
                                String status =
                                    leadProvider.selectedStatus.toString();

                                String fromDate =
                                    leadProvider.formattedFromDate;
                                String toDate = leadProvider.formattedToDate;

                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');

                                leadProvider.getSearchLeadReports(
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
                    if (leadProvider.fromDate != null ||
                        leadProvider.toDate != null ||
                        leadProvider.selectedStatus != null ||
                        leadProvider.selectedUser != null)
                      ElevatedButton(
                        onPressed: () {
                          leadProvider.selectDateFilterOption(null);
                          leadProvider.removeStatus();
                          leadProvider.getSearchLeadReports(
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
              child: SingleChildScrollView(
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
                          leadProvider.leadReportData.length, // Number of leads
                      itemBuilder: (context, index) {
                        var lead = leadProvider.leadReportData[index];

                        return InkWell(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration:
                                BoxDecoration(color: AppColors.whiteColor),
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
                                                  BorderRadius.circular(16))),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                print("object");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CustomerDetailPageMobile(
                                                      customerId:
                                                          lead.customerId,
                                                      fromLead: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                lead.customerName + ' >',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.bluebutton,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors.bluebutton,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              lead.contactNumber,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textBlack),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: getAvatarColor(
                                                      lead.statusName)
                                                  .withOpacity(.15)),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                              child: Text(
                                                lead.statusName,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: getAvatarColor(
                                                      lead.statusName),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      lead.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textBlack),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 22,
                                        decoration: BoxDecoration(
                                            color: AppColors.scaffoldColor,
                                            border: Border.all(
                                                color: AppColors.grey),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_outlined,
                                                size: 16,
                                                color: AppColors.textGrey3,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                lead.nextFollowUpDate
                                                    .toString()
                                                    .toFormattedDate(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textGrey3),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                ' - ${lead.toUserName}',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textGrey3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding:
                                      //       const EdgeInsets.symmetric(horizontal: 5),
                                      //   child: Text(
                                      //     '•',
                                      //     style: GoogleFonts.plusJakartaSans(
                                      //         fontSize: 10,
                                      //         fontWeight: FontWeight.w500,
                                      //         color: AppColors.textGrey3),
                                      //   ),
                                      // ),
                                      // Container(
                                      //   height: 20,
                                      //   width: 20,
                                      //   decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.circular(100),
                                      //       color: AppColors.textRed),
                                      // ),
                                      // const SizedBox(width: 4),
                                      // Text(
                                      //   'David',
                                      //   style: GoogleFonts.plusJakartaSans(
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.w500,
                                      //       color: AppColors.textGrey3),
                                      // ),
                                      const Spacer(),
                                      Text(
                                        lead.entryDate.toString().toTimeAgo(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey3),
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
      builder: (context) => Consumer<LeadsProvider>(
        builder: (context, leadProvider, child) {
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
                            leadProvider.setDateFilter(title);
                            leadProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              leadProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: leadProvider.selectedDateFilterIndex == index
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
                            onTap: () => leadProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.fromDate != null
                                  ? '${leadProvider.fromDate!.toLocal()}'
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
                                leadProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.toDate != null
                                  ? '${leadProvider.toDate!.toLocal()}'
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
                          leadProvider.formatDate();
                          String status =
                              leadProvider.selectedStatus.toString();

                          String fromDate = leadProvider.formattedFromDate;
                          String toDate = leadProvider.formattedToDate;

                          await leadProvider.getSearchLeadReports(
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
