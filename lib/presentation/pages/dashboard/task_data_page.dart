import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/job_sheet_page.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_dialog.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_form_filler_view.dart';
import 'package:vidyanexis/presentation/widgets/common/document_preview_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield_search.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/home/task_audio_recording_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/task_card.dart';
import 'package:vidyanexis/utils/extensions.dart';

class TotalTaskDataPage extends StatefulWidget {
  final String source;
  final String fromDate;
  final String toDate;
  final int user;

  const TotalTaskDataPage({
    super.key,
    required this.source,
    required this.fromDate,
    required this.toDate,
    required this.user,
  });

  @override
  State<TotalTaskDataPage> createState() => _TotalTaskDataPageState();
}

class _TotalTaskDataPageState extends State<TotalTaskDataPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  int _totalCount = 0;

  List<TaskReportModel> _tasks = [];
  List<TaskReportModel> _filteredTasks = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _mobileScrollController = ScrollController();

  int? _hoveredRowIndex;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _mobileScrollController.addListener(_mobileScrollListener);
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _fetchTasks();
  }

  void _mobileScrollListener() {
    if (_mobileScrollController.hasClients) {
      if (_mobileScrollController.position.pixels >=
              _mobileScrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMoreData) {
        _fetchTasks(isPagination: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTasks = List.from(_tasks);
        _expandedIndex = null;
      });
    } else {
      final q = query.toLowerCase();
      setState(() {
        _expandedIndex = null;
        _filteredTasks = _tasks.where((task) {
          return task.customerName.toLowerCase().contains(q) ||
              task.mobile.toLowerCase().contains(q) ||
              task.taskTypeName.toLowerCase().contains(q) ||
              task.taskStatusName.toLowerCase().contains(q) ||
              task.toUserName.toLowerCase().contains(q) ||
              task.taskId.toString().contains(q) ||
              task.customerId.toString().contains(q) ||
              (task.leadCode ?? '').toLowerCase().contains(q) ||
              task.description.toLowerCase().contains(q) ||
              (task.consumerNo ?? '').toLowerCase().contains(q) ||
              (task.remark ?? '').toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _mobileScrollController.dispose();
    super.dispose();
  }

  String _formatDateSafely(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr.toLowerCase() == 'null') {
      return '';
    }
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      try {
        return dateStr.toDayMonthYearFormat();
      } catch (_) {
        return dateStr;
      }
    }
  }

  String _followUpDateTime(TaskReportModel task) {
    String date = '';
    try {
      date = task.taskDate.toDayMonthYearFormat();
    } catch (_) {
      date = task.taskDate;
    }
    String time = '';
    if (task.taskTime.isNotEmpty) {
      try {
        final parsed = DateFormat('HH:mm:ss').parse(task.taskTime);
        time = DateFormat('hh:mm a').format(parsed);
      } catch (_) {
        time = task.taskTime;
      }
    }
    return time.isEmpty ? date : '$date $time';
  }

  Future<void> _fetchTasks({bool isPagination = false}) async {
    if (!isPagination) {
      setState(() {
        _isLoading = true;
        _hasMoreData = true;
        _tasks.clear();
        _filteredTasks.clear();
        _currentPage = 1;
      });
    } else {
      if (_isLoadingMore) return;
      setState(() => _isLoadingMore = true);
      _currentPage++;
    }

    final int startLimit = ((_currentPage - 1) * _pageSize) + 1;
    final int endLimit = _currentPage * _pageSize;

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchTaskDashboard,
        bodyData: {
          "lead_Name": "",
          "Is_Date": widget.fromDate.isNotEmpty ? "1" : "0",
          "Fromdate": widget.fromDate,
          "Todate": widget.toDate,
          "To_User_Id": widget.user.toString(),
          "Status_Id": "0",
          "Page_Index1": startLimit.toString(),
          "Page_Index2": endLimit.toString(),
          "Enquiry_For_Id": "0",
          "Enquiry_Source_Id": "0",
          "Source": widget.source,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<TaskReportModel> newTasks = [];

        if (data is Map) {
          final List<dynamic> list = data['Data'] ?? data['data'] ?? [];
          newTasks = list
              .map(
                  (e) => TaskReportModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          _totalCount = int.tryParse(data['Total_Count']?.toString() ??
                  data['total_count']?.toString() ??
                  '0') ??
              0;
        } else if (data is List) {
          newTasks = data
              .map(
                  (e) => TaskReportModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (_totalCount == 0) _totalCount = newTasks.length;
        }

        if (!isPagination) {
          _tasks = newTasks;
        } else {
          if (!AppStyles.isWebScreen(context)) {
            _tasks.addAll(newTasks);
          } else {
            _tasks = newTasks;
          }
        }

        if (_tasks.length >= _totalCount || newTasks.isEmpty) {
          _hasMoreData = false;
        }

        setState(() {
          _filteredTasks = List.from(_tasks);
          if (_searchController.text.isNotEmpty) {
            _onSearchChanged(_searchController.text);
          }
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load tasks: ${response.statusCode}';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (_currentPage * _pageSize >= _totalCount && _totalCount > 0) return;
    await _fetchTasks(isPagination: true);
  }

  Future<void> _fetchPreviousPage() async {
    if (_currentPage <= 1) return;
    setState(() => _currentPage = _currentPage - 2);
    await _fetchTasks(isPagination: true);
  }

  Widget _buildPaginationControls() {
    int startItem = 0;
    int endItem = 0;
    if (_filteredTasks.isNotEmpty) {
      startItem = ((_currentPage - 1) * _pageSize) + 1;
      endItem = startItem + _filteredTasks.length - 1;
    }
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (_currentPage > 1) && !_isLoadingMore
                ? _fetchPreviousPage
                : null,
          ),
          Text(
            'Showing $startItem - $endItem of $_totalCount',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: (endItem < _totalCount) && !_isLoadingMore
                ? _fetchNextPage
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !AppStyles.isWebScreen(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final title = widget.source
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isMobile
          ? CustomAppBar(
              title: title,
              showFilterIcon: false,
              onSearchTap: () => sideProvider.startSearch(),
              onClearTap: () {
                sideProvider.stopSearch();
                _searchController.clear();
              },
              onSearch: (_) {},
              searchController: _searchController,
              leadingWidget: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFF152D70),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: Column(
        children: [
          if (!isMobile)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF152D70)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF152D70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_totalCount > 0)
                    Text(
                      '($_totalCount)',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF152D70),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: 'Search here....',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        suffixIcon: Icon(Icons.search, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF64748B), size: 20),
                    onPressed: () => _fetchTasks(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText(
                    'Total Tasks: $_totalCount',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey3,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredTasks.isEmpty
                        ? const Center(child: Text('No tasks found'))
                        : isMobile
                            ? _buildMobileList()
                            : _buildWebTable(),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 10),
            _buildPaginationControls(),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return RefreshIndicator(
      onRefresh: () => _fetchTasks(),
      child: ListView.builder(
        controller: _mobileScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredTasks.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredTasks.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final task = _filteredTasks[index];
          return Column(
            children: [
              const Divider(height: 1),
              TaskCard(
                task: task,
                isExpanded: _expandedIndex == index,
                onTap: () {
                  setState(() {
                    _expandedIndex = _expandedIndex == index ? null : index;
                  });
                },
                showStatusUpdate: (ctx, t) {
                  final reportsProvider =
                      Provider.of<TaskPageProvider>(context, listen: false);
                  reportsProvider.selectedTaskTypeIds.clear();
                  reportsProvider.taskTypeModel.clear();
                  statusDialogMobile(t).then((value) {
                    if (value == true) {
                      _fetchTasks();
                    }
                  });
                },
              ),
            ],
          );
        },
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

  /// Same columns as TaskPage web table
  Widget _buildWebTable() {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool showLeadCode = settingsProvider.showLeadCode == 1;
    final bool showJobSheet = settingsProvider.jobSheet == 1;

    const double headerH = 48.0;
    const double rowH = 36.0;

    // widths match TaskPage
    final double tableMinWidth = 60 + // No
        (showLeadCode ? 120.0 : 0.0) +
        180 + // Customer
        120 + // Mobile
        180 + // Task
        140 + // Status
        150 + // Enquiry for
        120 + // Staff
        140 + // Consumer No
        180 + // Description
        180 + // Remark
        150 + // Priority
        140 + // Created Date
        120 + // Duration
        120 + // Overdue
        160 + // Followup
        (showJobSheet ? 130.0 : 0.0);

    TextStyle headerStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13,
      fontFamily: 'PlusJakartaSans',
    );
    const TextStyle cellStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 13,
      color: Color(0xFF334155),
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double tableWidth = tableMinWidth > constraints.maxWidth
                ? tableMinWidth
                : constraints.maxWidth;

            return Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header — same order as TaskPage
                      Container(
                        height: headerH,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                child: Text('No.', style: headerStyle),
                              ),
                            ),
                            if (showLeadCode)
                              TableWidget(
                                width: 120,
                                title: 'Lead Code',
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                alignment: Alignment.centerLeft,
                                color: Colors.white,
                              ),
                            const TableWidget(
                              width: 180,
                              title: 'Customer',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              alignment: Alignment.centerLeft,
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 120,
                              title: 'Mobile No.',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 180,
                              title: 'Task',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 140,
                              title: 'Status',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 150,
                              title: 'Enquiry for',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 120,
                              title: 'Staff',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 140,
                              title: 'Consumer No',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 180,
                              title: 'Description',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 180,
                              title: 'Remark',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 150,
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              data: Text(
                                'Priority',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const TableWidget(
                              width: 140,
                              title: 'Created Date',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 120,
                              title: 'Duration',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 120,
                              title: 'Overdue',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            const TableWidget(
                              width: 160,
                              title: 'Followup Date&Time',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            if (showJobSheet)
                              const TableWidget(
                                width: 130,
                                title: 'Job Sheet',
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _verticalScrollController,
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _hoveredRowIndex = index),
                                onExit: (_) =>
                                    setState(() => _hoveredRowIndex = null),
                                child: Container(
                                  height: rowH,
                                  color: index == _hoveredRowIndex
                                      ? const Color(0xFFE2E8F0)
                                      : (index % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFF6F7F9)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          child: Text(
                                            '${(index + 1) + (_currentPage - 1) * _pageSize}',
                                            style: cellStyle,
                                          ),
                                        ),
                                      ),
                                      if (showLeadCode)
                                        TableWidget(
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          title: task.leadCode ?? '-',
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      TableWidget(
                                        width: 180,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.customerName.isNotEmpty
                                              ? task.customerName
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.mobile,
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 180,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.taskTypeName.isNotEmpty
                                              ? task.taskTypeName
                                              : task.taskName,
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          statusDialog(task).then((_) {
                                            if (!mounted) return;
                                            _fetchTasks();
                                          });
                                        },
                                        child: TableWidget(
                                          width: 140,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          data: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  (task.colorCode ?? Colors.blue)
                                                      .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              task.taskStatusName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                    task.colorCode ?? Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'PlusJakartaSans',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 150,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.enquiryForName.isNotEmpty
                                              ? task.enquiryForName
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.toUserName.isNotEmpty
                                              ? task.toUserName
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 140,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          (task.consumerNo ?? '').isNotEmpty
                                              ? task.consumerNo!
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 180,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.description.isNotEmpty
                                              ? task.description
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 180,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          (task.remark ?? '').isNotEmpty
                                              ? task.remark!
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 150,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.priorityName.isNotEmpty
                                              ? task.priorityName
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 140,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.entryDate.isNotEmpty
                                              ? task.entryDate
                                                  .toDayMonthYearFormat()
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.leadDuration.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.overdue.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      TableWidget(
                                        width: 160,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          _followUpDateTime(task),
                                          overflow: TextOverflow.ellipsis,
                                          style: cellStyle,
                                        ),
                                      ),
                                      if (showJobSheet)
                                        TableWidget(
                                          width: 130,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          data: SizedBox(
                                            height: 28,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryBlue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                minimumSize: const Size(70, 28),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        JobSheetPage(
                                                      taskId: task.taskId,
                                                      customerId: int.tryParse(
                                                              task.customerId
                                                                  .toString()) ??
                                                          0,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Job Sheet',
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Status Dialog
  // ========== ADD THESE FIELDS ==========
  final Set<int> _uploadingDocs = {};
  final Map<int, double> _uploadProgress = {};
  final Map<int, String> _uploadedDocUrls = {};
  final Map<int, String> _uploadedDocImageIds = {};
  final ValueNotifier<int> _docTick = ValueNotifier(0);

  void _refreshDocs() => _docTick.value++;
  final GlobalKey<CustomFieldSectionWidgetState> customFieldTaskStatusKey =
      GlobalKey<CustomFieldSectionWidgetState>();

  Future<List<TaskTypeStatusModel>> getStatusType(
      BuildContext ctx, String taskTypeId) async {
    return Provider.of<DropDownProvider>(ctx, listen: false)
        .getStatusByTaskTypeId(ctx, taskTypeId, '3');
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

  Widget _buildUploadOtherDocTile(BuildContext context, TaskReportModel task) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: InkWell(
        onTap: () async {
          final result = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => ImageUploadAlert(
              customerId: task.customerId.toString(),
              taskId: task.taskId.toString(),
            ),
          );

          if (!context.mounted) return;
          _handleUploadedDocumentsResult(result: result, context: context);
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 16, color: AppColors.appViolet),
                    SizedBox(width: 6),
                    Text(
                      'Upload another document',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appViolet,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.appViolet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 16,
                  color: AppColors.appViolet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUploadedDocumentsResult({
    required dynamic result,
    required BuildContext context,
  }) {
    final imageProvider =
        Provider.of<ImageUploadProvider>(context, listen: false);
    final reportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);

    List<dynamic> uploadedList = [];
    if (result is List && result.isNotEmpty) {
      uploadedList = result;
    } else if (imageProvider.lastUploadedDocuments.isNotEmpty) {
      uploadedList = List.from(imageProvider.lastUploadedDocuments);
    }

    if (uploadedList.isNotEmpty) {
      for (var item in uploadedList) {
        if (item is Map) {
          final int docId = item['documentTypeId'] as int? ?? 0;
          String docName = item['documentTypeName'] as String? ?? '';
          final String url = item['url'] as String? ?? '';

          if (docId != 0) {
            if (url.isNotEmpty) {
              _uploadedDocUrls[docId] = url;
            }

            if (docName.isEmpty) {
              try {
                final matched = dropDownProvider.documentType.firstWhere(
                  (d) => d.documentTypeId == docId,
                );
                docName = matched.documentTypeName ?? '';
              } catch (_) {}
            }

            final existingIndex = reportsProvider.documentTypeModel
                .indexWhere((d) => d.documentTypeId == docId);

            if (existingIndex == -1) {
              reportsProvider.addOrUpdateDocumentType(
                DocumentTypeModel(
                  documentTypeId: docId,
                  documentTypeName: docName.isNotEmpty ? docName : 'Document',
                  deleteStatus: 0,
                  isMandatory: false,
                  isView: false,
                ),
              );
            }
          }
        }
      }
      _refreshDocs();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _uploadDocument({
    required BuildContext context,
    required dynamic doc,
    required String customerId,
    required String taskId,
  }) async {
    final int docId = doc.documentTypeId;

    // Guard: skip if the server returned a document type with no valid ID.
    if (docId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot upload: this document type has no valid ID. '
              'Please contact your administrator.'),
        ),
      );
      return;
    }

    final imageProvider =
        Provider.of<ImageUploadProvider>(context, listen: false);
    // Do NOT call clearFiles() here — files from other rows must be preserved
    // so all pending documents are batched together in uploadAllDocumentsGrouped.
    imageProvider.setCutomerId(customerId);
    imageProvider.updateDocumentType(docId, doc.documentTypeName);

    await imageProvider.addFileMobile();
    if (!context.mounted) return;

    // Only examine files belonging to this specific document type.
    final pickedForThisDoc = imageProvider.fileInfoList
        .where((f) => f['docTypeId'] == docId)
        .toList();
    if (pickedForThisDoc.isEmpty) return;

    final file = pickedForThisDoc.first;
    final shouldUpload = await showDocumentPreviewDialog(
      context: context,
      fileName: file['name'] as String? ?? 'document',
      bytes: file['data'] as Uint8List?,
      mimeType: file['mimeType'] as String?,
      onUpload: () async {
        // start progress
        _uploadingDocs.add(docId);
        _uploadProgress[docId] = 0.05;
        _refreshDocs();

        Timer? progressTimer;
        progressTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
          if (!_uploadingDocs.contains(docId)) {
            progressTimer?.cancel();
            return;
          }
          final p = _uploadProgress[docId] ?? 0;
          if (p < 0.9) {
            _uploadProgress[docId] = p + 0.07;
            _refreshDocs();
          }
        });

        try {
          final urls = await imageProvider.uploadAllDocumentsGrouped(
            context,
            shouldPop: false,
            taskId: taskId,
          );

          progressTimer.cancel();
          _uploadProgress[docId] = 1.0;
          _refreshDocs();
          await Future.delayed(const Duration(milliseconds: 200));

          _uploadingDocs.remove(docId);
          _uploadProgress.remove(docId);
          if (urls.isNotEmpty) {
            _uploadedDocUrls[docId] = urls.first;

            // ADD
            final imageId = await _findImageIdByUrl(customerId, urls.first);
            if (imageId != null && imageId != '0') {
              _uploadedDocImageIds[docId] = imageId;
            }
          }
          _refreshDocs();
          return urls.isNotEmpty;
        } catch (_) {
          progressTimer.cancel();
          _uploadingDocs.remove(docId);
          _uploadProgress.remove(docId);
          _refreshDocs();
          rethrow;
        }
      },
    );
    if (shouldUpload != true) {
      // Remove only the files just picked for this doc type;
      // leave everything else staged for other rows.
      imageProvider.removeFilesForDocType(docId);
      return;
    }
  }

  Future<String?> _findImageIdByUrl(String customerId, String url) async {
    final cd = Provider.of<CustomerDetailsProvider>(context, listen: false);
    await cd.getDocument(customerId, context);
    final fileName = url.split('/').last;
    for (final group in cd.documentList) {
      for (final img in group.imageDetails) {
        final path = img.filePath.toString();
        if (path == url ||
            path.endsWith(fileName) ||
            url.endsWith(path.split('/').last)) {
          return img.imageId.toString();
        }
      }
    }
    return null;
  }

  Future<void> _deleteDoc(int docId, String customerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    String? imageId = _uploadedDocImageIds[docId];
    if (imageId == null || imageId == '0') {
      final url = _uploadedDocUrls[docId];
      if (url != null) imageId = await _findImageIdByUrl(customerId, url);
    }
    if (imageId == null || imageId == '0') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete: image not found')),
        );
      }
      return;
    }

    await Provider.of<CustomerDetailsProvider>(context, listen: false)
        .deleteImage(context, imageId, customerId);

    if (!mounted) return;
    setState(() {
      _uploadedDocUrls.remove(docId);
      _uploadedDocImageIds.remove(docId);
    });
    _refreshDocs();
  }

  void _openViewer(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 48,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateFollowUpWidget() {
    final taskProvider = Provider.of<TaskPageProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Follow-up Date',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                          fontFamily: 'PlusJakartaSans',
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
        Text.rich(
          TextSpan(
            text: 'Follow-up Time',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                          fontFamily: 'PlusJakartaSans',
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
                fontFamily: 'PlusJakartaSans',
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

  Future statusDialog(TaskReportModel task) {
    _uploadedDocUrls.clear();
    _uploadedDocImageIds.clear(); // ADD
    _uploadProgress.clear();
    _uploadingDocs.clear();
    // Clear any previously staged files so each dialog session starts fresh.
    Provider.of<ImageUploadProvider>(context, listen: false).clearFiles();
    final prefetchReportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
    final Future<Map<String, dynamic>> locationFuture =
        prefetchReportsProvider.getCurrentLocation();

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
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 900,
              maxHeight: isSmallScreen
                  ? MediaQuery.of(context).size.height * 0.9
                  : 680,
              minHeight: isSmallScreen ? 0 : 400,
              minWidth: isSmallScreen ? 0 : 700,
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
                          fontFamily: 'PlusJakartaSans',
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
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.taskTypeName ?? '',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: task.parsedTaskTypeColor ??
                                      const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'for',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  final sideprovider =
                                      Provider.of<SidebarProvider>(context,
                                          listen: false);
                                  if (task.isLead == '1') {
                                    sideprovider.name = 'Lead /';
                                  } else {
                                    sideprovider.name = 'Customer /';
                                  }
                                  context.push(
                                      '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                },
                                child: Text(
                                  task.customerName,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              if (settingsProvider.menuIsViewMap[225] == 1) ...[
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 28,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text(
                                      'Receipt',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () {
                                      final cdProvider =
                                          Provider.of<CustomerDetailsProvider>(
                                              context,
                                              listen: false);
                                      cdProvider.customerId =
                                          task.customerId.toString();
                                      cdProvider.clearRecieptDetails();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return RecieptCreationWidget(
                                            recieptId: '0',
                                            isEdit: false,
                                            customerId:
                                                task.customerId.toString(),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
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
                                  fontFamily: 'PlusJakartaSans',
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
                                style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: theme.colorScheme.error),
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
                          reportsProvider.clearProcessFlowData();
                          final formProvider =
                              Provider.of<FormProvider>(context, listen: false);
                          formProvider.clearForms();
                          dropDownProvider.getUserDetails(context);
                          reportsProvider.clearTaskUserAssignments();
                          reportsProvider.clearDescription();
                          Provider.of<AudioFileProvider>(context, listen: false)
                              .clearAudios();

                          // formProvider.getFormDataByCustomer(
                          //   task.customerId.toString(),
                          //   enquiryForId: task.enquiryForId.toString(),
                          // );
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

                        // final ValueNotifier<TaskTypeStatusModel>
                        //     selectedStatus = ValueNotifier(defaultStatus);
                        final ValueNotifier<TaskTypeStatusModel>
                            selectedStatus = ValueNotifier(
                                TaskTypeStatusModel()); // for deafult showing status value uncomment above code
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
                                            fontFamily: 'PlusJakartaSans',
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
                                                _uploadedDocUrls.clear();
                                                _uploadedDocImageIds.clear();
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
                                                final formProvider =
                                                    Provider.of<FormProvider>(
                                                        context,
                                                        listen: false);
                                                // await formProvider
                                                //     .getFormDataByCustomer(
                                                //   task.customerId.toString(),
                                                //   enquiryForId: task
                                                //       .enquiryForId
                                                //       .toString(),
                                                //   taskTypeId: tId.toString(),
                                                // );
                                                formProvider
                                                    .fetchAvailableFields(
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
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B))),
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<SubStatus?>(
                                          valueListenable: selectedSubStatus,
                                          builder: (context, subVal, _) {
                                            return DropdownButtonFormField<
                                                SubStatus>(
                                              initialValue: subVal,
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
                                                    fontFamily:
                                                        'PlusJakartaSans',
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                              isExpanded: true,
                                              onChanged: (sub) async {
                                                selectedSubStatus.value = sub;
                                                if (sub != null) {
                                                  await reportsProvider
                                                      .fetchTaskTypes(
                                                    task.taskTypeId,
                                                    sub.subStatusId ?? 0,
                                                    task.customerId,
                                                    task.enquiryForId,
                                                    context,
                                                  );
                                                  final formProvider =
                                                      Provider.of<FormProvider>(
                                                          context,
                                                          listen: false);
                                                  // await formProvider
                                                  //     .getFormDataByCustomer(
                                                  //   task.customerId.toString(),
                                                  //   enquiryForId: task
                                                  //       .enquiryForId
                                                  //       .toString(),
                                                  //   taskTypeId: task.taskTypeId
                                                  //       .toString(),
                                                  // );
                                                  formProvider
                                                      .fetchAvailableFields(
                                                          context);
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
                                                          fontFamily:
                                                              'PlusJakartaSans',
                                                          color: Colors.black,
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

                              // Process Flow / Mandatory Task message banner
                              Consumer<TaskPageProvider>(
                                builder: (context, reportsProvider, child) {
                                  if (reportsProvider.processFlowMessage ==
                                          null ||
                                      reportsProvider
                                          .processFlowMessage!.trim().isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      border: Border.all(
                                          color: const Color(0xFFFCA5A5)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFDC2626),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            reportsProvider.processFlowMessage!,
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF991B1B),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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

                              // Row 2: Next Task + Department
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
                                                    child: Text('Next Task',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'PlusJakartaSans',
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
                                                            fontFamily:
                                                                'PlusJakartaSans',
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
                                                            fontFamily:
                                                                'PlusJakartaSans',
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
                                                    .contains(
                                                        taskItem.uniqueId ??
                                                            taskItem.taskTypeId
                                                                .toString());
                                                return InkWell(
                                                  onTap: () {
                                                    reportsProvider
                                                        .toggleTaskTypeSelection(
                                                            taskItem.uniqueId ??
                                                                taskItem
                                                                    .taskTypeId
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
                                                              // Container(
                                                              //   width: 18,
                                                              //   height: 18,
                                                              //   decoration:
                                                              //       BoxDecoration(
                                                              //     color: selected
                                                              //         ? AppColors
                                                              //             .darkGreen
                                                              //         : Colors
                                                              //             .white,
                                                              //     borderRadius:
                                                              //         BorderRadius
                                                              //             .circular(
                                                              //                 4),
                                                              //     border: Border.all(
                                                              //         color: selected
                                                              //             ? AppColors
                                                              //                 .darkGreen
                                                              //             : Colors
                                                              //                 .grey
                                                              //                 .shade400),
                                                              //   ),
                                                              //   child: selected
                                                              //       ? const Icon(
                                                              //           Icons
                                                              //               .check,
                                                              //           size:
                                                              //               14,
                                                              //           color: Colors
                                                              //               .white)
                                                              //       : null,
                                                              // ),
                                                              // const SizedBox(
                                                              //     width: 10),
                                                              Text(
                                                                  taskItem.taskTypeName ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'PlusJakartaSans',
                                                                      color: Colors
                                                                          .black,
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
                                                                  fontFamily:
                                                                      'PlusJakartaSans',
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
                                                                    // Compute staff list for this department only
                                                                    List<SearchUserDetails>
                                                                        getDepartmentStaff(
                                                                            dynamic
                                                                                departmentId) {
                                                                      if (departmentId ==
                                                                              null ||
                                                                          departmentId
                                                                              .toString()
                                                                              .trim()
                                                                              .isEmpty ||
                                                                          departmentId.toString().trim() ==
                                                                              "0") {
                                                                        return [];
                                                                      }

                                                                      final targetDeptList = departmentId
                                                                          .toString()
                                                                          .trim()
                                                                          .split(
                                                                              ',')
                                                                          .map((e) => e
                                                                              .trim())
                                                                          .where((e) =>
                                                                              e.isNotEmpty)
                                                                          .toList();

                                                                      return dropDownProvider
                                                                          .searchUserDetails
                                                                          .where(
                                                                              (staff) {
                                                                        if (staff.workingStatus !=
                                                                            "1") {
                                                                          return false;
                                                                        }

                                                                        final staffDeptList = (staff.departmentId ??
                                                                                '')
                                                                            .toString()
                                                                            .trim()
                                                                            .split(
                                                                                ',')
                                                                            .map((e) =>
                                                                                e.trim())
                                                                            .where((e) => e.isNotEmpty)
                                                                            .toList();

                                                                        List<String>
                                                                            transferDeptList =
                                                                            [];
                                                                        if (staff.transferDepartments !=
                                                                            null) {
                                                                          if (staff.transferDepartments
                                                                              is Iterable) {
                                                                            for (var t
                                                                                in staff.transferDepartments) {
                                                                              if (t is Map) {
                                                                                final tId = t["Department_Id"]?.toString() ?? t["department_id"]?.toString();
                                                                                if (tId != null) transferDeptList.add(tId.trim());
                                                                              } else if (t != null) {
                                                                                transferDeptList.addAll(t.toString().split(',').map((e) => e.trim()));
                                                                              }
                                                                            }
                                                                          } else {
                                                                            transferDeptList.addAll(staff.transferDepartments.toString().split(',').map((e) =>
                                                                                e.trim()));
                                                                          }
                                                                        }

                                                                        return targetDeptList.any((dept) =>
                                                                            staffDeptList.contains(dept) ||
                                                                            transferDeptList.contains(dept));
                                                                      }).toList();
                                                                    }

                                                                    final departmentStaff =
                                                                        getDepartmentStaff(
                                                                            taskItem.departmentIds);

                                                                    // Default selected user name
                                                                    final taskKey = taskItem
                                                                            .uniqueId ??
                                                                        taskItem
                                                                            .taskTypeId
                                                                            .toString();
                                                                    int?
                                                                        assignedUserId =
                                                                        reportsProvider
                                                                            .taskTypeToUserMap[taskKey];
                                                                    String
                                                                        defaultUserName =
                                                                        '';

                                                                    final leadProvider = Provider.of<
                                                                            LeadsProvider>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                    final int loginUserId = leadProvider.loginUserId !=
                                                                            0
                                                                        ? leadProvider
                                                                            .loginUserId
                                                                        : (int.tryParse(reportsProvider.loginUserId) ??
                                                                            0);

                                                                    if (assignedUserId !=
                                                                        null) {
                                                                      try {
                                                                        final matchedStaff = dropDownProvider
                                                                            .staffData
                                                                            .firstWhere(
                                                                          (s) =>
                                                                              s.userDetailsId ==
                                                                              assignedUserId,
                                                                        );
                                                                        defaultUserName =
                                                                            matchedStaff.userDetailsName ??
                                                                                '';
                                                                      } catch (_) {}
                                                                    } else if (loginUserId !=
                                                                        0) {
                                                                      try {
                                                                        final loggedInStaff =
                                                                            departmentStaff.firstWhere(
                                                                          (s) =>
                                                                              s.userDetailsId ==
                                                                              loginUserId,
                                                                        );
                                                                        assignedUserId =
                                                                            loggedInStaff.userDetailsId;
                                                                        defaultUserName =
                                                                            loggedInStaff.userDetailsName ??
                                                                                '';
                                                                        WidgetsBinding
                                                                            .instance
                                                                            .addPostFrameCallback((_) {
                                                                          if (reportsProvider.taskTypeToUserMap[taskKey] ==
                                                                              null) {
                                                                            reportsProvider.setTaskUser(taskKey,
                                                                                loggedInStaff.userDetailsId);
                                                                          }
                                                                        });
                                                                      } catch (_) {}
                                                                    }

                                                                    return CustomAutocompleteSearch<
                                                                        SearchUserDetails>(
                                                                      key: ValueKey(
                                                                          'user_search_${taskKey}_${assignedUserId ?? 0}'),
                                                                      showOptionsOnTap:
                                                                          true,
                                                                      maxHeight:
                                                                          300,
                                                                      optionsViewOpenDirection:
                                                                          OptionsViewOpenDirection
                                                                              .down,
                                                                      items:
                                                                          departmentStaff,
                                                                      displayStringFunction:
                                                                          (staff) =>
                                                                              staff.userDetailsName ??
                                                                              '',
                                                                      defaultText:
                                                                          defaultUserName,
                                                                      labelText:
                                                                          'User',
                                                                      suffixIcon:
                                                                          const Icon(
                                                                              Icons.search),
                                                                      onTap:
                                                                          () {},
                                                                      onSelected:
                                                                          (SearchUserDetails
                                                                              selected) {
                                                                        dropDownProvider
                                                                            .setSelectedUserId(selected.userDetailsId);

                                                                        reportsProvider
                                                                            .setTaskUser(
                                                                          taskKey,
                                                                          selected
                                                                              .userDetailsId,
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (_) {},
                                                                      onSearch:
                                                                          (_) async {},
                                                                    );
                                                                  },
                                                                )
                                                              : const SizedBox(),
                                                        ),
                                                        Consumer<
                                                            SettingsProvider>(
                                                          builder: (context,
                                                              settingsProvider,
                                                              _) {
                                                            if (settingsProvider
                                                                    .taskDuplicateButton !=
                                                                1) {
                                                              return const SizedBox
                                                                  .shrink();
                                                            }
                                                            return IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  color: AppColors
                                                                      .primaryBlue,
                                                                  size: 20),
                                                              onPressed: () {
                                                                reportsProvider
                                                                    .duplicateTask(
                                                                        index);
                                                              },
                                                              tooltip:
                                                                  'Duplicate Task',
                                                            );
                                                          },
                                                        ),
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
                                                /*
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'PlusJakartaSans',
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontWeight:
                                                            FontWeight.w500)), */
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
                                                              final result =
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
                                                                  taskId: task
                                                                      .taskId
                                                                      .toString(),
                                                                ),
                                                              );
                                                              if (!context
                                                                  .mounted)
                                                                return;
                                                              _handleUploadedDocumentsResult(
                                                                result: result,
                                                                context:
                                                                    context,
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
                                                        ValueListenableBuilder<
                                                            int>(
                                                          valueListenable:
                                                              _docTick,
                                                          builder:
                                                              (_, __, ___) {
                                                            return Column(
                                                              children:
                                                                  reportsProvider
                                                                      .documentTypeModel
                                                                      .map(
                                                                          (doc) {
                                                                final int
                                                                    docId =
                                                                    doc.documentTypeId ??
                                                                        0;
                                                                final bool
                                                                    isUploading =
                                                                    _uploadingDocs
                                                                        .contains(
                                                                            docId);
                                                                final double
                                                                    progress =
                                                                    _uploadProgress[
                                                                            docId] ??
                                                                        0;
                                                                final String?
                                                                    url =
                                                                    _uploadedDocUrls[
                                                                        docId];
                                                                final bool
                                                                    isUploaded =
                                                                    url != null &&
                                                                        url.isNotEmpty;

                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Text.rich(
                                                                              TextSpan(
                                                                                text: doc.documentTypeName ?? '',
                                                                                style: const TextStyle(
                                                                                  fontFamily: 'PlusJakartaSans',
                                                                                  color: Colors.black,
                                                                                  fontSize: 13,
                                                                                ),
                                                                                children: [
                                                                                  if (doc.isMandatory)
                                                                                    const TextSpan(
                                                                                      text: ' *',
                                                                                      style: TextStyle(
                                                                                        color: Color(0xFFDC2626),
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          if (isUploaded)
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                InkWell(
                                                                                  onTap: () => _openViewer(
                                                                                    context,
                                                                                    url!,
                                                                                    doc.documentTypeName ?? 'Document',
                                                                                  ),
                                                                                  child: const Text(
                                                                                    'View',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'PlusJakartaSans',
                                                                                      color: Color(0xFF1A7AE8),
                                                                                      fontSize: 13,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(width: 10),
                                                                                // ADD THIS
                                                                                InkWell(
                                                                                  onTap: () => _deleteDoc(docId, task.customerId.toString()),
                                                                                  child: const Text('Delete',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'PlusJakartaSans',
                                                                                        color: Color(0xFFDC2626),
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      )),
                                                                                ),
                                                                                const SizedBox(width: 6),
                                                                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                                                              ],
                                                                            )
                                                                          else if (isUploading)
                                                                            Text(
                                                                              '${(progress * 100).toInt()}%',
                                                                              style: const TextStyle(
                                                                                fontFamily: 'PlusJakartaSans',
                                                                                fontSize: 12,
                                                                                color: Color(0xFF1A7AE8),
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            )
                                                                          else
                                                                            InkWell(
                                                                              onTap: () => _uploadDocument(
                                                                                context: context,
                                                                                doc: doc,
                                                                                customerId: task.customerId.toString(),
                                                                                taskId: task.taskId.toString(),
                                                                              ),
                                                                              child: Container(
                                                                                padding: const EdgeInsets.all(4),
                                                                                decoration: BoxDecoration(
                                                                                  color: AppColors.darkGreen.withOpacity(0.1),
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                ),
                                                                                child: const Icon(
                                                                                  Icons.upload_rounded,
                                                                                  size: 16,
                                                                                  color: AppColors.darkGreen,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                      if (isUploading)
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 6),
                                                                          child:
                                                                              LinearProgressIndicator(
                                                                            value:
                                                                                progress,
                                                                            minHeight:
                                                                                3,
                                                                            backgroundColor:
                                                                                const Color(0xFFE2E8F0),
                                                                            color:
                                                                                const Color(0xFF1A7AE8),
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            );
                                                          },
                                                        ),
                                                      if (hasDocs &&
                                                          !isDocumentButtonEnabled)
                                                        _buildUploadOtherDocTile(
                                                            context, task),
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
                                                                          fontFamily:
                                                                              'PlusJakartaSans',
                                                                          color: Colors
                                                                              .black,
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
                                      fontFamily: 'PlusJakartaSans',
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
                                        fontFamily: 'PlusJakartaSans',
                                        color: Colors.grey.shade400,
                                        fontSize: 13),
                                  ),
                                  style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      color: Color(0xFF1E293B)),
                                ),
                              ),
                              if (settingsProvider.showView[165] == 1) ...[
                                const SizedBox(height: 12),
                                Text('Remarks / Feedback',
                                    style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
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
                                          fontFamily: 'PlusJakartaSans',
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                    ),
                                    style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 14,
                                        color: Color(0xFF1E293B)),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const TaskAudioRecordingWidget(),
                              const SizedBox(height: 16),
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
                                              fontFamily: 'PlusJakartaSans',
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
                                                            fontFamily:
                                                                'PlusJakartaSans',
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
                                                            fontFamily:
                                                                'PlusJakartaSans',
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
                                                    fontFamily:
                                                        'PlusJakartaSans',
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
                                                    fontFamily:
                                                        'PlusJakartaSans',
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
                                                    if (provider.processFlowMessage !=
                                                            null &&
                                                        provider
                                                            .processFlowMessage!
                                                            .trim()
                                                            .isNotEmpty) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
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
                                                                const Icon(
                                                                    Icons
                                                                        .warning_amber_rounded,
                                                                    color: Color(
                                                                        0xFFDC2626)),
                                                                const SizedBox(
                                                                    width: 10),
                                                                const Text(
                                                                    "Cannot Proceed",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'PlusJakartaSans',
                                                                        color: Colors
                                                                            .black,
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
                                                                          400),
                                                              child: Text(
                                                                provider
                                                                    .processFlowMessage!,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'PlusJakartaSans',
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15,
                                                                ),
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
                                                                child: const Text(
                                                                    "OK"),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      return;
                                                    }

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
                                                                        fontFamily:
                                                                            'PlusJakartaSans',
                                                                        color: Colors
                                                                            .black,
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
                                                                          fontFamily:
                                                                              'PlusJakartaSans',
                                                                          color: Colors
                                                                              .black,
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

                                                    if (selectedStatus.value
                                                                .statusId ==
                                                            null ||
                                                        selectedStatus.value
                                                                .statusId ==
                                                            0) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
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
                                                                      .darkGreen,
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                const Text(
                                                                  "Unable to Save",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'PlusJakartaSans',
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content: const Text(
                                                              "Please choose a status",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PlusJakartaSans',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
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
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(4),
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10,
                                                                  ),
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

                                                    //Remark Mandatory Check
                                                    // Follow-up Date Mandatory Check
                                                    final bool
                                                        isFollowupDateRequired =
                                                        selectedStatus.value
                                                                    .followup ==
                                                                1 ||
                                                            selectedStatus.value
                                                                    .viewDateFollowup ==
                                                                1;
                                                    if (isFollowupDateRequired &&
                                                        provider
                                                            .followUpDateController
                                                            .text
                                                            .trim()
                                                            .isEmpty) {
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
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'PlusJakartaSans',
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content: const Text(
                                                              "Follow-up Date Missing",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PlusJakartaSans',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
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

                                                    // Follow-up Time Mandatory Check
                                                    final bool
                                                        isFollowupTimeRequired =
                                                        selectedStatus
                                                                .value.isTime ==
                                                            1;
                                                    if (isFollowupTimeRequired &&
                                                        provider
                                                            .followUpTimeController
                                                            .text
                                                            .trim()
                                                            .isEmpty) {
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
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'PlusJakartaSans',
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content: const Text(
                                                              "Follow-up Time Missing",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'PlusJakartaSans',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
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

                                                    int remarkMandatoty =
                                                        settingsProvider
                                                            .taskRemarkMandatory;
                                                    int ramcoAdminTaskPhoto =
                                                        settingsProvider
                                                            .ramcoAdminTaskPhoto;
                                                    SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String userId =
                                                        preferences.getString(
                                                                'userId') ??
                                                            "0";

                                                    final bool
                                                        isRemarkRequired =
                                                        remarkMandatoty == 1
                                                            ? true
                                                            : (ramcoAdminTaskPhoto ==
                                                                    1 &&
                                                                userId == "1");
                                                    if (isRemarkRequired &&
                                                        provider
                                                            .remarksController
                                                            .text
                                                            .isEmpty) {
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
                                                                        fontFamily:
                                                                            'PlusJakartaSans',
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20)),
                                                              ],
                                                            ),
                                                            content: const Text(
                                                                "Remark Missing",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'PlusJakartaSans',
                                                                    color: Colors
                                                                        .black,
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
                                                      return;
                                                    }

                                                    // Custom Fields Mandatory Check
                                                    final bool
                                                        hasMandatoryCustomFields =
                                                        provider
                                                            .showCustomFields
                                                            .any((f) =>
                                                                f.isMandatory ==
                                                                1);
                                                    if (hasMandatoryCustomFields) {
                                                      List<String>
                                                          customFieldErrors =
                                                          [];
                                                      if (customFieldTaskStatusKey
                                                              .currentState !=
                                                          null) {
                                                        final validation =
                                                            customFieldTaskStatusKey
                                                                .currentState!
                                                                .validateForm();
                                                        if (!validation
                                                                .isValid ||
                                                            validation.errors
                                                                .isNotEmpty) {
                                                          customFieldErrors =
                                                              validation.errors
                                                                      .isNotEmpty
                                                                  ? validation
                                                                      .errors
                                                                  : [
                                                                      "Please fill mandatory custom fields"
                                                                    ];
                                                        }
                                                      }
                                                      if (customFieldErrors
                                                          .isEmpty) {
                                                        for (final f in provider
                                                            .showCustomFields) {
                                                          if (f.isMandatory ==
                                                                  1 &&
                                                              f.customFieldId !=
                                                                  null) {
                                                            final val = customFieldTaskStatusKey
                                                                    .currentState
                                                                    ?.getFieldValue(
                                                                        f.customFieldId!)
                                                                    ?.value ??
                                                                f.datavalue;
                                                            final fieldType =
                                                                CustomFieldType
                                                                    .fromValue(f
                                                                        .customFieldTypeId);
                                                            if (fieldType ==
                                                                CustomFieldType
                                                                    .checkbox) {
                                                              final availableOptions = (f
                                                                          .checkboxValues ??
                                                                      [])
                                                                  .map((o) => o
                                                                      .checkBoxValues
                                                                      ?.toString()
                                                                      .trim()
                                                                      .toLowerCase())
                                                                  .where((o) =>
                                                                      o !=
                                                                          null &&
                                                                      o.isNotEmpty)
                                                                  .toSet();
                                                              bool selected =
                                                                  false;
                                                              if (val != null &&
                                                                  val
                                                                      .trim()
                                                                      .isNotEmpty &&
                                                                  val != "0" &&
                                                                  val.toLowerCase() !=
                                                                      "false") {
                                                                final parts = val
                                                                    .split(',')
                                                                    .map((e) => e
                                                                        .trim())
                                                                    .where((e) =>
                                                                        e.isNotEmpty &&
                                                                        e !=
                                                                            "0" &&
                                                                        e.toLowerCase() !=
                                                                            "false")
                                                                    .toList();
                                                                if (availableOptions
                                                                    .isNotEmpty) {
                                                                  selected = parts
                                                                      .any((p) =>
                                                                          availableOptions
                                                                              .contains(p.toLowerCase()));
                                                                } else {
                                                                  selected = parts
                                                                      .isNotEmpty;
                                                                }
                                                              }
                                                              if (!selected) {
                                                                customFieldErrors
                                                                    .add(
                                                                        '${f.customFieldName ?? "Custom field"} is required');
                                                              }
                                                            } else if (fieldType ==
                                                                    CustomFieldType
                                                                        .fileUpload ||
                                                                fieldType ==
                                                                    CustomFieldType
                                                                        .signature) {
                                                              final hasPending = customFieldTaskStatusKey
                                                                      .currentState
                                                                      ?.getPendingFileBytes()
                                                                      .containsKey(
                                                                          f.customFieldId!) ??
                                                                  false;
                                                              final hasVal = val !=
                                                                      null &&
                                                                  val
                                                                      .trim()
                                                                      .isNotEmpty;
                                                              if (!hasVal &&
                                                                  !hasPending) {
                                                                customFieldErrors
                                                                    .add(
                                                                        '${f.customFieldName ?? "Custom field"} is required');
                                                              }
                                                            } else {
                                                              if (val == null ||
                                                                  val
                                                                      .trim()
                                                                      .isEmpty) {
                                                                customFieldErrors
                                                                    .add(
                                                                        '${f.customFieldName ?? "Custom field"} is required');
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }

                                                      if (customFieldErrors
                                                          .isNotEmpty) {
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
                                                                      width:
                                                                          10),
                                                                  const Text(
                                                                    "Unable to Save",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'PlusJakartaSans',
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Text(
                                                                    "Custom Fields Not Filled",
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'PlusJakartaSans',
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  if (customFieldErrors
                                                                      .isNotEmpty) ...[
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                    ...customFieldErrors.map(
                                                                        (err) =>
                                                                            Text(
                                                                              "• $err",
                                                                              style: const TextStyle(
                                                                                fontFamily: 'PlusJakartaSans',
                                                                                color: Colors.black87,
                                                                                fontSize: 14,
                                                                              ),
                                                                            )),
                                                                  ],
                                                                ],
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
                                                                            BorderRadius.circular(4)),
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
                                                    }

                                                    bool
                                                        hasPendingMandatoryDocs =
                                                        provider
                                                            .documentTypeModel
                                                            .any((doc) {
                                                      final int docId =
                                                          doc.documentTypeId;
                                                      final bool isUploaded =
                                                          _uploadedDocUrls[
                                                                      docId] !=
                                                                  null &&
                                                              _uploadedDocUrls[
                                                                      docId]!
                                                                  .isNotEmpty;
                                                      return doc.isMandatory &&
                                                          !isUploaded;
                                                    });

                                                    if (!hasPendingMandatoryDocs ||
                                                        (ramcoAdminTaskPhoto ==
                                                                1 &&
                                                            userId == "1")) {
                                                      isSaving.value = true;
                                                      try {
                                                        final audioProvider =
                                                            Provider.of<
                                                                    AudioFileProvider>(
                                                                context,
                                                                listen: false);
                                                        List<
                                                                Map<String,
                                                                    String>>
                                                            uploadedAudioFiles =
                                                            [];
                                                        if (audioProvider.audios
                                                            .isNotEmpty) {
                                                          uploadedAudioFiles =
                                                              await audioProvider
                                                                  .uploadAllAudios(
                                                            task.taskId
                                                                .toString(),
                                                            context,
                                                          );
                                                        }

                                                        bool isSuccess = await provider
                                                            .changeTaskStatus(
                                                                context,
                                                                selectedStatus
                                                                    .value,
                                                                task.taskId,
                                                                await locationFuture,
                                                                subStatus:
                                                                    selectedSubStatus
                                                                        .value,
                                                                audioFiles:
                                                                    uploadedAudioFiles);

                                                        if (!context.mounted) {
                                                          return;
                                                        }

                                                        if (isSuccess) {
                                                          audioProvider
                                                              .clearAudios();
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
                                                                        fontFamily:
                                                                            'PlusJakartaSans',
                                                                        color: Colors
                                                                            .black,
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
                                                                    fontFamily:
                                                                        'PlusJakartaSans',
                                                                    color: Colors
                                                                        .black,
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
                                                        fontFamily:
                                                            'PlusJakartaSans',
                                                        color: Colors.black,
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
}
