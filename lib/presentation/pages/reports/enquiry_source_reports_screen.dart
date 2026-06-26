import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/enquiry_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class EnquirySourceReportsScreen extends StatefulWidget {
  static const String route = '/enquirySourceReport/';
  final String userId;
  const EnquirySourceReportsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EnquirySourceReportsScreen> createState() =>
      _EnquirySourceReportsScreenState();
}

class _EnquirySourceReportsScreenState
    extends State<EnquirySourceReportsScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<EnquiryReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchTaskReport(widget.userId, context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '0');

      //search
      // searchController.addListener(() {
      //   reportsProvider.selectDateFilterOption(null);
      //   reportsProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   reportsProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EnquiryReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldColor,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
            )
          : CustomAppBar(
              title: 'Enquiry Source Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onFilterTap: () => reportsProvider.toggleFilter(),
              showSearch: true,
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchTaskReport(widget.userId, context);
              },
              searchController: searchController,
            ),
      body: Consumer<EnquiryReportProvider>(
        builder: (context, reportsProvider, child) {
          if (AppStyles.isWebScreen(context)) {
            return Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWebHeader(context, reportsProvider),
                  if (reportsProvider.isFilter)
                    _buildWebFilterPanel(context, reportsProvider, provider),
                  _buildWebDataTable(context, reportsProvider),
                ],
              ),
            );
          }
          return _buildMobileLayout(context, reportsProvider, provider);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context,
      EnquiryReportProvider reportsProvider, DropDownProvider provider) {
    return Column(
      children: [
        if (reportsProvider.isFilter)
          _buildMobileFilterPanel(context, reportsProvider, provider),
        if (reportsProvider.taskReport.isNotEmpty && !reportsProvider.isFilter)
          CommonReportSummaryBar(
            totalLabel: 'Total Enquiries',
            totalCount: reportsProvider.taskReport.length,
            showingLabel: 'Showing',
            showingCount: reportsProvider.taskReport.length,
          ),
        Expanded(
          child: reportsProvider.taskReport.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reportsProvider.taskReport.length,
                  itemBuilder: (context, index) {
                    final task = reportsProvider.taskReport[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportListItem(
                        onTap: () {
                          context.push(
                              '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                        },
                        title: task.customer,
                        subtitle: task.mobile,
                        description: task.remark,
                        status: task.statusName,
                        statusColor: parseColor(task.colorCode),
                        bottomLeftIcon: Icons.calendar_today_outlined,
                        bottomLeftText: task.followUp,
                        bottomRightText: task.followUpBy,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMobileFilterPanel(BuildContext context,
      EnquiryReportProvider reportsProvider, DropDownProvider provider) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: reportsProvider.fromDate?.toString(),
              toDate: reportsProvider.toDate?.toString(),
              formattedFromDate: reportsProvider.formattedFromDate,
              formattedToDate: reportsProvider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            CustomText('Status',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: reportsProvider.selectedStatus == 0 ||
                      reportsProvider.selectedStatus == null,
                  onTap: () {
                    reportsProvider.setStatus(0);
                    reportsProvider.setTaskSearchCriteria(
                        reportsProvider.Search,
                        reportsProvider.formattedFromDate,
                        reportsProvider.formattedToDate,
                        '0',
                        reportsProvider.AssignedTo);
                    reportsProvider.getSearchTaskReport(widget.userId, context);
                  },
                ),
                ...provider.followUpData.map((status) {
                  return FilterChipWidget(
                    label: status.statusName ?? 'Unknown',
                    isSelected:
                        reportsProvider.selectedStatus == status.statusId,
                    onTap: () {
                      reportsProvider.setStatus(status.statusId ?? 0);
                      reportsProvider.setTaskSearchCriteria(
                          reportsProvider.Search,
                          reportsProvider.formattedFromDate,
                          reportsProvider.formattedToDate,
                          (status.statusId ?? 0).toString(),
                          reportsProvider.AssignedTo);
                      reportsProvider.getSearchTaskReport(
                          widget.userId, context);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      reportsProvider.getSearchTaskReport(
                          widget.userId, context);
                      reportsProvider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.removeStatus();
                    searchController.clear();
                    reportsProvider.setTaskSearchCriteria(
                      '',
                      '',
                      '',
                      '',
                      '',
                    );
                    reportsProvider.getSearchTaskReport(widget.userId, context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(
      BuildContext context, EnquiryReportProvider reportsProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Enquiry Source Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(child: Container()),
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
              onTap: () {
                Future.microtask(() {
                  if (searchController.text.isNotEmpty &&
                      searchController.selection.baseOffset == 0 &&
                      searchController.selection.extentOffset ==
                          searchController.text.length) {
                    searchController.selection = TextSelection.collapsed(
                        offset: searchController.text.length);
                  }
                });
              },
              onSubmitted: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchTaskReport(widget.userId, context);
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
                suffixIcon: GestureDetector(
                  onTap: () {
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.fromDateS,
                      reportsProvider.toDateS,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                    );
                    reportsProvider.getSearchTaskReport(widget.userId, context);
                  },
                  child: const Icon(Icons.search,
                      color: Color(0xFF64748B), size: 18),
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
          CommonReportExportButton(
                      onPressed: () {
              exportToExcel(
                headers: [
                  'Customer Name',
                  'Mobile',
                  'Address',
                  'Follow Up By',
                  'Remark',
                  'Entry Date',
                  'Follow Up Date',
                  'Status'
                ],
                data: reportsProvider.taskReport.map((task) {
                  return {
                    'Customer Name': task.customer,
                    'Mobile': task.mobile,
                    'Address': task.address1,
                    'Follow Up By': task.followUpBy,
                    'Remark': task.remark,
                    'Entry Date': task.entryDate,
                    'Follow Up Date': task.followUp,
                    'Status': task.statusName,
                  };
                }).toList(),
                fileName: 'Work_Report',
              );
            },
                      label: 'Export to Excel',
                    )
        ],
      ),
    );
  }

  Widget _buildWebFilterPanel(BuildContext context,
      EnquiryReportProvider reportsProvider, DropDownProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
      child: Row(
        children: [
          Container(
            height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Row(
              children: [
                const Text('Status: '),
                DropdownButton<int>(
                  value: reportsProvider.selectedStatus,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text(
                            'All',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ] +
                      provider.followUpData
                          .map((status) => DropdownMenuItem<int>(
                                value: status.statusId,
                                child: Text(
                                  status.statusName ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      reportsProvider.setStatus(newValue);
                    }
                    reportsProvider.setTaskSearchCriteria(
                        reportsProvider.Search,
                        reportsProvider.formattedFromDate,
                        reportsProvider.formattedToDate,
                        (newValue ?? 0).toString(),
                        reportsProvider.AssignedTo);
                    reportsProvider.getSearchTaskReport(widget.userId, context);
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          const Spacer(),
          if (reportsProvider.fromDate != null ||
              reportsProvider.toDate != null ||
              (reportsProvider.selectedStatus != null &&
                  reportsProvider.selectedStatus != 0) ||
              (reportsProvider.selectedUser != null &&
                  reportsProvider.selectedUser != 0) ||
              reportsProvider.Search.isNotEmpty)
            CommonReportResetButton(
              onReset: () {
                reportsProvider.removeStatus();
                searchController.clear();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  '',
                  '',
                  '',
                  '',
                );
                reportsProvider.getSearchTaskReport(widget.userId, context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWebDataTable(
      BuildContext context, EnquiryReportProvider reportsProvider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Header Row (Table Column Titles)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF2F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 25.0),
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
                          flex: 1, title: 'Mobile', color: Color(0xFF607185)),
                      TableWidget(
                          flex: 2, title: 'Address', color: Color(0xFF607185)),
                      TableWidget(
                          flex: 1,
                          title: 'Follow Up By',
                          color: Color(0xFF607185)),
                      TableWidget(
                          flex: 3, title: 'Remark', color: Color(0xFF607185)),
                      TableWidget(
                          flex: 1,
                          title: 'Entry Date',
                          color: Color(0xFF607185)),
                      TableWidget(
                          flex: 1,
                          title: 'Follow Up Date',
                          color: Color(0xFF607185)),
                      TableWidget(
                          flex: 1, title: 'Status', color: Color(0xFF607185)),
                    ],
                  ),
                ),
                // Data Rows
                Expanded(
                  child: reportsProvider.taskReport.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: reportsProvider.taskReport.length,
                          itemBuilder: (context, index) {
                            var task = reportsProvider.taskReport[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : const Color(0xFFF6F7F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 25.0),
                                      child: Text((index + 1).toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                  TableWidget(
                                    flex: 2,
                                    data: InkWell(
                                      onTap: () {
                                        context.push(
                                            '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                      },
                                      child: Container(
                                        height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                          color: const Color(0xFFE9EDF1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Text(
                                          task.customer,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableWidget(flex: 1, title: task.mobile),
                                  TableWidget(
                                    flex: 2,
                                    data: Tooltip(
                                      message: task.address1,
                                      child: Text(
                                        task.address1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableWidget(flex: 1, title: task.followUpBy),
                                  TableWidget(flex: 3, title: task.remark),
                                  TableWidget(flex: 1, title: task.entryDate),
                                  TableWidget(flex: 1, title: task.followUp),
                                  TableWidget(
                                    flex: 1,
                                    data: Container(
                                      padding: task.statusName.isNotEmpty
                                          ? const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4)
                                          : const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: parseColor(task.colorCode)
                                            .withOpacity(0.1)
                                            .withAlpha(30),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.black45, width: 0.1),
                                      ),
                                      child: Text(
                                        task.statusName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: parseColor(task.colorCode),
                                          fontSize: 13,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No reports found');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<EnquiryReportProvider>(
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
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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

                          print(reportsProvider.formattedFromDate);
                          print(reportsProvider.formattedToDate);

                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo);
                          reportsProvider.getSearchTaskReport(
                              widget.userId, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getSearchTaskReport(
                              widget.userId, context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
