import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/task_summary_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class TaskSummaryReportScreen extends StatefulWidget {
  const TaskSummaryReportScreen({super.key});

  @override
  State<TaskSummaryReportScreen> createState() =>
      _TaskSummaryReportScreenState();
}

class _TaskSummaryReportScreenState extends State<TaskSummaryReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TaskSummaryProvider>(context, listen: false);
      provider.resetFilters();
      provider.getTaskSummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskSummaryProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Task Summary Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack),
              onFilterTap: () => provider.toggleFilter(),
              showSearch: false,
              onSearch: (_) {},
            ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWeb)
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
                    Text(
                      'Task Summary Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF152D70),
                      ),
                    ),
                    const Spacer(),
                    CommonReportExportButton(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'User Name',
                            'Total Task',
                            'Pending',
                            'Completed'
                          ],
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
                      label: 'Export to Excel',
                    ),
                  ],
                ),
              ),

            // Mobile Filter Screen (fullscreen)
            if (!isWeb && provider.isFilter)
              Expanded(
                child: _buildFilterPanel(context, provider),
              )
            else ...[
              // Date filters for web (inline)
              if (isWeb)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildWebFilterBar(context, provider),
                ),
              const SizedBox(height: 8),

              // Summary bar for mobile
              if (!isWeb && provider.taskSummaries.isNotEmpty)
                CommonReportSummaryBar(
                  totalLabel: 'Total Records',
                  totalCount: provider.taskSummaries.length,
                  showingLabel: 'Showing',
                  showingCount: provider.taskSummaries.length,
                ),

              // Table / Card Section
              Expanded(
                child: isWeb
                    ? _buildWebTable(context, provider)
                    : _buildMobileList(context, provider),
              ),
            ]
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (!isWeb && provider.isFilter)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_task_summary_report_filter_fab',
                  onPressed: () {
                    provider.getTaskSummary(context);
                    provider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false)
                        .stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterPanel(BuildContext context, TaskSummaryProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CustomText(
            'Date Range',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CommonReportDateFilter(
                  fromDate: provider.fromDate?.toString(),
                  toDate: provider.to_toDate?.toString(),
                  formattedFromDate: provider.formattedFromDate,
                  formattedToDate: provider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                  label: 'Date',
                ),
              ),
              if (provider.fromDate != null || provider.to_toDate != null) ...[
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    provider.selectDateFilterOption(null);
                    provider.getTaskSummary(context);
                  },
                ),
              ]
            ],
          ),
          const SizedBox(height: 40),
          if (provider.fromDate != null || provider.to_toDate != null)
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                label: 'Reset All Filters',
                onReset: () {
                  provider.selectDateFilterOption(null);
                  provider.getTaskSummary(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textRed,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.textRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebFilterBar(
      BuildContext context, TaskSummaryProvider provider) {
    bool hasDates = provider.fromDate != null || provider.to_toDate != null;
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
          CommonReportDateFilter(
            fromDate: provider.fromDate?.toString(),
            toDate: provider.to_toDate?.toString(),
            formattedFromDate: provider.formattedFromDate,
            formattedToDate: provider.formattedToDate,
            onTap: () => onClickTopButton(context),
            label: 'Date',
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => provider.getTaskSummary(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Search',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          if (hasDates)
            CommonReportResetButton(
              onReset: () {
                provider.selectDateFilterOption(null);
                provider.getTaskSummary(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: const BorderSide(color: AppColors.textRed),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
    );
  }

  Widget _buildWebTable(BuildContext context, TaskSummaryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: CustomTableHeaderCell(label: 'User Name'),
                      )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: CustomTableHeaderCell(
                            label: 'Total Tasks', textAlign: TextAlign.center),
                      )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: CustomTableHeaderCell(
                            label: 'Pending', textAlign: TextAlign.center),
                      )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: CustomTableHeaderCell(
                            label: 'Completed', textAlign: TextAlign.center),
                      )),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: provider.taskSummaries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: provider.taskSummaries.length,
                      itemBuilder: (context, index) {
                        final task = provider.taskSummaries[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[100]!)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  child: Text(
                                    task.userName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  child: Text(
                                    task.totalTask.toString(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
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
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
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
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, TaskSummaryProvider provider) {
    if (provider.taskSummaries.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: provider.taskSummaries.length,
      itemBuilder: (context, index) {
        final task = provider.taskSummaries[index];

        String initials = '';
        if (task.userName.isNotEmpty) {
          final parts = task.userName.trim().split(' ');
          if (parts.isNotEmpty) {
            initials = parts[0][0].toUpperCase();
            if (parts.length > 1 && parts[1].isNotEmpty) {
              initials += parts[1][0].toUpperCase();
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : 'U',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.userName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Total Tasks: ${task.totalTask}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFD97706).withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENDING',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB45309),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            task.pending,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMPLETED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF15803D),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            task.completed,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No records found');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<TaskSummaryProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Choose Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        final bool isSelected =
                            reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pick a custom date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.to_toDate != null
                                  ? '${reportsProvider.to_toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.formatDate();
                          reportsProvider.getTaskSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.getTaskSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.08),
                          foregroundColor: AppColors.textRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Clear Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
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
