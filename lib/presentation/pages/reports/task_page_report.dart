import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class TaskPageReport extends StatefulWidget {
  final bool fromDashBoard;

  const TaskPageReport({super.key, this.fromDashBoard = false});

  @override
  State<TaskPageReport> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPageReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1);
      reportsProvider.getSearchTaskReport(context);

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
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    if (!AppStyles.isWebScreen(context)) {
      return const TaskPageReportMobile();
    }

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: _buildPaginationControls(context),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  // Header
                  if (widget.fromDashBoard) ...[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF152D70),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          ScaffoldState? parent;
                          context.visitAncestorElements((element) {
                            if (element is StatefulElement &&
                                element.state is ScaffoldState) {
                              ScaffoldState scaffold =
                                  element.state as ScaffoldState;
                              if (scaffold.hasDrawer) {
                                parent = scaffold;
                                return false;
                              }
                            }
                            return true;
                          });
                          parent?.openDrawer();
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.sort,
                            size: 20,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Task Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF152D70),
                    ),
                  ),
                  const SizedBox(width: 32),
                  const Spacer(),
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
                              searchController.selection.baseOffset == 0 &&
                              searchController.selection.extentOffset ==
                                  searchController.text.length) {
                            searchController.selection =
                                TextSelection.collapsed(
                                    offset: searchController.text.length);
                          }
                        });
                      },
                      onSubmitted: (query) {
                        reportsProvider.setTaskSearchCriteria(
                          query,
                          reportsProvider.fromDateS,
                          reportsProvider.toDateS,
                          reportsProvider.Status,
                          reportsProvider.AssignedTo,
                          reportsProvider.TaskType,
                        );
                        reportsProvider.getSearchTaskReport(context,
                            resetPage: true);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search here....',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            reportsProvider.setTaskSearchCriteria(
                              searchController.text,
                              reportsProvider.fromDateS,
                              reportsProvider.toDateS,
                              reportsProvider.Status,
                              reportsProvider.AssignedTo,
                              reportsProvider.TaskType,
                            );
                            reportsProvider.getSearchTaskReport(context,
                                resetPage: true);
                          },
                          child: const Icon(Icons.search,
                              color: Color(0xFF64748B), size: 18),
                        ),
                      ),
                    ),
                  ),
                  CustomFilterButton(
                    onPressed: () {
                      reportsProvider.toggleFilter();
                    },
                    isFilter: reportsProvider.isFilter,
                  ),
                  const SizedBox(width: 16),
                  CommonReportExportButton(
                      onPressed: () async {
                      final allTasks =
                          await reportsProvider.fetchAllTasksForExport(context);
                      if (allTasks.isNotEmpty) {
                        exportToExcel(
                          headers: [
                            'Customer Name',
                            'Phone Number',
                            'Address',
                            'Task',
                            'Enquiry for',
                            'Assigned To',
                            'Description',
                            'Date',
                            'Location',
                            'Status'
                          ],
                          data: allTasks.map((task) {
                            return {
                              'Customer Name': task.customerName,
                              'Phone Number': task.mobile,
                              'Address':
                                  '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                              'Task': task.taskTypeName,
                              'Enquiry for': task.enquiryForName,
                              'Assigned To': task.toUserName,
                              'Description': task.description,
                              'Date': task.entryDate.isNotEmpty
                                  ? DateFormat('dd MMM yyyy')
                                      .format(DateTime.parse(task.entryDate))
                                  : '',
                              'Location': task.location,
                              'Status': task.taskStatusName,
                            };
                          }).toList(),
                          fileName: 'Task_Report',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No data found')),
                        );
                      }
                    },
                      label: 'Export',
                    )
                ],
              ),
            ),
            if (reportsProvider.isFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildStatusFilter(reportsProvider, provider),
                    const SizedBox(
                      width: 10,
                    ),
                    CommonReportDateFilter(
                      fromDate: reportsProvider.fromDate?.toString(),
                      toDate: reportsProvider.toDate?.toString(),
                      formattedFromDate: reportsProvider.formattedFromDate,
                      formattedToDate: reportsProvider.formattedToDate,
                      onTap: () => onClickTopButton(context),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedUser != null &&
                                    reportsProvider.selectedUser != 0
                                ? AppColors.primaryBlue
                                : AppColors.primaryBlue),
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
                                    .map((status) => DropdownMenuItem<int>(
                                          value: status.userDetailsId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              status.userDetailsName ?? '',
                                              overflow: TextOverflow
                                                  .ellipsis, // Adds ellipsis when the text is too long
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setUserFilterStatus(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  reportsProvider.selectedStatus.toString();
                              String assignedTo =
                                  reportsProvider.selectedUser.toString();
                              String fromDate =
                                  reportsProvider.formattedFromDate;
                              String toDate = reportsProvider.formattedToDate;
                              String taskType =
                                  reportsProvider.selectedTaskType.toString();
                              reportsProvider.setTaskSearchCriteria(
                                reportsProvider.Search,
                                fromDate,
                                toDate,
                                status,
                                assignedTo,
                                taskType,
                              );
                              reportsProvider.getSearchTaskReport(context,
                                  resetPage: true);
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
                      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: reportsProvider.selectedTaskType != null &&
                                    reportsProvider.selectedTaskType != 0
                                ? AppColors.primaryBlue
                                : AppColors.primaryBlue),
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
                                    .map((status) => DropdownMenuItem<int>(
                                          value: status.taskTypeId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              status.taskTypeName,
                                              overflow: TextOverflow
                                                  .ellipsis, // Adds ellipsis when the text is too long
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setTaskType(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  reportsProvider.selectedStatus.toString();
                              String assignedTo =
                                  reportsProvider.selectedUser.toString();
                              String fromDate =
                                  reportsProvider.formattedFromDate;
                              String toDate = reportsProvider.formattedToDate;
                              String tasktype =
                                  reportsProvider.selectedTaskType.toString();
                              reportsProvider.setTaskSearchCriteria(
                                reportsProvider.Search,
                                fromDate,
                                toDate,
                                status,
                                assignedTo,
                                tasktype,
                              );
                              reportsProvider.getSearchTaskReport(context,
                                  resetPage: true);
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null ||
                        (reportsProvider.selectedStatus != null &&
                            reportsProvider.selectedStatus != 0) ||
                        (reportsProvider.selectedUser != null &&
                            reportsProvider.selectedUser != 0) ||
                        (reportsProvider.selectedTaskType != null &&
                            reportsProvider.selectedTaskType != 0) ||
                        reportsProvider.Search.isNotEmpty)
                      CommonReportResetButton(
                        onReset: () {
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.toggleStatus(0); // Reset to All
                          searchController.clear();
                          reportsProvider.setTaskSearchCriteria(
                            '',
                            '',
                            '',
                            '0',
                            '',
                            '',
                          );
                          reportsProvider.getSearchTaskReport(context,
                              resetPage: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          elevation: 0,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 1700
                      ? 1700
                      : MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Header Row (Table Column Titles)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF2F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 60,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 12.0),
                                          child: const Text('No.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 180,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Customer Name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 140,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Phone Number',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 150,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Address',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 160,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Task',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 140,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Enquiry for',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 140,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Staff',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Description',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 130,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Date',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 150,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Location',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 100,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Status',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                  SizedBox(
                                      width: 100,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8.0),
                                          child: const Text('Details',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF607185))))),
                                ],
                              ),
                            ),
                            // Data Rows
                            reportsProvider.taskReport.isEmpty
                                ? const CommonEmptyState(
                                    message: 'No task reports found')
                                : Column(
                                    children: List.generate(
                                        reportsProvider.taskReport.length,
                                        (index) {
                                      var task =
                                          reportsProvider.taskReport[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0
                                              ? Colors.white
                                              : const Color(0xFFF6F7F9),
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                                width: 60,
                                                child: Text(((reportsProvider
                                                                    .pageIndex -
                                                                1) *
                                                            reportsProvider
                                                                .pageSize +
                                                        index +
                                                        1)
                                                    .toString())),
                                            SizedBox(
                                              width: 180,
                                              child: InkWell(
                                                onTap: () {
                                                  context.push(
                                                      '${CustomerDetailsScreen.route}${task.customerId.toString()}/true');
                                                },
                                                child: Text(
                                                  task.customerName,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.blue),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 140,
                                              child: Text(
                                                task.mobile,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: Tooltip(
                                                message:
                                                    '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                                                child: Text(
                                                  '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: 160,
                                                child: Text(task.taskTypeName,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            SizedBox(
                                                width: 140,
                                                child: Text(task.enquiryForName,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            SizedBox(
                                                width: 140,
                                                child: Text(task.toUserName,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            Expanded(
                                              child: Text(
                                                task.description,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 130,
                                              child: Text((task
                                                      .entryDate.isNotEmpty)
                                                  ? DateFormat('dd MMM yyyy')
                                                      .format(DateTime.parse(
                                                          task.entryDate))
                                                  : ''),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: Tooltip(
                                                message: task.locationName.isNotEmpty 
                                                    ? task.locationName 
                                                    : task.location.isEmpty ? 'No Location' : task.location,
                                                child: Text(
                                                  task.locationName.isNotEmpty 
                                                      ? task.locationName 
                                                      : task.location.isEmpty ? 'No Location' : task.location,
                                                  style: const TextStyle(fontSize: 14),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: SizedBox(
                                                  height: 28,
                                                  child: Container(
                                                    padding: task.taskStatusName
                                                            .isNotEmpty
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4)
                                                        : EdgeInsets.zero,
                                                    decoration: BoxDecoration(
                                                      color: StatusUtils
                                                          .getTaskColor(task
                                                              .taskStatusId),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: Colors.black45,
                                                          width: 0.1),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        task.taskStatusName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: StatusUtils
                                                                .getTaskTextColor(
                                                                    task.taskStatusId),
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: SizedBox(
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors
                                                                .primaryBlue,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 6),
                                                        minimumSize:
                                                            const Size(80, 32),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4))),
                                                    onPressed: () async {
                                                      String taskId = task
                                                          .taskMasterId
                                                          .toString();
                                                      String customerId = task
                                                          .customerId
                                                          .toString();
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
                                                                showEdit:
                                                                    false);
                                                          });
                                                    },
                                                    child:
                                                        const Text('Details'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                          );
                          reportsProvider.getSearchTaskReport(context,
                              resetPage: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                          reportsProvider.getSearchTaskReport(context,
                              resetPage: true);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildPaginationControls(BuildContext context) {
    return Consumer<TaskReportProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 0 || provider.taskReport.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Tasks: ${provider.totalSize > 0 ? provider.totalSize : provider.taskReport.length}',
                  style: const TextStyle(
                    color: Color(0xFF6C7C93),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: provider.pageIndex > 1
                        ? () {
                            provider.previousPage();
                            provider.getSearchTaskReport(context);
                          }
                        : null,
                  ),
                  ...List.generate(provider.totalPages, (index) {
                    int page = index + 1;
                    if (provider.totalPages > 7) {
                      if (index > 1 &&
                          index < provider.totalPages - 2 &&
                          (page < provider.pageIndex - 1 ||
                              page > provider.pageIndex + 1)) {
                        if (page == provider.pageIndex - 2 ||
                            page == provider.pageIndex + 2) {
                          return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('...'));
                        }
                        return const SizedBox.shrink();
                      }
                    }

                    bool isSelected = page == provider.pageIndex;
                    return InkWell(
                      onTap: () {
                        if (!isSelected) {
                          provider.goToPage(page);
                          provider.getSearchTaskReport(context);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : const Color(0xFFEaeaeb),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: provider.pageIndex < provider.totalPages
                        ? () {
                            provider.nextPage();
                            provider.getSearchTaskReport(context);
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter(
      TaskReportProvider reportsProvider, DropDownProvider dropDownProvider) {
    final bool hasSelection = reportsProvider.selectedStatusIds.isNotEmpty &&
        reportsProvider.selectedStatusIds.first != 0;

    // Build label text from selected statuses
    String labelText = 'All';
    if (hasSelection) {
      final selectedNames = dropDownProvider.followUpData
          .where((s) => reportsProvider.selectedStatusIds.contains(s.statusId))
          .map((s) => s.statusName ?? '')
          .toList();
      labelText = selectedNames.join(', ');
    }

    return Container(
      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasSelection ? AppColors.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (ctx) {
                  return _StatusMultiSelectDialog(
                    allStatuses: dropDownProvider.followUpData,
                    selectedIds:
                        List<int>.from(reportsProvider.selectedStatusIds),
                    onApply: (selectedIds) {
                      if (selectedIds.isEmpty || selectedIds.contains(0)) {
                        reportsProvider.toggleStatus(0);
                      } else {
                        reportsProvider.toggleStatus(0); // Reset first
                        for (final id in selectedIds) {
                          reportsProvider.toggleStatus(id);
                        }
                      }
                      reportsProvider.setTaskSearchCriteria(
                        reportsProvider.Search,
                        reportsProvider.fromDateS,
                        reportsProvider.toDateS,
                        reportsProvider.Status,
                        reportsProvider.AssignedTo,
                        reportsProvider.TaskType,
                      );
                      reportsProvider.getSearchTaskReport(context,
                          resetPage: true);
                    },
                  );
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.15),
                  child: Text(
                    'Status: $labelText',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          hasSelection ? AppColors.primaryBlue : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: hasSelection ? AppColors.primaryBlue : Colors.black45,
                ),
              ],
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                reportsProvider.toggleStatus(0); // Reset to All
                reportsProvider.setTaskSearchCriteria(
                  reportsProvider.Search,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                  reportsProvider.TaskType,
                );
                reportsProvider.getSearchTaskReport(context, resetPage: true);
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select Status dialog (Adapted for Task Report)
// ---------------------------------------------------------------------------
class _StatusMultiSelectDialog extends StatefulWidget {
  final List allStatuses;
  final List<int> selectedIds;
  final void Function(List<int>) onApply;

  const _StatusMultiSelectDialog({
    required this.allStatuses,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<_StatusMultiSelectDialog> createState() =>
      _StatusMultiSelectDialogState();
}

class _StatusMultiSelectDialogState extends State<_StatusMultiSelectDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<int>.from(widget.selectedIds);
    _tempSelected.remove(0);
  }

  void _toggle(int id) {
    setState(() {
      if (_tempSelected.contains(id)) {
        _tempSelected.remove(id);
      } else {
        _tempSelected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Status',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allStatuses.length,
                itemBuilder: (ctx, idx) {
                  final status = widget.allStatuses[idx];
                  final id = status.statusId;
                  final name = status.statusName ?? '';
                  final isSelected = _tempSelected.contains(id);

                  return InkWell(
                    onTap: () => _toggle(id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(name,
                                  style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
