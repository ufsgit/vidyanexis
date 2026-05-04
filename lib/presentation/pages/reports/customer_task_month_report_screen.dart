import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_task_month_provider.dart';
import 'package:vidyanexis/controller/models/customer_task_month_model.dart';

class CustomerTaskMonthReportScreen extends StatefulWidget {
  const CustomerTaskMonthReportScreen({super.key});

  @override
  State<CustomerTaskMonthReportScreen> createState() =>
      _CustomerTaskMonthReportScreenState();
}

class _CustomerTaskMonthReportScreenState
    extends State<CustomerTaskMonthReportScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerTaskMonthProvider>(context, listen: false)
          .getCustomerTaskMonth(context);
    });
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerTaskMonthProvider>(context);
    final fromDate = provider.fromDate ??
        DateTime(provider.selectedMonth.year, provider.selectedMonth.month, 1);
    final toDate = provider.toDate ??
        DateTime(
            provider.selectedMonth.year, provider.selectedMonth.month + 1, 0);

    // Generate list of dates in range
    final List<DateTime> datesInRange = [];
    DateTime currentDate = fromDate;
    while (
        currentDate.isBefore(toDate) || currentDate.isAtSameMomentAs(toDate)) {
      datesInRange.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    final groupedData = provider.groupedDataInRange(datesInRange);
    final customers = groupedData.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Customer Task Report',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _onClickTopButton(context, provider),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded,
                  color: AppColors.primaryBlue, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd MMM').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isMobile) _buildGridHeader(datesInRange),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customers.isEmpty
                        ? _buildEmptyState()
                        : isMobile
                            ? _buildMobileListView(
                                customers, datesInRange, groupedData)
                            : SingleChildScrollView(
                                controller: _verticalScrollController,
                                child: _buildWebGridView(
                                    customers, datesInRange, groupedData),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_late_rounded,
                size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your date filters',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileListView(
    List<String> customers,
    List<DateTime> dates,
    Map<String, Map<String, List<CustomerTaskMonthModel>>> groupedData,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customerName = customers[index];
        final customerTasks = groupedData[customerName] ?? {};
        int totalTasks = 0;
        customerTasks.forEach((key, value) => totalTasks += value.length);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              title: Text(
                customerName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              subtitle: Text(
                '$totalTasks total tasks in this period',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dates.map((date) {
                      final dateStr = DateFormat('yyyy-MM-dd').format(date);
                      final tasks = customerTasks[dateStr] ?? [];

                      if (tasks.isEmpty) return const SizedBox.shrink();

                      return InkWell(
                        onTap: () => _showTaskDetails(context, tasks),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(tasks.first.taskStatusName)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(tasks.first.taskStatusName)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${date.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _getStatusColor(
                                      tasks.first.taskStatusName),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                      tasks.first.taskStatusName),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${tasks.length}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebGridView(
    List<String> customers,
    List<DateTime> dates,
    Map<String, Map<String, List<CustomerTaskMonthModel>>> groupedData,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Left Column (Customer Names)
        _buildCustomerColumn(customers),

        // Scrollable Grid Area
        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: _buildTaskGrid(customers, dates, groupedData),
          ),
        ),
      ],
    );
  }

  Widget _buildGridHeader(List<DateTime> dates) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Customer Name',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF495057),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(dates.length, (index) {
                  return Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Text(
                      '${dates[index].day}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF495057),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerColumn(List<String> customers) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[200]!),
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: List.generate(customers.length, (index) {
          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Text(
              customers[index],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskGrid(
    List<String> customers,
    List<DateTime> dates,
    Map<String, Map<String, List<CustomerTaskMonthModel>>> groupedData,
  ) {
    return Container(
      width: (dates.length * 50).toDouble(),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: List.generate(customers.length, (rowIndex) {
          final customerName = customers[rowIndex];
          return Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: List.generate(dates.length, (colIndex) {
                final dateStr =
                    DateFormat('yyyy-MM-dd').format(dates[colIndex]);
                final tasks = groupedData[customerName]?[dateStr] ?? [];

                return GestureDetector(
                  onTap: tasks.isNotEmpty
                      ? () => _showTaskDetails(context, tasks)
                      : null,
                  child: Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      border:
                          Border(left: BorderSide(color: Colors.grey[100]!)),
                      color: tasks.isNotEmpty
                          ? _getStatusColor(tasks.first.taskStatusName)
                              .withOpacity(0.08)
                          : Colors.transparent,
                    ),
                    child: tasks.isEmpty
                        ? null
                        : Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(tasks.first.taskStatusName),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(
                                            tasks.first.taskStatusName)
                                        .withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${tasks.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _onClickTopButton(
      BuildContext context, CustomerTaskMonthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CustomerTaskMonthProvider>(
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
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(reportsProvider.fromDate!)
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
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(reportsProvider.toDate!)
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              provider.getCustomerTaskMonth(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFB60A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Apply',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              reportsProvider.setSelectedMonth(DateTime.now());
                              Navigator.pop(context);
                              provider.getCustomerTaskMonth(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Clear',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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

  void _showTaskDetails(
      BuildContext context, List<CustomerTaskMonthModel> tasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details - ${tasks.first.taskDate}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.taskTypeName ?? 'No Task Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${task.taskStatusName ?? 'N/A'}'),
                    if (task.staffName != null)
                      Text('Assigned To: ${task.staffName}'),
                    if (task.projectWing != null)
                      Text('Project Wing: ${task.projectWing}'),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(task.taskStatusName).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: _getStatusColor(task.taskStatusName)),
                  ),
                  child: Text(
                    task.taskStatusName ?? 'N/A',
                    style: TextStyle(
                      color: _getStatusColor(task.taskStatusName),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
