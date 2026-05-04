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
      appBar: AppBar(
        title: Text(
          'Customer Task Month Report',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF152D70),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF152D70)),
            onPressed: () => _onClickTopButton(context, provider),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${DateFormat('dd MMM').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF152D70),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Header Row (Fixed Top)
            _buildGridHeader(datesInRange),

            // Main Content Area
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customers.isEmpty
                      ? const Center(
                          child: Text('No data found for this range'))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fixed Left Column (Customer Names)
                            _buildCustomerColumn(customers),

                            // Scrollable Grid Area
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: _buildTaskGrid(
                                    customers, datesInRange, groupedData),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridHeader(List<DateTime> dates) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Customer Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics:
                  const NeverScrollableScrollPhysics(), // Sync with main grid
              child: Row(
                children: List.generate(dates.length, (index) {
                  return Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: Text(
                      '${dates[index].day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.builder(
        controller: _verticalScrollController,
        itemCount: customers.length,
        itemBuilder: (context, index) {
          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Text(
              customers[index],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskGrid(
    List<String> customers,
    List<DateTime> dates,
    Map<String, Map<String, List<CustomerTaskMonthModel>>> groupedData,
  ) {
    return SizedBox(
      width: (dates.length * 50).toDouble(),
      child: ListView.builder(
        controller: _verticalScrollController,
        itemCount: customers.length,
        itemBuilder: (context, rowIndex) {
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
                              .withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: tasks.isEmpty
                        ? null
                        : Center(
                            child: Tooltip(
                              message: tasks
                                  .map((t) =>
                                      '${t.taskTypeName}: ${t.taskStatusName}')
                                  .join('\n'),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                      tasks.first.taskStatusName),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${tasks.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                );
              }),
            ),
          );
        },
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
