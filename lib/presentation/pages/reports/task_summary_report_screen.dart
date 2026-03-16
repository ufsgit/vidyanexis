import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/task_summary_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class TaskSummaryReportScreen extends StatefulWidget {
  const TaskSummaryReportScreen({super.key});

  @override
  State<TaskSummaryReportScreen> createState() => _TaskSummaryReportScreenState();
}

class _TaskSummaryReportScreenState extends State<TaskSummaryReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskSummaryProvider>(context, listen: false).getTaskSummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskSummaryProvider>(context);

    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              title: const Text('Task Summary Report'),
              backgroundColor: AppColors.whiteColor,
              surfaceTintColor: AppColors.scaffoldColor,
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppStyles.isWebScreen(context))
              Row(
                children: [
                  Text(
                    'Task Summary Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF152D70),
                    ),
                  ),
                  const Spacer(),
                  CustomElevatedButton(
                    onPressed: () {
                      exportToExcel(
                        headers: ['User Name', 'Total Task', 'Pending', 'Completed'],
                        data: provider.taskSummaries.map((task) {
                          return {
                            'User Name': task.userName,
                            'Total Task': task.totalTask,
                            'Pending': task.pending,
                            'Completed': task.completed,
                          };
                        }).toList(),
                        fileName: 'Task_Summary_Report',
                      );
                    },
                    buttonText: 'Export to Excel',
                    textColor: AppColors.whiteColor,
                    borderColor: AppColors.appViolet,
                    backgroundColor: AppColors.appViolet,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Date Filter Section
            _buildFilterSection(context, provider),
            const SizedBox(height: 16),
            // Table Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(context),
                    const Divider(height: 1),
                    Expanded(
                      child: provider.taskSummaries.isEmpty
                          ? const Center(child: Text('No data found'))
                          : ListView.builder(
                              itemCount: provider.taskSummaries.length,
                              itemBuilder: (context, index) {
                                final task = provider.taskSummaries[index];
                                return _buildTableRow(context, task);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, TaskSummaryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: provider.isDateCheck,
                onChanged: (value) {
                  provider.setIsDateCheck(value ?? false);
                },
              ),
              const Text('Enable Date Filter'),
            ],
          ),
          _buildDateField(
            context,
            'From Date',
            provider.fromDate,
            (date) => provider.setFromDate(date),
          ),
          _buildDateField(
            context,
            'To Date',
            provider.to_toDate,
            (date) => provider.setToDate(date),
          ),
          ElevatedButton(
            onPressed: () => provider.getTaskSummary(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Search'),
          ),
          TextButton(
            onPressed: () {
              provider.resetFilters();
              provider.getTaskSummary(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) onSelect(pickedDate);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : label,
              style: TextStyle(color: date != null ? Colors.black : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.grey[50],
      child: Row(
        children: const [
          Expanded(flex: 3, child: CustomTableHeaderCell(label: 'User Name')),
          Expanded(flex: 2, child: CustomTableHeaderCell(label: 'Total Tasks', textAlign: TextAlign.center)),
          Expanded(flex: 2, child: CustomTableHeaderCell(label: 'Pending', textAlign: TextAlign.center)),
          Expanded(flex: 2, child: CustomTableHeaderCell(label: 'Completed', textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, var task) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              task.userName,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              task.totalTask.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              task.pending,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              task.completed,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTableHeaderCell extends StatelessWidget {
  final String label;
  final TextAlign textAlign;

  const CustomTableHeaderCell({
    super.key,
    required this.label,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: textAlign,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: const Color(0xFF152D70),
      ),
    );
  }
}
