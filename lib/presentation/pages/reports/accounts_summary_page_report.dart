import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/accounts_summary_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/utils/extensions.dart';

class AccountsSummaryPageReport extends StatefulWidget {
  final bool fromDashBoard;
  const AccountsSummaryPageReport({super.key, this.fromDashBoard = false});

  @override
  State<AccountsSummaryPageReport> createState() => _AccountsSummaryPageReportState();
}

class _AccountsSummaryPageReportState extends State<AccountsSummaryPageReport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<AccountsSummaryReportProvider>(context, listen: false);

      provider.setDateFilter('This Month');
      provider.selectDateFilterOption(4);
      provider.formatDate();
      provider.setSearchCriteria(
        provider.formattedFromDate,
        provider.formattedToDate,
      );
      provider.getAccountsSummaryReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const _AccountsSummaryPageReportMobile();
    }
    return _buildWebUI(context);
  }

  // ---------------------------------------------------------------------------
  // WEB UI
  // ---------------------------------------------------------------------------
  Widget _buildWebUI(BuildContext context) {
    final reportsProvider = Provider.of<AccountsSummaryReportProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  if (widget.fromDashBoard) ...[
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          size: 24, color: Color(0xFF152D70)),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          ScaffoldState? parent;
                          context.visitAncestorElements((element) {
                            if (element is StatefulElement &&
                                element.state is ScaffoldState) {
                              final scaffold = element.state as ScaffoldState;
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
                          child: const Icon(Icons.sort,
                              size: 20, color: AppColors.secondaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Accounts Summary Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF152D70),
                    ),
                  ),
                  const Spacer(),
                  CustomFilterButton(
                    onPressed: () => reportsProvider.toggleFilter(),
                    isFilter: reportsProvider.isFilter,
                  ),
                  const SizedBox(width: 16),
                  CommonReportExportButton(
                    onPressed: () async {
                      final all =
                          await reportsProvider.fetchAllForExport(context);
                      if (all.isNotEmpty) {
                        exportToExcel(
                          headers: [
                            'Delivery Date',
                            'Customer Id',
                            'Customer Name',
                            'Project Type',
                            'Advance Payment',
                            'Second Payment',
                            'Third Payment',
                            'Balance Payment',
                            'Subsidy Amount',
                          ],
                          data: all
                              .map((t) => {
                                    'Delivery Date': t.materialDeliveryDate ?? '',
                                    'Customer Id': t.customerId,
                                    'Customer Name': t.customerName,
                                    'Project Type': t.projectType ?? '',
                                    'Advance Payment': t.advancePayment ?? '',
                                    'Second Payment': t.secondPayment ?? '',
                                    'Third Payment': t.thirdPayment ?? '',
                                    'Balance Payment': t.balancePayment,
                                    'Subsidy Amount': t.subsidyAmount ?? '',
                                  })
                              .toList(),
                          fileName: 'Accounts_Summary_Report',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No data found')),
                        );
                      }
                    },
                    label: 'Export',
                  ),
                ],
              ),
            ),

            // Filter bar
            if (reportsProvider.isFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CommonReportDateFilter(
                      fromDate: reportsProvider.fromDate?.toString(),
                      toDate: reportsProvider.toDate?.toString(),
                      formattedFromDate: reportsProvider.formattedFromDate,
                      formattedToDate: reportsProvider.formattedToDate,
                      onTap: () => _onClickDateButton(context),
                    ),
                    const Spacer(),
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null)
                      CommonReportResetButton(
                        onReset: () {
                          reportsProvider.removeFilters();
                          reportsProvider.setSearchCriteria(
                            reportsProvider.formattedFromDate,
                            reportsProvider.formattedToDate,
                          );
                          reportsProvider.getAccountsSummaryReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          elevation: 0,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 1400
                        ? 1400
                        : MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF2F5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    _headerCell('No.', 60),
                                    _headerCell('Delivery Date', 140),
                                    _headerCell('Customer ID', 120),
                                    _headerCell('Customer Name', 180),
                                    _headerCell('Project Type', 140),
                                    _headerCell('Advance Payment', 140),
                                    _headerCell('Second Payment', 140),
                                    _headerCell('Third Payment', 140),
                                    _headerCell('Balance Payment', 140),
                                    _headerCell('Subsidy Amount', 140),
                                  ],
                                ),
                              ),
                              reportsProvider.accountsSummaryReport.isEmpty
                                  ? const CommonEmptyState(
                                      message: 'No records found')
                                  : Column(
                                      children: List.generate(
                                        reportsProvider.accountsSummaryReport.length,
                                        (index) {
                                          final t = reportsProvider
                                              .accountsSummaryReport[index];
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Colors.white
                                                  : const Color(0xFFF6F7F9),
                                              border: Border(
                                                bottom: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 60,
                                                  child: Text('${index + 1}'),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.materialDeliveryDate ?? '-'),
                                                ),
                                                SizedBox(
                                                  width: 120,
                                                  child: Text(t.customerId.toString()),
                                                ),
                                                SizedBox(
                                                  width: 180,
                                                  child: Text(
                                                    t.customerName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.projectType ?? '-'),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.advancePayment ?? '0.00'),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.secondPayment ?? '0.00'),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.thirdPayment ?? '0.00'),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.balancePayment),
                                                ),
                                                SizedBox(
                                                  width: 140,
                                                  child: Text(t.subsidyAmount ?? '0.00'),
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

  Widget _headerCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF607185),
          ),
        ),
      ),
    );
  }

  void _onClickDateButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer<AccountsSummaryReportProvider>(
        builder: (ctx, provider, _) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                      children: List.generate(
                        [
                          'Yesterday',
                          'Today',
                          'Tomorrow',
                          'This Week',
                          'This Month'
                        ].length,
                        (index) {
                          final titles = [
                            'Yesterday',
                            'Today',
                            'Tomorrow',
                            'This Week',
                            'This Month'
                          ];
                          return ActionChip(
                            onPressed: () {
                              provider.setDateFilter(titles[index]);
                              provider.selectDateFilterOption(index);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            label: Text(titles[index]),
                            backgroundColor:
                                provider.selectedDateFilterIndex == index
                                    ? AppColors.primaryBlue
                                    : Colors.white,
                            labelStyle: TextStyle(
                              color: provider.selectedDateFilterIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        },
                      ),
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
                            onTap: () => provider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: provider.fromDate != null
                                  ? '${provider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: provider.toDate != null
                                  ? '${provider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.formatDate();
                          provider.setSearchCriteria(
                            provider.formattedFromDate,
                            provider.formattedToDate,
                          );
                          provider.getAccountsSummaryReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.selectDateFilterOption(null);
                          provider.setSearchCriteria('', '');
                          provider.getAccountsSummaryReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Clear'),
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
}

// ---------------------------------------------------------------------------
// MOBILE UI (private, same file)
// ---------------------------------------------------------------------------
class _AccountsSummaryPageReportMobile extends StatefulWidget {
  const _AccountsSummaryPageReportMobile();

  @override
  State<_AccountsSummaryPageReportMobile> createState() =>
      _AccountsSummaryPageReportMobileState();
}

class _AccountsSummaryPageReportMobileState extends State<_AccountsSummaryPageReportMobile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<AccountsSummaryReportProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      provider.setFilter(false);
      searchProvider.stopSearch();
      provider.setDateFilter('This Month');
      provider.selectDateFilterOption(4);
      provider.formatDate();
      provider.setSearchCriteria(
        provider.formattedFromDate,
        provider.formattedToDate,
      );
      provider.getAccountsSummaryReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AccountsSummaryReportProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Accounts Summary Report',
        showFilterIcon: true,
        onFilterTap: () => reportsProvider.toggleFilter(),
        titleStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
        showExcel: true,
        showSearch: false,
        onExcelTap: () async {
          final all = await reportsProvider.fetchAllForExport(context);
          if (all.isNotEmpty) {
            exportToExcel(
              headers: [
                'Delivery Date',
                'Customer Id',
                'Customer Name',
                'Project Type',
                'Advance Payment',
                'Second Payment',
                'Third Payment',
                'Balance Payment',
                'Subsidy Amount',
              ],
              data: all
                  .map((t) => {
                        'Delivery Date': t.materialDeliveryDate ?? '',
                        'Customer Id': t.customerId,
                        'Customer Name': t.customerName,
                        'Project Type': t.projectType ?? '',
                        'Advance Payment': t.advancePayment ?? '',
                        'Second Payment': t.secondPayment ?? '',
                        'Third Payment': t.thirdPayment ?? '',
                        'Balance Payment': t.balancePayment,
                        'Subsidy Amount': t.subsidyAmount ?? '',
                      })
                  .toList(),
              fileName: 'Accounts_Summary_Report',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data found')),
            );
          }
        },
        onClearTap: () {
          searchProvider.stopSearch();
          reportsProvider.setFilter(false);
          reportsProvider.removeFilters();
          reportsProvider.getAccountsSummaryReport(context);
        },
        onSearch: (String p1) {},
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (reportsProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('Date Range',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _onClickDateButton(context),
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: CustomText(
                                  reportsProvider.fromDate == null &&
                                          reportsProvider.toDate == null
                                      ? 'Date'
                                      : 'Date : ${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textBlack,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null)
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              reportsProvider.removeFilters();
                              reportsProvider.getAccountsSummaryReport(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (!reportsProvider.isFilter)
              Expanded(
                child: reportsProvider.accountsSummaryReport.isEmpty
                    ? const CommonEmptyState(message: 'No records found')
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: reportsProvider.accountsSummaryReport.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = reportsProvider.accountsSummaryReport[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.customerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF152D70),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _mobileRow('Delivery Date', t.materialDeliveryDate ?? '-'),
                                  _mobileRow('Customer ID', t.customerId.toString()),
                                  _mobileRow('Project Type', t.projectType ?? '-'),
                                  _mobileRow('Advance Payment', t.advancePayment ?? '0.00'),
                                  _mobileRow('Second Payment', t.secondPayment ?? '0.00'),
                                  _mobileRow('Third Payment', t.thirdPayment ?? '0.00'),
                                  _mobileRow('Balance Payment', t.balancePayment),
                                  _mobileRow('Subsidy Amount', t.subsidyAmount ?? '0.00'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: reportsProvider.isFilter
          ? Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: FloatingActionButton.extended(
                heroTag: 'apply_accounts_summary_report_filter_fab',
                onPressed: () {
                  reportsProvider.setSearchCriteria(
                    reportsProvider.formattedFromDate,
                    reportsProvider.formattedToDate,
                  );
                  reportsProvider.getAccountsSummaryReport(context);
                  reportsProvider.setFilter(false);
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
            )
          : null,
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _onClickDateButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer<AccountsSummaryReportProvider>(
        builder: (ctx, provider, _) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        'Yesterday',
                        'Today',
                        'Tomorrow',
                        'This Week',
                        'This Month'
                      ].asMap().entries.map((e) {
                        return ActionChip(
                          onPressed: () {
                            provider.setDateFilter(e.value);
                            provider.selectDateFilterOption(e.key);
                          },
                          label: Text(e.value),
                          backgroundColor:
                              provider.selectedDateFilterIndex == e.key
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: provider.selectedDateFilterIndex == e.key
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              hintText: provider.fromDate != null
                                  ? '${provider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              hintText: provider.toDate != null
                                  ? '${provider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.formatDate();
                          provider.setSearchCriteria(
                            provider.formattedFromDate,
                            provider.formattedToDate,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
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
}
