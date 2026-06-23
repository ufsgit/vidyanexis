import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/followup_reports_provider.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class FollowupReportMobile extends StatefulWidget {
  const FollowupReportMobile({super.key});

  @override
  State<FollowupReportMobile> createState() => _FollowupReportMobile();
}

class _FollowupReportMobile extends State<FollowupReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final followUpReportsProvider =
          Provider.of<FollowupReportsProvider>(context, listen: false);
      followUpReportsProvider.setFollowupSearch(
        searchController.text,
        followUpReportsProvider.fromDateS,
        followUpReportsProvider.toDateS,
        followUpReportsProvider.Status,
        followUpReportsProvider.AssignedTo,
      );
      followUpReportsProvider.getFollowupReports(context);
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
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Followup Report',
        onSearchTap: () {
          searchProvider.startSearch();
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
          followUpReportsProvider.setFollowupSearch(
            '',
            followUpReportsProvider.fromDateS,
            followUpReportsProvider.toDateS,
            followUpReportsProvider.Status,
            followUpReportsProvider.AssignedTo,
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
        child: followUpReportsProvider.isFilter
            ? SingleChildScrollView(
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
                          isSelected: followUpReportsProvider.selectedStatus ==
                                  0 ||
                              followUpReportsProvider.selectedStatus == null,
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
                              color: followUpReportsProvider
                                          .selectedDateFilterIndex !=
                                      null
                                  ? AppColors.primaryBlue.withOpacity(0.1)
                                  : Colors.grey[100],
                              border: Border.all(
                                color: followUpReportsProvider
                                            .selectedDateFilterIndex !=
                                        null
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: followUpReportsProvider
                                              .selectedDateFilterIndex !=
                                          null
                                      ? AppColors.primaryBlue
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  followUpReportsProvider
                                              .selectedDateFilterIndex !=
                                          null
                                      ? dateButtonTitles[followUpReportsProvider
                                          .selectedDateFilterIndex!]
                                      : 'Select Date Range',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: followUpReportsProvider
                                                .selectedDateFilterIndex !=
                                            null
                                        ? AppColors.primaryBlue
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (followUpReportsProvider.fromDate != null ||
                            followUpReportsProvider.toDate != null)
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.05),
                              border: Border.all(
                                  color:
                                      AppColors.primaryBlue.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Center(
                              child: Text(
                                "${followUpReportsProvider.formattedFromDate} - ${followUpReportsProvider.formattedToDate}",
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
                          isSelected:
                              followUpReportsProvider.selectedUser == 0 ||
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
                    // ── Reset ────────────────────────────────────
                    if (followUpReportsProvider.fromDate != null ||
                        followUpReportsProvider.toDate != null ||
                        (followUpReportsProvider.selectedStatus != null &&
                            followUpReportsProvider.selectedStatus != 0) ||
                        (followUpReportsProvider.selectedUser != null &&
                            followUpReportsProvider.selectedUser != 0))
                      SizedBox(
                        width: double.infinity,
                        child: CommonReportResetButton(
                          label: 'Reset',
                          onReset: () {
                            followUpReportsProvider
                                .selectDateFilterOption(null);
                            followUpReportsProvider.removeStatus();
                            searchController.clear();
                            followUpReportsProvider.setFollowupSearch(
                                '', '', '', '', '');
                            followUpReportsProvider.getFollowupReports(context);
                            searchProvider.stopSearch();
                            followUpReportsProvider.setFilter(false);
                          },
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              )
            : followUpReportsProvider.pendingFolloWuP.isEmpty
                ? const CommonEmptyState(message: 'No followup reports found')
                : ListView.separated(
                    separatorBuilder: (context, index) {
                      if (index == 0) return const SizedBox.shrink();
                      return const SizedBox(height: 12);
                    },
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount:
                        followUpReportsProvider.pendingFolloWuP.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CommonReportSummaryBar(
                            totalLabel: 'Total Followups',
                            totalCount:
                                followUpReportsProvider.pendingFolloWuP.length,
                            showingLabel: 'Showing',
                            showingCount:
                                followUpReportsProvider.pendingFolloWuP.length,
                          ),
                        );
                      }

                      var followup =
                          followUpReportsProvider.pendingFolloWuP[index - 1];
                      return ReportListItem(
                        onTap: () {},
                        onSubtitleTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailPageMobile(
                                customerId: followup.customerId ?? 0,
                                fromLead: false,
                              ),
                            ),
                          );
                        },
                        title: followup.customerName ?? '',
                        subtitle: '${followup.phoneNumber ?? ''} >',
                        status: followup.statusName ?? '',
                        statusColor: getAvatarColor(followup.statusName ?? ''),
                        description: followup.remark ?? '',
                        bottomLeftIcon: Icons.calendar_today_outlined,
                        bottomLeftText: followup.nextFollowUpDate
                            .toString()
                            .toFormattedDate(),
                        bottomRightText: followup.toUserName ?? '',
                      );
                    },
                  ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: followUpReportsProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_filter_fab',
                  onPressed: () async {
                    followUpReportsProvider.formatDate();
                    followUpReportsProvider.setFollowupSearch(
                      searchController.text,
                      followUpReportsProvider.formattedFromDate,
                      followUpReportsProvider.formattedToDate,
                      followUpReportsProvider.selectedStatus.toString(),
                      followUpReportsProvider.selectedUser.toString(),
                    );
                    await followUpReportsProvider.getFollowupReports(context);
                    searchProvider.stopSearch();
                    followUpReportsProvider.setFilter(false);
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

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<FollowupReportsProvider>(
        builder: (context, followUprovider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
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
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                        onPressed: () {
                          Navigator.pop(context);
                          followUprovider.formatDate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Select',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          followUprovider.selectDateFilterOption(null);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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
