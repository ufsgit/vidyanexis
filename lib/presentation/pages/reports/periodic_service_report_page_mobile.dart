import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/amc_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/periodic_service_details_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/extensions.dart';

class PeriodicServiceReportPageMobile extends StatefulWidget {
  static String route = '/periodicServiceReports/';
  const PeriodicServiceReportPageMobile({
    super.key,
  });

  @override
  State<PeriodicServiceReportPageMobile> createState() =>
      _PeriodicServiceReportPageMobileState();
}

class _PeriodicServiceReportPageMobileState
    extends State<PeriodicServiceReportPageMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<AMCReportProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchAmcReport(context);
      searchProvider.stopSearch();
      reportsProvider.setFilter(false);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AMCReportProvider>(context);
    // final provider = Provider.of<DropDownProvider>(context);
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
        title: 'Periodic service Report',
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
          reportsProvider.toggleFilter();

          searchProvider.stopSearch();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
          );
          reportsProvider.getSearchAmcReport(context);
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
          reportsProvider.getSearchAmcReport(context);
        },
        searchController: searchController,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FILTER PANEL ────────────────────────────────────────────────
            if (reportsProvider.isFilter)
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CustomText('Status',
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
                              isSelected: reportsProvider.selectedStatus == 0 ||
                                  reportsProvider.selectedStatus == null,
                              onTap: () {
                                reportsProvider.setStatus(0);
                                reportsProvider.getSearchAmcReport(context);
                              },
                            ),
                            ...dropDownProvider.amcStatus.map((s) =>
                                FilterChipWidget(
                                  label: s.amcStatusName ?? 'Unknown',
                                  isSelected: reportsProvider.selectedStatus ==
                                      s.amcStatusId,
                                  onTap: () {
                                    reportsProvider.setStatus(s.amcStatusId);
                                    reportsProvider.getSearchAmcReport(context);
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomText('Date Range',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack),
                    const SizedBox(height: 8),
                    CommonReportDateFilter(
                      fromDate: reportsProvider.fromDate?.toString(),
                      toDate: reportsProvider.toDate?.toString(),
                      formattedFromDate: reportsProvider.formattedFromDate,
                      formattedToDate: reportsProvider.formattedToDate,
                      onTap: () => onClickTopButton(context),
                    ),
                    const SizedBox(height: 16),
                    CustomText('Assigned Staff',
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
                              isSelected: reportsProvider.selectedUser == 0 ||
                                  reportsProvider.selectedUser == null,
                              onTap: () {
                                reportsProvider.setUserFilterStatus(0);
                                reportsProvider.getSearchAmcReport(context);
                              },
                            ),
                            ...dropDownProvider.searchUserDetails.map((u) =>
                                FilterChipWidget(
                                  label: u.userDetailsName ?? 'Unknown',
                                  isSelected: reportsProvider.selectedUser ==
                                      u.userDetailsId,
                                  onTap: () {
                                    reportsProvider
                                        .setUserFilterStatus(u.userDetailsId);
                                    reportsProvider.getSearchAmcReport(context);
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null ||
                        (reportsProvider.selectedStatus != null &&
                            reportsProvider.selectedStatus != 0) ||
                        (reportsProvider.selectedUser != null &&
                            reportsProvider.selectedUser != 0) ||
                        reportsProvider.Search.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: CommonReportResetButton(
                          label: 'Reset All Filters',
                          onReset: () {
                            reportsProvider.selectDateFilterOption(null);
                            reportsProvider.removeStatus();
                            searchController.clear();
                            reportsProvider.setTaskSearchCriteria(
                                '', '', '', '', '');
                            reportsProvider.getSearchAmcReport(context);
                          },
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

            // ── LIST ────────────────────────────────────────────────────────

            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  height: 2,
                  color: AppColors.grey,
                );
              },
              itemCount: reportsProvider.amcReport.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                var service = reportsProvider.amcReport[index];

                Color statusColor = service.amcStatusName == "Completed"
                    ? Colors.green
                    : service.amcStatusName == "In Progress"
                        ? Colors.orange
                        : Colors.red;
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return PeriodicServiceDetailsPageMobile(item: service);
                      },
                    ));
                  },
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(color: AppColors.whiteColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 36,
                                  width: 3,
                                  decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(16))),
                              const SizedBox(
                                width: 8,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.serviceName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack),
                                  ),
                                  Text(
                                    service.productName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textGrey4),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerDetailPageMobile(
                                            customerId: service.customerId,
                                            fromLead: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          service.customerName,
                                          style: GoogleFonts.plusJakartaSans(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AppColors.bluebutton,
                                              decorationThickness: 1.5,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.bluebutton),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_right_rounded,
                                          color: AppColors.bluebutton,
                                          size: 18,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: statusColor.withOpacity(.1),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      child: Text(
                                        service.amcStatusName,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: statusColor),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              service.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textGrey3),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              service.amount != "0" &&
                                      service.amount != "0.0" &&
                                      service.amount != "0.000"
                                  ? CustomText(
                                      "₹${service.amount.split('.')[0]}",
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGrey4,
                                    )
                                  : SizedBox(),
                              service.amount != "0" &&
                                      service.amount != "0.0" &&
                                      service.amount != "0.000"
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: CustomText(
                                        '•',
                                        color:
                                            AppColors.textGrey4.withOpacity(.5),
                                      ),
                                    )
                                  : SizedBox(),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textBlack.withOpacity(.4),
                                  ),
                                  children: [
                                    const TextSpan(text: 'From  '),
                                    TextSpan(
                                      text: service.fromDate
                                          .toString()
                                          .toMonthDayYearFormat(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textGrey4,
                                      ),
                                    ),
                                    const TextSpan(text: '  to  '),
                                    TextSpan(
                                      text: service.toDate
                                          .toString()
                                          .toMonthDayYearFormat(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textGrey4,
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<AMCReportProvider>(
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
                          reportsProvider.getSearchAmcReport(context);
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
                          reportsProvider.getSearchAmcReport(context);
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
