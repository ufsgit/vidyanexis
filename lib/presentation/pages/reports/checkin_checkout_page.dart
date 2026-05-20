import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/check_in_out_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:go_router/go_router.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  _CheckInOutScreenState createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<CheckInOutProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
      reportsProvider.getSearchTaskReport(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getUserDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<CheckInOutProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Attendance Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        onFilterTap: () => reportsProvider.toggleFilter(),
        showSearch: true,
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.AssignedTo,
            reportsProvider.TaskType,
          );
          reportsProvider.getSearchTaskReport(context);
        },
        searchController: searchController,
      ),
      body: Column(
        children: [
          if (reportsProvider.isFilter)
            _buildFilterPanel(context, reportsProvider, provider),
          Expanded(
            child: reportsProvider.taskReport.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportsProvider.taskReport.length,
                    itemBuilder: (context, index) {
                      final task = reportsProvider.taskReport[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReportListItem(
                          title: task.userDetailsName,
                          subtitle: task.checkInDate,
                          description:
                              'Check-In: ${task.checkInTimeOnly} • Check-Out: ${task.checkOutTimeOnly.isEmpty ? "-" : task.checkOutTimeOnly}',
                          statusColor: AppColors.primaryBlue,
                          bottomLeftIcon: Icons.location_on_outlined,
                          bottomLeftText: task.location.isEmpty
                              ? 'No Location'
                              : task.location,
                          bottomRightText: 'No. ${index + 1}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context,
      CheckInOutProvider reportsProvider, DropDownProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: reportsProvider.fromDate?.toString(),
              toDate: reportsProvider.toDate?.toString(),
              formattedFromDate: reportsProvider.formattedFromDate,
              formattedToDate: reportsProvider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            CustomText('Staff',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: reportsProvider.selectedUser == 0 ||
                      reportsProvider.selectedUser == null,
                  onTap: () {
                    reportsProvider.setUserFilterStatus(0);
                    reportsProvider.getSearchTaskReport(context);
                  },
                ),
                ...provider.searchUserDetails.map((u) {
                  return FilterChipWidget(
                    label: u.userDetailsName ?? 'Unknown',
                    isSelected: reportsProvider.selectedUser == u.userDetailsId,
                    onTap: () {
                      reportsProvider.setUserFilterStatus(u.userDetailsId);
                      reportsProvider.getSearchTaskReport(context);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      reportsProvider.getSearchTaskReport(context);
                      reportsProvider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.selectDateFilterOption(null);
                    reportsProvider.removeStatus();
                    searchController.clear();
                    reportsProvider.setTaskSearchCriteria(
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                    );
                    reportsProvider.getSearchTaskReport(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No attendance reports found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CheckInOutProvider>(
        builder: (context, reportsProvider, child) {
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
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            reportsProvider.formattedFromDate,
                            reportsProvider.formattedToDate,
                            reportsProvider.Status,
                            reportsProvider.selectedUser.toString(),
                            reportsProvider.selectedTaskType.toString(),
                          );
                          reportsProvider.getSearchTaskReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
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
