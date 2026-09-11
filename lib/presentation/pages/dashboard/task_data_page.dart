import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/home/task_card.dart';

class TotalTaskDataPage extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final int user;

  const TotalTaskDataPage({
    super.key,
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
              task.description.toLowerCase().contains(q);
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
    } catch (e) {
      return dateStr;
    }
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
          "Source": "Total_Task",
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isMobile
          ? CustomAppBar(
              title: 'Total Task',
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
          // ========== WEB HEADER ==========
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
                  const Text(
                    'Total Task',
                    style: TextStyle(
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
                  const SizedBox(width: 16),
                ],
              ),
            ),

          // ========== BODY ==========
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredTasks.isEmpty
                        ? const Center(child: Text("No tasks found"))
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

  // ==================== MOBILE ====================
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
                showStatusUpdate: (ctx, t) {},
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== WEB TABLE (SINGLE SCROLL like TaskPage) ====================
  Widget _buildWebTable() {
    const double headerH = 48.0;
    const double rowH = 36.0;
    const double tableMinWidth = 1700; // adjust if needed

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
                      // ========== HEADER ==========
                      Container(
                        height: headerH,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                child: Text('No.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ),
                            TableWidget(
                              width: 110,
                              title: 'Lead Code',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              alignment: Alignment.centerLeft,
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 180,
                              title: 'Customer',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              alignment: Alignment.centerLeft,
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 120,
                              title: 'Mobile No.',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 180,
                              title: 'Task',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 150,
                              title: 'Enquiry for',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 140,
                              title: 'Staff',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 140,
                              title: 'Status',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 130,
                              title: 'Task Date',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 130,
                              title: 'Entry Date',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 120,
                              title: 'Priority',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                            TableWidget(
                              width: 220,
                              title: 'Description',
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // ========== ROWS (vertical scroll) ==========
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
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : const Color(0xFFF6F7F9),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          child: Text(
                                            '${(index + 1) + (_currentPage - 1) * _pageSize}',
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 110,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.leadCode ?? '-',
                                          style: const TextStyle(fontSize: 13),
                                        ),
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
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.mobile,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
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
                                          style: const TextStyle(fontSize: 13),
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
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 140,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.toUserName.isNotEmpty
                                              ? task.toUserName
                                              : '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      TableWidget(
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
                                            style: TextStyle(
                                              color:
                                                  task.colorCode ?? Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 130,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.taskDate.isNotEmpty
                                              ? task.taskDate
                                              : '-',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 130,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          _formatDateSafely(task.entryDate),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 120,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.priorityName.isNotEmpty
                                              ? task.priorityName
                                              : '-',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 220,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12),
                                        data: Text(
                                          task.description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 13),
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
}
