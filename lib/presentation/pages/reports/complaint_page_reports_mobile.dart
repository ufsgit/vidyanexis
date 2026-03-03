import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/service_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/complaints_details_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';

class ComplaintPageReportsMobile extends StatefulWidget {
  static String route = '/complaintReports/';
  const ComplaintPageReportsMobile({
    super.key,
  });

  @override
  State<ComplaintPageReportsMobile> createState() =>
      _ComplaintPageReportsMobileState();
}

class _ComplaintPageReportsMobileState
    extends State<ComplaintPageReportsMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<ServiceReportProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchServiceReport(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      searchProvider.stopSearch();

      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ServiceReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              searchProvider.stopSearch();

              customerProvider.setFilter(false);
              leadProvider.setFilter(false);
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: 'Complaint Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          reportsProvider.toggleFilter();
          print(reportsProvider.isFilter);
        },
        onSearchTap: () {
          searchProvider.startSearch();
          reportsProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          reportsProvider.toggleFilter();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
          );
          reportsProvider.getSearchServiceReport(context);
        },
        onSearch: (query) {
          // reportsProvider.selectDateFilterOption(null);
          // reportsProvider.removeStatus();
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.AssignedTo,
          );
          reportsProvider.getSearchServiceReport(context);
        },
        searchController: searchController,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (reportsProvider.isFilter)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: reportsProvider.selectedStatus != null &&
                                      reportsProvider.selectedStatus != 0
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Text('Status: '),
                            DropdownButton<int>(
                              value: reportsProvider.selectedStatus,
                              hint: const Text('All'),
                              items: [
                                    const DropdownMenuItem<int>(
                                      value:
                                          0, // Use 0 or null to represent "All"
                                      child: Text(
                                        'All',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ] +
                                  const [
                                    DropdownMenuItem<int>(
                                      value: 1,
                                      child: Text(
                                        'Pending',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    DropdownMenuItem<int>(
                                      value: 2,
                                      child: Text(
                                        'Completed',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  reportsProvider.setStatus(
                                      newValue); // Update the status in the provider
                                }
                                String status =
                                    reportsProvider.selectedStatus.toString();
                                String assignedTo =
                                    reportsProvider.selectedUser.toString();
                                String fromDate =
                                    reportsProvider.formattedFromDate;
                                String toDate = reportsProvider.formattedToDate;
                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                reportsProvider.setTaskSearchCriteria(
                                    reportsProvider.Search,
                                    fromDate,
                                    toDate,
                                    status,
                                    assignedTo);
                                reportsProvider.getSearchServiceReport(context);
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
                                color: reportsProvider.fromDate != null ||
                                        reportsProvider.toDate != null
                                    ? AppColors.primaryBlue
                                    : Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              if (reportsProvider.fromDate == null &&
                                  reportsProvider.toDate == null)
                                const Text('Added Date: All'),
                              if (reportsProvider.fromDate != null &&
                                  reportsProvider.toDate != null)
                                Text(
                                    'Date : ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}'),
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
                      // Removed the Spacer() which can cause issues in a horizontal scroll
                      const SizedBox(
                        width: 20,
                      ), // Fixed spacing instead of Spacer()
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null ||
                          (reportsProvider.selectedStatus != null &&
                              reportsProvider.selectedStatus != 0) ||
                          (reportsProvider.selectedUser != null &&
                              reportsProvider.selectedUser != 0) ||
                          reportsProvider.Search.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            reportsProvider.selectDateFilterOption(null);
                            reportsProvider.removeStatus();
                            searchController.clear();
                            reportsProvider.setTaskSearchCriteria(
                              '',
                              '',
                              '',
                              '',
                              '',
                            );
                            reportsProvider.getSearchServiceReport(context);
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
            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  height: 2,
                  color: AppColors.grey,
                );
              },
              itemCount: reportsProvider.serviceReport.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                var service = reportsProvider.serviceReport[index];

                Color statusColor = service.serviceStatusName == "Completed"
                    ? Colors.green
                    : service.serviceStatusName == "In Progress"
                        ? Colors.orange
                        : Colors.red;
                return ReportListItem(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ComplaintsDetailsPageMobile(service: service);
                      },
                    ));
                  },
                  onSubtitleTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailPageMobile(
                            customerId: service.customerId,
                            fromLead: false,
                          ),
                        ));
                  },
                  title: service.serviceName,
                  subtitle: '${service.customerName} >',
                  status: service.serviceStatusName,
                  statusColor: statusColor,
                  description: service.description,
                  bottomLeftText: (service.amount != "0" &&
                          service.amount != "0.0" &&
                          service.amount != "0.000")
                      ? '₹${service.amount.split('.')[0]}'
                      : null,
                  bottomRightText:
                      'By ${service.createdByName} on ${service.createDate.toMonthDayYearFormat()}',
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<ServiceReportProvider>(
        builder: (contextx, reportsProvider, child) {
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
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportsProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                reportsProvider.selectedDateFilterIndex == index
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
                                reportsProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
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
                                reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
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

                          reportsProvider.formatDate();

                          print(reportsProvider.formattedFromDate);
                          print(reportsProvider.formattedToDate);

                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo);
                          reportsProvider.getSearchServiceReport(context);
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = '';
                          String toDate = '';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getSearchServiceReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
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
