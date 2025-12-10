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

class TaskPageReportMobile extends StatefulWidget {
  const TaskPageReportMobile({super.key});

  @override
  State<TaskPageReportMobile> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPageReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
      reportsProvider.getSearchTaskReport(context);
      searchProvider.stopSearch();
      reportsProvider.setFilter(false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "3");

      //search
      // searchController.addListener(() {
      //   reportsProvider.selectDateFilterOption(null);
      //   reportsProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   reportsProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<TaskReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
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
        title: 'Task Report',
        onSearchTap: () {
          searchProvider.startSearch();
          reportsProvider.toggleFilter();
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          reportsProvider.toggleFilter();
          print(reportsProvider.isFilter);
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
            '',
          );
          reportsProvider.getSearchTaskReport(context);
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
            reportsProvider.TaskType,
          );
          reportsProvider.getSearchTaskReport(context);
        },
        searchController: searchController,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedStatus !=
                                              null &&
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
                                      provider.followUpData
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
                                      reportsProvider.setStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String taskType = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
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
                                    const Text('Date: All'),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedUser != null &&
                                          reportsProvider.selectedUser != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Text('Assigned to: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedUser,
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
                                      provider.searchUserDetails
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.userDetailsId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.userDetailsName ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setUserFilterStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String taskType = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
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
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedTaskType !=
                                              null &&
                                          reportsProvider.selectedTaskType != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Text('Task Type: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedTaskType,
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
                                      provider.taskType
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.taskTypeId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.taskTypeName,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setTaskType(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String tasktype = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      tasktype,
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
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Apply the selected filters (You can use values from the provider)
                          //     String status =
                          //         reportsProvider.selectedStatus.toString();
                          //     String fromDate =
                          //         reportsProvider.formattedFromDate;
                          //     String toDate = reportsProvider.formattedToDate;
                          //     print(
                          //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //     reportsProvider.setSearchCriteria(
                          //       reportsProvider.search,
                          //       fromDate,
                          //       toDate,
                          //       status,
                          //     );
                          //     reportsProvider.getSearchCustomers(context);
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.white,
                          //     foregroundColor: AppColors.primaryBlue,
                          //     side: BorderSide(color: AppColors.primaryBlue),
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 16,
                          //       vertical: 12,
                          //     ),
                          //   ),
                          //   child: const Text('Apply'),
                          // ),
                          // const SizedBox(
                          //   width: 10,
                          // ),
                          if (reportsProvider.fromDate != null ||
                              reportsProvider.toDate != null ||
                              (reportsProvider.selectedStatus != null &&
                                  reportsProvider.selectedStatus != 0) ||
                              (reportsProvider.selectedUser != null &&
                                  reportsProvider.selectedUser != 0) ||
                              (reportsProvider.selectedTaskType != null &&
                                  reportsProvider.selectedTaskType != 0) ||
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
                                  '',
                                );
                                reportsProvider.getSearchTaskReport(context);
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
                    )
                  // mobile
                  : Container(
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
                                  color: reportsProvider.selectedStatus !=
                                              null &&
                                          reportsProvider.selectedStatus != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                      provider.followUpData
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
                                      reportsProvider.setStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String taskType = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (reportsProvider.fromDate == null &&
                                      reportsProvider.toDate == null)
                                    const Text('Date: All'),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedUser != null &&
                                          reportsProvider.selectedUser != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Assigned to: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedUser,
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
                                      provider.searchUserDetails
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.userDetailsId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.userDetailsName ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setUserFilterStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String taskType = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
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
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedTaskType !=
                                              null &&
                                          reportsProvider.selectedTaskType != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Task Type: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedTaskType,
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
                                      provider.taskType
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.taskTypeId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.taskTypeName,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setTaskType(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    String tasktype = reportsProvider
                                        .selectedTaskType
                                        .toString();
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      tasktype,
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
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Apply the selected filters (You can use values from the provider)
                          //     String status =
                          //         reportsProvider.selectedStatus.toString();
                          //     String fromDate =
                          //         reportsProvider.formattedFromDate;
                          //     String toDate = reportsProvider.formattedToDate;
                          //     print(
                          //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //     reportsProvider.setSearchCriteria(
                          //       reportsProvider.search,
                          //       fromDate,
                          //       toDate,
                          //       status,
                          //     );
                          //     reportsProvider.getSearchCustomers(context);
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.white,
                          //     foregroundColor: AppColors.primaryBlue,
                          //     side: BorderSide(color: AppColors.primaryBlue),
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 16,
                          //       vertical: 12,
                          //     ),
                          //   ),
                          //   child: const Text('Apply'),
                          // ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (reportsProvider.fromDate != null ||
                              reportsProvider.toDate != null ||
                              (reportsProvider.selectedStatus != null &&
                                  reportsProvider.selectedStatus != 0) ||
                              (reportsProvider.selectedUser != null &&
                                  reportsProvider.selectedUser != 0) ||
                              (reportsProvider.selectedTaskType != null &&
                                  reportsProvider.selectedTaskType != 0) ||
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
                                  '',
                                );
                                reportsProvider.getSearchTaskReport(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textRed,
                                side: BorderSide(color: AppColors.textRed),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
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
                      itemCount: reportsProvider.taskReport.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final task = reportsProvider.taskReport[index];

                        Color statusColor = task.taskStatusName == "Completed"
                            ? Colors.green
                            : task.taskStatusName == "In Progress"
                                ? Colors.orange
                                : Colors.red;
                        return InkWell(
                          onTap: () {
                            // context.push(
                            //     '${TaskDetailsPagePhone.route}${task.taskMasterId}/${task.taskId}');

                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return TaskDetailsPagePhone(
                                    taskId: task.taskId.toString(),
                                    taskMasterId: task.taskMasterId.toString(),
                                    customerId: task.customerId.toString());
                              },
                            ));
                          },
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
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(16))),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      // SizedBox(
                                      //     height: 16,
                                      //     width: 16,
                                      //     child: Image.asset(
                                      //       task.taskTypeId == 1
                                      //           ? 'assets/images/icon_site.png'
                                      //           : task.taskTypeId == 2
                                      //               ? 'assets/images/icon_installation.png'
                                      //               : task.taskTypeId == 3
                                      //                   ? 'assets/images/icon_service.png'
                                      //                   : 'assets/images/icon_amc.png',
                                      //     )),
                                      // const SizedBox(
                                      //   width: 4,
                                      // ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.taskTypeName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textBlack),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                print("object");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CustomerDetailPageMobile(
                                                      customerId:
                                                          task.customerId,
                                                      fromLead: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                task.customerName + ' >',
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
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: statusColor.withAlpha(25)),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                              child: Text(
                                                task.taskStatusName,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: statusColor),
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
                                      task.description,
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
                                                task.taskDate
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
                                        task.entryDate.toString().toTimeAgo(),
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
      barrierDismissible: false,
      builder: (contextx) => Consumer<TaskReportProvider>(
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withAlpha(25),
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
