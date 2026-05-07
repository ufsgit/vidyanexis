import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/followup_reports_provider.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/extensions.dart';

class FollowupReportMobile extends StatefulWidget {
  const FollowupReportMobile({super.key});

  @override
  State<FollowupReportMobile> createState() => _FollowupReportMobile();
}

class _FollowupReportMobile extends State<FollowupReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final followUpReportsProvider =
          Provider.of<FollowupReportsProvider>(context, listen: false);
      followUpReportsProvider.setFollowupSearch(
        '',
        '',
        '',
        '',
        '',
      );
      followUpReportsProvider.getFollowupReports(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "1");
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

    final searchProvider = Provider.of<SidebarProvider>(context);

    final provider = Provider.of<DropDownProvider>(context);
    final followUpReportsProvider =
        Provider.of<FollowupReportsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              followUpReportsProvider.setFilter(false);
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
        title: 'Followup Report',
        onSearchTap: () {
          searchProvider.startSearch();
          followUpReportsProvider.toggleFilter();
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          followUpReportsProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          followUpReportsProvider.toggleFilter();

          followUpReportsProvider.setFollowupSearch(
            '',
            '',
            '',
            '',
            '',
          );
          followUpReportsProvider.getFollowupReports(context);
        },
        onSearch: (query) {
          // reportsProvider.selectDateFilterOption(null);
          // reportsProvider.removeStatus();
          followUpReportsProvider.setFollowupSearch(
            query,
            followUpReportsProvider.fromDateS,
            followUpReportsProvider.toDateS,
            followUpReportsProvider.Status,
            followUpReportsProvider.AssignedTo,
          );
          followUpReportsProvider.getFollowupReports(context);
        },
        searchController: searchController,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FILTER PANEL ────────────────────────────────────────────────
            if (followUpReportsProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      CustomText('Status',
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
                            isSelected:
                                followUpReportsProvider.selectedStatus == 0 ||
                                    followUpReportsProvider.selectedStatus ==
                                        null,
                            onTap: () => followUpReportsProvider.setStatus(0),
                          ),
                          ...provider.followUpData.map((s) => FilterChipWidget(
                                label: s.statusName ?? 'Unknown',
                                isSelected:
                                    followUpReportsProvider.selectedStatus ==
                                        s.statusId,
                                onTap: () => followUpReportsProvider
                                    .setStatus(s.statusId ?? 0),
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Date Range',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      CommonReportDateFilter(
                        fromDate: followUpReportsProvider.fromDate?.toString(),
                        toDate: followUpReportsProvider.toDate?.toString(),
                        formattedFromDate:
                            followUpReportsProvider.formattedFromDate,
                        formattedToDate:
                            followUpReportsProvider.formattedToDate,
                        onTap: () => onClickTopButton(context),
                      ),
                      const SizedBox(height: 16),
                      CustomText('Assigned Staff',
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
                            isSelected: followUpReportsProvider.selectedUser ==
                                    0 ||
                                followUpReportsProvider.selectedUser == null,
                            onTap: () =>
                                followUpReportsProvider.setUserFilterStatus(0),
                          ),
                          ...provider.searchUserDetails
                              .map((u) => FilterChipWidget(
                                    label: u.userDetailsName ?? 'Unknown',
                                    isSelected:
                                        followUpReportsProvider.selectedUser ==
                                            u.userDetailsId,
                                    onTap: () => followUpReportsProvider
                                        .setUserFilterStatus(
                                            u.userDetailsId ?? 0),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (followUpReportsProvider.fromDate != null ||
                          followUpReportsProvider.toDate != null ||
                          (followUpReportsProvider.selectedStatus != null &&
                              followUpReportsProvider.selectedStatus != 0) ||
                          (followUpReportsProvider.selectedUser != null &&
                              followUpReportsProvider.selectedUser != 0))
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              followUpReportsProvider
                                  .selectDateFilterOption(null);
                              followUpReportsProvider.removeStatus();
                              followUpReportsProvider.setFollowupSearch(
                                  '', '', '', '', '');
                              followUpReportsProvider
                                  .getFollowupReports(context);
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
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

            // ── LIST ────────────────────────────────────────────────────────
            if (!followUpReportsProvider.isFilter)
              Expanded(
                child: followUpReportsProvider.pendingFolloWuP.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),
                            Icon(Icons.search_off_outlined,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No followup reports found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.separated(
                              separatorBuilder: (context, index) =>
                                  Divider(height: 2, color: AppColors.grey),
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: followUpReportsProvider
                                  .pendingFolloWuP.length,
                              itemBuilder: (context, index) {
                                var followup = followUpReportsProvider
                                    .pendingFolloWuP[index];
                                return InkWell(
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                        color: AppColors.whiteColor),
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
                                                      color: getAvatarColor(
                                                          followup.statusName ??
                                                              ''),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16))),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
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
                                                              customerId: followup
                                                                      .customerId ??
                                                                  0,
                                                              fromLead: false,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        '${followup.customerName ?? ''} >',
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .bluebutton,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              AppColors
                                                                  .bluebutton,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      followup.phoneNumber ??
                                                          '',
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColors
                                                                  .textBlack),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: getAvatarColor(
                                                              followup.statusName ??
                                                                  '')
                                                          .withOpacity(.15)),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 2),
                                                      child: Text(
                                                        followup.statusName ??
                                                            '',
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: getAvatarColor(
                                                              followup.statusName ??
                                                                  ''),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              followup.remark ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.textBlack),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                height: 22,
                                                decoration: BoxDecoration(
                                                    color:
                                                        AppColors.scaffoldColor,
                                                    border: Border.all(
                                                        color: AppColors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          size: 16,
                                                          color: AppColors
                                                              .textGrey3),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        followup
                                                            .nextFollowUpDate
                                                            .toString()
                                                            .toFormattedDate(),
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColors
                                                                    .textGrey3),
                                                      ),
                                                      const SizedBox(width: 4),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${followup.toUserName}',
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
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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
      builder: (context) => Consumer<FollowupReportsProvider>(
        builder: (context, followUprovider, child) {
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
                            followUprovider.setDateFilter(title);
                            followUprovider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              followUprovider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                followUprovider.selectedDateFilterIndex == index
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
                                followUprovider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: followUprovider.fromDate != null
                                  ? '${followUprovider.fromDate!.toLocal()}'
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
                                followUprovider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: followUprovider.toDate != null
                                  ? '${followUprovider.toDate!.toLocal()}'
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
                          followUprovider.formatDate();
                          String status =
                              followUprovider.selectedStatus.toString();
                          String assignedTo =
                              followUprovider.selectedUser.toString();
                          String fromDate = followUprovider.formattedFromDate;
                          String toDate = followUprovider.formattedToDate;
                          followUprovider.setFollowupSearch(
                              followUprovider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo);
                          await followUprovider.getFollowupReports(context);
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
