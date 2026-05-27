import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/task_history_popup.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CustomerTaskOverviewTab extends StatefulWidget {
  final String customerId;
  const CustomerTaskOverviewTab({super.key, required this.customerId});

  @override
  State<CustomerTaskOverviewTab> createState() =>
      _CustomerTaskOverviewTabState();
}

class _CustomerTaskOverviewTabState extends State<CustomerTaskOverviewTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getCustomerTaskOverview(widget.customerId);
    });
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
                  'No summary data available',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final isWeb = AppStyles.isWebScreen(context);

        if (isWeb) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: tasks.map((task) {
                return _buildSummaryCard(task, isWeb: isWeb);
              }).toList(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildSummaryCard(task, isWeb: isWeb);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(TaskCustomerModel task, {bool isWeb = false}) {
    return InkWell(
      onTap: () {
        final provider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        provider.fetchTaskHistory(task.taskId.toString());
        showDialog(
          context: context,
          builder: (context) => TaskHistoryPopup(
            taskId: task.taskId.toString(),
            taskName: task.taskTypeName,
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 220,
        margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.taskTypeName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              task.taskStatusName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(task.taskStatusName),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Created on ${_formatDate(task.entryDate.toString())}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Completed on ${_formatDate(task.taskDate.toString())}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'By ${task.toUsername}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String statusName) {
    final status = statusName.toLowerCase();
    if (status.contains('complete') ||
        status.contains('finish') ||
        status.contains('done')) {
      return const Color(0xFF10B981);
    } else if (status.contains('pending') || status.contains('wait')) {
      return const Color(0xFFF59E0B);
    } else if (status.contains('hold') || status.contains('cancel')) {
      return const Color(0xFFEF4444);
    } else if (status.contains('progress')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF3B82F6);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
