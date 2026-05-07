import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
      reportsProvider.selectDateFilterOption(1); // 1 is 'Today' index
      reportsProvider.getSearchTaskReport(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AttendanceReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Attendance Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppStyles.isWebScreen(context))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Attendance Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomFilterButton(
                      onPressed: () {
                        reportsProvider.toggleFilter();
                      },
                      isFilter: reportsProvider.isFilter,
                    ),
                  ],
                ),
              ),
            if (!AppStyles.isWebScreen(context))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: searchController,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (query) {
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
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          suffixIcon: reportsProvider.Search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    searchController.clear();
                                    reportsProvider.setTaskSearchCriteria(
                                      '',
                                      reportsProvider.fromDateS,
                                      reportsProvider.toDateS,
                                      reportsProvider.Status,
                                      reportsProvider.AssignedTo,
                                      reportsProvider.TaskType,
                                    );
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomFilterButton(
                          onPressed: () {
                            reportsProvider.toggleFilter();
                          },
                          isFilter: reportsProvider.isFilter,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (reportsProvider.isFilter)
              AppStyles.isWebScreen(context)
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CommonReportDateFilter(
                            fromDate: reportsProvider.fromDate?.toString(),
                            toDate: reportsProvider.toDate?.toString(),
                            formattedFromDate:
                                reportsProvider.formattedFromDate,
                            formattedToDate: reportsProvider.formattedToDate,
                            onTap: () => onClickTopButton(context),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.AssignedTo != '0' &&
                                          reportsProvider.AssignedTo != ''
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Text('Staff Name: '),
                                DropdownButton<int>(
                                  value: int.tryParse(
                                          reportsProvider.AssignedTo) ??
                                      0,
                                  hint: const Text('All'),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text(
                                            'All',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ] +
                                      provider.searchUserDetails
                                          .map((user) => DropdownMenuItem<int>(
                                                value: user.userDetailsId,
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 150),
                                                  child: Text(
                                                    user.userDetailsName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider
                                          .setUserFilterStatus(newValue);
                                    }
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      reportsProvider.formattedFromDate,
                                      reportsProvider.formattedToDate,
                                      reportsProvider.Status,
                                      reportsProvider.AssignedTo,
                                      reportsProvider.TaskType,
                                    );
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
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
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            CustomText('Date Range',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack),
                            const SizedBox(height: 8),
                            CommonReportDateFilter(
                              fromDate: reportsProvider.fromDate?.toString(),
                              toDate: reportsProvider.toDate?.toString(),
                              formattedFromDate:
                                  reportsProvider.formattedFromDate,
                              formattedToDate: reportsProvider.formattedToDate,
                              onTap: () => onClickTopButton(context),
                            ),
                            const SizedBox(height: 16),
                            CustomText('Staff Name',
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
                                      reportsProvider.AssignedTo == '0' ||
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
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                ),
                                ...provider.searchUserDetails.map((user) {
                                  return FilterChipWidget(
                                    label: user.userDetailsName ?? 'Unknown',
                                    isSelected: reportsProvider.AssignedTo ==
                                        user.userDetailsId.toString(),
                                    onTap: () {
                                      reportsProvider.setUserFilterStatus(
                                          user.userDetailsId ?? 0);
                                      reportsProvider.setTaskSearchCriteria(
                                        reportsProvider.Search,
                                        reportsProvider.formattedFromDate,
                                        reportsProvider.formattedToDate,
                                        reportsProvider.Status,
                                        reportsProvider.AssignedTo,
                                        reportsProvider.TaskType,
                                      );
                                      reportsProvider
                                          .getSearchTaskReport(context);
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (reportsProvider.fromDate != null ||
                                reportsProvider.toDate != null ||
                                (reportsProvider.AssignedTo != '0' &&
                                    reportsProvider.AssignedTo != '') ||
                                reportsProvider.Search.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: CommonReportResetButton(
                                  label: 'Reset All Filters',
                                  onReset: () {
                                    reportsProvider
                                        .selectDateFilterOption(null);
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
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.textRed,
                                    elevation: 0,
                                    side: BorderSide(color: AppColors.textRed),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Header Row
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 12.0),
                                  child: Text('No.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              TableWidget(
                                  flex: 1,
                                  title: 'Name',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Date',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Time',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Location',
                                  color: Color(0xFF607185)),
                            ],
                          ),
                        ),
                        // Data Rows
                        Expanded(
                          child: reportsProvider.taskReport.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off_outlined,
                                          size: 80, color: Colors.grey[300]),
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
                                )
                              : ListView.builder(
                                  itemCount: reportsProvider.taskReport.length,
                                  itemBuilder: (context, index) {
                                    var task =
                                        reportsProvider.taskReport[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : const Color(0xFFF6F7F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
                                              child: Text(
                                                  (index + 1).toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                          ),
                                          TableWidget(
                                            flex: 1,
                                            data: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE9EDF1),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                task.userDetailsName,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableWidget(
                                              flex: 1, title: task.checkInDate),
                                          TableWidget(
                                              flex: 1,
                                              title: task.checkInTimeOnly),
                                          TableWidget(
                                              flex: 1, title: task.location),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
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
}
