import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/work_completion_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class WorkCompletionReportScreen extends StatefulWidget {
  const WorkCompletionReportScreen({super.key});

  @override
  State<WorkCompletionReportScreen> createState() => _WorkCompletionReportScreenState();
}

class _WorkCompletionReportScreenState extends State<WorkCompletionReportScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<WorkCompletionReportProvider>(context, listen: false);
      reportProvider.fetchReports(context);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNodeWeb.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _exportData(WorkCompletionReportProvider provider) {
    final headers = [
      'S.No',
      'Data',
    ];

    final data = provider.reports.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return {
        'S.No': index,
        'Data': item.rawData.toString(),
      };
    }).toList();

    exportToExcel(
      headers: headers,
      data: data,
      fileName: 'Work_Completion_Report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void _showDateFilterDialog(
      BuildContext context, WorkCompletionReportProvider reportProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Center(
                child: Text(
                  'Select Date Range',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        reportProvider.dateButtonTitles.length,
                        (index) {
                          final title = reportProvider.dateButtonTitles[index];
                          final isSelected =
                              reportProvider.selectedDateFilterIndex == index;
                          return ActionChip(
                            onPressed: () {
                              reportProvider.setDateFilter(title);
                              reportProvider.selectDateFilterOption(index);
                              Navigator.pop(dialogContext);
                              reportProvider.fetchReports(context);
                            },
                            backgroundColor:
                                isSelected ? AppColors.primaryBlue : Colors.grey[100],
                            label: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () async {
                              await reportProvider.selectDate(context, true);
                              setDialogState(() {});
                              if (context.mounted) {
                                reportProvider.fetchReports(context);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              hintText: reportProvider.formattedFromDate,
                              suffixIcon: const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () async {
                              await reportProvider.selectDate(context, false);
                              setDialogState(() {});
                              if (context.mounted) {
                                reportProvider.fetchReports(context);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              hintText: reportProvider.formattedToDate,
                              suffixIcon: const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<WorkCompletionReportProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Work Completion Report',
              onSearch: (value) {
                reportProvider.setSearchQuery(value);
              },
              onSearchTap: () {
                reportProvider.toggleSearch();
              },
              onFilterTap: () {
                reportProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                reportProvider.setSearchQuery('');
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(reportProvider),
            ),
      body: isWeb
          ? _buildWebBody(context, reportProvider)
          : _buildMobileBody(context, reportProvider),
    );
  }

  Widget _buildWebBody(
    BuildContext context,
    WorkCompletionReportProvider reportProvider,
  ) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
              child: _buildWebHeader(context, reportProvider)),
          if (reportProvider.isFilter)
            SliverToBoxAdapter(
                child: _buildWebFilter(context, reportProvider)),
          SliverToBoxAdapter(child: _buildTableHeader()),
          if (reportProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reportProvider.reports.isEmpty)
            const SliverFillRemaining(
              child: CommonEmptyState(message: 'No work completion reports found'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = reportProvider.reports[index];
                  return _buildTableRow(item, index);
                },
                childCount: reportProvider.reports.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(
    BuildContext context,
    WorkCompletionReportProvider reportProvider,
  ) {
    final sideProvider = Provider.of<SidebarProvider>(context);
    return Column(
      children: [
        if (reportProvider.isSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Customer Name, Phone Number, etc...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                isDense: true,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (val) {
                 reportProvider.setSearchQuery(val);
              },
            ),
          ),
        if (reportProvider.isFilter)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CommonReportDateFilter(
                    fromDate: reportProvider.fromDate?.toString(),
                    toDate: reportProvider.toDate?.toString(),
                    formattedFromDate: reportProvider.formattedFromDate,
                    formattedToDate: reportProvider.formattedToDate,
                    onTap: () => _showDateFilterDialog(context, reportProvider),
                    label: 'Date',
                  ),
                  const SizedBox(width: 8),
                  CommonReportResetButton(
                    onReset: () {
                      searchController.clear();
                      reportProvider.clearFilters(context);
                    },
                    label: 'Reset',
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: reportProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reportProvider.reports.isEmpty
                  ? const CommonEmptyState(message: 'No reports found')
                  : ListView.builder(
                      itemCount: reportProvider.reports.length,
                      itemBuilder: (context, index) {
                        final item = reportProvider.reports[index];
                        final rawData = item.rawData;
                        final cName = _getValue(rawData, ['Customer_Name', 'Customer Name', 'CustomerName']);
                        final pNum = _getValue(rawData, ['Phone_Number', 'Phone Number', 'Phone', 'Mobile']);
                        final address = _getValue(rawData, ['Address', 'Location']);
                        final email = _getValue(rawData, ['Email', 'Email_ID', 'Email ID']);
                        final workCompletionDate = _getValue(rawData, ['Work_Completion_Date', 'Work Completion Date', 'Completion Date', 'Completion_Date']);
                        final assignedStaff = _getValue(rawData, ['Assigned_Staff', 'Assigned Staff', 'Staff', 'Staff_Name']);
                        final firstServiceDate = _getValue(rawData, ['1st_service_date(amc)', '1st Service Date', 'First_Service_Date', 'AMC_Date', '1st_Service_Date']);
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMobileRow('Customer Name', cName, isTitle: true),
                                const Divider(),
                                _buildMobileRow('Phone No', pNum),
                                _buildMobileRow('Address', address),
                                _buildMobileRow('Email', email),
                                _buildMobileRow('Work Completion Date', workCompletionDate),
                                _buildMobileRow('Assigned Staff', assignedStaff),
                                _buildMobileRow('Service Date(AMC)', firstServiceDate),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(
      BuildContext context, WorkCompletionReportProvider reportProvider) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () {
                ScaffoldState? parent;
                ctx.visitAncestorElements((element) {
                  if (element is StatefulElement &&
                      element.state is ScaffoldState) {
                    ScaffoldState scaffold = element.state as ScaffoldState;
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
            'Work Completion Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              color: const Color(0xFF152D70),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Search Bar
          Container(
            width: 280,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (query) => reportProvider.setSearchQuery(query),
              decoration: InputDecoration(
                hintText: 'Search here....',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                suffixIcon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 18),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CustomFilterButton(
            onPressed: () {
              reportProvider.toggleFilter();
            },
            isFilter: reportProvider.isFilter,
          ),
          const SizedBox(width: 16),
          CommonReportExportButton(
            onPressed: () => _exportData(reportProvider),
            label: 'Export',
          ),
        ],
      ),
    );
  }

  Widget _buildWebFilter(
    BuildContext context,
    WorkCompletionReportProvider reportProvider,
  ) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
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
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CommonReportDateFilter(
              fromDate: reportProvider.fromDate?.toString(),
              toDate: reportProvider.toDate?.toString(),
              formattedFromDate: reportProvider.formattedFromDate,
              formattedToDate: reportProvider.formattedToDate,
              onTap: () => _showDateFilterDialog(context, reportProvider),
              label: 'Date',
            ),
            CommonReportResetButton(
              onReset: () {
                searchController.clear();
                reportProvider.clearFilters(context);
              },
              label: 'Reset',
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CustomTableCell(text: 'S.No', flex: 1, isHeader: true),
              CustomTableCell(text: 'Customer Name', flex: 2, isHeader: true),
              CustomTableCell(text: 'Phone No', flex: 2, isHeader: true),
              CustomTableCell(text: 'Address', flex: 3, isHeader: true),
              CustomTableCell(text: 'Email', flex: 2, isHeader: true),
              CustomTableCell(text: 'Work Completion Date', flex: 2, isHeader: true),
              CustomTableCell(text: 'Assigned Staff', flex: 2, isHeader: true),
              CustomTableCell(text: '1st Service Date(AMC)', flex: 2, isHeader: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(var item, int index) {
    final rawData = item.rawData;
    final cName = _getValue(rawData, ['Customer_Name', 'Customer Name', 'CustomerName']);
    final pNum = _getValue(rawData, ['Phone_Number', 'Phone Number', 'Phone', 'Mobile']);
    final address = _getValue(rawData, ['Address', 'Location']);
    final email = _getValue(rawData, ['Email', 'Email_ID', 'Email ID']);
    final workCompletionDate = _getValue(rawData, ['Work_Completion_Date', 'Work Completion Date', 'Completion Date', 'Completion_Date']);
    final assignedStaff = _getValue(rawData, ['Assigned_Staff', 'Assigned Staff', 'Staff', 'Staff_Name']);
    final firstServiceDate = _getValue(rawData, ['1st_service_date(amc)', '1st Service Date', 'First_Service_Date', 'AMC_Date', '1st_Service_Date']);

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CustomTableCell(text: '${index + 1}', flex: 1),
              CustomTableCell(text: cName, flex: 2),
              CustomTableCell(text: pNum, flex: 2),
              CustomTableCell(text: address, flex: 3),
              CustomTableCell(text: email, flex: 2),
              CustomTableCell(text: workCompletionDate, flex: 2),
              CustomTableCell(text: assignedStaff, flex: 2),
              CustomTableCell(text: firstServiceDate, flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  String _getValue(Map<String, dynamic> rawData, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      if (rawData.containsKey(key)) {
        return rawData[key]?.toString() ?? 'N/A';
      }
    }
    for (final entry in rawData.entries) {
      for (final key in possibleKeys) {
        if (entry.key.toLowerCase().replaceAll(' ', '_') == key.toLowerCase().replaceAll(' ', '_')) {
          return entry.value?.toString() ?? 'N/A';
        }
      }
    }
    return 'N/A';
  }

  Widget _buildMobileRow(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
                color: isTitle ? Colors.black87 : Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
                color: isTitle ? Colors.black87 : Colors.black,
                fontSize: isTitle ? 15 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;

  const CustomTableCell({
    Key? key,
    required this.text,
    this.flex = 1,
    this.isHeader = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.black87 : Colors.black87,
            fontSize: isHeader ? 13 : 12,
          ),
        ),
      ),
    );
  }
}
