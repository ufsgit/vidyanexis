import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/task_aging_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class TaskAgingReportScreen extends StatefulWidget {
  const TaskAgingReportScreen({super.key});

  @override
  State<TaskAgingReportScreen> createState() => _TaskAgingReportScreenState();
}

class _TaskAgingReportScreenState extends State<TaskAgingReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskAgingReportProvider>(context, listen: false)
          .fetchReportData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<TaskAgingReportProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding:
                EdgeInsets.all(AppStyles.isWebScreen(context) ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.reportData.isEmpty
                          ? const CommonEmptyState(
                              message: 'No data found for this report')
                          : _buildTableCard(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TaskAgingReportProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child:
              const Icon(Icons.arrow_back, size: 24, color: Color(0xFF152D70)),
        ),
        const SizedBox(width: 8),
        CustomText(
          'Task Aging Report',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        const Spacer(),
        if (provider.reportData.isNotEmpty)
          CommonReportExportButton(
            onPressed: () {
              exportToExcel(
                headers: [
                  'Employee',
                  '0-2 Days',
                  '3-7 Days',
                  '8-15 Days',
                  '15+ Days'
                ],
                data: provider.reportData.map((item) {
                  return {
                    'Employee': item.employee ?? '-',
                    '0-2 Days': item.zeroToTwoDays ?? '0',
                    '3-7 Days': item.threeToSevenDays ?? '0',
                    '8-15 Days': item.eightToFifteenDays ?? '0',
                    '15+ Days': item.fifteenPlusDays ?? '0',
                  };
                }).toList(),
                fileName: 'Task_Aging_Report',
              );
            },
          ),
      ],
    );
  }

  Widget _buildTableCard(TaskAgingReportProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomText('Task Aging Summary',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - (AppStyles.isWebScreen(context) ? 48 : 32),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: const Color(0xFFE2E8F0),
                    ),
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                      headingRowHeight: 56,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      horizontalMargin: 24,
                      columnSpacing: 40,
                      columns: [
                        _buildColumnHeader('Employee'),
                        _buildColumnHeader('0-2 Days', numeric: true),
                        _buildColumnHeader('3-7 Days', numeric: true),
                        _buildColumnHeader('8-15 Days', numeric: true),
                        _buildColumnHeader('15+ Days', numeric: true),
                      ],
                      rows: provider.reportData.map((item) {
                        return DataRow(
                          cells: [
                            _buildDataCell(item.employee ?? '-', isBold: true),
                            _buildDataCell(item.zeroToTwoDays ?? '0', isNumeric: true),
                            _buildDataCell(item.threeToSevenDays ?? '0', isNumeric: true),
                            _buildDataCell(item.eightToFifteenDays ?? '0', isNumeric: true),
                            _buildDataCell(item.fifteenPlusDays ?? '0', isNumeric: true),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _buildColumnHeader(String label, {bool numeric = false}) {
    return DataColumn(
      label: Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF475569),
          ),
          textAlign: numeric ? TextAlign.right : TextAlign.left,
        ),
      ),
      numeric: numeric,
    );
  }

  DataCell _buildDataCell(String value,
      {bool isBold = false, bool isNumeric = false}) {
    return DataCell(
      Container(
        alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color:
                isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
