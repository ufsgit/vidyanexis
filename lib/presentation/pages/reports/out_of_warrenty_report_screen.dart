import 'dart:async';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

class OutOfWarrentyReportScreen extends StatefulWidget {
  const OutOfWarrentyReportScreen({super.key});

  @override
  State<OutOfWarrentyReportScreen> createState() =>
      _OutOfWarrentyReportScreen();
}

class _OutOfWarrentyReportScreen extends State<OutOfWarrentyReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final reportsProvider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria(
        query,
        reportsProvider.fromDateS,
        reportsProvider.toDateS,
        reportsProvider.Status,
        reportsProvider.AssignedTo,
      );
      reportsProvider.getSearchOutOfWarrentyReport(context);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchOutOfWarrentyReport(context);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WarrentyReportProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    final isMobile = !isWeb;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? const SidebarDrawer() : null,
      appBar: isMobile
          ? CustomAppBar(
              title: 'Out of Warranty Reports',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              showFilterIcon: false,
              searchHintText: 'Search Reports...',
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onSearchTap: () {
                Provider.of<SidebarProvider>(context, listen: false).startSearch();
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                reportsProvider.toggleFilter();
                Provider.of<SidebarProvider>(context, listen: false).stopSearch();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchOutOfWarrentyReport(context);
              },
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchOutOfWarrentyReport(context);
              },
              onChanged: _onSearchChanged,
              searchController: searchController,
              showExcel: true,
              onExcelTap: () {
                exportToExcel(
                  headers: [
                    'No',
                    'Customer Name',
                    'Contact No',
                    'Address',
                    'District',
                    'Company',
                    'From Date',
                    'To Date'
                  ],
                  data: reportsProvider.outOfWarrentyReport
                      .asMap()
                      .entries
                      .map((entry) {
                    var index = entry.key;
                    var task = entry.value;
                    return {
                      'No': (index + 1).toString(),
                      'Customer Name': task.customerName,
                      'Contact No': task.contactNumber,
                      'Address': task.address1,
                      'District': task.district,
                      'Company': task.company,
                      'From Date': task.installationDate.toDayMonthYearFormat(),
                      'To Date': task.expiryDate.toDayMonthYearFormat(),
                    };
                  }).toList(),
                  fileName: 'Out_Of_Warranty_Report',
                );
              },
            )
          : null,
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
                            borderRadius: BorderRadius.circular(12),
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
                      'Out of Warranty Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(child: Container()),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (query) {
                          reportsProvider.setTaskSearchCriteria(
                            query,
                            reportsProvider.fromDateS,
                            reportsProvider.toDateS,
                            reportsProvider.Status,
                            reportsProvider.AssignedTo,
                          );
                          reportsProvider
                              .getSearchOutOfWarrentyReport(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                String query = searchController.text;
                                if (reportsProvider.Search.isNotEmpty) {
                                  searchController.clear();
                                  reportsProvider.setTaskSearchCriteria(
                                    '',
                                    reportsProvider.fromDateS,
                                    reportsProvider.toDateS,
                                    reportsProvider.Status,
                                    reportsProvider.AssignedTo,
                                  );
                                  reportsProvider
                                      .getSearchOutOfWarrentyReport(
                                          context);
                                } else {
                                  reportsProvider.setTaskSearchCriteria(
                                    query,
                                    reportsProvider.fromDateS,
                                    reportsProvider.toDateS,
                                    reportsProvider.Status,
                                    reportsProvider.AssignedTo,
                                  );
                                  reportsProvider
                                      .getSearchOutOfWarrentyReport(
                                          context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textGrey4,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(reportsProvider.Search.isNotEmpty
                                  ? 'Cancel'
                                  : 'Search'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomFilterButton(
                      onPressed: () {
                        reportsProvider.toggleFilter();
                      },
                      isFilter: reportsProvider.isFilter,
                    ),
                    const SizedBox(width: 16),
                    CustomElevatedButton(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'No',
                            'Customer Name',
                            'Contact No',
                            'Address',
                            'District',
                            'Company',
                            'From Date',
                            'To Date'
                          ],
                          data: reportsProvider.outOfWarrentyReport
                              .asMap()
                              .entries
                              .map((entry) {
                            var index = entry.key;
                            var task = entry.value;
                            return {
                              'No': (index + 1).toString(),
                              'Customer Name': task.customerName,
                              'Contact No': task.contactNumber,
                              'Address': task.address1,
                              'District': task.district,
                              'Company': task.company,
                              'From Date': task.installationDate
                                  .toDayMonthYearFormat(),
                              'To Date':
                                  task.expiryDate.toDayMonthYearFormat(),
                            };
                          }).toList(),
                          fileName: 'Out_Of_Warranty_Report',
                        );
                      },
                      buttonText: 'Export to Excel',
                      textColor: AppColors.whiteColor,
                      borderColor: AppColors.appViolet,
                      backgroundColor: AppColors.appViolet,
                    ),
                  ],
                ),
              ),

            // ── MOBILE FILTER PANEL ────────────────────────────────────────────────
            if (!AppStyles.isWebScreen(context) && reportsProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomText('Date Range',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 200),
                                        child: CustomText(
                                          reportsProvider.fromDate == null && reportsProvider.toDate == null
                                              ? 'Date'
                                              : 'Date : ${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textBlack,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey3, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null ||
                          (reportsProvider.selectedStatus != null &&
                              reportsProvider.selectedStatus != 0) ||
                          (reportsProvider.selectedUser != null &&
                              reportsProvider.selectedUser != 0) ||
                          reportsProvider.Search.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              searchController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                '',
                                '',
                                '',
                                '',
                                '',
                              );
                              reportsProvider.getSearchOutOfWarrentyReport(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // ── LIST / TABLE CONTAINER ─────────────────────────────────────────────
            if (AppStyles.isWebScreen(context) || !reportsProvider.isFilter)
              Expanded(
                child: AppStyles.isWebScreen(context)
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Header Row
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF2F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 15.0),
                                          child: Text('No.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF607185))),
                                        ),
                                      ),
                                      TableWidget(
                                          flex: 2,
                                          title: 'Customer Name',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Contact No',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 2,
                                          title: 'Address',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'District',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Company',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'From Date',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'To Date',
                                          color: Color(0xFF607185)),
                                    ],
                                  ),
                                ),
                                // Data Rows
                                Expanded(
                                  child: reportsProvider
                                          .outOfWarrentyReport.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 80),
                                              Icon(Icons.search_off_outlined,
                                                  size: 80,
                                                  color: Colors.grey[300]),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No out of warranty reports found',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: reportsProvider
                                              .outOfWarrentyReport.length,
                                          itemBuilder: (context, index) {
                                            var item = reportsProvider
                                                .outOfWarrentyReport[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : const Color(0xFFF6F7F9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 12.0,
                                                          horizontal: 15.0),
                                                      child: Text(
                                                          (index + 1).toString(),
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                    ),
                                                  ),
                                                  TableWidget(
                                                    flex: 2,
                                                    data: InkWell(
                                                      onTap: () {
                                                        context.push(
                                                            '${CustomerDetailsScreen.route}${item.customerId.toString()}/${'true'}');
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFFE9EDF1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: Text(
                                                          item.customerName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TableWidget(
                                                      flex: 1,
                                                      title: item.contactNumber),
                                                  TableWidget(
                                                    flex: 2,
                                                    data: Tooltip(
                                                      message: item.address1,
                                                      child: Text(
                                                        item.address1,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  TableWidget(
                                                      flex: 1,
                                                      title: item.district),
                                                  TableWidget(
                                                      flex: 1,
                                                      title: item.company),
                                                  TableWidget(
                                                      flex: 1,
                                                      title: item.installationDate
                                                          .toDayMonthYearFormat()),
                                                  TableWidget(
                                                      flex: 1,
                                                      title: item.expiryDate
                                                          .toDayMonthYearFormat()),
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
                      )
                    : Column(
                        children: [
                          if (reportsProvider.outOfWarrentyReport.isNotEmpty)
                            CommonReportSummaryBar(
                              totalLabel: 'Total Records',
                              totalCount: reportsProvider.outOfWarrentyReport.length,
                              showingLabel: 'Showing',
                              showingCount: reportsProvider.outOfWarrentyReport.length,
                            ),
                          Expanded(
                            child: reportsProvider.outOfWarrentyReport.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.assignment_outlined,
                                            size: 64, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No out of warranty reports found',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemCount: reportsProvider.outOfWarrentyReport.length,
                                    itemBuilder: (context, index) {
                                      var item = reportsProvider.outOfWarrentyReport[index];
                                      return ReportListItem(
                                        title: item.customerName,
                                        subtitle: item.contactNumber,
                                        onTap: () {
                                          context.push(
                                              '${CustomerDetailsScreen.route}${item.customerId.toString()}/${'true'}');
                                        },
                                        status: 'Expired: ${item.expiryDate.toDayMonthYearFormat()}',
                                        statusColor: AppColors.textRed,
                                        description: '${item.address1} ${item.district}'.trim(),
                                        bottomLeftIcon: Icons.medical_services_outlined,
                                        bottomLeftText: 'Warranty',
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: (isMobile && reportsProvider.isFilter)
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_outofwarrenty_report_filter_fab',
                  onPressed: () {
                    reportsProvider.getSearchOutOfWarrentyReport(context);
                    reportsProvider.toggleFilter();
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
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<WarrentyReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
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
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportsProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                reportsProvider.selectedDateFilterIndex == index
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }),
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
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
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
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
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

                          reportsProvider.formatDate();

                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo);
                          reportsProvider.getSearchOutOfWarrentyReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = '';
                          String toDate = '';
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getSearchOutOfWarrentyReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
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
