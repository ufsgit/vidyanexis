import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/deleted_lead_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/deleted_lead_report_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class DeletedLeadReportScreen extends StatefulWidget {
  const DeletedLeadReportScreen({super.key});

  @override
  State<DeletedLeadReportScreen> createState() => _DeletedLeadReportScreenState();
}

class _DeletedLeadReportScreenState extends State<DeletedLeadReportScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<DeletedLeadReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      dropDownProvider.getUserDetails(context);
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

  void _exportData(DeletedLeadReportProvider provider) {
    final headers = [
      'S.No',
      'Lead ID',
      'Customer Name',
      'User Name',
      'Deleted Date',
      'Deleted Time'
    ];

    final data = provider.reports.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return {
        'S.No': index,
        'Lead ID': item.leadId ?? '',
        'Customer Name': item.customerName ?? 'N/A',
        'User Name': item.userName ?? 'N/A',
        'Deleted Date': item.deletedDate,
        'Deleted Time': item.deletedTime,
      };
    }).toList();

    exportToExcel(
      headers: headers,
      data: data,
      fileName: 'Deleted_Lead_Report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void _showDateFilterDialog(
      BuildContext context, DeletedLeadReportProvider reportProvider) {
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
    final reportProvider = Provider.of<DeletedLeadReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Deleted Lead Reports',
              onSearchTap: () {
                sideProvider.startSearch();
              },
              onSearch: (query) {
                reportProvider.setSearchQuery(query);
              },
              onClearTap: () {
                searchController.clear();
                sideProvider.stopSearch();
                reportProvider.setSearchQuery('');
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(reportProvider),
            ),
      body: isWeb
          ? _buildWebBody(context, reportProvider, dropDownProvider)
          : _buildMobileBody(context, reportProvider, dropDownProvider),
    );
  }

  Widget _buildWebBody(
    BuildContext context,
    DeletedLeadReportProvider reportProvider,
    DropDownProvider dropDownProvider,
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
                child: _buildWebFilter(context, reportProvider, dropDownProvider)),
          SliverToBoxAdapter(child: _buildTableHeader()),
          if (reportProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reportProvider.reports.isEmpty)
            const SliverFillRemaining(
              child: CommonEmptyState(message: 'No deleted lead reports found'),
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

  Widget _buildWebHeader(
      BuildContext context, DeletedLeadReportProvider reportProvider) {
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
            'Deleted Lead Reports',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              color: const Color(0xFF152D70),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: 280,
            height: 38,
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
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNodeWeb,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                reportProvider.setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search here....',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 18),
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
    DeletedLeadReportProvider reportProvider,
    DropDownProvider dropDownProvider,
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
            // Filter 1: Date Filter
            CommonReportDateFilter(
              fromDate: reportProvider.fromDate?.toString(),
              toDate: reportProvider.toDate?.toString(),
              formattedFromDate: reportProvider.formattedFromDate,
              formattedToDate: reportProvider.formattedToDate,
              onTap: () => _showDateFilterDialog(context, reportProvider),
              label: 'Date',
            ),

            // Filter 2: User Name Dropdown Filter
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'User Name: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: reportProvider.selectedUserName,
                      hint: Text(
                        'All Users',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'All Users',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          ),
                        ),
                        ...dropDownProvider.searchUserDetails.map((user) {
                          return DropdownMenuItem<String?>(
                            value: user.userDetailsName,
                            child: Text(
                              user.userDetailsName,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        reportProvider.setUserName(val);
                        reportProvider.fetchReports(context);
                      },
                      isDense: true,
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
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
        ),
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            children: [
              TableWidget(
                title: 'S.No',
                flex: 1,
                fontWeight: FontWeight.bold,
              ),
              TableWidget(
                title: 'Lead ID',
                flex: 1,
                fontWeight: FontWeight.bold,
              ),
              TableWidget(
                title: 'Customer Name',
                flex: 2,
                fontWeight: FontWeight.bold,
              ),
              TableWidget(
                title: 'User Name',
                flex: 2,
                fontWeight: FontWeight.bold,
              ),
              TableWidget(
                title: 'Deleted Date',
                flex: 2,
                fontWeight: FontWeight.bold,
              ),
              TableWidget(
                title: 'Deleted Time',
                flex: 2,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(DeletedLeadReportModel item, int index) {
    final isEven = index % 2 == 0;
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? Colors.white : const Color(0xFFF8FAFC),
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            TableWidget(
              title: '${index + 1}',
              flex: 1,
            ),
            TableWidget(
              title: '${item.leadId ?? ''}',
              flex: 1,
              fontWeight: FontWeight.w600,
            ),
            TableWidget(
              title: item.customerName ?? 'N/A',
              flex: 2,
            ),
            TableWidget(
              title: item.userName ?? 'N/A',
              flex: 2,
            ),
            TableWidget(
              title: item.deletedDate,
              flex: 2,
            ),
            TableWidget(
              title: item.deletedTime,
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBody(
    BuildContext context,
    DeletedLeadReportProvider reportProvider,
    DropDownProvider dropDownProvider,
  ) {
    return Column(
      children: [
        if (reportProvider.isFilter)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _showDateFilterDialog(context, reportProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${reportProvider.formattedFromDate} to ${reportProvider.formattedToDate}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12),
                              ),
                              const Icon(Icons.calendar_month, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: reportProvider.selectedUserName,
                            hint: Text(
                              'Select User Name',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Users',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                              ),
                              ...dropDownProvider.searchUserDetails.map((user) {
                                return DropdownMenuItem<String?>(
                                  value: user.userDetailsName,
                                  child: Text(user.userDetailsName,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13)),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              reportProvider.setUserName(val);
                              reportProvider.fetchReports(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (reportProvider.reports.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total Reports: ${reportProvider.reports.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey3,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: reportProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reportProvider.reports.isEmpty
                  ? const CommonEmptyState(
                      message: 'No deleted lead reports found')
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: reportProvider.reports.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.grey.withOpacity(0.4),
                      ),
                      itemBuilder: (context, index) {
                        final item = reportProvider.reports[index];
                        return ReportListItem(
                          title: item.customerName ?? 'N/A',
                          subtitle: '',
                          id: item.leadId?.toString(),
                          status: 'By ${item.userName ?? 'N/A'}',
                          statusColor: AppColors.primaryBlue,
                          bottomLeftText: '${item.deletedDate} ${item.deletedTime}',
                          bottomLeftIcon: Icons.access_time_outlined,
                          showArrow: true,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
