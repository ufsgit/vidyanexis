// Check line 1776
import 'package:vidyanexis/controller/models/priority_model.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_dialog.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_form_filler_view.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield_search.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';

import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
import 'package:vidyanexis/presentation/widgets/home/expandable_fab_button.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/job_sheet_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/home/task_card.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_multi_level_dropdown.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';

class TaskPage extends StatefulWidget {
  final int? initialStatusFilter;
  const TaskPage({super.key, this.initialStatusFilter});

  @override
  State<TaskPage> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();
  final FocusNode staffFocusNode = FocusNode();
  DropDownProvider provider = DropDownProvider();
  late TaskPageProvider reportsProvider;
  final ScrollController _scrollController = ScrollController();
  late final ScrollController _horizontalScrollController = ScrollController();
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
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadProvider.searchUserController.clear();

      _updateScreenType();
      _setupScrollListener();
      reportsProvider.removeStatus();
      searchProvider.stopSearch();

      customerProvider.resetExpansion();

      if (widget.initialStatusFilter != null) {
        reportsProvider.setStatus(widget.initialStatusFilter!);
        reportsProvider.setTaskSearchCriteria(
            '', '', '', widget.initialStatusFilter.toString(), '', '', '');
      } else {
        reportsProvider.setTaskSearchCriteria('', '', '', '', '', '', '');
      }

