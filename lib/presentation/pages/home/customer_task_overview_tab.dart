import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerTaskOverviewTab extends StatefulWidget {
  final String customerId;
  const CustomerTaskOverviewTab({super.key, required this.customerId});

  @override
  State<CustomerTaskOverviewTab> createState() =>
      _CustomerTaskOverviewTabState();
}

class _CustomerTaskOverviewTabState extends State<CustomerTaskOverviewTab> {
  final ScrollController _verticalScrollController = ScrollController();
  final String _selectedYear = DateFormat('yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getCustomerTaskOverview(widget.customerId);
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isTaskOverviewLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = provider.customerTaskOverviewTasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No task data available for this customer',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: _buildGanttChart(tasks),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Text(
                  _selectedYear,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGanttChart(List<TaskCustomerModel> tasks) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final monthHeaders = List.generate(12, (index) {
      final monthNum = index + 1;

      // Get tasks created (entryDate) in this month
      final monthTasks =
          tasks.where((t) => t.entryDate?.month == monthNum).toList();

      if (monthTasks.isEmpty) return monthNames[index];

      // Get the earliest creation day in this month
      monthTasks.sort(
          (a, b) => (a.entryDate?.day ?? 0).compareTo(b.entryDate?.day ?? 0));
      final entryDate = monthTasks.first.entryDate;
      if (entryDate == null) return monthNames[index];

      final day = entryDate.day;

      String suffix = 'th';
      if (day >= 11 && day <= 13) {
        suffix = 'th';
      } else {
        switch (day % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      return '$day$suffix ${monthNames[index]}';
    });

    Map<String, List<TaskCustomerModel>> groupedTasks = {};
    for (var task in tasks) {
      groupedTasks.putIfAbsent(task.taskTypeName, () => []).add(task);
    }
    final taskTypes = groupedTasks.keys.toList();

    return Column(
      children: [
        // Calendar Header Row
        Container(
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Container(
                width: 150,
                padding: const EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tasks',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              ...monthHeaders.map((m) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(width: 20),
            ],
          ),
        ),
        // Task Rows
        Expanded(
          child: ListView.builder(
            controller: _verticalScrollController,
            itemCount: taskTypes.length,
            itemBuilder: (context, index) {
              final type = taskTypes[index];
              final typeTasks = groupedTasks[type]!;
              return _buildTaskRow(type, typeTasks, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow(String title, List<TaskCustomerModel> tasks, int index) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.white
            : const Color(0xFFF8FAFC).withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: List.generate(
                    12,
                    (i) => Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: const Color(0xFFE2E8F0)
                                      .withOpacity(0.5))),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildStatusMarkers(tasks),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildStatusMarkers(List<TaskCustomerModel> tasks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double monthWidth = constraints.maxWidth / 12;

        return Stack(
          children: tasks.map((task) {
            final date = task.taskDate;
            double leftOffset = (date.month - 1) * monthWidth;
            double finalLeft = leftOffset + (monthWidth / 2) - 30;

            Color statusColor = const Color(0xFF3B82F6);
            final status = task.taskStatusName.toLowerCase();
            if (status.contains('complete') ||
                status.contains('finish') ||
                status.contains('done')) {
              statusColor = const Color(0xFF10B981);
            } else if (status.contains('pending') || status.contains('wait')) {
              statusColor = const Color(0xFFF59E0B);
            } else if (status.contains('hold') || status.contains('cancel')) {
              statusColor = const Color(0xFFEF4444);
            } else if (status.contains('progress')) {
              statusColor = const Color(0xFF8B5CF6);
            }

            return Positioned(
              left: finalLeft,
              top: 15,
              child: Tooltip(
                message:
                    '${task.taskTypeName}\nScheduled: ${DateFormat('MMM d, yyyy').format(date)}\nCreated: ${task.entryDate != null ? DateFormat('MMM d, yyyy').format(task.entryDate!) : 'N/A'}\nUser: ${task.toUsername}',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  constraints: const BoxConstraints(minWidth: 60),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      task.taskStatusName.isNotEmpty
                          ? task.taskStatusName
                          : 'N/A',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
