import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/duplicate_entry_attempts_provider.dart';
import 'package:vidyanexis/controller/models/duplicate_entry_attempts_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class DuplicateEntryAttemptsReportScreen extends StatefulWidget {
  const DuplicateEntryAttemptsReportScreen({super.key});

  @override
  State<DuplicateEntryAttemptsReportScreen> createState() =>
      _DuplicateEntryAttemptsReportScreenState();
}

class _DuplicateEntryAttemptsReportScreenState
    extends State<DuplicateEntryAttemptsReportScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<DuplicateEntryAttemptsProvider>(context, listen: false);
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

  // ─── Type color (hardcoded 3 types) ───────────────────────────────────────

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'phone':
        return Colors.orange;
      case 'consumer':
        return Colors.blue;
      case 'aadhaar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ─── Export ───────────────────────────────────────────────────────────────

  void _exportData(DuplicateEntryAttemptsProvider provider) {
    final headers = [
      'S.No',
      'Duplicate Type',
      'Phone Number',
      'Consumer Number',
      'Aadhaar No',
      'Existing Customer ID',
      'Existing Customer Name',
      'Existing Phone Number',
      'Attempted By',
      'Attempt Date',
      'Attempt Time',
    ];

    final data = provider.reports.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return {
        'S.No': index,
        'Duplicate Type': item.duplicateType ?? '',
        'Phone Number': item.phoneNumber ?? '',
        'Consumer Number': item.consumerNumber ?? '',
        'Aadhaar No': item.aadhaarNo ?? '',
        'Existing Customer ID': item.existingCustomerId ?? '',
        'Existing Customer Name': item.existingCustomerName ?? '',
        'Existing Phone Number': item.existingPhoneNumber ?? '',
        'Attempted By': item.attemptedBy ?? '',
        'Attempt Date': item.formattedDate,
        'Attempt Time': item.formattedTime,
      };
    }).toList();

    exportToExcel(
      headers: headers,
      data: data,
      fileName:
          'Duplicate_Entry_Attempts_Report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ─── Date Filter Dialog ────────────────────────────────────────────────────

  void _showDateFilterDialog(
      BuildContext context, DuplicateEntryAttemptsProvider reportProvider) {
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
                            backgroundColor: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey[100],
                            label: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
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
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
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
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<DuplicateEntryAttemptsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Duplicate Entry Attempts',
              onSearchTap: () {
                sideProvider.startSearch();
              },
              onSearch: (query) {
                reportProvider.setSearchQuery(query, context);
              },
              onClearTap: () {
                searchController.clear();
                sideProvider.stopSearch();
                reportProvider.setSearchQuery('', context);
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(reportProvider),
            ),
      body: isWeb
          ? _buildWebBody(context, reportProvider, dropDownProvider)
          : _buildMobileBody(context, reportProvider, dropDownProvider),
      bottomNavigationBar: _buildPaginationControls(context),
    );
  }

  // ─── Web Body ──────────────────────────────────────────────────────────────

  Widget _buildWebBody(
    BuildContext context,
    DuplicateEntryAttemptsProvider reportProvider,
    DropDownProvider dropDownProvider,
  ) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildWebHeader(context, reportProvider)),
          if (reportProvider.isFilter)
            SliverToBoxAdapter(
                child:
                    _buildWebFilter(context, reportProvider, dropDownProvider)),
          SliverToBoxAdapter(child: _buildTableHeader()),
          if (reportProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reportProvider.reports.isEmpty)
            const SliverFillRemaining(
              child: CommonEmptyState(
                  message: 'No duplicate entry attempt records found'),
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

  // ─── Web Header ────────────────────────────────────────────────────────────

  Widget _buildWebHeader(
      BuildContext context, DuplicateEntryAttemptsProvider reportProvider) {
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
                  color: AppColors.secondaryBlue.withValues(alpha: 0.1),
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
            'Duplicate Entry Attempts Report',
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
                  color: Colors.black.withValues(alpha: 0.02),
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
                // Optional: debounce here if you want
                reportProvider.setSearchQuery(val, context);
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

  // ─── Web Filter ────────────────────────────────────────────────────────────

  Widget _buildWebFilter(
    BuildContext context,
    DuplicateEntryAttemptsProvider reportProvider,
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
              color: Colors.black.withValues(alpha: 0.02),
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
            _buildDropdownContainer(
              label: 'User: ',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: reportProvider.selectedUserId,
                  hint: Text(
                    'All Users',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: const Color(0xFF1E293B)),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Users',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                    ...dropDownProvider.searchUserDetails.map((user) {
                      return DropdownMenuItem<int?>(
                        value: user.userDetailsId,
                        child: Text(user.userDetailsName,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    reportProvider.setUserId(val);
                    reportProvider.fetchReports(context);
                  },
                  isDense: true,
                  iconSize: 20,
                ),
              ),
            ),
            _buildDropdownContainer(
              label: 'Type: ',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: reportProvider.selectedDuplicateType.isEmpty
                      ? 'All'
                      : reportProvider.selectedDuplicateType,
                  items: reportProvider.duplicateTypeOptions
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type,
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      reportProvider.setDuplicateType(val);
                      reportProvider.fetchReports(context);
                    }
                  },
                  isDense: true,
                  iconSize: 20,
                ),
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

  Widget _buildDropdownContainer(
      {required String label, required Widget child}) {
    return Container(
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
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // ─── Table Header (Attempt ID removed, Aadhaar No added) ───────────────────

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
              TableWidget(title: 'S.No', flex: 1, fontWeight: FontWeight.bold),
              TableWidget(title: 'Type', flex: 1, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Phone Number', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Consumer No', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Aadhaar No', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Existing Customer',
                  flex: 2,
                  fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Existing Phone',
                  flex: 2,
                  fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Attempted By', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Date & Time', flex: 2, fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Table Row ─────────────────────────────────────────────────────────────

  Widget _buildTableRow(DuplicateEntryAttemptsModel item, int index) {
    final isEven = index % 2 == 0;
    final typeColor = _typeColor(item.duplicateType);

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
            TableWidget(title: '${index + 1}', flex: 1),

            // Type with color badge
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: typeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    item.duplicateType ?? '-',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            TableWidget(title: item.phoneNumber ?? '-', flex: 2),
            TableWidget(
                title: (item.consumerNumber?.isEmpty ?? true)
                    ? '-'
                    : item.consumerNumber!,
                flex: 2),
            TableWidget(
                title:
                    (item.aadhaarNo?.isEmpty ?? true) ? '-' : item.aadhaarNo!,
                flex: 2),
            TableWidget(
                title: item.existingCustomerName ?? '-',
                flex: 2,
                fontWeight: FontWeight.w600),
            TableWidget(title: item.existingPhoneNumber ?? '-', flex: 2),
            TableWidget(title: item.attemptedBy ?? '-', flex: 2),
            TableWidget(
                title: '${item.formattedDate} ${item.formattedTime}', flex: 2),
          ],
        ),
      ),
    );
  }

  // ─── Mobile Body ───────────────────────────────────────────────────────────

  Widget _buildMobileBody(
    BuildContext context,
    DuplicateEntryAttemptsProvider reportProvider,
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
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12),
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
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: reportProvider.selectedUserId,
                            hint: Text('Select User',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 13)),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Users',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                              ),
                              ...dropDownProvider.searchUserDetails.map((user) {
                                return DropdownMenuItem<int?>(
                                  value: user.userDetailsId,
                                  child: Text(user.userDetailsName,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13)),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              reportProvider.setUserId(val);
                              reportProvider.fetchReports(context);
                            },
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
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: reportProvider.selectedDuplicateType.isEmpty
                                ? 'All'
                                : reportProvider.selectedDuplicateType,
                            items: reportProvider.duplicateTypeOptions
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                reportProvider.setDuplicateType(val);
                                reportProvider.fetchReports(context);
                              }
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
                  'Total: ${reportProvider.totalCount}',
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
                      message: 'No duplicate entry attempt records found')
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: reportProvider.reports.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.grey.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final item = reportProvider.reports[index];
                        final typeColor = _typeColor(item.duplicateType);

                        return ReportListItem(
                          title: item.existingCustomerName ?? 'N/A',
                          subtitle:
                              'Phone: ${item.phoneNumber ?? '-'}  •  Aadhaar: ${item.aadhaarNo ?? '-'}',
                          id: null, // Attempt ID removed
                          status: item.duplicateType ?? '-',
                          statusColor: typeColor,
                          bottomLeftText:
                              '${item.formattedDate}  ${item.formattedTime}  •  By: ${item.attemptedBy ?? '-'}',
                          bottomLeftIcon: Icons.access_time_outlined,
                          showArrow: false,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final reportProvider = Provider.of<DuplicateEntryAttemptsProvider>(context);

    final startItem = reportProvider.startLimit;
    final endItem = (reportProvider.endLimit < reportProvider.totalCount)
        ? reportProvider.endLimit
        : reportProvider.totalCount;

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: reportProvider.hasPreviousPage
                ? () => reportProvider.fetchPreviousPage(context)
                : null,
          ),
          Text(
            'Showing $startItem – $endItem of ${reportProvider.totalCount}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: reportProvider.hasNextPage
                ? () => reportProvider.fetchNextPage(context)
                : null,
          ),
        ],
      ),
    );
  }
}