      reportsProvider.searchTaskByCustomer(context);
      provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "3");
      provider.getEnquiryFor(context);

      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      provider.getEnquirySource(context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchsourceCategoryData('', context);
      settingsProvider.searchPermission(context);
      provider.getDistricts(context);
      provider.getStatesDropdown(context);
      settingsProvider.getPriorities(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScreenType();
    reportsProvider = Provider.of<TaskPageProvider>(context, listen: false);
  }

  void _openTaskDialog(
      TaskReportModel task, TaskTypeModel taskType, SearchUserDetails user) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    customerDetailsProvider.customerId = task.customerId.toString();
    customerDetailsProvider.clearTaskDetails();

    // Pre-populate data
    customerDetailsProvider.updateTaskType(
        taskType.taskTypeId, taskType.taskTypeName);
    final userInTask = UserInTaskModel(
        userDetailsId: user.userDetailsId,
        userDetailsName: user.userDetailsName);
    customerDetailsProvider.addAssignedWorker(userInTask);

    // Open Dialog
    if (AppStyles.isWebScreen(context)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: TaskCreationWidget(isEdit: false, taskId: '0'),
        ),
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddTaskMobile(isEdit: false, taskId: '0')));
    }
  }

  Future<void> _quickSaveTask(TaskReportModel task, TaskTypeModel taskType,
      SearchUserDetails user) async {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    customerDetailsProvider.customerId = task.customerId.toString();
    customerDetailsProvider.clearTaskDetails();

    // Set task type
    customerDetailsProvider.updateTaskType(
        taskType.taskTypeId, taskType.taskTypeName);

    // Set default AMC status if any
    final defaultStatusId = taskType.defaultStatusId;
    customerDetailsProvider.updateAMCStatus(
        defaultStatusId != 0 ? defaultStatusId : 1, '');

    // Set user
    final userInTask = UserInTaskModel(
        userDetailsId: user.userDetailsId,
        userDetailsName: user.userDetailsName);
    customerDetailsProvider.addAssignedWorker(userInTask);

    // Perform save task
    await customerDetailsProvider.saveTask(
      '0',
      '0',
      taskType.taskTypeId.toString(),
      '', // description
      DateFormat('dd MMM yyyy').format(
          DateTime.now().add(Duration(days: taskType.duration))), // date
      DateFormat('HH:mm').format(DateTime.now()), // time
      user.userDetailsId.toString(), // assignedWorker
      context,
      false, // isEdit
      [], // audioFiles
      dismissDialog: false,
    );

    if (mounted) {
      reportsProvider.searchTaskByCustomer(context);
    }
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
        reportsProvider.enquiryForS,
      );
      reportsProvider.goToPage(1);
      reportsProvider.searchTaskByCustomer(context, isShowLoader: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final double rowHeight = AppStyles.isWebScreen(context) ? 36.0 : 48.0;
    // Removed unused leadProvider

    final reportsProvider = Provider.of<TaskPageProvider>(context);

    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor:
          AppStyles.isWebScreen(context) ? null : AppColors.scaffoldColor,
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              leadingWidget: widget.initialStatusFilter != null
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  : null,
              onExcelTap: () async {
                await reportsProvider.fetchTasksForExport(context);
              },
              showExcel: false,
              showLogo: false,
              showUserName: false,
              showFilterIcon: false,
              showSort: true,
              onSortTap: (value) {
                reportsProvider.setSortOption(value, context);
              },
              showOrder: true,
              sortOrder: reportsProvider.sortOrder,
              onOrderTap: () {
                reportsProvider.toggleSortOrder(context);
              },
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
                reportsProvider.setTaskSearchCriteria(
                    '', '', '', '', '', '', '');
                reportsProvider.goToPage(1);
                reportsProvider.searchTaskByCustomer(context);
              },
              title: 'Tasks',
              onSearch: (String query) {
                print('Searching for: $query');
                if (AppStyles.isWebScreen(context)) {
                  reportsProvider.setTaskSearchCriteria(
                    query,
                    reportsProvider.fromDateS,
                    reportsProvider.toDateS,
                    reportsProvider.Status,
                    reportsProvider.AssignedTo,
                    reportsProvider.TaskType,
                    reportsProvider.enquiryForS,
                  );
                } else {
                  reportsProvider.setTaskSearchCriteria(
                    query,
                    reportsProvider.fromDateS,
                    reportsProvider.toDateS,
                    reportsProvider.Status,
                    reportsProvider.AssignedTo,
                    reportsProvider.TaskType,
                    reportsProvider.enquiryForS,
                  );
                }

                reportsProvider.searchTaskByCustomer(context);
              },
              onChanged: _onSearchChanged,
              searchController: searchController,
              customActionWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: reportsProvider.entryType == 'all' ? 'ALL' : 'ME',
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryBlue),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        reportsProvider
                            .setEntryType(newValue == 'ALL' ? 'all' : 'myown');
                        reportsProvider.goToPage(1);
                        reportsProvider.searchTaskByCustomer(context);
                      }
                    },
                    items: <String>['ME', 'ALL']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          : null,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      body: Container(
        color: AppStyles.isWebScreen(context)
            ? Colors.grey[50]
            : AppColors.scaffoldColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Header
            // AppStyles.isWebScreen(context)
            //     ?

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: AppStyles.isWebScreen(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.initialStatusFilter != null) ...[
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBlue
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Entry Type Filter
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    reportsProvider.setEntryType('myown');
                                    reportsProvider.goToPage(1);
                                    reportsProvider
                                        .searchTaskByCustomer(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              reportsProvider.entryType != 'all'
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'ME',
                                      style: TextStyle(
                                        color:
                                            reportsProvider.entryType != 'all'
                                                ? AppColors.primaryBlue
                                                : Colors.grey,
                                        fontWeight:
                                            reportsProvider.entryType != 'all'
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    reportsProvider.setEntryType('all');
                                    reportsProvider.goToPage(1);
                                    reportsProvider
                                        .searchTaskByCustomer(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              reportsProvider.entryType == 'all'
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        color:
                                            reportsProvider.entryType == 'all'
                                                ? AppColors.primaryBlue
                                                : Colors.grey,
                                        fontWeight:
                                            reportsProvider.entryType == 'all'
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 280,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                focusNode: searchFocusNodeWeb,
                                textAlignVertical: TextAlignVertical.center,
                                onTap: () {
                                  Future.microtask(() {
                                    if (searchController.text.isNotEmpty &&
                                        searchController.selection.baseOffset ==
                                            0 &&
                                        searchController
                                                .selection.extentOffset ==
                                            searchController.text.length) {
                                      searchController.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  searchController.text.length);
                                    }
                                  });
                                },
                                onSubmitted: (query) {
                                  if (_debounce?.isActive ?? false) {
                                    _debounce!.cancel();
                                  }
                                  reportsProvider.setTaskSearchCriteria(
                                    query,
                                    reportsProvider.fromDateS,
                                    reportsProvider.toDateS,
                                    reportsProvider.Status,
                                    reportsProvider.AssignedTo,
                                    reportsProvider.TaskType,
                                    reportsProvider.enquiryForS,
                                  );
                                  reportsProvider.searchTaskByCustomer(context);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search here...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      if (_debounce?.isActive ?? false) {
                                        _debounce!.cancel();
                                      }
                                      reportsProvider.setTaskSearchCriteria(
                                        searchController.text,
                                        reportsProvider.fromDateS,
                                        reportsProvider.toDateS,
                                        reportsProvider.Status,
                                        reportsProvider.AssignedTo,
                                        reportsProvider.TaskType,
                                        reportsProvider.enquiryForS,
                                      );
                                      reportsProvider.goToPage(1);
                                      reportsProvider
                                          .searchTaskByCustomer(context);
                                    },
                                    child: const Icon(Icons.search,
                                        color: Color(0xFF64748B), size: 18),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuButton<int>(
                              icon: const Icon(Icons.sort,
                                  color: Color(0xFF64748B)),
                              tooltip: 'Sort By',
                              onSelected: (int value) {
                                reportsProvider.setSortOption(value, context);
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 0,
                                  child: Text('Default'),
                                ),
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('ID No'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Creation Date'),
                                ),
                                const PopupMenuItem(
                                  value: 3,
                                  child: Text('Followup Date'),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                reportsProvider.sortOrder == 'ASC'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () =>
                                  reportsProvider.toggleSortOrder(context),
                              tooltip: reportsProvider.sortOrder == 'ASC'
                                  ? 'Ascending'
                                  : 'Descending',
                            ),
                            CustomFilterButton(
                              onPressed: () {
                                reportsProvider.toggleFilter();
                              },
                              isFilter: reportsProvider.isFilter,
                            ),
                            if (settingsProvider.menuIsViewMap[156] == 1)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final dropDownProvider =
                                      Provider.of<DropDownProvider>(context,
                                          listen: false);
                                  final leadsProvider =
                                      Provider.of<LeadsProvider>(context,
                                          listen: false);

                                  dropDownProvider.updateEnquiryForName(
                                      null, '');
                                  dropDownProvider.updateDistrict(null, '');

                                  final settingsProvider =
                                      Provider.of<SettingsProvider>(context,
                                          listen: false);
                                  await Future.wait([
                                    leadsProvider.getLeadDropdowns(context),
                                    dropDownProvider.getFollowUpStatus(
                                        context, "1"),
                                    dropDownProvider.getEnquirySource(context),
                                    dropDownProvider.getEnquiryFor(context),
                                    settingsProvider.searchsourceCategoryData(
                                        '', context),
                                  ]);
                                  settingsProvider.searchBranch(context);
                                  settingsProvider.searchDepartment(
                                      '', context);

                                  if (!context.mounted) return;

                                  await showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return const NewLeadDrawerWidget(
                                        isEdit: false,
                                      );
                                    },
                                  );

                                  if (context.mounted) {
                                    dropDownProvider.getFollowUpStatus(
                                        context, "3");
                                  }
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(
                                  'New Lead',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            //Create Task
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return TaskCreationWidget(
                                        isEdit: false,
                                        taskId: '0',
                                        showDocument: true,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Task'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            //
                          ],
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (reportsProvider.isFilter && AppStyles.isWebScreen(context))
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status Filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedStatus != null &&
                                    reportsProvider.selectedStatus != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Status: ',
                              style: TextStyle(fontSize: 14)),
                          DropdownButton<int>(
                            value: reportsProvider.selectedStatus,
                            hint: const Text('All',
                                style: TextStyle(fontSize: 14)),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('All',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ] +
                                provider.followUpData
                                    .map((status) => DropdownMenuItem<int>(
                                          value: status.statusId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              StatusUtils.getDisplayStatus(
                                                  status.statusName ?? ''),
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setStatus(newValue);
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),

                    // Date Filter
                    GestureDetector(
                      onTap: () {
                        onClickTopButton(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: reportsProvider.fromDate != null ||
                                      reportsProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reportsProvider.fromDate == null &&
                                      reportsProvider.toDate == null
                                  ? 'Follow-Up Date: All'
                                  : 'Date: ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black45, size: 20),
                          ],
                        ),
                      ),
                    ),

                    // Assigned To Filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedUser != null &&
                                    reportsProvider.selectedUser != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Assigned To: ',
                              style: TextStyle(fontSize: 14)),
                          DropdownButton<int>(
                            value: reportsProvider.selectedUser,
                            hint: const Text('All',
                                style: TextStyle(fontSize: 14)),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('All',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ] +
                                provider.searchUserDetails
                                    .map((user) => DropdownMenuItem<int>(
                                          value: user.userDetailsId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              user.userDetailsName,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setUserFilterStatus(newValue);
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),

                    // Task Type Filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedTaskType != null &&
                                    reportsProvider.selectedTaskType != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Task Type: ',
                              style: TextStyle(fontSize: 14)),
                          DropdownButton<int>(
                            value: reportsProvider.selectedTaskType,
                            hint: const Text('All',
                                style: TextStyle(fontSize: 14)),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('All',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ] +
                                provider.taskType
                                    .map((task) => DropdownMenuItem<int>(
                                          value: task.taskTypeId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              task.taskTypeName,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setTaskType(newValue);
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),

                    // Enquiry For Filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedEnquiryFor != null &&
                                    reportsProvider.selectedEnquiryFor != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Enquiry For: ',
                              style: TextStyle(fontSize: 14)),
                          DropdownButton<int>(
                            value: reportsProvider.selectedEnquiryFor,
                            hint: const Text('All',
                                style: TextStyle(fontSize: 14)),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('All',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ] +
                                provider.enquiryForList
                                    .map((enquiry) => DropdownMenuItem<int>(
                                          value: enquiry.enquiryForId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              enquiry.enquiryForName,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setEnquiryFor(newValue);
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),

                    // Department Filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedBranch != null &&
                                    reportsProvider.selectedBranch != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Department: ',
                              style: TextStyle(fontSize: 14)),
                          DropdownButton<int>(
                            value: reportsProvider.selectedBranch,
                            hint: const Text('All',
                                style: TextStyle(fontSize: 14)),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('All',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ] +
                                settingsProvider.branchModel
                                    .map((branch) => DropdownMenuItem<int>(
                                          value: branch.branchId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              branch.branchName ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setBranchFilter(newValue);
                                reportsProvider.goToPage(1);
                                reportsProvider.searchTaskByCustomer(context);
                              }
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),

                    //Priority Filter
                    _buildPriorityFilter(reportsProvider),

                    // Reset Button
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null ||
                        (reportsProvider.selectedStatus != null &&
                            reportsProvider.selectedStatus != 0) ||
                        (reportsProvider.selectedUser != null &&
                            reportsProvider.selectedUser != 0) ||
                        (reportsProvider.selectedTaskType != null &&
                            reportsProvider.selectedTaskType != 0) ||
                        (reportsProvider.selectedEnquiryFor != null &&
                            reportsProvider.selectedEnquiryFor != 0) ||
                        (reportsProvider.selectedBranch != null &&
                            reportsProvider.selectedBranch != 0) ||
                        (reportsProvider.selectedPriority != null &&
                            reportsProvider.selectedPriority != 0) ||
                        reportsProvider.Search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.removeStatus();
                          reportsProvider.setEntryType('myown');
                          searchController.clear();
                          reportsProvider.setTaskSearchCriteria(
                              '', '', '', '', '', '', '');
                          reportsProvider.goToPage(1);
                          reportsProvider.searchTaskByCustomer(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),
            if (reportsProvider.isFilter && !AppStyles.isWebScreen(context))
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Filter (lead page order: Status first)
                      const CustomText('Status',
                          fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                reportsProvider.selectedStatusIds.contains(0),
                            onTap: () => reportsProvider.toggleStatus(0),
                          ),
                          ...provider.followUpData
                              .map((status) => FilterChipWidget(
                                    label: StatusUtils.getDisplayStatus(
                                        status.statusName ?? ''),
                                    isSelected: reportsProvider
                                        .selectedStatusIds
                                        .contains(status.statusId),
                                    onTap: () => reportsProvider
                                        .toggleStatus(status.statusId!),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        'Priority',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.selectedPriority == 0,
                            onTap: () {
                              reportsProvider.setPriorityFilter(0);
                            },
                          ),
                          ...settingsProvider.priorities.map((priority) {
                            return FilterChipWidget(
                              label: priority.priorityName,
                              isSelected: reportsProvider.selectedPriority ==
                                  priority.priorityId,
                              onTap: () {
                                reportsProvider
                                    .setPriorityFilter(priority.priorityId);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date Filter button for Mobile (after Status, like lead page)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 200),
                                        child: Text(
                                          reportsProvider.fromDate == null &&
                                                  reportsProvider.toDate == null
                                              ? 'Follow-Up Date: All'
                                              : 'Date : ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomText('Assigned To',
                          fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                reportsProvider.selectedUserIds.contains(0),
                            onTap: () => reportsProvider.toggleUserFilter(0),
                          ),
                          ...provider.searchUserDetails
                              .map((user) => FilterChipWidget(
                                    label: user.userDetailsName,
                                    isSelected: reportsProvider.selectedUserIds
                                        .contains(user.userDetailsId),
                                    onTap: () => reportsProvider
                                        .toggleUserFilter(user.userDetailsId),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomText('Task Type',
                          fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider
                                .selectedTaskTypeFilterIds
                                .contains(0),
                            onTap: () =>
                                reportsProvider.toggleTaskTypeFilter(0),
                          ),
                          ...provider.taskType.map((task) => FilterChipWidget(
                                label: task.taskTypeName,
                                isSelected: reportsProvider
                                    .selectedTaskTypeFilterIds
                                    .contains(task.taskTypeId),
                                onTap: () => reportsProvider
                                    .toggleTaskTypeFilter(task.taskTypeId),
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomText('Entry Type',
                          fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.entryType == 'all',
                            onTap: () {
                              reportsProvider.setEntryType('all');
                            },
                          ),
                          FilterChipWidget(
                            label: 'My Own',
                            isSelected: reportsProvider.entryType == 'myown',
                            onTap: () {
                              reportsProvider.setEntryType('myown');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomText('Enquiry For',
                          fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.selectedEnquiryForIds
                                .contains(0),
                            onTap: () =>
                                reportsProvider.toggleEnquiryForFilter(0),
                          ),
                          ...provider.enquiryForList
                              .map((enquiry) => FilterChipWidget(
                                    label: enquiry.enquiryForName,
                                    isSelected: reportsProvider
                                        .selectedEnquiryForIds
                                        .contains(enquiry.enquiryForId),
                                    onTap: () =>
                                        reportsProvider.toggleEnquiryForFilter(
                                            enquiry.enquiryForId),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null ||
                          !reportsProvider.selectedStatusIds
                              .every((id) => id == 0) ||
                          !reportsProvider.selectedUserIds
                              .every((id) => id == 0) ||
                          !reportsProvider.selectedTaskTypeFilterIds
                              .every((id) => id == 0) ||
                          !reportsProvider.selectedEnquiryForIds
                              .every((id) => id == 0) ||
                          reportsProvider.Search.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              reportsProvider.setEntryType('myown');
                              searchController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                  '', '', '', '', '', '', '');
                              reportsProvider.goToPage(1);
                              reportsProvider.searchTaskByCustomer(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textRed,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Reset All Filters'),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            if (!reportsProvider.isFilter || AppStyles.isWebScreen(context))
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
                          ? BorderRadius.circular(4)
                          : BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: AppStyles.isWebScreen(context)
                          ? const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0)
                          : EdgeInsets.zero,
                      child: Column(
                        children: [
                          if (!AppStyles.isWebScreen(context))
                            Expanded(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          'Total Tasks: ${reportsProvider.totalSize}',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: reportsProvider.taskReport.isEmpty
                                        ? const Center(
                                            child: Text("No tasks found"))
                                        : ListView.builder(
                                            controller: _scrollController,
                                            itemCount: reportsProvider
                                                    .taskReport.length +
                                                (_isLoadingMore ? 1 : 0),
                                            itemBuilder: (context, index) {
                                              if (index ==
                                                      reportsProvider
                                                          .taskReport.length &&
                                                  _isLoadingMore) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                );
                                              }
                                              var task = reportsProvider
                                                  .taskReport[index];
                                              return Column(
                                                children: [
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1,
                                                    color: AppColors.grey,
                                                  ),
                                                  TaskCard(
                                                    task: task,
                                                    isExpanded: reportsProvider
                                                            .expandedIndex ==
                                                        index,
                                                    onTap: () => reportsProvider
                                                        .toggleExpansion(index),
                                                    showStatusUpdate:
                                                        (context, task) {
                                                      reportsProvider
                                                          .selectedTaskTypeIds
                                                          .clear();
                                                      reportsProvider
                                                          .taskTypeModel
                                                          .clear();
                                                      if (task.customerName
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
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            )

                          // === WEB TABLE WITH HORIZONTAL SCROLLING ===
                          else
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double minWidth = 1850;
                                  if (settingsProvider.showView[162] != 1) {
                                    minWidth -= 130;
                                  }
                                  double tableWidth =
                                      minWidth > constraints.maxWidth
                                          ? minWidth
                                          : constraints.maxWidth;
                                  return Scrollbar(
                                    controller: _horizontalScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _horizontalScrollController,
                                      child: SizedBox(
                                        width: tableWidth,
                                        child: Column(
                                          children: [
                                            // Header
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlue,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      child: Text('No.',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white)),
                                                    ),
                                                  ),
                                                  TableWidget(
                                                      width: 120,
                                                      title: 'Lead Code',
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 180,
                                                      title: 'Customer',
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 110,
                                                      title: 'Mobile No.',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 180,
                                                      title: 'Task',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 150,
                                                      title: 'Enquiry for',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 120,
                                                      title: 'Staff',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 180,
                                                      title: 'Description',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                    width: 150,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 12.0),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    data: const Text(
                                                      'Priority',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  TableWidget(
                                                      width: 140,
                                                      title: 'Created Date',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 160,
                                                      title:
                                                          'Followup Date&Time',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  TableWidget(
                                                      width: 120,
                                                      title: 'Status',
                                                      fontSize: 13,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 12.0),
                                                      color: Colors.white),
                                                  if (settingsProvider
                                                          .showView[162] ==
                                                      1)
                                                    TableWidget(
                                                        width: 130,
                                                        title: 'Job Sheet',
                                                        fontSize: 13,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        color: Colors.white),
                                                ],
                                              ),
                                            ),

                                            // Data Rows
                                            Expanded(
                                              child:
                                                  reportsProvider
                                                          .taskReport.isEmpty
                                                      ? const Center(
                                                          child: Text(
                                                              "No tasks found"))
                                                      : ListView.builder(
                                                          controller:
                                                              _scrollController,
                                                          shrinkWrap: false,
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(),
                                                          itemCount: reportsProvider
                                                                  .taskReport
                                                                  .length +
                                                              (_isLoadingMore &&
                                                                      !AppStyles
                                                                          .isWebScreen(
                                                                              context)
                                                                  ? 1
                                                                  : 0),
                                                          itemBuilder:
                                                              (context, index) {
                                                            // Loading indicator for mobile
                                                            if (!AppStyles
                                                                    .isWebScreen(
                                                                        context) &&
                                                                index ==
                                                                    reportsProvider
                                                                        .taskReport
                                                                        .length &&
                                                                _isLoadingMore) {
                                                              return const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                              );
                                                            }

                                                            var task =
                                                                reportsProvider
                                                                        .taskReport[
                                                                    index];
                                                            final itemNumber =
                                                                ((reportsProvider.pageIndex ??
                                                                                1) -
                                                                            1) *
                                                                        (reportsProvider.pageSize ??
                                                                            20) +
                                                                    index +
                                                                    1;

                                                            if (!AppStyles
                                                                .isWebScreen(
                                                                    context)) {
                                                              return Column(
                                                                children: [
                                                                  Divider(
                                                                    height: 1,
                                                                    thickness:
                                                                        1,
                                                                    color:
                                                                        AppColors
                                                                            .grey,
                                                                  ),
                                                                  TaskCard(
                                                                    task: task,
                                                                    isExpanded:
                                                                        reportsProvider.expandedIndex ==
                                                                            index,
                                                                    onTap: () =>
                                                                        reportsProvider
                                                                            .toggleExpansion(index),
                                                                    showStatusUpdate:
                                                                        (ctx,
                                                                            t) {
                                                                      reportsProvider
                                                                          .selectedTaskTypeIds
                                                                          .clear();
                                                                      reportsProvider
                                                                          .taskTypeModel
                                                                          .clear();
                                                                      statusDialogMobile(
                                                                              t)
                                                                          .then(
                                                                              (value) {
                                                                        if (value ==
                                                                            true) {
                                                                          reportsProvider
                                                                              .goToPage(1);
                                                                          reportsProvider
                                                                              .searchTaskByCustomer(context);
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            }

                                                            // === WEB ROW ===
                                                            return InkWell(
                                                              onTap: () {
                                                                reportsProvider
                                                                    .selectedTaskTypeIds
                                                                    .clear();
                                                                reportsProvider
                                                                    .taskTypeModel
                                                                    .clear();
                                                                if (task
                                                                    .customerName
                                                                    .isEmpty) {
                                                                  updateStatusDialogWithoutTask(
                                                                          task)
                                                                      .then(
                                                                          (value) {
                                                                    if (value ==
                                                                        true) {
                                                                      reportsProvider
                                                                          .goToPage(
                                                                              1);
                                                                      reportsProvider
                                                                          .searchTaskByCustomer(
                                                                              context);
                                                                    }
                                                                  });
                                                                } else {
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
                                                                            .goToPage(1);
                                                                        reportsProvider
                                                                            .searchTaskByCustomer(context);
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
                                                                            .goToPage(1);
                                                                        reportsProvider
                                                                            .searchTaskByCustomer(context);
                                                                      }
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              hoverColor:
                                                                  const Color(
                                                                      0xFFF8FAFC),
                                                              child: Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                        minHeight:
                                                                            rowHeight),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: index %
                                                                              2 ==
                                                                          0
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFFF6F7F9),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 60,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                4.0,
                                                                            horizontal:
                                                                                12.0),
                                                                        child:
                                                                            Text(
                                                                          itemNumber
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          120,
                                                                      fontSize:
                                                                          13,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      title: task
                                                                              .leadCode ??
                                                                          '-',
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          180,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data: Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                color: const Color(0xFFEBF5FF),
                                                                                borderRadius: BorderRadius.circular(5),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  context.push('${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                                                },
                                                                                child: Text(
                                                                                  task.customerName.isNotEmpty ? task.customerName : 'Unknown',
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  maxLines: 1,
                                                                                  style: const TextStyle(
                                                                                    color: Colors.blue,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          _HoverMenuAnchor(
                                                                            builder: (context,
                                                                                controller,
                                                                                onHover,
                                                                                child) {
                                                                              return InkWell(
                                                                                onTap: () {
                                                                                  if (controller.isOpen) {
                                                                                    controller.close();
                                                                                  } else {
                                                                                    controller.open();
                                                                                  }
                                                                                },
                                                                                onHover: onHover,
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.all(4),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.transparent,
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                  ),
                                                                                  child: Icon(
                                                                                    Icons.keyboard_arrow_down_rounded,
                                                                                    size: 20,
                                                                                    color: Colors.grey[500],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                            menuChildren: [
                                                                              // Add your menu items here (Create Task, Edit Lead, etc.)
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          110,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Tooltip(
                                                                        message:
                                                                            task.mobile,
                                                                        child:
                                                                            Text(
                                                                          task.mobile.isNotEmpty
                                                                              ? task.mobile
                                                                              : '-',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Color(0xFF334155),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          180,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Tooltip(
                                                                        message:
                                                                            task.taskTypeName ??
                                                                                '',
                                                                        child:
                                                                            Text(
                                                                          task.taskTypeName ??
                                                                              '',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Color(0xFF334155),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          150,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Tooltip(
                                                                        message: provider.getEnquiryForNameById(
                                                                            task.enquiryForId,
                                                                            task.enquiryForName),
                                                                        child:
                                                                            Text(
                                                                          provider.getEnquiryForNameById(
                                                                              task.enquiryForId,
                                                                              task.enquiryForName),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Color(0xFF334155),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          120,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Text(
                                                                        task.toUserName ??
                                                                            '',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Color(0xFF334155),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          180,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Tooltip(
                                                                        message:
                                                                            task.description ??
                                                                                '',
                                                                        child:
                                                                            Text(
                                                                          task.description ??
                                                                              '',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Color(0xFF334155),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          150,
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data: PopupMenuButton<
                                                                          PriorityModel>(
                                                                        tooltip:
                                                                            task.priorityName,
                                                                        constraints:
                                                                            const BoxConstraints(maxHeight: 300),
                                                                        offset: const Offset(
                                                                            0,
                                                                            40),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8)),
                                                                        onSelected:
                                                                            (PriorityModel
                                                                                selected) async {
                                                                          await reportsProvider
                                                                              .updateTaskPriority(
                                                                            context:
                                                                                context,
                                                                            taskId:
                                                                                task.taskId,
                                                                            priorityId:
                                                                                selected.priorityId,
                                                                          );
                                                                        },
                                                                        itemBuilder:
                                                                            (context) {
                                                                          return settingsProvider
                                                                              .priorities
                                                                              .map((priority) {
                                                                            return PopupMenuItem<PriorityModel>(
                                                                              value: priority,
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 12,
                                                                                    height: 12,
                                                                                    decoration: BoxDecoration(
                                                                                      color: AppColors.parseColor(priority.colorCode).withOpacity(0.8),
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 10),
                                                                                  Text(
                                                                                    priority.priorityName,
                                                                                    style: TextStyle(
                                                                                      color: AppColors.parseColor(priority.colorCode),
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }).toList();
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              32,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 6),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppColors.parseColor(task.priorityColor).withOpacity(0.2),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Text(
                                                                                  task.priorityName,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: AppColors.parseColor(task.priorityColor),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 4),
                                                                              Icon(
                                                                                Icons.arrow_drop_down,
                                                                                size: 18,
                                                                                color: AppColors.parseColor(task.priorityColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          140,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Text(
                                                                        task.entryDate
                                                                            .toDayMonthYearFormat(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Color(0xFF334155),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          160,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          Text(
                                                                        () {
                                                                          String
                                                                              date =
                                                                              task.taskDate.toDayMonthYearFormat();
                                                                          String
                                                                              time =
                                                                              '';
                                                                          if (task
                                                                              .taskTime
                                                                              .isNotEmpty) {
                                                                            try {
                                                                              final parsed = DateFormat('HH:mm:ss').parse(task.taskTime);
                                                                              time = DateFormat('hh:mm a').format(parsed);
                                                                            } catch (_) {
                                                                              time = task.taskTime;
                                                                            }
                                                                          }
                                                                          return time.isEmpty
                                                                              ? date
                                                                              : '$date $time';
                                                                        }(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Color(0xFF334155),
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TableWidget(
                                                                      width:
                                                                          120,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              12.0),
                                                                      data:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          reportsProvider
                                                                              .selectedTaskTypeIds
                                                                              .clear();
                                                                          reportsProvider
                                                                              .taskTypeModel
                                                                              .clear();
                                                                          if (task
                                                                              .customerName
                                                                              .isEmpty) {
                                                                            updateStatusDialogWithoutTask(task).then((value) {
                                                                              if (value == true) {
                                                                                reportsProvider.goToPage(1);
                                                                                reportsProvider.searchTaskByCustomer(context);
                                                                              }
                                                                            });
                                                                          } else {
                                                                            if (AppStyles.isWebScreen(context)) {
                                                                              statusDialog(task).then((value) {
                                                                                if (value == true) {
                                                                                  reportsProvider.goToPage(1);
                                                                                  reportsProvider.searchTaskByCustomer(context);
                                                                                }
                                                                              });
                                                                            } else {
                                                                              statusDialogMobile(task).then((value) {
                                                                                if (value == true) {
                                                                                  reportsProvider.goToPage(1);
                                                                                  reportsProvider.searchTaskByCustomer(context);
                                                                                }
                                                                              });
                                                                            }
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(30),
                                                                            color:
                                                                                (task.colorCode ?? const Color(0xFF3B82F6)).withOpacity(0.2),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                              child: Text(
                                                                                task.taskStatusName,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 1,
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: task.colorCode ?? const Color(0xFF3B82F6),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    if (settingsProvider
                                                                            .showView[162] ==
                                                                        1)
                                                                      TableWidget(
                                                                        width:
                                                                            130,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                4.0,
                                                                            horizontal:
                                                                                12.0),
                                                                        data:
                                                                            Center(
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                32,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), minimumSize: const Size(80, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                                                              onPressed: () async {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => JobSheetPage(
                                                                                      taskId: task.taskId,
                                                                                      customerId: int.tryParse(task.customerId.toString()) ?? 0,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: const Text('Job Sheet', style: TextStyle(fontSize: 12)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                            ),
                                          ],
                                        ),
                                      ),
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
      bottomNavigationBar:
          buildResponsivePaginationControls(context, reportsProvider),
      floatingActionButton: reportsProvider.isFilter &&
              !AppStyles.isWebScreen(context)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_task_filter_fab',
                  backgroundColor: AppColors.darkGreen,
                  onPressed: () {
                    reportsProvider.setFilterState(false);
                    searchProvider.stopSearch();
                    reportsProvider.goToPage(1);
                    reportsProvider.searchTaskByCustomer(context,
                        isShowLoader: false);
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text(
                    'APPLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : !reportsProvider.isFilter && !AppStyles.isWebScreen(context)
              ? //Create Task

              Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: FloatingActionButton(
                    backgroundColor: AppColors.appViolet,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext sheetContext) {
                          return SafeArea(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.task,
                                        color: AppColors.primaryBlue),
                                    title: const Text('Create Task',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return TaskCreationWidget(
                                            isEdit: false,
                                            taskId: '0',
                                            showDocument: true,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if (settingsProvider.menuIsViewMap[156] ==
                                      1) ...[
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.person_add,
                                          color: AppColors.primaryBlue),
                                      title: const Text('Add New Lead',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      onTap: () async {
                                        Navigator.pop(sheetContext);

                                        final dropDownProvider =
                                            Provider.of<DropDownProvider>(
                                                context,
                                                listen: false);
                                        final leadsProvider =
                                            Provider.of<LeadsProvider>(context,
                                                listen: false);

                                        dropDownProvider.updateEnquiryForName(
                                            null, '');
                                        dropDownProvider.updateDistrict(
                                            null, '');
                                        final settingsProvider =
                                            Provider.of<SettingsProvider>(
                                                context,
                                                listen: false);

                                        await Future.wait([
                                          leadsProvider
                                              .getLeadDropdowns(context),
                                          dropDownProvider.getFollowUpStatus(
                                              context, "1"),
                                          dropDownProvider
                                              .getEnquirySource(context),
                                          dropDownProvider
                                              .getEnquiryFor(context),
                                          settingsProvider
                                              .searchsourceCategoryData(
                                                  '', context),
                                        ]);
                                        settingsProvider.searchBranch(context);
                                        settingsProvider.searchDepartment(
                                            '', context);

                                        if (!context.mounted) return;

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NewLeadDrawerMobileWidget(
                                              isEdit: false,
                                              customerId: '0',
                                            ),
                                          ),
                                        );

                                        if (context.mounted) {
                                          dropDownProvider.getFollowUpStatus(
                                              context, "3");
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              : null,
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
            getStatusType(context, task.taskTypeId.toString());
        final reportsProvider =
            Provider.of<TaskPageProvider>(context, listen: false);
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);

        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 480,
              maxHeight: 520,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.end,
                          children: [
                            Text(
                              'Task:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              task.taskTypeName ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: FutureBuilder<List<TaskTypeStatusModel>>(
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
                          child: Center(
                              child: Text('Error loading status options')),
                        );
                      } else {
                        final statusOptions = snapshot.data!;
                        TaskTypeStatusModel defaultStatus =
                            statusOptions.firstWhere(
                          (status) => status.statusId == task.taskStatusId,
                          orElse: () => statusOptions.first,
                        );

                        final ValueNotifier<TaskTypeStatusModel>
                            selectedStatus = ValueNotifier(defaultStatus);
                        final ValueNotifier<SubStatus?> selectedSubStatus =
                            ValueNotifier(null);
                        final ValueNotifier<bool> isSaving =
                            ValueNotifier(false);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          reportsProvider.clearDescription();
                        });

                        Widget formFields = Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Select Status',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B))),
                                    const SizedBox(height: 8),
                                    ValueListenableBuilder<TaskTypeStatusModel>(
                                      valueListenable: selectedStatus,
                                      builder: (context, value, _) {
                                        return Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: statusOptions.map((status) {
                                            bool isSelected = value.statusId ==
                                                status.statusId;
                                            return _buildCustomStatusChip(
                                              status: status,
                                              isSelected: isSelected,
                                              onTap: () {
                                                selectedStatus.value = status;
                                                selectedSubStatus.value = null;
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              ValueListenableBuilder<TaskTypeStatusModel>(
                                valueListenable: selectedStatus,
                                builder: (context, currentStatus, _) {
                                  final validSubStatuses = currentStatus
                                          .subStatuses
                                          ?.where((s) =>
                                              s.subStatusId != null &&
                                              s.subStatusId != 0 &&
                                              s.subStatusName != null &&
                                              s.subStatusName!.isNotEmpty)
                                          .toList() ??
                                      [];
                                  if (validSubStatuses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Select Sub Status',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B))),
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<SubStatus?>(
                                          valueListenable: selectedSubStatus,
                                          builder: (context, subVal, _) {
                                            return DropdownButtonFormField<
                                                SubStatus>(
                                              value: subVal,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF1A7AE8),
                                                      width: 1),
                                                ),
                                                hintText: 'Select Sub Status',
                                                hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                              isExpanded: true,
                                              onChanged: (sub) {
                                                selectedSubStatus.value = sub;
                                                if (sub != null) {
                                                  reportsProvider
                                                      .fetchTaskTypes(
                                                    task.taskTypeId,
                                                    sub.subStatusId ?? 0,
                                                    task.customerId,
                                                    task.enquiryForId,
                                                    context,
                                                  );
                                                }
                                              },
                                              items:
                                                  validSubStatuses.map((sub) {
                                                return DropdownMenuItem<
                                                    SubStatus>(
                                                  value: sub,
                                                  child: Text(
                                                      sub.subStatusName ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 14)),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              ValueListenableBuilder<TaskTypeStatusModel>(
                                valueListenable: selectedStatus,
                                builder: (ctx, status, child) {
                                  bool showDate = status.followup == 1 ||
                                      status.viewDateFollowup == 1;
                                  bool showTime = status.isTime == 1;
                                  if (!showDate && !showTime) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        if (showDate)
                                          Expanded(child: dateFollowUpWidget()),
                                        if (showDate && showTime)
                                          const SizedBox(width: 12),
                                        if (showTime)
                                          Expanded(child: timeFollowUpWidget()),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text('Add Notes',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: TextField(
                                  controller:
                                      reportsProvider.descriptionController,
                                  maxLines: 3,
                                  minLines: 2,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: InputBorder.none,
                                    hintText: 'Enter notes here...',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade400),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF1E293B)),
                                ),
                              ),
                              if (settingsProvider.showView[165] == 1) ...[
                                const SizedBox(height: 12),
                                Text('Remarks / Feedback',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3)),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: TextField(
                                    controller:
                                        reportsProvider.remarksController,
                                    maxLines: 3,
                                    minLines: 2,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                      border: InputBorder.none,
                                      hintText: 'Enter remarks here...',
                                      hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xFF1E293B)),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                child: formFields,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: isSaving,
                                builder: (ctx, saving, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: saving
                                            ? null
                                            : () =>
                                                Navigator.pop(context, false),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          side: const BorderSide(
                                              color: Color(0xFFE2E8F0)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                        ),
                                        child: const Text('Cancel',
                                            style: TextStyle(
                                                color: Color(0xFF1E293B),
                                                fontWeight: FontWeight.w700)),
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
                                                    await reportsProvider
                                                        .getCurrentLocation(),
                                                    subStatus:
                                                        selectedSubStatus.value,
                                                  );
                                                  if (isSuccess) {
                                                    Navigator.of(context)
                                                        .pop(true);
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
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          backgroundColor:
                                              const Color(0xFF1A7AE8),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        child: saving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white)))
                                            : const Text('Save',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                      ),
                                    ],
                                  );
                                },
                              ),
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

  Future statusDialogMobile(TaskReportModel task) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessFlowDialog(task: task),
      ),
    );
  }

  void _showWebFormDialog(
      BuildContext context, FormModel form, TaskReportModel task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomFormFillerView(
            form: form,
            taskId: task.taskId,
            customerId: task.customerId,
            taskTypeId: task.taskTypeId.toString(),
            enquiryForId: task.enquiryForId,
            formDataDetailsId: form.instanceId?.toString(),
            onSaved: () {
              // Any specific refresh logic for TaskPage if needed?
            },
          ),
        ),
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
            getStatusType(context, task.taskTypeId.toString());
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);

        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 900,
              maxHeight: 600,
              minHeight: 600,
              minWidth: 900,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Task:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.taskTypeName ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'for',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  context.push(
                                      '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                },
                                child: Text(
                                  task.customerName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
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
                        final dropDownProvider = Provider.of<DropDownProvider>(
                            context,
                            listen: false);
                        final leadProvider =
                            Provider.of<LeadsProvider>(context, listen: false);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          reportsProvider.fetchTaskTypes(tasktypeId, statusId,
                              customerId, enquiryForId, context);
                          dropDownProvider.getUserDetails(context);
                          dropDownProvider.filteredStaffData.clear();
                          leadProvider.searchUserController.clear();
                          reportsProvider.clearDescription();

                          // Also fetch forms for this customer
                          final formProvider =
                              Provider.of<FormProvider>(context, listen: false);
                          formProvider.getFormDataByCustomer(
                            task.customerId.toString(),
                            enquiryForId: task.enquiryForId.toString(),
                          );
                          formProvider.fetchAvailableFields(context);

                          // Pre-fill Description and Follow-Up Date if available
                          reportsProvider.descriptionController.clear();
                          if (task.nextFollowupDate != null &&
                              task.nextFollowupDate!.isNotEmpty) {
                            try {
                              DateTime parsedDate =
                                  DateTime.parse(task.nextFollowupDate!);
                              reportsProvider.followUpDateController.text =
                                  DateFormat('dd MMM yyyy').format(parsedDate);
                            } catch (e) {
                              reportsProvider.followUpDateController.text =
                                  task.nextFollowupDate!;
                            }
                          } else {
                            reportsProvider.followUpDateController.clear();
                          }
                        });

                        final ValueNotifier<TaskTypeStatusModel>
                            selectedStatus = ValueNotifier(defaultStatus);
                        final ValueNotifier<SubStatus?> selectedSubStatus =
                            ValueNotifier(null);
                        final ValueNotifier<bool> isSaving =
                            ValueNotifier(false);

                        Widget formFields = Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Row 1: Current Status Dropdown
                              // Row 1: Current Status Chips Selection
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Select Status',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B))),
                                    const SizedBox(height: 8),
                                    ValueListenableBuilder<TaskTypeStatusModel>(
                                      valueListenable: selectedStatus,
                                      builder: (context, value, _) {
                                        return Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: statusOptions.map((status) {
                                            bool isSelected = value.statusId ==
                                                status.statusId;
                                            return _buildCustomStatusChip(
                                              status: status,
                                              isSelected: isSelected,
                                              onTap: () async {
                                                selectedStatus.value = status;
                                                selectedSubStatus.value = null;
                                                int sId = status.statusId ?? 0;
                                                int tId =
                                                    status.taskTypeId ?? 0;
                                                await reportsProvider
                                                    .fetchTaskTypes(
                                                        tId,
                                                        sId,
                                                        customerId,
                                                        enquiryForId,
                                                        context);
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              ValueListenableBuilder<TaskTypeStatusModel>(
                                valueListenable: selectedStatus,
                                builder: (context, currentStatus, _) {
                                  final validSubStatuses = currentStatus
                                          .subStatuses
                                          ?.where((s) =>
                                              s.subStatusId != null &&
                                              s.subStatusId != 0 &&
                                              s.subStatusName != null &&
                                              s.subStatusName!.isNotEmpty)
                                          .toList() ??
                                      [];
                                  if (validSubStatuses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Select Sub Status',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B))),
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<SubStatus?>(
                                          valueListenable: selectedSubStatus,
                                          builder: (context, subVal, _) {
                                            return DropdownButtonFormField<
                                                SubStatus>(
                                              value: subVal,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF1A7AE8),
                                                      width: 1),
                                                ),
                                                hintText: 'Select Sub Status',
                                                hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                              isExpanded: true,
                                              onChanged: (sub) {
                                                selectedSubStatus.value = sub;
                                                if (sub != null) {
                                                  reportsProvider
                                                      .fetchTaskTypes(
                                                    task.taskTypeId,
                                                    sub.subStatusId ?? 0,
                                                    task.customerId,
                                                    task.enquiryForId,
                                                    context,
                                                  );
                                                }
                                              },
                                              items:
                                                  validSubStatuses.map((sub) {
                                                return DropdownMenuItem<
                                                    SubStatus>(
                                                  value: sub,
                                                  child: Text(
                                                      sub.subStatusName ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 14)),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // CustomField
                              Consumer<TaskPageProvider>(
                                builder: (context, reportsProvider, child) {
                                  if (reportsProvider
                                      .showCustomFields.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      CustomFieldSectionWidget(
                                        key:
                                            customFieldTaskStatusKey, // Make sure this GlobalKey is defined
                                        customFields:
                                            reportsProvider.showCustomFields,
                                        controllerKey:
                                            'task_status_${task.taskId}', // Unique key
                                        showEditButton: false,
                                        enabled: true,
                                        showMore: false,
                                        onFieldValuesChanged: (values) {
                                          // Optional: You can also handle here if needed
                                          reportsProvider
                                              .fetchTaskTypesWithCustomFields(
                                                  selectedStatus
                                                          .value.taskTypeId ??
                                                      0,
                                                  selectedStatus
                                                          .value.statusId ??
                                                      0,
                                                  customerId,
                                                  enquiryForId,
                                                  context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),

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
                                              BorderRadius.circular(4),
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
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text('New Task',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text('Department',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text('User',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
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
                                                    dropDownProvider
                                                        .filterStaffByBranchAndDepartment(
                                                      branchId:
                                                          taskItem.branchIds,
                                                      departmentId: taskItem
                                                          .departmentIds,
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
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
                                                                        size:
                                                                            14,
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
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                              taskItem.departmentName ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700)),
                                                        ),
                                                        //User DropDown
                                                        Expanded(
                                                          flex: 1,
                                                          child: taskItem
                                                                      .showUser ==
                                                                  1
                                                              ? Consumer<
                                                                  DropDownProvider>(
                                                                  builder: (context,
                                                                      dropDownProvider,
                                                                      child) {
                                                                    return CustomAutocompleteSearch<
                                                                        SearchUserDetails>(
                                                                      showOptionsOnTap:
                                                                          true,
                                                                      focusNode:
                                                                          staffFocusNode,
                                                                      maxHeight:
                                                                          300,
                                                                      optionsViewOpenDirection:
                                                                          OptionsViewOpenDirection
                                                                              .down,
                                                                      items: dropDownProvider
                                                                          .filteredStaffData,
                                                                      displayStringFunction:
                                                                          (staff) =>
                                                                              staff.userDetailsName,
                                                                      defaultText: leadProvider
                                                                          .searchUserController
                                                                          .text,
                                                                      labelText:
                                                                          'User',
                                                                      controller:
                                                                          leadProvider
                                                                              .searchUserController,
                                                                      suffixIcon:
                                                                          const Icon(
                                                                              Icons.search),
                                                                      onTap: () {
                                                                        dropDownProvider.filterStaffByBranchAndDepartment(
                                                                          branchId: taskItem.branchIds,
                                                                          departmentId: taskItem.departmentIds,
                                                                        );
                                                                      },
                                                                      onSelected:
                                                                          (SearchUserDetails
                                                                              selected) {
                                                                        dropDownProvider
                                                                            .setSelectedUserId(
                                                                          selected
                                                                              .userDetailsId,
                                                                        );

                                                                        leadProvider
                                                                            .searchUserController
                                                                            .text = selected.userDetailsName;

                                                                        final taskTypeIdStr = taskItem
                                                                            .taskTypeId
                                                                            .toString();
                                                                        reportsProvider.setTaskUser(
                                                                            taskTypeIdStr,
                                                                            selected.userDetailsId);
                                                                      },
                                                                      onChanged:
                                                                          (value) {
                                                                        int branchId =
                                                                            taskItem.branchIds ??
                                                                                0;
                                                                        int departmentId =
                                                                            taskItem.departmentIds ??
                                                                                0;
                                                                        dropDownProvider.filterStaffByBranchAndDepartment(
                                                                            branchId:
                                                                                branchId,
                                                                            departmentId:
                                                                                departmentId);
                                                                        dropDownProvider
                                                                            .filterStaff(value);
                                                                      },
                                                                      onSearch:
                                                                          (query) async {
                                                                        dropDownProvider
                                                                            .filterStaff(query);
                                                                      },
                                                                    );
                                                                  },
                                                                )
                                                              : SizedBox(),
                                                        )
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
                                      bool showDate = status.followup == 1 ||
                                          status.viewDateFollowup == 1;
                                      bool showTime = status.isTime == 1;
                                      bool hasDocs = reportsProvider
                                          .documentTypeModel.isNotEmpty;
                                      bool hasMandatory =
                                          reportsProvider.statusData.isNotEmpty;
                                      bool showRightList =
                                          hasDocs || hasMandatory;
                                      final settingsProvider =
                                          Provider.of<SettingsProvider>(context,
                                              listen: false);
                                      bool isDocumentButtonEnabled =
                                          settingsProvider
                                                  .documentButtonTaskStatus ==
                                              1;

                                      Widget leftSide = (showDate || showTime)
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (showDate) ...[
                                                  dateFollowUpWidget(),
                                                  if (showTime)
                                                    const SizedBox(height: 12),
                                                ],
                                                if (showTime)
                                                  timeFollowUpWidget(),
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
                                                            4),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (hasDocs &&
                                                          isDocumentButtonEnabled)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child:
                                                              CustomElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              await showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        ImageUploadAlert(
                                                                  customerId: task
                                                                      .customerId
                                                                      .toString(),
                                                                ),
                                                              );
                                                            },
                                                            buttonText:
                                                                'Upload Documents',
                                                            backgroundColor:
                                                                AppColors
                                                                    .appViolet,
                                                            borderColor:
                                                                AppColors
                                                                    .appViolet,
                                                            textColor:
                                                                Colors.white,
                                                            radius: 4,
                                                          ),
                                                        ),
                                                      if (hasDocs &&
                                                          !isDocumentButtonEnabled)
                                                        ...reportsProvider
                                                            .documentTypeModel
                                                            .map(
                                                                (doc) =>
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              4),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text(doc.documentTypeName ?? '', style: const TextStyle(fontSize: 13)),
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              final result = await showDialog(
                                                                                barrierDismissible: false,
                                                                                context: context,
                                                                                builder: (context) => ImageUploadAlert(
                                                                                  customerId: task.customerId.toString(),
                                                                                  initialDocumentTypeId: doc.documentTypeId,
                                                                                  initialDocumentTypeName: doc.documentTypeName,
                                                                                ),
                                                                              );
                                                                              if (result == true) {
                                                                                reportsProvider.removePendingDocument(doc.documentTypeId ?? 0);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.all(4),
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.darkGreen.withOpacity(0.1),
                                                                                borderRadius: BorderRadius.circular(4),
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.upload_rounded,
                                                                                size: 16,
                                                                                color: AppColors.darkGreen,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
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
                                                                      '${e.key + 1 + (hasDocs && !isDocumentButtonEnabled ? reportsProvider.documentTypeModel.length : (hasDocs ? 1 : 0))}. ${e.value.taskTypeName}-${e.value.requiredStatuses}',
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

                                      if (!showDate &&
                                          !showTime &&
                                          !showRightList) {
                                        return const SizedBox.shrink();
                                      }

                                      if (isSmallScreen) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (showDate || showTime) ...[
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
                                                if (showDate || showTime)
                                                  Expanded(child: leftSide),
                                                if ((showDate || showTime) &&
                                                    showRightList)
                                                  const SizedBox(width: 16),
                                                if (showRightList)
                                                  Expanded(child: rightSide),
                                                if (!showRightList &&
                                                    (showDate || showTime))
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
                              Text('Comments',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: TextField(
                                  controller: Provider.of<TaskPageProvider>(
                                          context,
                                          listen: false)
                                      .descriptionController,
                                  maxLines: 3,
                                  minLines: 2,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: InputBorder.none,
                                    hintText: 'Enter notes here...',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF1E293B)),
                                ),
                              ),
                              if (settingsProvider.showView[165] == 1) ...[
                                const SizedBox(height: 12),
                                Text('Remarks / Feedback',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3)),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: TextField(
                                    controller: Provider.of<TaskPageProvider>(
                                            context,
                                            listen: false)
                                        .remarksController,
                                    maxLines: 3,
                                    minLines: 2,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                      border: InputBorder.none,
                                      hintText: 'Enter remarks here...',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xFF1E293B)),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Consumer<FormProvider>(
                                builder: (context, formProvider, child) {
                                  if (formProvider.isFetchingCustomerForms) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  final rawForms =
                                      formProvider.customerForms.where((form) {
                                    return form.id.isNotEmpty &&
                                        form.id != '0' &&
                                        form.name.isNotEmpty;
                                  }).toList();

                                  // Deduplicate locally to ensure "One button per form type"
                                  // We prefer the "Definition" (instanceId == null) so the button opens a fresh form.
                                  final Map<String, FormModel> uniqueForms = {};
                                  for (var f in rawForms) {
                                    if (!uniqueForms.containsKey(f.id)) {
                                      uniqueForms[f.id] = f;
                                    } else if (f.instanceId == null &&
                                        uniqueForms[f.id]!.instanceId != null) {
                                      uniqueForms[f.id] = f;
                                    }
                                  }
                                  final validForms =
                                      uniqueForms.values.toList();

                                  if (validForms.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('FORMS',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3)),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: validForms.map((form) {
                                          return InkWell(
                                            onTap: () {
                                              _showWebFormDialog(
                                                  context, form, task);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Container(
                                              width: 180,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEEF2F6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .description_outlined,
                                                      color: Color(0xFF1E293B),
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          "1",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF1E293B),
                                                          ),
                                                        ),
                                                        Text(
                                                          form.name.isNotEmpty
                                                              ? form.name
                                                              : "Attached Form",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );

                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: formFields,
                              ),
                            ),

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
                                                size: 16,
                                                color: Color(0xFF1E293B)),
                                            label: const Text("View History",
                                                style: TextStyle(
                                                    color: Color(0xFF1E293B),
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Color(0xFFE2E8F0)),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 14),
                                            ),
                                            onPressed: () async {
                                              final provider =
                                                  Provider.of<TaskPageProvider>(
                                                      context,
                                                      listen: false);
                                              await provider.fetchTaskHistory(
                                                  task.userDetailsId ?? 0,
                                                  task.taskId ?? 0);
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                          "Task History",
                                                          style: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .textBlack,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.close),
                                                        )
                                                      ],
                                                    ),
                                                    content: Container(
                                                      color: Colors.white,
                                                      width: 500,
                                                      height: 400,
                                                      child: Consumer<
                                                          TaskPageProvider>(
                                                        builder:
                                                            (_, provider, __) {
                                                          if (provider
                                                              .isHistoryLoading) {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          }
                                                          if (provider
                                                              .taskHistoryList
                                                              .isEmpty) {
                                                            return Center(
                                                              child: Text(
                                                                "No history found.",
                                                                style: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  color: Colors
                                                                          .grey[
                                                                      500],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return ListView
                                                              .builder(
                                                            itemCount: provider
                                                                .taskHistoryList
                                                                .length,
                                                            itemBuilder:
                                                                (_, index) {
                                                              final item = provider
                                                                      .taskHistoryList[
                                                                  index];
                                                              const Color
                                                                  statusColor =
                                                                  Color(
                                                                      0xFF3B82F6);
                                                              return Card(
                                                                color: Colors
                                                                    .white,
                                                                elevation: 0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  side: const BorderSide(
                                                                      color: Color(
                                                                          0xFFE2E8F0)),
                                                                ),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            12),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          12),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: statusColor.withOpacity(0.1),
                                                                              borderRadius: BorderRadius.circular(20),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              item.statusName ?? 'Updated',
                                                                              style: GoogleFonts.plusJakartaSans(
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.w700,
                                                                                color: statusColor,
                                                                                letterSpacing: 0.3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              const Icon(
                                                                                Icons.access_time_rounded,
                                                                                size: 13,
                                                                                color: Color(0xFF94A3B8),
                                                                              ),
                                                                              const SizedBox(width: 4),
                                                                              Text(
                                                                                item.entryDate ?? '',
                                                                                style: GoogleFonts.plusJakartaSans(
                                                                                  fontSize: 11.5,
                                                                                  color: const Color(0xFF64748B),
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      if (item.description !=
                                                                              null &&
                                                                          item.description!
                                                                              .trim()
                                                                              .isNotEmpty) ...[
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 12,
                                                                              vertical: 8),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xFFF8FAFC),
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                            border:
                                                                                Border.all(color: const Color(0xFFE2E8F0)),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  const Icon(
                                                                                    Icons.chat_bubble_outline_rounded,
                                                                                    size: 13,
                                                                                    color: Color(0xFF3B82F6),
                                                                                  ),
                                                                                  const SizedBox(width: 6),
                                                                                  Text(
                                                                                    'Comments',
                                                                                    style: GoogleFonts.plusJakartaSans(
                                                                                      fontSize: 11.5,
                                                                                      fontWeight: FontWeight.w700,
                                                                                      color: const Color(0xFF334155),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 4),
                                                                              Text(
                                                                                item.description!,
                                                                                style: GoogleFonts.plusJakartaSans(
                                                                                  fontSize: 12.5,
                                                                                  color: const Color(0xFF1E293B),
                                                                                  height: 1.4,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      if (item.remarks !=
                                                                              null &&
                                                                          item.remarks!
                                                                              .trim()
                                                                              .isNotEmpty) ...[
                                                                        const SizedBox(
                                                                            height:
                                                                                8),
                                                                        Container(
                                                                          width:
                                                                              double.infinity,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 12,
                                                                              vertical: 8),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xFFFFFBEB),
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                            border:
                                                                                Border.all(color: const Color(0xFFFDE68A)),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  const Icon(
                                                                                    Icons.rate_review_outlined,
                                                                                    size: 13,
                                                                                    color: Color(0xFFD97706),
                                                                                  ),
                                                                                  const SizedBox(width: 6),
                                                                                  Text(
                                                                                    'Remarks / Feedback',
                                                                                    style: GoogleFonts.plusJakartaSans(
                                                                                      fontSize: 11.5,
                                                                                      fontWeight: FontWeight.w700,
                                                                                      color: const Color(0xFFB45309),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 4),
                                                                              Text(
                                                                                item.remarks!,
                                                                                style: GoogleFonts.plusJakartaSans(
                                                                                  fontSize: 12.5,
                                                                                  color: const Color(0xFF1E293B),
                                                                                  height: 1.4,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.account_circle_outlined,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                Color(0xFF64748B),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 4),
                                                                          Text(
                                                                            item.byUserName ??
                                                                                '',
                                                                            style:
                                                                                GoogleFonts.plusJakartaSans(
                                                                              fontSize: 11.5,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: const Color(0xFF475569),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    actions: [
                                                      CustomElevatedButton(
                                                        buttonText: 'Close',
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        radius: 4,
                                                        backgroundColor:
                                                            AppColors
                                                                .whiteColor,
                                                        borderColor:
                                                            const Color(
                                                                0xFFE2E8F0),
                                                        textColor: const Color(
                                                            0xFF64748B),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          OutlinedButton(
                                            onPressed: saving
                                                ? null
                                                : () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Color(0xFFE2E8F0)),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                            ),
                                            child: const Text("Cancel",
                                                style: TextStyle(
                                                    color: Color(0xFF1E293B),
                                                    fontWeight:
                                                        FontWeight.w500)),
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
                                                                            4)),
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
                                                                              4)),
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

                                                    final settingsProvider =
                                                        Provider.of<
                                                                SettingsProvider>(
                                                            context,
                                                            listen: false);
                                                    bool
                                                        isDocumentButtonEnabled =
                                                        settingsProvider
                                                                .documentButtonTaskStatus ==
                                                            1;

                                                    if (isDocumentButtonEnabled ||
                                                        provider
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
                                                                await provider
                                                                    .getCurrentLocation(),
                                                                subStatus:
                                                                    selectedSubStatus
                                                                        .value);

                                                        if (!context.mounted) {
                                                          return;
                                                        }

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
                                                        if (!context.mounted) {
                                                          return;
                                                        }
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
                                                                            4)),
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
                                                                              4)),
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
                                              backgroundColor:
                                                  const Color(0xFF1A7AE8),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 28,
                                                      vertical: 14),
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
                                                : const Text('Save',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700)),
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

  Future<List<TaskTypeStatusModel>> getStatusType(
      BuildContext ctx, String taskTypeId) async {
    return Provider.of<DropDownProvider>(ctx, listen: false)
        .getStatusByTaskTypeId(ctx, taskTypeId, '3');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<TaskPageProvider>(
        builder: (contextx, reportsProvider, child) {
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
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                            reportsProvider.enquiryForS,
                          );
                          reportsProvider.goToPage(1);
                          reportsProvider.searchTaskByCustomer(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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
                            reportsProvider.enquiryForS,
                          );
                          reportsProvider.goToPage(1);
                          reportsProvider.searchTaskByCustomer(context);
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

  Widget dateFollowUpWidget() {
    final taskProvider = Provider.of<TaskPageProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow-up Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
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
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: taskProvider.followUpDateController,
                    builder: (_, val, __) {
                      final hasDate = val.text.isNotEmpty;
                      return Text(
                        hasDate ? val.text : 'DD MMM YYYY',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasDate
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget timeFollowUpWidget() {
    final taskProvider = Provider.of<TaskPageProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow-up Time',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              taskProvider.followUpTimeController.text = picked.format(context);
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: taskProvider.followUpTimeController,
                    builder: (_, val, __) {
                      final hasTime = val.text.isNotEmpty;
                      return Text(
                        hasTime ? val.text : 'HH:MM AM/PM',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasTime
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(String displayLogo) {
    if (displayLogo.isEmpty) {
      return Image.asset(
        AppStyles.logo(),
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
    if (displayLogo.startsWith('http')) {
      return Image.network(
        displayLogo,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppStyles.logo(),
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    } else {
      return Image.asset(
        displayLogo,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppStyles.logo(),
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      );
    }
  }

  Widget _buildHeaderPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStatusChip({
    required TaskTypeStatusModel status,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color statusColor = status.colorCode ?? const Color(0xFF3B82F6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? statusColor : statusColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: statusColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : statusColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              status.statusName ?? '',
              style: TextStyle(
                color: isSelected ? Colors.white : statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPriorityFilter(TaskPageProvider taskProvider) {
  return Consumer<SettingsProvider>(
    builder: (context, settingsProvider, child) {
      final List<DropdownMenuItem<int>> items = [
            const DropdownMenuItem<int>(
              value: 0,
              child: Text(
                'All',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ] +
          settingsProvider.priorities
              .map((priority) => DropdownMenuItem<int>(
                    value: priority.priorityId,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        priority.priorityName ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.parseColor(priority.colorCode),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: (taskProvider.selectedPriority != null &&
                    taskProvider.selectedPriority != 0)
                ? AppColors.primaryBlue
                : Colors.grey[300]!,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: taskProvider.selectedPriority ?? 0,
            hint: const Text('Priority: All',
                style: TextStyle(fontSize: 14, color: Colors.black87)),
            items: items,
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((DropdownMenuItem<int> item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Priority: ',
                        style: TextStyle(fontSize: 14, color: Colors.black87)),
                    item.child,
                  ],
                );
              }).toList();
            },
            onChanged: (int? newValue) {
              if (newValue != null) {
                taskProvider.setPriorityFilter(newValue);
                taskProvider.goToPage(1);
                taskProvider.searchTaskByCustomer(context);
              }
            },
            isDense: true,
            iconSize: 18,
          ),
        ),
      );
    },
  );
}

class _HoverMenuAnchor extends StatefulWidget {
  final Widget Function(
      BuildContext, MenuController, void Function(bool), Widget?) builder;
  final List<Widget Function(void Function(bool))> menuChildren;

  const _HoverMenuAnchor({
    required this.builder,
    required this.menuChildren,
  });

  @override
  State<_HoverMenuAnchor> createState() => _HoverMenuAnchorState();
}

class _HoverMenuAnchorState extends State<_HoverMenuAnchor> {
  final MenuController _controller = MenuController();
  Timer? _hoverTimer;

  void _updateHover(bool isIn) {
    _hoverTimer?.cancel();
    if (isIn) {
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      _hoverTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted && _controller.isOpen) {
          _controller.close();
        }
      });
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateHover(true),
      onExit: (_) => _updateHover(false),
      child: MenuAnchor(
        controller: _controller,
        alignmentOffset: const Offset(-20, 0),
        style: MenuStyle(
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(8),
          shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        menuChildren: widget.menuChildren.map((childBuilder) {
          return childBuilder((hovering) => _updateHover(hovering));
        }).toList(),
        builder: (context, controller, child) {
          return widget.builder(context, controller, _updateHover, child);
        },
      ),
    );
  }
}
