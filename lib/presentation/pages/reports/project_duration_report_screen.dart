import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/project_duration_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ProjectDurationReportScreen extends StatefulWidget {
  const ProjectDurationReportScreen({super.key});

  @override
  State<ProjectDurationReportScreen> createState() => _ProjectDurationReportScreenState();
}

class _ProjectDurationReportScreenState extends State<ProjectDurationReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectDurationReportProvider>(context, listen: false)
          .getProjectDurationReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ProjectDurationReportProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              title: 'Project Duration Report',
              onSearch: (value) {},
              onSearchTap: () {},
              onFilterTap: () {},
              showFilterIcon: false,
              showSearch: false,
              showExcel: false,
              showPdf: false,
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (AppStyles.isWebScreen(context))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
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
                    const Text(
                      'Project Duration Report',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: reportProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportProvider.projectDurationReport.isEmpty
                      ? const Center(
                          child: CommonEmptyState(
                            message: 'No project duration report available.',
                          ),
                        )
                      : _buildTableCard(reportProvider),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildTableCard(ProjectDurationReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
              child: Text(
                'Project Duration Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
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
                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                        headingRowHeight: 56,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        horizontalMargin: 24,
                        columnSpacing: 40,
                        columns: [
                          _buildColumnHeader('Project'),
                          _buildColumnHeader('Expected'),
                          _buildColumnHeader('Actual'),
                          _buildColumnHeader('Difference'),
                        ],
                        rows: provider.projectDurationReport.map((item) {
                          String differenceStr = '';
                          int diff = item.difference ?? 0;
                          if (diff > 0) {
                            differenceStr = '+$diff';
                          } else {
                            differenceStr = '$diff';
                          }
                          return DataRow(
                            cells: [
                              _buildDataCell(item.customerName ?? '-', isBold: true),
                              _buildDataCell('${item.expectedDuration ?? 0} days'),
                              _buildDataCell('${item.actualDuration ?? 0} days'),
                              _buildDataCell(differenceStr),
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
      ),
    );
  }

  DataColumn _buildColumnHeader(String label) {
    return DataColumn(
      label: Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF475569),
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value, {bool isBold = false}) {
    return DataCell(
      Container(
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
