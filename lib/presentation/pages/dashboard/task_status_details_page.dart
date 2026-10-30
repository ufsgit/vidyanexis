import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class TaskStatusDetailsView extends StatefulWidget {
  final int? taskTypeId;
  final String taskTypeName;
  final int? taskStatusId;
  final String taskStatusName;
  final String fromDate;
  final String toDate;
  final int user;
  final VoidCallback onBack;

  const TaskStatusDetailsView({
    super.key,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.fromDate,
    required this.toDate,
    required this.user,
    required this.onBack,
  });

  @override
  State<TaskStatusDetailsView> createState() => _TaskStatusDetailsViewState();
}

class _TaskStatusDetailsViewState extends State<TaskStatusDetailsView> {
  bool _isLoading = true;
  String? _errorMessage;
  List<TaskReportModel> _tasks = [];
  List<TaskReportModel> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  @override
  void didUpdateWidget(covariant TaskStatusDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromDate != widget.fromDate ||
        oldWidget.toDate != widget.toDate ||
        oldWidget.user != widget.user ||
        oldWidget.taskTypeId != widget.taskTypeId ||
        oldWidget.taskStatusId != widget.taskStatusId) {
      _fetchTaskDetails();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTaskDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final body = {
        "Task_Type_Id": widget.taskTypeId?.toString() ?? "0",
        "Task_Status_Id": widget.taskStatusId?.toString() ?? "0",
        "Fromdate": widget.fromDate,
        "Todate": widget.toDate,
        "Is_Date": widget.fromDate.isNotEmpty ? "1" : "0",
        if (widget.user != 0) "User": widget.user.toString(),
      };

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getTaskDetailsByStatus,
        bodyData: body,
        menuId: 233,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is Map) {
          if (data['data'] is List) {
            rawList = data['data'];
          } else if (data['Data'] is List) {
            rawList = data['Data'];
          }
        } else if (data is List) {
          rawList = data;
        }

        final parsed = rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => TaskReportModel.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _tasks = parsed;
            _applySearch(_searchController.text);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to load task details (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applySearch(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      _filteredTasks = List.from(_tasks);
    } else {
      _filteredTasks = _tasks.where((task) {
        final name = task.customerName.toLowerCase();
        final phone = task.mobile.toLowerCase();
        final staff = task.userDetailsName.toLowerCase();
        final consumer = task.consumerNo.toLowerCase();
        final desc = task.description.toLowerCase();
        final remark = task.remark.toLowerCase();
        final enquiry = task.enquiryForName.toLowerCase();

        return name.contains(cleanQuery) ||
            phone.contains(cleanQuery) ||
            staff.contains(cleanQuery) ||
            consumer.contains(cleanQuery) ||
            desc.contains(cleanQuery) ||
            remark.contains(cleanQuery) ||
            enquiry.contains(cleanQuery);
      }).toList();
    }
  }

