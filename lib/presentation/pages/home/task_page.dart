import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/status_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/reports_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  DropDownProvider provider = DropDownProvider();
  TaskPageProvider reportsProvider = TaskPageProvider();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late bool _isMobile;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final taskPageProvider =
          Provider.of<TaskPageProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      _updateScreenType();
      _setupScrollListener();
      taskPageProvider.setFilter(false);
      searchProvider.stopSearch();

      customerProvider.resetExpansion();

      reportsProvider = Provider.of<TaskPageProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
      reportsProvider.searchTaskByCustomer(context);
      provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "3");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScreenType();
  }

  void _updateScreenType() {
    _isMobile = !AppStyles.isWebScreen(context);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Only trigger on mobile
      if (!AppStyles.isWebScreen(context)) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          _loadMoreTasks();
        }
      }
    });
  }

  Future<void> _loadMoreTasks() async {
    // Use TaskPageProvider (not ReportsProvider)
    final taskProvider = Provider.of<TaskPageProvider>(context, listen: false);

    if (_isLoadingMore || !taskProvider.hasMorePages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Use the loadMoreData method we just added
      await taskProvider.loadMoreData(context);
    } catch (e) {
      print('Error loading more tasks: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);

    final reportsProvider = Provider.of<TaskPageProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      backgroundColor:
          AppStyles.isWebScreen(context) ? null : AppColors.whiteColor,
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              onExcelTap: () {
                exportToExcel(
                  headers: [
                    'Customer',
                    'Task',
                    'Assigned To',
                    'Description',
                    'Date',
                    'Status'
                  ],
                  data: reportsProvider.taskReport.map((task) {
                    return {
                      'Customer': task.customerName,
                      'Task': task.taskTypeName,
                      'Assigned To': task.toUserName,
                      'Description': task.description,
                      'Date': task.entryDate.isNotEmpty
                          ? DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(task.entryDate))
                          : '',
                      'Status': task.taskStatusName,
                    };
                  }).toList(),
                  fileName: 'Task',
                );
              },
              showExcel: true,
              onSearchTap: () {
                reportsProvider.toggleFilter();

                searchProvider.startSearch();
              },
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                reportsProvider.toggleFilter();
                searchProvider.stopSearch();
                reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');

                reportsProvider.searchTaskByCustomer(context);
              },
              title: 'Tasks',
              onSearch: (String query) {
                print(query);
                if (reportsProvider.Search.isNotEmpty) {
                  searchController.clear();
                  reportsProvider.setTaskSearchCriteria(
                    '',
                    reportsProvider.fromDateS,
                    reportsProvider.toDateS,
                    reportsProvider.Status,
                    reportsProvider.AssignedTo,
                    reportsProvider.TaskType,
                  );
                } else {
                  reportsProvider.setTaskSearchCriteria(
                    query,
                    reportsProvider.fromDateS,
                    reportsProvider.toDateS,
                    reportsProvider.Status,
                    reportsProvider.AssignedTo,
                    reportsProvider.TaskType,
                  );
                }
                reportsProvider.searchTaskByCustomer(context);
              },
              searchController: searchController,
            )
          : null,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      body: Container(
        color: AppStyles.isWebScreen(context)
            ? Colors.grey[50]
            : AppColors.whiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Header
            // AppStyles.isWebScreen(context)
            //     ?

            // Responsive header implementation - modify your existing padding section:
            Padding(
              padding:
                  EdgeInsets.all(AppStyles.isWebScreen(context) ? 16.0 : 0),
              child: Column(
                children: [
                  // Main row with adaptive layout

                  AppStyles.isWebScreen(context)
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final isMobile = !AppStyles.isWebScreen(context);

                            return Column(
                              children: [
                                // Top row with Tasks title on left, everything else on right
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Left side: Tasks title only
                                    if (!isMobile)
                                      const Text(
                                        'Tasks',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    // Right side: Search, Filter, and Export
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Search container
                                          Container(
                                            width: isMobile
                                                ? constraints.maxWidth * 0.4
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    (screenWidth > 860 ? 5 : 4),
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.grey[300]!),
                                            ),
                                            child: TextField(
                                              controller: searchController,
                                              onSubmitted: (query) {
                                                reportsProvider
                                                    .setTaskSearchCriteria(
                                                  query,
                                                  reportsProvider.fromDateS,
                                                  reportsProvider.toDateS,
                                                  reportsProvider.Status,
                                                  reportsProvider.AssignedTo,
                                                  reportsProvider.TaskType,
                                                );
                                                reportsProvider
                                                    .searchTaskByCustomer(
                                                        context);
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Search here....',
                                                prefixIcon:
                                                    const Icon(Icons.search),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 4,
                                                ),
                                                suffixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      String query =
                                                          searchController.text;
                                                      print(query);
                                                      if (reportsProvider
                                                          .Search.isNotEmpty) {
                                                        searchController
                                                            .clear();
                                                        reportsProvider
                                                            .setTaskSearchCriteria(
                                                          '',
                                                          reportsProvider
                                                              .fromDateS,
                                                          reportsProvider
                                                              .toDateS,
                                                          reportsProvider
                                                              .Status,
                                                          reportsProvider
                                                              .AssignedTo,
                                                          reportsProvider
                                                              .TaskType,
                                                        );
                                                      } else {
                                                        reportsProvider
                                                            .setTaskSearchCriteria(
                                                          query,
                                                          reportsProvider
                                                              .fromDateS,
                                                          reportsProvider
                                                              .toDateS,
                                                          reportsProvider
                                                              .Status,
                                                          reportsProvider
                                                              .AssignedTo,
                                                          reportsProvider
                                                              .TaskType,
                                                        );
                                                      }
                                                      reportsProvider
                                                          .searchTaskByCustomer(
                                                              context);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          AppColors.textGrey4,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    child: Text(reportsProvider
                                                            .Search.isNotEmpty
                                                        ? 'Cancel'
                                                        : 'Search'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          // Filter button
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              reportsProvider.toggleFilter();
                                              print(reportsProvider.isFilter);
                                            },
                                            icon: const Icon(Icons.filter_list),
                                            label: Text(MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    600
                                                ? 'Filter'
                                                : ''),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  reportsProvider.isFilter
                                                      ? Colors.white
                                                      : AppColors.primaryBlue,
                                              backgroundColor:
                                                  reportsProvider.isFilter
                                                      ? const Color(0xFF5499D9)
                                                      : Colors.white,
                                              side: BorderSide(
                                                  color: reportsProvider
                                                          .isFilter
                                                      ? const Color(0xFF5499D9)
                                                      : AppColors.primaryBlue),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // Export button
                                          if (!isMobile || screenWidth > 400)
                                            CustomElevatedButton(
                                              onPressed: () {
                                                exportToExcel(
                                                  headers: [
                                                    'Customer',
                                                    'Task',
                                                    'Assigned To',
                                                    'Description',
                                                    'Date',
                                                    'Status'
                                                  ],
                                                  data: reportsProvider
                                                      .taskReport
                                                      .map((task) {
                                                    return {
                                                      'Customer':
                                                          task.customerName,
                                                      'Task': task.taskTypeName,
                                                      'Assigned To':
                                                          task.toUserName,
                                                      'Description':
                                                          task.description,
                                                      'Date': task.entryDate
                                                              .isNotEmpty
                                                          ? DateFormat(
                                                                  'dd MMM yyyy')
                                                              .format(DateTime
                                                                  .parse(task
                                                                      .entryDate))
                                                          : '',
                                                      'Status':
                                                          task.taskStatusName,
                                                    };
                                                  }).toList(),
                                                  fileName: 'Task',
                                                );
                                              },
                                              buttonText: screenWidth > 600
                                                  ? 'Export to Excel'
                                                  : 'Export',
                                              textColor: AppColors.whiteColor,
                                              borderColor: AppColors.appViolet,
                                              backgroundColor:
                                                  AppColors.appViolet,
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        )
                      : const SizedBox(),

                  // Filter section
                  if (reportsProvider.isFilter)
                    AppStyles.isWebScreen(context)
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 16),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final isMobile = screenWidth < 600;

                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.start,
                                  children: [
                                    // Status filter
                                    Container(
                                      width: isMobile
                                          ? constraints.maxWidth
                                          : null,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: reportsProvider
                                                            .selectedStatus !=
                                                        null &&
                                                    reportsProvider
                                                            .selectedStatus !=
                                                        0
                                                ? AppColors.primaryBlue
                                                : Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Status: '),
                                          Expanded(
                                            child: DropdownButton<int>(
                                              value: reportsProvider
                                                  .selectedStatus,
                                              hint: const Text('All'),
                                              isExpanded: true,
                                              items: [
                                                    const DropdownMenuItem<int>(
                                                      value: 0,
                                                      child: Text(
                                                        'All',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ] +
                                                  provider.followUpData
                                                      .map((status) =>
                                                          DropdownMenuItem<int>(
                                                            value:
                                                                status.statusId,
                                                            child: Text(
                                                              status.statusName ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ))
                                                      .toList(),
                                              onChanged: (int? newValue) {
                                                if (newValue != null) {
                                                  reportsProvider
                                                      .setStatus(newValue);
                                                }
                                                String status = reportsProvider
                                                    .selectedStatus
                                                    .toString();
                                                String assignedTo =
                                                    reportsProvider.selectedUser
                                                        .toString();
                                                String fromDate =
                                                    reportsProvider
                                                        .formattedFromDate;
                                                String toDate = reportsProvider
                                                    .formattedToDate;
                                                String taskType =
                                                    reportsProvider
                                                        .selectedTaskType
                                                        .toString();

                                                reportsProvider
                                                    .setTaskSearchCriteria(
                                                  reportsProvider.Search,
                                                  fromDate,
                                                  toDate,
                                                  status,
                                                  assignedTo,
                                                  taskType,
                                                );
                                                reportsProvider
                                                    .searchTaskByCustomer(
                                                        context);
                                              },
                                              underline: Container(),
                                              isDense: true,
                                              iconSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Date filter
                                    Container(
                                      width: isMobile
                                          ? constraints.maxWidth
                                          : null,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: reportsProvider.fromDate !=
                                                        null ||
                                                    reportsProvider.toDate !=
                                                        null
                                                ? AppColors.primaryBlue
                                                : Colors.grey[300]!),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          onClickTopButton(context);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (reportsProvider.fromDate ==
                                                    null &&
                                                reportsProvider.toDate == null)
                                              const Expanded(
                                                  child: Text('Date: All',
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                            if (reportsProvider.fromDate !=
                                                    null &&
                                                reportsProvider.toDate != null)
                                              Expanded(
                                                child: Text(
                                                  'Date: ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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

                                    // Staff filter
                                    Container(
                                      width: isMobile
                                          ? constraints.maxWidth
                                          : null,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color:
                                                reportsProvider.selectedUser !=
                                                            null &&
                                                        reportsProvider
                                                                .selectedUser !=
                                                            0
                                                    ? AppColors.primaryBlue
                                                    : Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Staff: '),
                                          Expanded(
                                            child: DropdownButton<int>(
                                              value:
                                                  reportsProvider.selectedUser,
                                              hint: const Text('All'),
                                              isExpanded: true,
                                              items: [
                                                    const DropdownMenuItem<int>(
                                                      value: 0,
                                                      child: Text(
                                                        'All',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ] +
                                                  provider.searchUserDetails
                                                      .map((status) =>
                                                          DropdownMenuItem<int>(
                                                            value: status
                                                                .userDetailsId,
                                                            child: Text(
                                                              status.userDetailsName ??
                                                                  '',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ))
                                                      .toList(),
                                              onChanged: (int? newValue) {
                                                if (newValue != null) {
                                                  reportsProvider
                                                      .setUserFilterStatus(
                                                          newValue);
                                                }
                                                String status = reportsProvider
                                                    .selectedStatus
                                                    .toString();
                                                String assignedTo =
                                                    reportsProvider.selectedUser
                                                        .toString();
                                                String fromDate =
                                                    reportsProvider
                                                        .formattedFromDate;
                                                String toDate = reportsProvider
                                                    .formattedToDate;
                                                String taskType =
                                                    reportsProvider
                                                        .selectedTaskType
                                                        .toString();

                                                reportsProvider
                                                    .setTaskSearchCriteria(
                                                  reportsProvider.Search,
                                                  fromDate,
                                                  toDate,
                                                  status,
                                                  assignedTo,
                                                  taskType,
                                                );
                                                reportsProvider
                                                    .searchTaskByCustomer(
                                                        context);
                                              },
                                              underline: Container(),
                                              isDense: true,
                                              iconSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Task Type filter
                                    Container(
                                      width: isMobile
                                          ? constraints.maxWidth
                                          : null,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: reportsProvider
                                                            .selectedTaskType !=
                                                        null &&
                                                    reportsProvider
                                                            .selectedTaskType !=
                                                        0
                                                ? AppColors.primaryBlue
                                                : Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Task Type: '),
                                          Expanded(
                                            child: DropdownButton<int>(
                                              value: reportsProvider
                                                  .selectedTaskType,
                                              hint: const Text('All'),
                                              isExpanded: true,
                                              items: [
                                                    const DropdownMenuItem<int>(
                                                      value: 0,
                                                      child: Text(
                                                        'All',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ] +
                                                  provider.taskType
                                                      .map((status) =>
                                                          DropdownMenuItem<int>(
                                                            value: status
                                                                .taskTypeId,
                                                            child: Text(
                                                              status
                                                                  .taskTypeName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ))
                                                      .toList(),
                                              onChanged: (int? newValue) {
                                                if (newValue != null) {
                                                  reportsProvider
                                                      .setTaskType(newValue);
                                                }
                                                String status = reportsProvider
                                                    .selectedStatus
                                                    .toString();
                                                String assignedTo =
                                                    reportsProvider.selectedUser
                                                        .toString();
                                                String fromDate =
                                                    reportsProvider
                                                        .formattedFromDate;
                                                String toDate = reportsProvider
                                                    .formattedToDate;
                                                String tasktype =
                                                    reportsProvider
                                                        .selectedTaskType
                                                        .toString();

                                                reportsProvider
                                                    .setTaskSearchCriteria(
                                                  reportsProvider.Search,
                                                  fromDate,
                                                  toDate,
                                                  status,
                                                  assignedTo,
                                                  tasktype,
                                                );
                                                reportsProvider
                                                    .searchTaskByCustomer(
                                                        context);
                                              },
                                              underline: Container(),
                                              isDense: true,
                                              iconSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Reset button - only shown when filters are active
                                    if (reportsProvider.fromDate != null ||
                                        reportsProvider.toDate != null ||
                                        (reportsProvider.selectedStatus !=
                                                null &&
                                            reportsProvider.selectedStatus !=
                                                0) ||
                                        (reportsProvider.selectedUser != null &&
                                            reportsProvider.selectedUser !=
                                                0) ||
                                        (reportsProvider.selectedTaskType !=
                                                null &&
                                            reportsProvider.selectedTaskType !=
                                                0) ||
                                        reportsProvider.Search.isNotEmpty)
                                      Container(
                                        width: isMobile
                                            ? constraints.maxWidth
                                            : null,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            reportsProvider
                                                .selectDateFilterOption(null);
                                            reportsProvider.removeStatus();
                                            searchController.clear();
                                            reportsProvider
                                                .setTaskSearchCriteria(
                                              '',
                                              '',
                                              '',
                                              '',
                                              '',
                                              '',
                                            );
                                            reportsProvider
                                                .searchTaskByCustomer(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppColors.textRed,
                                            side: BorderSide(
                                                color: AppColors.textRed),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text('Reset'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8.0, // horizontal spacing between items
                              runSpacing: 8.0, // vertical spacing between lines
                              alignment: WrapAlignment.start,
                              children: [
                                StatusDropdownWidget<int>(
                                  containerWidth:
                                      MediaQuery.sizeOf(context).width / 1.1,
                                  statusName: 'Status',
                                  items: [0] +
                                      provider.followUpData
                                          .map((status) => status.statusId ?? 0)
                                          .toList(),
                                  initialValue: leadProvider.selectedStatus,
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setStatus(newValue);
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

                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
                                    );
                                    reportsProvider
                                        .searchTaskByCustomer(context);
                                  },
                                  displayStringFor: (int statusId) {
                                    if (statusId == 0) return 'All';

                                    final status = provider.followUpData
                                        .firstWhere(
                                            (status) =>
                                                status.statusId == statusId,
                                            orElse: () => SearchLeadStatusModel(
                                                statusId: statusId,
                                                statusName: "Unknown"));

                                    return status.statusName ?? 'Unknown';
                                  },
                                  areItemsEqual: (a, b) => a == b,
                                  label: 'Status',
                                ),
                                Consumer<TaskPageProvider>(
                                  builder: (context, reportsProvider, child) {
                                    return GestureDetector(
                                      onTap: () {
                                        onClickTopButton(context);
                                      },
                                      child: Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.scaffoldColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 230),
                                                  child: CustomText(
                                                    reportsProvider.fromDate ==
                                                                null &&
                                                            reportsProvider
                                                                    .toDate ==
                                                                null
                                                        ? 'Date'
                                                        : reportsProvider
                                                                        .fromDate !=
                                                                    null &&
                                                                reportsProvider
                                                                        .toDate !=
                                                                    null
                                                            ? 'Date : ${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}'
                                                            : "Date",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textBlack,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: AppColors.textGrey3,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                StatusDropdownWidget<int>(
                                  containerWidth:
                                      MediaQuery.sizeOf(context).width / 2.5,
                                  statusName: 'Assigned staff',
                                  items: [0] +
                                      provider.searchUserDetails
                                          .map((status) =>
                                              status.userDetailsId ?? 0)
                                          .toList(),
                                  initialValue: leadProvider.selectedUser,
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider
                                          .setUserFilterStatus(newValue);
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

                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      taskType,
                                    );
                                    reportsProvider
                                        .searchTaskByCustomer(context);
                                  },
                                  displayStringFor: (int statusId) {
                                    if (statusId == 0) return 'All';

                                    final status = provider.searchUserDetails
                                        .firstWhere(
                                            (status) =>
                                                status.userDetailsId ==
                                                statusId,
                                            orElse: () => SearchUserDetails(
                                                userDetailsId: 0,
                                                userDetailsName: ''));

                                    return status.userDetailsName ?? 'Unknown';
                                  },
                                  areItemsEqual: (a, b) => a == b,
                                  label: 'All Staff',
                                ),
                                StatusDropdownWidget<int>(
                                  containerWidth:
                                      MediaQuery.sizeOf(context).width / 2.5,
                                  statusName: 'Task Type',
                                  items: [0] +
                                      provider.taskType
                                          .map((status) =>
                                              status.taskTypeId ?? 0)
                                          .toList(),
                                  initialValue: leadProvider.selectedEnquiryFor,
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setTaskType(newValue);
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

                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      fromDate,
                                      toDate,
                                      status,
                                      assignedTo,
                                      tasktype,
                                    );
                                    reportsProvider
                                        .searchTaskByCustomer(context);
                                  },
                                  displayStringFor: (int statusId) {
                                    if (statusId == 0) return 'All';

                                    final status = provider.taskType.firstWhere(
                                        (status) =>
                                            status.taskTypeId == statusId,
                                        orElse: () => TaskTypeModel(
                                              locationTracking: 0,
                                              taskTypeId: 0,
                                              taskTypeName: '',
                                              taskTypeColor: '',
                                              taskTypeImage: '',
                                              deleteStatus: 0,
                                              departmentIds: '',
                                              branchIds: '',
                                              defaultStatusId: 0,
                                              duration: 0,
                                              conversionTask: 0,
                                              statuses: [],
                                              departmentName: '',
                                            ));

                                    return status.taskTypeName ?? '';
                                  },
                                  areItemsEqual: (a, b) => a == b,
                                  label: 'Task Type',
                                ),
                              ],
                            ),
                          ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.all(!AppStyles.isWebScreen(context) ? 0 : 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (!AppStyles.isWebScreen(context))
                          const SizedBox()
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 90, 69),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 25.0),
                                    child: Text('No.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFFFFFF))),
                                  ),
                                ),
                                TableWidget(
                                    flex: 2,
                                    title: 'Customer',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 1,
                                    title: 'Task',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 1,
                                    title: 'Staff',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 2,
                                    title: 'Description',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 1,
                                    title: 'Date',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 1,
                                    title: 'Status',
                                    color: const Color(0xFFFFFFFF)),
                                TableWidget(
                                    flex: 1,
                                    title: 'Details',
                                    color: const Color(0xFFFFFFFF)),
                              ],
                            ),
                          ),

                        // Data Rows - with proper error handling
                        Expanded(
                          child: reportsProvider.taskReport.isEmpty
                              ? const Center(child: Text("No tasks found"))
                              : ListView.builder(
                                  controller:
                                      _scrollController, // Add this line

                                  shrinkWrap: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: reportsProvider.taskReport.length +
                                      (_isLoadingMore &&
                                              !AppStyles.isWebScreen(context)
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    // Show loading indicator at bottom for mobile
                                    if (!AppStyles.isWebScreen(context) &&
                                        index ==
                                            reportsProvider.taskReport.length &&
                                        _isLoadingMore) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 8),
                                            CustomText(
                                              'Loading more tasks...',
                                              fontSize: 12,
                                              color: AppColors.textGrey2,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    var task =
                                        reportsProvider.taskReport[index];

                                    final itemNumber =
                                        ((reportsProvider.pageIndex ?? 1) - 1) *
                                                (reportsProvider.pageSize ??
                                                    10) +
                                            index +
                                            1;

                                    if (!AppStyles.isWebScreen(context)) {
                                      Color statusColor = task.taskStatusName ==
                                              "Completed"
                                          ? Colors.green
                                          : task.taskStatusName == "In Progress"
                                              ? Colors.orange
                                              : Colors.red;
                                      return Column(
                                        children: [
                                          Divider(
                                            height: 2,
                                            color: AppColors.grey,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              reportsProvider
                                                  .selectedTaskTypeIds
                                                  .clear();
                                              reportsProvider.taskTypeModel
                                                  .clear();
                                              if (AppStyles.isWebScreen(
                                                  context)) {
                                                statusDialog(task)
                                                    .then((value) {
                                                  if (value == true) {
                                                    reportsProvider
                                                        .searchTaskByCustomer(
                                                            context);
                                                  }
                                                });
                                              } else {
                                                statusDialogMobile(task)
                                                    .then((value) {
                                                  if (value == true) {
                                                    reportsProvider
                                                        .searchTaskByCustomer(
                                                            context);
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                              color: AppColors.whiteColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              // context.push(
                                                              //     '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                              reportsProvider
                                                                  .selectedTaskTypeIds
                                                                  .clear();
                                                              reportsProvider
                                                                  .taskTypeModel
                                                                  .clear();
                                                              if (AppStyles
                                                                  .isWebScreen(
                                                                      context)) {
                                                                statusDialog(
                                                                        task)
                                                                    .then(
                                                                        (value) {
                                                                  if (value ==
                                                                      true) {
                                                                    reportsProvider
                                                                        .searchTaskByCustomer(
                                                                            context);
                                                                  }
                                                                });
                                                              } else {
                                                                statusDialogMobile(
                                                                        task)
                                                                    .then(
                                                                        (value) async {
                                                                  if (value ==
                                                                      true) {
                                                                    reportsProvider
                                                                        .searchTaskByCustomer(
                                                                            context);
                                                                  }
                                                                });
                                                              }
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                    height: 22,
                                                                    width: 3,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            statusColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16))),
                                                                // const SizedBox(
                                                                //     width: 8),
                                                                // Image.asset(
                                                                //   'assets/images/lead_profile.png',
                                                                //   width: 15,
                                                                //   height: 15,
                                                                //   errorBuilder: (context,
                                                                //           error,
                                                                //           stackTrace) =>
                                                                //       const Icon(
                                                                //           Icons
                                                                //               .person,
                                                                //           size: 10),
                                                                // ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Flexible(
                                                                    child:
                                                                        CustomText(
                                                                  task.customerName,
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textBlack,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        // Status container
                                                        if (task.taskStatusName
                                                            .isNotEmpty)
                                                          InkWell(
                                                            onTap: () {
                                                              reportsProvider
                                                                  .selectedTaskTypeIds
                                                                  .clear();
                                                              reportsProvider
                                                                  .taskTypeModel
                                                                  .clear();
                                                              if (AppStyles
                                                                  .isWebScreen(
                                                                      context)) {
                                                                statusDialog(
                                                                        task)
                                                                    .then(
                                                                        (value) {
                                                                  if (value ==
                                                                      true) {
                                                                    reportsProvider
                                                                        .searchTaskByCustomer(
                                                                            context);
                                                                  }
                                                                });
                                                              } else {
                                                                statusDialogMobile(
                                                                        task)
                                                                    .then(
                                                                        (value) {
                                                                  if (value ==
                                                                      true) {
                                                                    reportsProvider
                                                                        .searchTaskByCustomer(
                                                                            context);
                                                                  }
                                                                });
                                                              }
                                                            },
                                                            child: Container(
                                                                height: 22,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  color: (task.colorCode ??
                                                                          Colors
                                                                              .black)
                                                                      .withAlpha(
                                                                          20),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            2),
                                                                    child: Text(
                                                                      task.taskStatusName,
                                                                      style: GoogleFonts
                                                                          .plusJakartaSans(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: task.colorCode ??
                                                                            Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: _buildMobileInfoRow(
                                                              context,
                                                              task.taskTypeName,
                                                              ''),
                                                        ),

                                                        // Date (right/end)
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_today_outlined,
                                                              size: 14,
                                                              color: AppColors
                                                                  .textGrey2,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            CustomText(
                                                              task.entryDate
                                                                  .toDayMonthYearFormat(),
                                                              fontSize: 12,
                                                              color: AppColors
                                                                  .textGrey2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF6F7F9),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
                                                  child: Text(
                                                    itemNumber.toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                data: InkWell(
                                                  onTap: () {
                                                    if (task.customerId !=
                                                        null) {
                                                      context.push(
                                                          '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFE9EDF1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1700
                                                            ? Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/lead_profile.png',
                                                                    width: 15,
                                                                    height: 15,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        const Icon(
                                                                            Icons
                                                                                .person,
                                                                            size:
                                                                                15),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    task.customerName.length >
                                                                            20
                                                                        ? '${task.customerName.substring(0, 20)}...'
                                                                        : task.customerName ??
                                                                            'Unknown',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Image.asset(
                                                                    'assets/images/forward.png',
                                                                    width: 12,
                                                                    height: 12,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        const Icon(
                                                                            Icons
                                                                                .arrow_forward,
                                                                            size:
                                                                                12),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                task.customerName ??
                                                                    'Unknown',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title:
                                                      task.taskTypeName ?? ''),
                                              TableWidget(
                                                  flex: 1,
                                                  title: task.toUserName ?? ''),
                                              TableWidget(
                                                  flex: 2,
                                                  title:
                                                      task.description ?? ''),
                                              TableWidget(
                                                  flex: 1,
                                                  title: task.entryDate != null
                                                      ? task.entryDate
                                                          .toDayMonthYearFormat()
                                                      : ''),
                                              TableWidget(
                                                flex: 1,
                                                data: InkWell(
                                                  onTap: () {
                                                    reportsProvider
                                                        .selectedTaskTypeIds
                                                        .clear();
                                                    reportsProvider
                                                        .taskTypeModel
                                                        .clear();
                                                    if (AppStyles.isWebScreen(
                                                        context)) {
                                                      statusDialog(task)
                                                          .then((value) {
                                                        if (value == true) {
                                                          reportsProvider
                                                              .searchTaskByCustomer(
                                                                  context);
                                                        }
                                                      });
                                                    } else {
                                                      statusDialogMobile(task)
                                                          .then((value) {
                                                        if (value == true) {
                                                          reportsProvider
                                                              .searchTaskByCustomer(
                                                                  context);
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: task.taskStatusName !=
                                                                null &&
                                                            task.taskStatusName
                                                                .isNotEmpty
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 2)
                                                        : const EdgeInsets.all(
                                                            0),
                                                    decoration: BoxDecoration(
                                                      color: (task.colorCode ??
                                                              Colors.black)
                                                          .withAlpha(20),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: Colors.black45,
                                                          width: 0.1),
                                                    ),
                                                    child: Text(
                                                      task.taskStatusName ?? '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: task.colorCode ??
                                                            Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: CustomOutlinedSvgButton(
                                                  showIcon: false,
                                                  onPressed: () async {
                                                    final taskId = task
                                                            .taskMasterId
                                                            ?.toString() ??
                                                        '';
                                                    final customerId = task
                                                            .customerId
                                                            ?.toString() ??
                                                        '';
                                                    if (taskId.isNotEmpty) {
                                                      customerDetailsProvider
                                                          .getTaskDetails(
                                                              taskId, context);

                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return TaskDetailsWidget(
                                                            taskId: taskId,
                                                            customerId:
                                                                customerId,
                                                            showEdit: false,
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  svgPath:
                                                      'assets/images/Print.svg',
                                                  label: 'Details',
                                                  breakpoint: 860,
                                                  foregroundColor:
                                                      AppColors.primaryBlue,
                                                  backgroundColor: Colors.white,
                                                  borderSide: BorderSide(
                                                      color: AppColors
                                                          .primaryBlue),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
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
      bottomNavigationBar:
          buildResponsivePaginationControls(context, reportsProvider),
    );
  }

  Widget buildResponsivePaginationControls(
      BuildContext context, TaskPageProvider reportsProvider) {
    // Check if mobile
    if (!AppStyles.isWebScreen(context)) {
      return SizedBox();
      // Container(
      //   height: 60,
      //   padding: const EdgeInsets.all(10.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       // CustomText(
      //       //   "Page ${reportsProvider.pageIndex} of ${reportsProvider.totalPages}",
      //       //   fontSize: 12,
      //       //   color: AppColors.textGrey4,
      //       //   fontWeight: FontWeight.w500,
      //       // ),
      //       CustomText(
      //         "Total Tasks: ${reportsProvider.totalSize}",
      //         fontSize: 12,
      //         color: AppColors.textGrey4,
      //         fontWeight: FontWeight.w500,
      //       ),
      //     ],
      //   ),
      // );
    }

    return _buildPaginationControls(context, reportsProvider);
  }

// Helper function for mobile info rows with more robust implementation
  Widget _buildMobileInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: CustomText(
              label,
              fontSize: 12,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 12,
              color: AppColors.textGrey4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(
      BuildContext contex, TaskPageProvider reportsProvidert) {
    final pagination = Provider.of<TaskPageProvider>(context);

    final int currentPage = pagination.pageIndex;
    final int totalPages = pagination.totalPages;
    final int totalSize = pagination.totalSize;

    final TextEditingController sizeController =
        TextEditingController(text: pagination.pageSize.toString());

    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          alignment: Alignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Page Number Buttons
            Center(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: () {
                  List<Widget> pageButtons = [];

                  const int visiblePages = 5;
                  int startPage = currentPage - (visiblePages ~/ 2);
                  int endPage = currentPage + (visiblePages ~/ 2);

                  if (startPage < 1) {
                    endPage += (1 - startPage);
                    startPage = 1;
                  }
                  if (endPage > totalPages) {
                    startPage -= (endPage - totalPages);
                    endPage = totalPages;
                  }
                  if (startPage < 1) startPage = 1;

                  // Add starting ellipsis if needed
                  if (startPage > 1) {
                    pageButtons
                        .add(const Text("...", style: TextStyle(fontSize: 18)));
                  }

                  // Main page buttons
                  for (int i = startPage; i <= endPage; i++) {
                    pageButtons.add(
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            pagination.goToPage(i);
                            pagination.searchTaskByCustomer(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: currentPage == i
                                ? Colors.blue
                                : Colors.grey.shade300,
                            foregroundColor:
                                currentPage == i ? Colors.white : Colors.black,
                          ),
                          child: Text(
                            i.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }

                  // Add ending ellipsis if needed
                  if (endPage < totalPages) {
                    pageButtons
                        .add(const Text("...", style: TextStyle(fontSize: 18)));
                  }

                  return pageButtons;
                }(),
              ),
            ),

            Row(
              children: [
                CustomText(
                  "Total Tasks: $totalSize",
                  fontSize: 12,
                  color: AppColors.textGrey4,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future statusDialogMobile(TaskReportModel task) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessFlowDialog(task: task),
      ),
    );
  }

  Future statusDialog(TaskReportModel task) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // Get screen size for responsive design
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 600;
        final theme = Theme.of(context);

        // Create a future to fetch the status options
        final Future<List<TaskTypeStatusModel>> statusOptionsFuture =
            getStatusType(task.taskTypeId.toString());

        return Dialog(
          elevation: 5,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : 40.0,
            vertical: 24.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: isSmallScreen ? screenSize.width * 0.9 : 480,
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              // mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.update, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Update Status Text
                            const Text(
                              'Update Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Customer Name with tap functionality
                            InkWell(
                              onTap: () {
                                context.push(
                                    '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                              },
                              child: Text(
                                task.customerName ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Task Type Name
                            Text(
                              task.taskTypeName ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<TaskTypeStatusModel>>(
                  future: statusOptionsFuture,
                  builder: (contextBuilder, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Loading state
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading status options...',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Error state
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading status options',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading status options',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Success state - we have the data
                      final statusOptions = snapshot.data!;

                      // Find the current status in the options or default to first one
                      TaskTypeStatusModel defaultStatus =
                          statusOptions.firstWhere(
                        (status) => status.statusId == task.taskStatusId,
                        orElse: () => statusOptions.first,
                      );

                      int statusId = defaultStatus.statusId ?? 0;
                      int tasktypeId = defaultStatus.taskTypeId ?? 0;
                      int customerId = task.customerId ?? 0;
                      int enquiryForId = defaultStatus.enquiryForId ?? 0;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        reportsProvider.fetchTaskTypes(tasktypeId, statusId,
                            customerId, enquiryForId, context);
                      });

                      final ValueNotifier<TaskTypeStatusModel> selectedStatus =
                          ValueNotifier(defaultStatus);
                      final ValueNotifier<bool> isSaving = ValueNotifier(false);

                      return Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Status',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                                color: theme.cardColor,
                              ),
                              child:
                                  ValueListenableBuilder<TaskTypeStatusModel>(
                                valueListenable: selectedStatus,
                                builder: (ctx, value, child) {
                                  return DropdownButtonFormField<
                                      TaskTypeStatusModel>(
                                    value: value,
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: theme.primaryColor),
                                    dropdownColor: theme.cardColor,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onChanged:
                                        (TaskTypeStatusModel? newValue) async {
                                      if (newValue != null) {
                                        selectedStatus.value = newValue;
                                        int statusId =
                                            selectedStatus.value.statusId ?? 0;
                                        int tasktypeId =
                                            selectedStatus.value.taskTypeId ??
                                                0;
                                        int customerId = task.customerId ?? 0;
                                        int enquiryForId =
                                            selectedStatus.value.enquiryForId ??
                                                0;

                                        await reportsProvider.fetchTaskTypes(
                                            tasktypeId,
                                            statusId,
                                            customerId,
                                            enquiryForId,
                                            context);
                                      }
                                    },
                                    items: statusOptions.map<
                                        DropdownMenuItem<TaskTypeStatusModel>>(
                                      (TaskTypeStatusModel status) {
                                        Color statusColor =
                                            status.colorCode ?? Colors.black;

                                        return DropdownMenuItem<
                                            TaskTypeStatusModel>(
                                          value: status,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                margin: const EdgeInsets.only(
                                                    right: 12),
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(status.statusName ?? ''),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  );
                                },
                              ),
                            ),
                            Consumer<TaskPageProvider>(
                              builder: (context, reportsProvider, child) {
                                if (reportsProvider.taskTypeModel.isNotEmpty) {
                                  return Card(
                                    margin: const EdgeInsets.only(top: 12),
                                    // padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                    // decoration: BoxDecoration(
                                    //     color: Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(12)
                                    // ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(12),
                                                      topRight:
                                                          Radius.circular(12))),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'New Task',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: theme.textTheme
                                                        .bodyLarge?.color,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Department',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.textTheme
                                                      .bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          constraints: const BoxConstraints(
                                              maxHeight: 300),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: reportsProvider
                                                .taskTypeModel
                                                .map((task) {
                                              return CheckboxListTile(
                                                contentPadding:
                                                    const EdgeInsets.all(0),
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            task.taskTypeName)),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          task.departmentName ??
                                                              ""),
                                                    ),
                                                  ],
                                                ),
                                                value: reportsProvider
                                                    .selectedTaskTypeIds
                                                    .contains(task.taskTypeId
                                                        .toString()),
                                                onChanged: (bool? value) {
                                                  reportsProvider
                                                      .toggleTaskTypeSelection(
                                                          task.taskTypeId
                                                              .toString());
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Text("");
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Consumer<TaskPageProvider>(
                              builder: (context, reportsProvider, child) {
                                if (reportsProvider
                                    .documentTypeModel.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          'Pending Documents',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: theme
                                                .textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                            maxHeight: 300),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
                                          itemCount: reportsProvider
                                              .documentTypeModel.length,
                                          itemBuilder: (context, index) {
                                            var task = reportsProvider
                                                .documentTypeModel[index];
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              title: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Container(
                                                        width: 35,
                                                        child: Text(((index + 1)
                                                                .toString() +
                                                            " ) "))),
                                                  ),
                                                  Text(task.documentTypeName),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text("");
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Consumer<TaskPageProvider>(
                              builder: (context, reportsProvider, child) {
                                if (reportsProvider.statusData.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          'Mandatory tasks',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: theme
                                                .textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                            maxHeight: 300),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
                                          itemCount:
                                              reportsProvider.statusData.length,
                                          itemBuilder: (context, index) {
                                            var task = reportsProvider
                                                .statusData[index];
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              title: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Container(
                                                        width: 35,
                                                        child: Text(((index + 1)
                                                                .toString() +
                                                            " ) "))),
                                                  ),
                                                  Text(
                                                      "${task.taskTypeName}-${task.requiredStatuses}"),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text("");
                                }
                              },
                            ),
                            // Divider(height: 1),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<bool>(
                              valueListenable: isSaving,
                              builder: (ctx, saving, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: saving
                                          ? null
                                          : () {
                                              Navigator.of(context).pop(
                                                  false); // Return false for cancel
                                            },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        side: BorderSide(
                                            color: theme.dividerColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 12),
                                    Consumer<TaskPageProvider>(builder:
                                        (context, reportsProvider, child) {
                                      return ElevatedButton(
                                        onPressed: saving
                                            ? null
                                            : () async {
                                                // Check if there are required statuses that need to be completed
                                                if (reportsProvider
                                                    .statusData.isNotEmpty) {
                                                  // Get list of required statuses that aren't completed
                                                  List<String>
                                                      incompleteStatuses =
                                                      reportsProvider.statusData
                                                          .map((status) =>
                                                              "${status.taskTypeName}-${status.requiredStatuses}")
                                                          .toList();

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                24, 24, 24, 8),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                24, 0, 24, 16),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 10),
                                                        title: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .warning_amber_rounded,
                                                              color: AppColors
                                                                  .primaryBlue,
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            const Text(
                                                              "Required Status Incomplete",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Container(
                                                          width: 450,
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 400,
                                                                  maxHeight:
                                                                      700),
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            children: [
                                                              const Text(
                                                                "Any one of the following required statuses must be completed for the corresponding task before saving:",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              ...incompleteStatuses
                                                                  .map((status) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(Icons.error_outline,
                                                                                color: Colors.red,
                                                                                size: 18),
                                                                            const SizedBox(width: 8),
                                                                            Expanded(child: Text(status)),
                                                                          ],
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryBlue,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  return; // Stop execution here
                                                }

                                                if (reportsProvider
                                                    .documentTypeModel
                                                    .isEmpty) {
                                                  isSaving.value = true;
                                                  try {
                                                    bool isSuccess = await reportsProvider
                                                        .changeTaskStatus(
                                                            context,
                                                            selectedStatus
                                                                .value,
                                                            task.taskId,
                                                            task.locationTracking ==
                                                                    1
                                                                ? await reportsProvider
                                                                    .getCurrentLocation()
                                                                : null);
                                                    if (isSuccess) {
                                                      Future.microtask(() {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      });
                                                    } else {
                                                      isSaving.value = false;
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Failed to update status')),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    isSaving.value = false;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Failed to update status: ${e.toString()}')),
                                                    );
                                                  }
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                24, 24, 24, 8),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                24, 0, 24, 16),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 10),
                                                        title: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .warning_amber_rounded,
                                                              color: AppColors
                                                                  .primaryBlue,
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            const Text(
                                                              "Unable to Save",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: const Text(
                                                          "Documents Not Uploaded",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              foregroundColor:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryBlue,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          backgroundColor: theme.primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: saving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('Save'),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  } // Function to fetch status options from API

  Future<List<TaskTypeStatusModel>> getStatusType(String taskTypeId) async {
    return provider.getStatusByTaskTypeId(context, taskTypeId, '3');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<TaskPageProvider>(
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
                          reportsProvider.searchTaskByCustomer(context);
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
                          reportsProvider.searchTaskByCustomer(context);
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
