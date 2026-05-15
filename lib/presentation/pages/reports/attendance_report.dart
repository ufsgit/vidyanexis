import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:go_router/go_router.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1);
      reportsProvider.getSearchTaskReport(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getUserDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AttendanceReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
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
          // ── Web Header & Filter ───────────────────────────────────────────
          if (isWeb) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Attendance Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                  // Search Bar
                  Container(
                    width: 300,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (query) {
                        reportsProvider.setTaskSearchCriteria(
                          query,
                          reportsProvider.formattedFromDate,
                          reportsProvider.formattedToDate,
                          reportsProvider.Status,
                          reportsProvider.AssignedTo,
                          reportsProvider.TaskType,
                        );
                        reportsProvider.getSearchTaskReport(context);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search here....',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  CustomFilterButton(
                    onPressed: () => reportsProvider.toggleFilter(),
                    isFilter: reportsProvider.isFilter,
                  ),
                  const SizedBox(width: 16),
                  // Export Button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_upload_outlined, size: 20),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (reportsProvider.isFilter)
              _buildWebFilterBar(context, reportsProvider, provider),
          ],

          // ── Mobile Filter ───────────────────────────────────────────────
          if (!isWeb && reportsProvider.isFilter)
            _buildFilterPanel(context, reportsProvider, provider),

          // ── Table Header (Web Only) ──────────────────────────────────────
          if (isWeb)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6).withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: _tableHeader('No.')),
                  Expanded(flex: 3, child: _tableHeader('Staff Name')),
                  Expanded(flex: 2, child: _tableHeader('Date')),
                  Expanded(flex: 2, child: _tableHeader('Check-In')),
                  Expanded(flex: 2, child: _tableHeader('Check-Out')),
                  Expanded(flex: 4, child: _tableHeader('Location')),
                ],
              ),
            ),

          if (reportsProvider.taskReport.isNotEmpty &&
              !reportsProvider.isFilter &&
              !isWeb)
            CommonReportSummaryBar(
              totalLabel: 'Total Records',
              totalCount: reportsProvider.taskReport.length,
              showingLabel: 'Showing',
              showingCount: reportsProvider.taskReport.length,
            ),

          Expanded(
            child: reportsProvider.taskReport.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportsProvider.taskReport.length,
                    itemBuilder: (context, index) {
                      final task = reportsProvider.taskReport[index];
                      if (isWeb) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Color(0xFFF3F4F6))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text('${index + 1}',
                                      style: _tableRowStyle())),
                              Expanded(
                                  flex: 3,
                                  child: Text(task.userDetailsName,
                                      style: _tableRowStyle())),
                              Expanded(
                                  flex: 2,
                                  child: Text(task.checkInDate,
                                      style: _tableRowStyle())),
                              Expanded(
                                  flex: 2,
                                  child: Text(task.checkInTimeOnly,
                                      style: _tableRowStyle())),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      task.checkOutTimeOnly.isEmpty
                                          ? '-'
                                          : task.checkOutTimeOnly,
                                      style: _tableRowStyle())),
                              Expanded(
                                  flex: 4,
                                  child: Text(
                                      task.location.isEmpty
                                          ? 'No Location'
                                          : task.location,
                                      style: _tableRowStyle(),
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }
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

  // ── Web: horizontal inline filter bar ───────────────────────────────────
  Widget _buildWebFilterBar(
    BuildContext context,
    AttendanceReportProvider reportsProvider,
    DropDownProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey),
      ),
      child: Row(
        children: [
          // Date picker chip
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            label: 'Date',
            onTap: () => onClickTopButton(context),
          ),
          const SizedBox(width: 12),
          // User dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: reportsProvider.AssignedTo != '0' &&
                        reportsProvider.AssignedTo != ''
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Staff: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                DropdownButton<int>(
                  value: int.tryParse(reportsProvider.AssignedTo) ?? 0,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      provider.searchUserDetails
                          .map((user) => DropdownMenuItem<int>(
                                value: user.userDetailsId,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    user.userDetailsName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      reportsProvider.setUserFilterStatus(newValue);
                    }
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Apply button
          ElevatedButton(
            onPressed: () {
              reportsProvider.setTaskSearchCriteria(
                searchController.text,
                reportsProvider.formattedFromDate,
                reportsProvider.formattedToDate,
                reportsProvider.Status,
                reportsProvider.AssignedTo,
                reportsProvider.TaskType,
              );
              reportsProvider.getSearchTaskReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAB308),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          // Reset button
          if (reportsProvider.fromDate != null ||
              (reportsProvider.AssignedTo != '0' &&
                  reportsProvider.AssignedTo != ''))
            CommonReportResetButton(
              label: 'Reset',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: BorderSide(color: AppColors.textRed),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context,
      AttendanceReportProvider reportsProvider, DropDownProvider provider) {
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
            CustomText('Staff Name',
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
                  isSelected: reportsProvider.AssignedTo == '0' ||
                      reportsProvider.AssignedTo == '',
                  onTap: () {
                    reportsProvider.setUserFilterStatus(0);
                    reportsProvider.setTaskSearchCriteria(
                      reportsProvider.Search,
                      reportsProvider.formattedFromDate,
                      reportsProvider.formattedToDate,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      reportsProvider.TaskType,
                    );
                    reportsProvider.getSearchTaskReport(context);
                  },
                ),
                ...provider.searchUserDetails.map((user) {
                  return FilterChipWidget(
                    label: user.userDetailsName ?? 'Unknown',
                    isSelected: reportsProvider.AssignedTo ==
                        user.userDetailsId.toString(),
                    onTap: () {
                      reportsProvider
                          .setUserFilterStatus(user.userDetailsId ?? 0);
                      reportsProvider.setTaskSearchCriteria(
                        reportsProvider.Search,
                        reportsProvider.formattedFromDate,
                        reportsProvider.formattedToDate,
                        reportsProvider.Status,
                        reportsProvider.AssignedTo,
                        reportsProvider.TaskType,
                      );
                      reportsProvider.getSearchTaskReport(context);
                    },
                  );
                }).toList(),
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
      builder: (context) => Consumer<AttendanceReportProvider>(
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
                            reportsProvider.AssignedTo,
                            reportsProvider.TaskType,
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

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  TextStyle _tableRowStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: const Color(0xFF374151),
    );
  }
}