  Color _getStatusColor(String statusName) {
    final lower = statusName.toLowerCase();
    if (lower.contains('complete') ||
        lower.contains('done') ||
        lower.contains('approved') ||
        lower.contains('success')) {
      return const Color(0xFF16A34A); // Green
    } else if (lower.contains('in progress') ||
        lower.contains('progress') ||
        lower.contains('processing')) {
      return const Color(0xFF2563EB); // Blue
    } else if (lower.contains('reject') ||
        lower.contains('cancel') ||
        lower.contains('failed')) {
      return const Color(0xFFDC2626); // Red
    } else if (lower.contains('pending') ||
        lower.contains('hold') ||
        lower.contains('waiting') ||
        lower.contains('need')) {
      return const Color(0xFFD97706); // Amber
    }
    return const Color(0xFF64748B); // Slate Grey
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (clean.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    final statusColor = _getStatusColor(widget.taskStatusName);

    // Calculate available screen space to eliminate blank space below the card
    final double screenH = MediaQuery.of(context).size.height;
    final double minCardHeight =
        isWeb && screenH > 500 ? (screenH - 110.0) : 450.0;
    final double availableTableHeight =
        (minCardHeight - 90.0) > 350.0 ? (minCardHeight - 90.0) : 350.0;

    return Container(
      constraints: BoxConstraints(minHeight: minCardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Back Button, Breadcrumb, Search, and Refresh
          _buildHeaderBar(isWeb, statusColor),
          const SizedBox(height: 14),

          // Main Task List / Table
          if (_isLoading)
            _buildLoadingView(availableTableHeight)
          else if (_errorMessage != null)
            _buildErrorView(availableTableHeight)
          else if (_filteredTasks.isEmpty)
            _buildEmptyView(availableTableHeight)
          else if (isWeb)
            _buildWebTableView(availableTableHeight)
          else
            _buildMobileListView(),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(bool isWeb, Color statusColor) {
    final breadcrumb = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back Button
        ElevatedButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 15),
          label: Text(
            'Back to Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Task Type Chip
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.taskTypeName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),

        // Status Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            widget.taskStatusName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Count Indicator
        if (!_isLoading)
          Text(
            '(${_filteredTasks.length} tasks)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input
        SizedBox(
          width: isWeb ? 260 : 180,
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _applySearch(val);
              });
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search customer, phone...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textGrey3,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 16, color: AppColors.textGrey3),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _applySearch('');
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Refresh Button
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded,
              size: 20, color: AppColors.secondaryBlue),
          onPressed: _fetchTaskDetails,
        ),
      ],
    );

    if (isWeb) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: breadcrumb),
          const SizedBox(width: 16),
          actions,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          breadcrumb,
          const SizedBox(height: 10),
          actions,
        ],
      );
    }
  }

  Widget _buildLoadingView(double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: 14),
          Text(
            'Loading task details...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            _searchController.text.isNotEmpty
                ? 'No matching tasks found'
                : 'No tasks found for this status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _applySearch('');
                  });
                },
                child: const Text('Clear search'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(double height) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 44, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'An error occurred',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _fetchTaskDetails,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        final statusColor = _getStatusColor(task.taskStatusName);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Sl No, Customer Name and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.customerName.isNotEmpty
                              ? task.customerName
                              : 'Unknown Customer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        if (task.mobile.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () => _makePhoneCall(task.mobile),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: AppColors.primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  task.mobile,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      task.taskStatusName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Details Wrap
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (task.enquiryForName.isNotEmpty)
                    _buildMobileInfoItem(
                      icon: Icons.flash_on_rounded,
                      label: 'Capacity',
                      value: task.enquiryForName,
                    ),
                  if (task.consumerNo.isNotEmpty)
                    _buildMobileInfoItem(
                      icon: Icons.numbers_rounded,
                      label: 'Consumer No',
                      value: task.consumerNo,
                    ),
                  if (task.userDetailsName.isNotEmpty ||
                      task.toUserName.isNotEmpty)
                    _buildMobileInfoItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Staff',
                      value: task.userDetailsName.isNotEmpty
                          ? task.userDetailsName
                          : task.toUserName,
                    ),
                  if (task.taskDate.isNotEmpty)
                    _buildMobileInfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Task Date',
                      value: task.taskDate,
                    ),
                ],
              ),

              if (task.description.isNotEmpty || task.remark.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.description.isNotEmpty
                        ? task.description
                        : task.remark,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildWebTableView(double availableTableHeight) {
    const double colWidthNo = 50;
    const double colWidthCustomer = 180;
    const double colWidthMobile = 130;
    const double colWidthTaskType = 180;
    const double colWidthStatus = 130;
    const double colWidthEnquiry = 120;
    const double colWidthStaff = 140;
    const double colWidthConsumer = 130;
    const double colWidthDesc = 200;
    const double colWidthRemark = 160;
    const double colWidthDate = 120;

    final double totalTableWidth = colWidthNo +
        colWidthCustomer +
        colWidthMobile +
        colWidthTaskType +
        colWidthStatus +
        colWidthEnquiry +
        colWidthStaff +
        colWidthConsumer +
        colWidthDesc +
        colWidthRemark +
        colWidthDate;

    const cellStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 12,
      color: Color(0xFF334155),
      fontWeight: FontWeight.w500,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = totalTableWidth > constraints.maxWidth
            ? totalTableWidth
            : constraints.maxWidth;

        return Container(
          height: availableTableHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          ),
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: effectiveWidth,
                child: Column(
                  children: [
                    // Header Row
                    Container(
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        children: const [
                          TableWidget(
                              width: colWidthNo,
                              title: 'No.',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthCustomer,
                              title: 'Customer Name',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthMobile,
                              title: 'Mobile No.',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthTaskType,
                              title: 'Task Type',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthStatus,
                              title: 'Status',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthEnquiry,
                              title: 'Enquiry for',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthStaff,
                              title: 'Staff',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthConsumer,
                              title: 'Consumer No.',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthDesc,
                              title: 'Description',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthRemark,
                              title: 'Remark',
                              color: Colors.white),
                          TableWidget(
                              width: colWidthDate,
                              title: 'Task Date',
                              color: Colors.white),
                        ],
                      ),
                    ),

                    // Scrollable Rows
                    Expanded(
                      child: Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _verticalScrollController,
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            final isHovered = _hoveredRowIndex == index;
                            final statusColor =
                                _getStatusColor(task.taskStatusName);

                            return MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredRowIndex = index),
                              onExit: (_) =>
                                  setState(() => _hoveredRowIndex = null),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 44),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? const Color(0xFFF1F5F9)
                                      : index % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFF8FAFC),
                                  border: const Border(
                                    bottom: BorderSide(
                                        color: Color(0xFFE2E8F0), width: 1.0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // No
                                    TableWidget(
                                      width: colWidthNo,
                                      data: Text('${index + 1}',
                                          style: cellStyle),
                                    ),

                                    // Customer Name
                                    TableWidget(
                                      width: colWidthCustomer,
                                      data: Text(
                                        task.customerName.isNotEmpty
                                            ? task.customerName
                                            : '-',
                                        style: cellStyle.copyWith(
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Mobile No
                                    TableWidget(
                                      width: colWidthMobile,
                                      data: task.mobile.isNotEmpty
                                          ? InkWell(
                                              onTap: () =>
                                                  _makePhoneCall(task.mobile),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.phone_outlined,
                                                      size: 13,
                                                      color: AppColors
                                                          .primaryBlue),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      task.mobile,
                                                      style: cellStyle.copyWith(
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const Text('-', style: cellStyle),
                                    ),

                                    // Task Type
                                    TableWidget(
                                      width: colWidthTaskType,
                                      data: Text(
                                        task.taskTypeName.isNotEmpty
                                            ? task.taskTypeName
                                            : widget.taskTypeName,
                                        style: cellStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Status Badge
                                    TableWidget(
                                      width: colWidthStatus,
                                      data: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: statusColor
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          task.taskStatusName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Enquiry For
                                    TableWidget(
                                      width: colWidthEnquiry,
                                      data: Text(
                                        task.enquiryForName.isNotEmpty
                                            ? task.enquiryForName
                                            : '-',
                                        style: cellStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Staff
                                    TableWidget(
                                      width: colWidthStaff,
                                      data: Text(
                                        task.userDetailsName.isNotEmpty
                                            ? task.userDetailsName
                                            : task.toUserName.isNotEmpty
                                                ? task.toUserName
                                                : '-',
                                        style: cellStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Consumer No
                                    TableWidget(
                                      width: colWidthConsumer,
                                      data: Text(
                                        task.consumerNo.isNotEmpty
                                            ? task.consumerNo
                                            : '-',
                                        style: cellStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Description
                                    TableWidget(
                                      width: colWidthDesc,
                                      data: Text(
                                        task.description.isNotEmpty
                                            ? task.description
                                            : '-',
                                        style: cellStyle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Remark
                                    TableWidget(
                                      width: colWidthRemark,
                                      data: Text(
                                        task.remark.isNotEmpty
                                            ? task.remark
                                            : '-',
                                        style: cellStyle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Task Date
                                    TableWidget(
                                      width: colWidthDate,
                                      data: Text(
                                        task.taskDate.isNotEmpty
                                            ? task.taskDate
                                            : task.entryDate.isNotEmpty
                                                ? task.entryDate.split(' ').first
                                                : '-',
                                        style: cellStyle,
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
          ),
        );
      },
    );
  }
}

class TaskStatusDetailsPage extends StatelessWidget {
  final int? taskTypeId;
  final String taskTypeName;
  final int? taskStatusId;
  final String taskStatusName;
  final String fromDate;
  final String toDate;
  final int user;

  const TaskStatusDetailsPage({
    super.key,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.fromDate,
    required this.toDate,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TaskStatusDetailsView(
            taskTypeId: taskTypeId,
            taskTypeName: taskTypeName,
            taskStatusId: taskStatusId,
            taskStatusName: taskStatusName,
            fromDate: fromDate,
            toDate: toDate,
            user: user,
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
