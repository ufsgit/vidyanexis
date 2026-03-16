// Check line 1776
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';

import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/home/add_task_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/task_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/utils/util_functions.dart';

class TaskPage extends StatefulWidget {
  final int? initialStatusFilter;
  const TaskPage({super.key, this.initialStatusFilter});

  @override
  State<TaskPage> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPage> {
  static const double rowHeight = 60.0;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  DropDownProvider provider = DropDownProvider();
  late TaskPageProvider reportsProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late bool _isMobile;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      reportsProvider = Provider.of<TaskPageProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      _updateScreenType();
      _setupScrollListener();
      reportsProvider.removeStatus();
      searchProvider.stopSearch();

      customerProvider.resetExpansion();

      if (widget.initialStatusFilter != null) {
        reportsProvider.setStatus(widget.initialStatusFilter!);
        reportsProvider.setTaskSearchCriteria(
            '', '', '', widget.initialStatusFilter.toString(), '', '');
      } else {
        reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
      }

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
    reportsProvider = Provider.of<TaskPageProvider>(context, listen: false);
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      reportsProvider.setTaskSearchCriteria(
        query,
        reportsProvider.fromDateS,
        reportsProvider.toDateS,
        reportsProvider.Status,
        reportsProvider.AssignedTo,
        reportsProvider.TaskType,
      );
      reportsProvider.goToPage(1);
      reportsProvider.searchTaskByCustomer(context, isShowLoader: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // Removed unused leadProvider

    final reportsProvider = Provider.of<TaskPageProvider>(context);

    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      backgroundColor:
          AppStyles.isWebScreen(context) ? null : AppColors.whiteColor,
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              leadingWidget: widget.initialStatusFilter != null
                  ? Builder(
                      builder: (context) => IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: InkWell(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Image.asset(
                              'assets/images/menu.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        );
                      },
                    ),
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
                      'Date': task.taskDate.isNotEmpty
                          ? DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(task.taskDate))
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
                reportsProvider.setFilterState(false);
                searchProvider.stopSearch();
                reportsProvider.selectDateFilterOption(null);
                reportsProvider.removeStatus();
                reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
                reportsProvider.goToPage(1);
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
                reportsProvider.goToPage(1);
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
              padding: AppStyles.isWebScreen(context)
                  ? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0)
                  : EdgeInsets.zero,
              child: Column(
                children: [
                  // Main row with adaptive layout

                  (AppStyles.isWebScreen(context))
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
                                      Row(
                                        children: [
                                          if (widget.initialStatusFilter !=
                                              null) ...[
                                            IconButton(
                                              icon: const Icon(Icons.arrow_back,
                                                  color: Color(0xFF152D70)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          const Text(
                                            'Tasks',
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Color(0xFF152D70),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                                                      (screenWidth > 860
                                                          ? 5
                                                          : 4),
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 1.5),
                                              ),
                                              child: TextField(
                                                controller: searchController,
                                                textAlignVertical:
                                                    TextAlignVertical.center,
                                                onChanged: _onSearchChanged,
                                                onSubmitted: (query) {
                                                  if (_debounce?.isActive ??
                                                      false)
                                                    _debounce!.cancel();
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
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 16,
                                                          right: 16,
                                                          bottom: 11),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      if (_debounce?.isActive ??
                                                          false)
                                                        _debounce!.cancel();
                                                      reportsProvider
                                                          .setTaskSearchCriteria(
                                                        searchController.text,
                                                        reportsProvider
                                                            .fromDateS,
                                                        reportsProvider.toDateS,
                                                        reportsProvider.Status,
                                                        reportsProvider
                                                            .AssignedTo,
                                                        reportsProvider
                                                            .TaskType,
                                                      );
                                                      reportsProvider.goToPage(1);
                                                      reportsProvider.searchTaskByCustomer(context);
                                                    },
                                                    child: const Icon(
                                                        Icons.search,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            Row(
                                              children: [
                                                // FILTER BUTTON
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    reportsProvider
                                                        .toggleFilter();
                                                  },
                                                  icon: const Icon(
                                                      Icons.filter_list),
                                                  label: const Text('Filter'),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        reportsProvider.isFilter
                                                            ? Colors.white
                                                            : AppColors
                                                                .primaryBlue,
                                                    backgroundColor:
                                                        reportsProvider.isFilter
                                                            ? const Color(
                                                                0xFF5499D9)
                                                            : Colors.white,
                                                    side: BorderSide(
                                                        color: reportsProvider
                                                                .isFilter
                                                            ? const Color(
                                                                0xFF5499D9)
                                                            : AppColors
                                                                .primaryBlue),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                // ÃƒÂ¢Ã…â€œÃ¢â‚¬Â¦ NEW TASK BUTTON (ADDED IN BETWEEN FILTER & EXPORT)
                                                // ElevatedButton.icon(
                                                //   onPressed: () {
                                                //     showDialog(
                                                //       context: context,
                                                //       builder: (_) =>
                                                //           const AddTaskWidget(
                                                //         taskId: 0,
                                                //       ),
                                                //     );
                                                //   },
                                                //   icon: const Icon(Icons.add),
                                                //   label: const Text('New Task'),
                                                //   style:
                                                //       ElevatedButton.styleFrom(
                                                //     backgroundColor:
                                                //         const Color(0xFFEAB308),
                                                //     foregroundColor:
                                                //         Colors.white,
                                                //     padding: const EdgeInsets
                                                //         .symmetric(
                                                //       horizontal: 16,
                                                //       vertical: 12,
                                                //     ),
                                                //   ),
                                                // ),
                                                // const SizedBox(width: 16),

                                                // Export button
                                                if (!isMobile ||
                                                    screenWidth > 400)
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
                                                            'Customer': task
                                                                .customerName,
                                                            'Task': task
                                                                .taskTypeName,
                                                            'Assigned To':
                                                                task.toUserName,
                                                            'Description': task
                                                                .description,
                                                            'Date': task
                                                                    .taskDate
                                                                    .isNotEmpty
                                                                ? DateFormat(
                                                                        'dd MMM yyyy')
                                                                    .format(DateTime
                                                                        .parse(task
                                                                            .taskDate))
                                                                : '',
                                                            'Status': task
                                                                .taskStatusName,
                                                          };
                                                        }).toList(),
                                                        fileName: 'Task',
                                                      );
                                                    },
                                                    buttonText:
                                                        screenWidth > 600
                                                            ? 'Export to Excel'
                                                            : 'Export',
                                                    textColor:
                                                        AppColors.whiteColor,
                                                    borderColor:
                                                        AppColors.appViolet,
                                                    backgroundColor:
                                                        AppColors.appViolet,
                                                  )
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        )
                      : const SizedBox(),

                  if (reportsProvider.isFilter)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Status filter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
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
                                  value: ([
                                                const DropdownMenuItem<int>(
                                                  value: 0,
                                                  child: Text(
                                                    'All',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ] +
                                              provider.followUpData
                                                  .map((status) =>
                                                      DropdownMenuItem<int>(
                                                        value: status.statusId,
                                                        child: ConstrainedBox(
                                                          constraints: const BoxConstraints(maxWidth: 150),
                                                          child: Text(
                                                            StatusUtils
                                                                .getDisplayStatus(
                                                                    status.statusName ??
                                                                        ''),
                                                            overflow: TextOverflow.ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 14),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList())
                                          .any((item) =>
                                              item.value ==
                                              reportsProvider.selectedStatus)
                                      ? reportsProvider.selectedStatus
                                      : 0,
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
                                      provider.followUpData
                                          .map((status) =>
                                              DropdownMenuItem<int>(
                                                value: status.statusId,
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 150),
                                                  child: Text(
                                                    StatusUtils.getDisplayStatus(
                                                        status.statusName ?? ''),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setStatus(newValue);
                                    }
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      reportsProvider.formattedFromDate,
                                      reportsProvider.formattedToDate,
                                      reportsProvider.selectedStatus.toString(),
                                      reportsProvider.selectedUser.toString(),
                                      reportsProvider.selectedTaskType
                                          .toString(),
                                    );
                                    reportsProvider.goToPage(1);
                                    reportsProvider.searchTaskByCustomer(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Date filter
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
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
                                  const SizedBox(width: 10),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
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
                                const Text('Staff: '),
                                DropdownButton<int>(
                                  value: ([
                                                const DropdownMenuItem<int>(
                                                  value: 0,
                                                  child: Text(
                                                    'All',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ] +
                                              provider.searchUserDetails
                                                  .map((user) =>
                                                      DropdownMenuItem<int>(
                                                        value:
                                                            user.userDetailsId,
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth:
                                                                      150),
                                                          child: Text(
                                                            user.userDetailsName ??
                                                                '',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList())
                                          .any((item) =>
                                              item.value ==
                                              reportsProvider.selectedUser)
                                      ? reportsProvider.selectedUser
                                      : 0,
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
                                      reportsProvider.selectedStatus.toString(),
                                      reportsProvider.selectedUser.toString(),
                                      reportsProvider.selectedTaskType
                                          .toString(),
                                    );
                                    reportsProvider.goToPage(1);
                                    reportsProvider.searchTaskByCustomer(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Task Type filter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
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
                                  value: ([
                                                const DropdownMenuItem<int>(
                                                  value: 0,
                                                  child: Text(
                                                    'All',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ] +
                                              provider.taskType
                                                  .map((type) =>
                                                      DropdownMenuItem<int>(
                                                        value: type.taskTypeId,
                                                        child: ConstrainedBox(
                                                          constraints: const BoxConstraints(maxWidth: 150),
                                                          child: Text(
                                                            type.taskTypeName,
                                                            overflow: TextOverflow.ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize: 14),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList())
                                          .any((item) =>
                                              item.value ==
                                              reportsProvider.selectedTaskType)
                                      ? reportsProvider.selectedTaskType
                                      : 0,
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
                                      provider.taskType
                                          .map((type) => DropdownMenuItem<int>(
                                                value: type.taskTypeId,
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 150),
                                                  child: Text(
                                                    type.taskTypeName,
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
                                      reportsProvider.setTaskType(newValue);
                                    }
                                    reportsProvider.setTaskSearchCriteria(
                                      reportsProvider.Search,
                                      reportsProvider.formattedFromDate,
                                      reportsProvider.formattedToDate,
                                      reportsProvider.selectedStatus.toString(),
                                      reportsProvider.selectedUser.toString(),
                                      reportsProvider.selectedTaskType
                                          .toString(),
                                    );
                                    reportsProvider.goToPage(1);
                                    reportsProvider.searchTaskByCustomer(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Reset button
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
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
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
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppStyles.isWebScreen(context)
                    ? const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 4.0)
                    : EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.isWebScreen(context)
                        ? BorderRadius.circular(14)
                        : BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: AppStyles.isWebScreen(context)
                        ? const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0)
                        : EdgeInsets.zero,
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
                                        vertical: 6.0, horizontal: 12.0),
                                    child: Text('No.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF))),
                                  ),
                                ),
                                TableWidget(
                                    flex: 2,
                                    title: 'Customer',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
                                TableWidget(
                                    flex: 2,
                                    title: 'Task',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
                                TableWidget(
                                    flex: 2,
                                    title: 'Staff',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
                                TableWidget(
                                    flex: 2,
                                    title: 'Description',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
                                TableWidget(
                                    flex: 1,
                                    title: 'Date',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
                                TableWidget(
                                    flex: 1,
                                    title: 'Status',
                                    fontSize: 12,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    color: Colors.white),
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

                                  shrinkWrap: false,
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
                                      return Column(
                                        children: [
                                          Divider(
                                            height: 2,
                                            color: AppColors.grey,
                                          ),
                                          TaskCard(
                                            task: task,
                                            isExpanded:
                                                reportsProvider.expandedIndex ==
                                                    index,
                                            onTap: () => reportsProvider
                                                .toggleExpansion(index),
                                            showStatusUpdate: (ctx, t) {
                                              reportsProvider
                                                  .selectedTaskTypeIds
                                                  .clear();
                                              reportsProvider.taskTypeModel
                                                  .clear();
                                              statusDialogMobile(t)
                                                  .then((value) {
                                                if (value == true) {
                                                  reportsProvider.goToPage(1);
                                                  reportsProvider
                                                      .searchTaskByCustomer(
                                                          context);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      return InkWell(
                                        onTap: () {
                                          reportsProvider.selectedTaskTypeIds
                                              .clear();
                                          reportsProvider.taskTypeModel.clear();
                                          if (task.customerName == null ||
                                              task.customerName!.isEmpty) {
                                            updateStatusDialogWithoutTask(task)
                                                .then((value) {
                                              if (value == true) {
                                                reportsProvider.goToPage(1);
                                                reportsProvider
                                                    .searchTaskByCustomer(
                                                        context);
                                              }
                                            });
                                          } else {
                                            if (AppStyles.isWebScreen(
                                                context)) {
                                              statusDialog(task).then((value) {
                                                if (value == true) {
                                                  reportsProvider.goToPage(1);
                                                  reportsProvider
                                                      .searchTaskByCustomer(
                                                          context);
                                                }
                                              });
                                            } else {
                                              statusDialogMobile(task)
                                                  .then((value) {
                                                if (value == true) {
                                                  reportsProvider.goToPage(1);
                                                  reportsProvider
                                                      .searchTaskByCustomer(
                                                          context);
                                                }
                                              });
                                            }
                                          }
                                        },
                                        hoverColor: const Color(0xFFF8FAFC),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          constraints: const BoxConstraints(
                                            minHeight: 15,
                                          ),
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
                                                      vertical: 6.0,
                                                      horizontal: 12.0),
                                                  child: Text(
                                                    itemNumber.toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: InkWell(
                                                  onTap: () {
                                                    if (task.customerId !=
                                                        null) {
                                                      context.push(
                                                          '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                    }
                                                  },
                                                  child: Text(
                                                    task.customerName ??
                                                        'Unknown',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2, // Changed from 1 to 2
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message:
                                                      task.taskTypeName ?? '',
                                                  child: Text(
                                                    task.taskTypeName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF334155),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Text(
                                                  task.toUserName ?? '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF334155),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message:
                                                      task.description ?? '',
                                                  child: Text(
                                                    task.description ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF334155),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 1,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Text(
                                                  task.taskDate != null
                                                      ? task.taskDate
                                                          .toDayMonthYearFormat()
                                                      : '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF334155),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 1,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: InkWell(
                                                  onTap: () {
                                                    reportsProvider
                                                        .selectedTaskTypeIds
                                                        .clear();
                                                    reportsProvider
                                                        .taskTypeModel
                                                        .clear();
                                                    if (task.customerName ==
                                                            null ||
                                                        task.customerName!
                                                            .isEmpty) {
                                                      updateStatusDialogWithoutTask(
                                                              task)
                                                          .then((value) {
                                                        if (value == true) {
                                                          reportsProvider
                                                              .goToPage(1);
                                                          reportsProvider
                                                              .searchTaskByCustomer(
                                                                  context);
                                                        }
                                                      });
                                                    } else {
                                                      if (AppStyles.isWebScreen(
                                                          context)) {
                                                        statusDialog(task)
                                                            .then((value) {
                                                          if (value == true) {
                                                            reportsProvider
                                                                .goToPage(1);
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
                                                                .goToPage(1);
                                                            reportsProvider
                                                                .searchTaskByCustomer(
                                                                    context);
                                                          }
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: StatusUtils
                                                              .getTaskColor(task
                                                                  .taskStatusId)
                                                          .withAlpha(40),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 2),
                                                        child: Text(
                                                          task.taskStatusName ??
                                                              '',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: StatusUtils
                                                                .getTaskTextColor(
                                                                    task.taskStatusId),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Expanded(
                                              //   child: Row(
                                              //     children: [
                                              //       OutlinedButton(
                                              //         onPressed: () async {
                                              //           final taskId = task
                                              //                   .taskId
                                              //                   ?.toString() ??
                                              //               '';
                                              //           final customerId = task
                                              //                   .customerId
                                              //                   ?.toString() ??
                                              //               '';
                                              //           if (taskId.isNotEmpty) {
                                              //             customerDetailsProvider
                                              //                 .getTaskDetails(
                                              //                     taskId,
                                              //                     context);

                                              //             showDialog(
                                              //               context: context,
                                              //               builder:
                                              //                   (BuildContext
                                              //                       context) {
                                              //                 return TaskDetailsWidget(
                                              //                   taskId: taskId,
                                              //                   customerId:
                                              //                       customerId,
                                              //                   showEdit: false,
                                              //                 );
                                              //               },
                                              //             );
                                              //           }
                                              //         },
                                              //         style: OutlinedButton
                                              //             .styleFrom(
                                              //           side: const BorderSide(
                                              //               color: Color(
                                              //                   0xFFEAB308)),
                                              //           foregroundColor:
                                              //               const Color(
                                              //                   0xFFEAB308),
                                              //           padding:
                                              //               const EdgeInsets
                                              //                   .symmetric(
                                              //                   horizontal: 12,
                                              //                   vertical: 0),
                                              //           minimumSize:
                                              //               const Size(0, 32),
                                              //           shape:
                                              //               RoundedRectangleBorder(
                                              //                   borderRadius:
                                              //                       BorderRadius
                                              //                           .circular(
                                              //                               4)),
                                              //         ),
                                              //         child: const Text(
                                              //             'Details',
                                              //             style: TextStyle(
                                              //                 fontSize: 12)),
                                              //       ),
                                              //       const SizedBox(width: 8),
                                              //       IconButton(
                                              //         icon: const Icon(
                                              //           Icons.edit_outlined,
                                              //           size: 18,
                                              //           color:
                                              //               Color(0xFFEAB308),
                                              //         ),
                                              //         tooltip: 'Edit',
                                              //         padding: EdgeInsets.zero,
                                              //         constraints:
                                              //             const BoxConstraints(),
                                              //         onPressed: () {
                                              //           showDialog(
                                              //             context: context,
                                              //             builder: (_) =>
                                              //                 AddTaskWidget(
                                              //               taskId: task
                                              //                   .taskMasterId,
                                              //             ),
                                              //           );
                                              //         },
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
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

  Widget _buildPaginationControls(
      BuildContext context, TaskPageProvider reportsProvider) {
    final int currentPage = reportsProvider.pageIndex;
    final int totalPages = reportsProvider.totalPages;
    final int totalSize = reportsProvider.totalSize;
    final int pageSize = reportsProvider.pageSize ?? 10;

    final int startItem = ((currentPage - 1) * pageSize) + 1;
    final int endItem = (currentPage * pageSize) > totalSize
        ? totalSize
        : (currentPage * pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Showing $startItem-$endItem of $totalSize",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        reportsProvider.goToPage(currentPage - 1);
                        reportsProvider.searchTaskByCustomer(context);
                      }
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: currentPage > 1
                    ? const Color(0xFFEAB308)
                    : const Color(0xFF64748B),
                tooltip: "Previous",
              ),
              const SizedBox(width: 16),
              Text(
                "Page $currentPage of $totalPages",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        reportsProvider.goToPage(currentPage + 1);
                        reportsProvider.searchTaskByCustomer(context);
                      }
                    : null,
                icon: const Icon(Icons.chevron_right, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: currentPage < totalPages
                    ? const Color(0xFFEAB308)
                    : const Color(0xFF64748B),
                tooltip: "Next",
              ),
            ],
          ),
          const Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Future<bool?> updateStatusDialogWithoutTask(TaskReportModel task) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 600;
        final theme = Theme.of(context);
        final Future<List<TaskTypeStatusModel>> statusOptionsFuture =
            getStatusType(task.taskTypeId.toString());
        final reportsProvider =
            Provider.of<TaskPageProvider>(context, listen: false);

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
                            const Text(
                              'Update Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.taskTypeName,
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
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child:
                            Center(child: Text('Error loading status options')),
                      );
                    } else {
                      final statusOptions = snapshot.data!;
                      TaskTypeStatusModel defaultStatus =
                          statusOptions.firstWhere(
                        (status) => status.statusId == task.taskStatusId,
                        orElse: () => statusOptions.first,
                      );

                      final ValueNotifier<TaskTypeStatusModel> selectedStatus =
                          ValueNotifier(defaultStatus);
                      final ValueNotifier<bool> isSaving = ValueNotifier(false);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        reportsProvider.clearDescription();
                      });

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
                                    ),
                                    onChanged: (TaskTypeStatusModel? newValue) {
                                      if (newValue != null) {
                                        selectedStatus.value = newValue;
                                      }
                                    },
                                    items: statusOptions.map((status) {
                                      Color statusColor =
                                          status.colorCode ?? Colors.black;
                                      return DropdownMenuItem(
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
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                            ValueListenableBuilder<TaskTypeStatusModel>(
                              valueListenable: selectedStatus,
                              builder: (ctx, status, child) {
                                if (status.followup == 1) {
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      dateFollowUpWidget(),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }
                                return const SizedBox(height: 16);
                              },
                            ),
                            Text(
                              'Description',
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
                              child: TextField(
                                controller:
                                    reportsProvider.descriptionController,
                                maxLines: 4,
                                minLines: 3,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  border: InputBorder.none,
                                  hintText: 'Enter description',
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: isSaving,
                              builder: (ctx, saving, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: saving
                                          ? null
                                          : () => Navigator.pop(context, false),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        side: BorderSide(
                                            color: theme.dividerColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: saving
                                          ? null
                                          : () async {
                                              isSaving.value = true;
                                              try {
                                                bool isSuccess =
                                                    await reportsProvider
                                                        .changeTaskStatus(
                                                  context,
                                                  selectedStatus.value,
                                                  task.taskId,
                                                  task.locationTracking == 1
                                                      ? await reportsProvider
                                                          .getCurrentLocation()
                                                      : null,
                                                );
                                                if (isSuccess) {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                } else {
                                                  isSaving.value = false;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Failed to update status')),
                                                  );
                                                }
                                              } catch (e) {
                                                isSaving.value = false;
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: saving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white)))
                                          : const Text('Save'),
                                    ),
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
        final theme = Theme.of(context);
        final isSmallScreen = MediaQuery.of(context).size.width < 600;

        // Create a future to fetch the status options
        final Future<List<TaskTypeStatusModel>> statusOptionsFuture =
            getStatusType(task.taskTypeId.toString());

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
              maxHeight: 700,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Dialog Header Redesign (Tab Style)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Text('Update Status',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        InkWell(
                          onTap: () {
                            context.push(
                                '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Text(task.customerName ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Text(task.taskTypeName ?? '',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: FutureBuilder<List<TaskTypeStatusModel>>(
                    future: statusOptionsFuture,
                    builder: (contextBuilder, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading status options',
                                style:
                                    TextStyle(color: theme.colorScheme.error),
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
                        final statusOptions = snapshot.data!;
                        TaskTypeStatusModel defaultStatus =
                            statusOptions.firstWhere(
                          (status) => status.statusId == task.taskStatusId,
                          orElse: () => statusOptions.first,
                        );

                        int statusId = defaultStatus.statusId ?? 0;
                        int tasktypeId = defaultStatus.taskTypeId ?? 0;
                        int customerId = task.customerId ?? 0;
                        int enquiryForId = task.enquiryForId ?? 0;
                        final reportsProvider = Provider.of<TaskPageProvider>(
                            context,
                            listen: false);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          reportsProvider.fetchTaskTypes(tasktypeId, statusId,
                              customerId, enquiryForId, context);
                          reportsProvider.clearDescription();
                        });

                        final ValueNotifier<TaskTypeStatusModel>
                            selectedStatus = ValueNotifier(defaultStatus);
                        final ValueNotifier<bool> isSaving =
                            ValueNotifier(false);

                        Widget formFields = Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Row 1: Current Status Dropdown
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child:
                                    ValueListenableBuilder<TaskTypeStatusModel>(
                                  valueListenable: selectedStatus,
                                  builder: (context, value, _) {
                                    return DropdownButtonFormField<
                                        TaskTypeStatusModel>(
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      value: value,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onChanged: (TaskTypeStatusModel?
                                          newValue) async {
                                        if (newValue != null) {
                                          selectedStatus.value = newValue;
                                          int sId = newValue.statusId ?? 0;
                                          int tId = newValue.taskTypeId ?? 0;
                                          await reportsProvider.fetchTaskTypes(
                                              tId,
                                              sId,
                                              customerId,
                                              enquiryForId,
                                              context);
                                        }
                                      },
                                      items: statusOptions.map((status) {
                                        return DropdownMenuItem(
                                          value: status,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                  color: status.colorCode ??
                                                      Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(status.statusName ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Row 2: New Task + Department
                              Consumer<TaskPageProvider>(
                                builder: (context, reportsProvider, child) {
                                  if (reportsProvider.taskTypeModel.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('New Task',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text('Department',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                            const Divider(height: 1),
                                            ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: reportsProvider
                                                  .taskTypeModel.length,
                                              itemBuilder: (context, index) {
                                                final taskItem = reportsProvider
                                                    .taskTypeModel[index];
                                                bool selected = reportsProvider
                                                    .selectedTaskTypeIds
                                                    .contains(taskItem
                                                        .taskTypeId
                                                        .toString());
                                                return InkWell(
                                                  onTap: () {
                                                    reportsProvider
                                                        .toggleTaskTypeSelection(
                                                            taskItem.taskTypeId
                                                                .toString());
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 18,
                                                              height: 18,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: selected
                                                                    ? AppColors
                                                                        .darkGreen
                                                                    : Colors
                                                                        .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                border: Border.all(
                                                                    color: selected
                                                                        ? AppColors
                                                                            .darkGreen
                                                                        : Colors
                                                                            .grey
                                                                            .shade400),
                                                              ),
                                                              child: selected
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check,
                                                                      size: 14,
                                                                      color: Colors
                                                                          .white)
                                                                  : null,
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                                taskItem.taskTypeName ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          ],
                                                        ),
                                                        Text(
                                                            taskItem.departmentName ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),

                              // Row 3: Follow-up Date + Pending Docs
                              ValueListenableBuilder<TaskTypeStatusModel>(
                                valueListenable: selectedStatus,
                                builder: (ctx, status, child) {
                                  return Consumer<TaskPageProvider>(
                                    builder: (context, reportsProvider, child) {
                                      bool showDate = status.followup == 1;
                                      bool hasDocs = reportsProvider
                                          .documentTypeModel.isNotEmpty;
                                      bool hasMandatory =
                                          reportsProvider.statusData.isNotEmpty;
                                      bool showRightList =
                                          hasDocs || hasMandatory;

                                      Widget leftSide = showDate
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Follow-up Date',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(height: 4),
                                                dateFollowUpWidget(),
                                              ],
                                            )
                                          : const SizedBox.shrink();

                                      Widget rightSide = showRightList
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Pending Documents',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(height: 4),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (hasDocs)
                                                        ...reportsProvider
                                                            .documentTypeModel
                                                            .asMap()
                                                            .entries
                                                            .map((e) => Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                                  child: Text(
                                                                      '${e.key + 1}. ${e.value.documentTypeName}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13)),
                                                                )),
                                                      if (hasMandatory)
                                                        ...reportsProvider
                                                            .statusData
                                                            .asMap()
                                                            .entries
                                                            .map((e) => Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                                  child: Text(
                                                                      '${e.key + 1 + (hasDocs ? reportsProvider.documentTypeModel.length : 0)}. ${e.value.taskTypeName}-${e.value.requiredStatuses}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13)),
                                                                )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink();

                                      if (!showDate && !showRightList)
                                        return const SizedBox.shrink();

                                      if (isSmallScreen) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (showDate) ...[
                                              leftSide,
                                              const SizedBox(height: 10)
                                            ],
                                            if (showRightList) ...[
                                              rightSide,
                                              const SizedBox(height: 10)
                                            ],
                                          ],
                                        );
                                      } else {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (showDate)
                                                  Expanded(child: leftSide),
                                                if (showDate && showRightList)
                                                  const SizedBox(width: 16),
                                                if (showRightList)
                                                  Expanded(child: rightSide),
                                                if (!showRightList && showDate)
                                                  const Expanded(
                                                      child: SizedBox()),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),

                              // Row 4: Description text area
                              Text('Description',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: Provider.of<TaskPageProvider>(
                                          context,
                                          listen: false)
                                      .descriptionController,
                                  maxLines: 2,
                                  minLines: 2,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    border: InputBorder.none,
                                    hintText: 'Enter description',
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isSmallScreen
                                ? Flexible(
                                    child: SingleChildScrollView(
                                        child: formFields))
                                : formFields, // No scrolling if large screen!

                            // Row 5: Action buttons aligned to right
                            ValueListenableBuilder<bool>(
                              valueListenable: isSaving,
                              builder: (ctx, saving, child) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 12, 20, 20),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        alignment: WrapAlignment.end,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.history,
                                                size: 16),
                                            label: const Text("History"),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            onPressed: () async {
                                              final provider =
                                                  Provider.of<TaskPageProvider>(
                                                      context,
                                                      listen: false);
                                              await provider.fetchTaskHistory(
                                                  task.userDetailsId ?? 0);
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return Dialog(
                                                    insetPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16,
                                                            vertical: 24),
                                                    child: Container(
                                                      width: 500,
                                                      height: 400,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Task History",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                          Expanded(
                                                            child: Consumer<
                                                                TaskPageProvider>(
                                                              builder: (_,
                                                                  provider,
                                                                  __) {
                                                                if (provider
                                                                    .isHistoryLoading) {
                                                                  return const Center(
                                                                      child:
                                                                          CircularProgressIndicator());
                                                                }
                                                                if (provider
                                                                    .taskHistoryList
                                                                    .isEmpty) {
                                                                  return const Center(
                                                                      child: Text(
                                                                          "No history found."));
                                                                }
                                                                return ListView
                                                                    .builder(
                                                                  itemCount: provider
                                                                      .taskHistoryList
                                                                      .length,
                                                                  itemBuilder:
                                                                      (_, index) {
                                                                    final item =
                                                                        provider
                                                                            .taskHistoryList[index];
                                                                    return Card(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              12),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(item.statusName ?? '',
                                                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                            const SizedBox(height: 6),
                                                                            Text(item.description ??
                                                                                ''),
                                                                            const SizedBox(height: 6),
                                                                            Text("By: ${item.byUserName ?? ''}",
                                                                                style: const TextStyle(fontSize: 12)),
                                                                            Text(item.entryDate ?? '',
                                                                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: const Text(
                                                                  "Close"),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              int statusId = selectedStatus
                                                      .value.statusId ??
                                                  0;
                                              int tasktypeId = selectedStatus
                                                      .value.taskTypeId ??
                                                  0;
                                              int customerId =
                                                  task.customerId ?? 0;
                                              int enquiryForId =
                                                  task.enquiryForId ?? 0;
                                              await showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) =>
                                                    ImageUploadAlert(
                                                        customerId: customerId
                                                            .toString()),
                                              );
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                Provider.of<TaskPageProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchTaskTypes(
                                                        tasktypeId,
                                                        statusId,
                                                        customerId,
                                                        enquiryForId,
                                                        context);
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            child:
                                                const Text("Upload Documents"),
                                          ),
                                          OutlinedButton(
                                            onPressed: saving
                                                ? null
                                                : () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: saving
                                                ? null
                                                : () async {
                                                    final provider = Provider
                                                        .of<TaskPageProvider>(
                                                            context,
                                                            listen: false);
                                                    if (provider.statusData
                                                        .isNotEmpty) {
                                                      List<String>
                                                          incompleteStatuses =
                                                          provider.statusData
                                                              .map((status) =>
                                                                  "${status.taskTypeName}-${status.requiredStatuses}")
                                                              .toList();
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            titlePadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    24,
                                                                    24,
                                                                    24,
                                                                    8),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    24,
                                                                    0,
                                                                    24,
                                                                    16),
                                                            actionsPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            title: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .warning_amber_rounded,
                                                                    color: AppColors
                                                                        .darkGreen),
                                                                const SizedBox(
                                                                    width: 10),
                                                                const Text(
                                                                    "Required Status Incomplete",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20)),
                                                              ],
                                                            ),
                                                            content: Container(
                                                              width: 450,
                                                              constraints:
                                                                  const BoxConstraints(
                                                                      maxWidth:
                                                                          400,
                                                                      maxHeight:
                                                                          700),
                                                              child: ListView(
                                                                shrinkWrap:
                                                                    true,
                                                                children: [
                                                                  const Text(
                                                                      "Any one of the following required statuses must be completed for the corresponding task before saving:",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16)),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  ...incompleteStatuses
                                                                      .map((s) =>
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 8.0),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                                                                const SizedBox(width: 8),
                                                                                Expanded(child: Text(s)),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .darkGreen,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child:
                                                                    const Text(
                                                                        "OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      return;
                                                    }

                                                    if (provider
                                                        .documentTypeModel
                                                        .isEmpty) {
                                                      isSaving.value = true;
                                                      try {
                                                        bool isSuccess = await provider
                                                            .changeTaskStatus(
                                                                context,
                                                                selectedStatus
                                                                    .value,
                                                                task.taskId,
                                                                task.locationTracking ==
                                                                        1
                                                                    ? await provider
                                                                        .getCurrentLocation()
                                                                    : null);

                                                        if (!context.mounted)
                                                          return;

                                                        if (isSuccess) {
                                                          Navigator.pop(
                                                              context, true);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Task status updated successfully")));
                                                        } else {
                                                          isSaving.value =
                                                              false;
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Failed to update status")));
                                                        }
                                                      } catch (e) {
                                                        if (!context.mounted)
                                                          return;
                                                        isSaving.value = false;
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        "Server timeout. Try again")));
                                                      }
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            titlePadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    24,
                                                                    24,
                                                                    24,
                                                                    8),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    24,
                                                                    0,
                                                                    24,
                                                                    16),
                                                            actionsPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            title: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .warning_amber_rounded,
                                                                    color: AppColors
                                                                        .darkGreen),
                                                                const SizedBox(
                                                                    width: 10),
                                                                const Text(
                                                                    "Unable to Save",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20)),
                                                              ],
                                                            ),
                                                            content: const Text(
                                                                "Documents Not Uploaded",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16)),
                                                            actions: [
                                                              TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .darkGreen,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8)),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child:
                                                                    const Text(
                                                                        "OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 10),
                                              backgroundColor:
                                                  AppColors.darkGreen,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: saving
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white)),
                                                  )
                                                : const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to fetch status options from API

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
                          reportsProvider.goToPage(1);
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
                          reportsProvider.goToPage(1);
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

  Widget dateFollowUpWidget() {
    final taskProvider = Provider.of<TaskPageProvider>(context, listen: false);
    final theme = Theme.of(context);
    taskProvider.followUpDateController.clear();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow-up Date',
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
          child: TextField(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                taskProvider.followUpDateController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
            readOnly: true,
            controller: taskProvider.followUpDateController,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: 'Enter Follow-up Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
