import 'package:vidyanexis/controller/models/followup_amount_report_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/followup_amount_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class FollowupAmountReportPage extends StatefulWidget {
  const FollowupAmountReportPage({super.key});

  @override
  State<FollowupAmountReportPage> createState() =>
      _FollowupAmountReportPageState();
}

class _FollowupAmountReportPageState extends State<FollowupAmountReportPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<FollowupAmountReportProvider>(context, listen: false);
      provider.resetFilters();
      provider.getReport(context);
      Provider.of<DropDownProvider>(context, listen: false)
          .getUserDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FollowupAmountReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    bool isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Followup Amount Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onSearchTap: () {
                sideProvider.startSearch();
              },
              onSearch: (query) {
                provider.setSearch(query);
              },
              onClearTap: () {
                searchController.clear();
                sideProvider.stopSearch();
                provider.setSearch('');
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(provider),
              onFilterTap: () {
                provider.toggleFilter();
              },
            ),
      body: isWeb
          ? _buildWebBody(provider, dropDownProvider)
          : _buildMobileBody(provider, dropDownProvider),
    );
  }

  Widget _buildWebBody(FollowupAmountReportProvider provider,
      DropDownProvider dropDownProvider) {
    final reportData = provider.filteredReportList;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildWebHeader(provider)),
          if (provider.isFilter)
            SliverToBoxAdapter(
                child: _buildWebFilterBar(provider, dropDownProvider)),
          SliverToBoxAdapter(child: _buildWebTableHeader()),
          if (reportData.isEmpty)
            const SliverFillRemaining(
              child:
                  CommonEmptyState(message: 'No followup amount reports found'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = reportData[index];
                  return _buildWebTableRow(item, index);
                },
                childCount: reportData.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(FollowupAmountReportProvider provider) {
    return Container(
      color: Colors.grey[50],
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
            'Followup Amount Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
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
              onChanged: (query) {
                provider.setSearch(query);
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
              provider.toggleFilter();
            },
            isFilter: provider.isFilter,
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _exportData(provider),
            icon: const Icon(Icons.download),
            label: Text(MediaQuery.of(context).size.width > 860
                ? 'Export To Excel'
                : ''),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFilterBar(FollowupAmountReportProvider provider,
      DropDownProvider dropDownProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey),
      ),
      child: Row(
        children: [
          CommonReportDateFilter(
            fromDate: provider.fromDate?.toString(),
            toDate: provider.toDate?.toString(),
            formattedFromDate: provider.formattedFromDate,
            formattedToDate: provider.formattedToDate,
            label: 'Registration Date',
            onTap: () => _showDateDialog(context, provider),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    provider.selectedUser != null && provider.selectedUser != 0
                        ? AppColors.primaryBlue
                        : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'To Staff: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                DropdownButton<int>(
                  value: provider.selectedUser,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      dropDownProvider.searchUserDetails
                          .map((user) => DropdownMenuItem<int>(
                                value: user.userDetailsId,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    user.userDetailsName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    provider.setUserFilter(newValue);
                    provider.getReport(context);
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (provider.fromDate != null ||
              (provider.selectedUser != null && provider.selectedUser != 0))
            CommonReportResetButton(
              label: 'Reset',
              onReset: () {
                provider.resetFilters();
                provider.getReport(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWebTableHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 60,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Text('No',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF607185))),
                ),
              ),
              TableWidget(
                  title: 'Next Followup Date',
                  flex: 2,
                  color: Color(0xFF607185)),
              TableWidget(
                  title: 'Customer Name', flex: 2, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Lead Creation Date',
                  flex: 2,
                  color: Color(0xFF607185)),
              TableWidget(
                  title: 'Lead Conversion Date',
                  flex: 2,
                  color: Color(0xFF607185)),
              TableWidget(title: 'Status', flex: 2, color: Color(0xFF607185)),
              TableWidget(title: 'Amount', flex: 2, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Assigned Staff', flex: 2, color: Color(0xFF607185)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebTableRow(FollowupAmountReportModel item, int index) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Text((index + 1).toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TableWidget(
                  data: Text(
                      item.nextFollowUpDate.isNotEmpty
                          ? item.nextFollowUpDate.toDayMonthYearFormat()
                          : '-',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  flex: 2),
              TableWidget(
                  data: Text(
                      item.customerName.isNotEmpty ? item.customerName : '-',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  flex: 2),
              TableWidget(
                  data: Text(item.leadCreationDate.isNotEmpty
                      ? item.leadCreationDate.toDayMonthYearFormat()
                      : '-'),
                  flex: 2),
              TableWidget(
                  data: Text(item.registeredDate.isNotEmpty
                      ? item.registeredDate.toDayMonthYearFormat()
                      : '-'),
                  flex: 2),
              TableWidget(
                  data:
                      Text(item.statusName.isNotEmpty ? item.statusName : '-'),
                  flex: 2),
              TableWidget(
                data: Text(
                  '₹ ${item.amount}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue),
                ),
                flex: 2,
              ),
              TableWidget(
                  data:
                      Text(item.toUserName.isNotEmpty ? item.toUserName : '-'),
                  flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBody(FollowupAmountReportProvider provider,
      DropDownProvider dropDownProvider) {
    final reportData = provider.filteredReportList;

    return Column(
      children: [
        if (provider.isFilter)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText('Registration Date Range',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack),
                  const SizedBox(height: 12),
                  CommonReportDateFilter(
                    fromDate: provider.fromDate?.toString(),
                    toDate: provider.toDate?.toString(),
                    formattedFromDate: provider.formattedFromDate,
                    formattedToDate: provider.formattedToDate,
                    label: 'Pick Date Range',
                    onTap: () => _showDateDialog(context, provider),
                  ),
                  const SizedBox(height: 24),
                  CustomText('Filter by Staff',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChipWidget(
                        label: 'All Staff',
                        isSelected: provider.selectedUser == null ||
                            provider.selectedUser == 0,
                        onTap: () {
                          provider.setUserFilter(0);
                          if (!AppStyles.isWebScreen(context)) {
                            provider.setFilter(false);
                          }
                          provider.getReport(context);
                        },
                      ),
                      ...dropDownProvider.searchUserDetails.map(
                        (user) => FilterChipWidget(
                          label: user.userDetailsName ?? '',
                          isSelected:
                              provider.selectedUser == user.userDetailsId,
                          onTap: () {
                            provider.setUserFilter(user.userDetailsId);
                            if (!AppStyles.isWebScreen(context)) {
                              provider.setFilter(false);
                            }
                            provider.getReport(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (provider.fromDate != null ||
                      (provider.selectedUser != null &&
                          provider.selectedUser != 0))
                    SizedBox(
                      width: double.infinity,
                      child: CommonReportResetButton(
                        onReset: () {
                          provider.resetFilters();
                          if (!AppStyles.isWebScreen(context)) {
                            provider.setFilter(false);
                          }
                          provider.getReport(context);
                        },
                        label: 'Reset',
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (!provider.isFilter)
          Expanded(
            child: reportData.isEmpty
                ? const CommonEmptyState(
                    message: 'No followup amount reports found')
                : Column(
                    children: [
                      CommonReportSummaryBar(
                        totalLabel: 'Total Records',
                        totalCount: reportData.length,
                        showingLabel: 'Showing',
                        showingCount: reportData.length,
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: reportData.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = reportData[index];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(
                                    color: AppColors.grey.withOpacity(0.5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.customerName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '₹ ${item.amount}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    _buildMobileRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Next Follow-up',
                                      value: item.nextFollowUpDate.isNotEmpty
                                          ? item.nextFollowUpDate
                                              .toDayMonthYearFormat()
                                          : '-',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMobileRow(
                                      icon: Icons.create_new_folder_outlined,
                                      label: 'Lead Created',
                                      value: item.leadCreationDate.isNotEmpty
                                          ? item.leadCreationDate
                                              .toDayMonthYearFormat()
                                          : '-',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMobileRow(
                                      icon: Icons.check_circle_outline,
                                      label: 'Converted Date',
                                      value: item.registeredDate.isNotEmpty
                                          ? item.registeredDate
                                              .toDayMonthYearFormat()
                                          : '-',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMobileRow(
                                      icon: Icons.info_outline,
                                      label: 'Status',
                                      value: item.statusName.isNotEmpty
                                          ? item.statusName
                                          : '-',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMobileRow(
                                      icon: Icons.person_outline,
                                      label: 'Staff',
                                      value: item.toUserName.isNotEmpty
                                          ? item.toUserName
                                          : '-',
                                    ),
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
      ],
    );
  }

  Widget _buildMobileRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey4),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textGrey4,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showDateDialog(
      BuildContext context, FollowupAmountReportProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<FollowupAmountReportProvider>(
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
                      children: List<Widget>.generate(_dateButtonTitles.length,
                          (index) {
                        String title = _dateButtonTitles[index];
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
                      'Pick From Date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      onTap: () => reportsProvider.selectDate(context, true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        hintText: reportsProvider.fromDate != null
                            ? '${reportsProvider.fromDate!.toLocal()}'
                                .split(' ')[0]
                            : 'From Date',
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick To Date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      onTap: () => reportsProvider.selectDate(context, false),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        hintText: reportsProvider.toDate != null
                            ? '${reportsProvider.toDate!.toLocal()}'
                                .split(' ')[0]
                            : 'To Date',
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.formatDate();
                          if (!AppStyles.isWebScreen(context)) {
                            reportsProvider.setFilter(false);
                          }
                          reportsProvider.getReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Select'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          if (!AppStyles.isWebScreen(context)) {
                            reportsProvider.setFilter(false);
                          }
                          reportsProvider.getReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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

  void _exportData(FollowupAmountReportProvider provider) {
    exportToExcel(
      headers: [
        'Next Followup Date',
        'Customer Name',
        'Lead Creation Date',
        'Lead Conversion Date',
        'Status',
        'Amount',
        'Assigned Staff',
      ],
      data: provider.filteredReportList.map((item) {
        return {
          'Next Followup Date': item.nextFollowUpDate.isNotEmpty
              ? item.nextFollowUpDate.toDayMonthYearFormat()
              : '-',
          'Customer Name':
              item.customerName.isNotEmpty ? item.customerName : '-',
          'Lead Creation Date': item.leadCreationDate.isNotEmpty
              ? item.leadCreationDate.toDayMonthYearFormat()
              : '-',
          'Lead Conversion Date': item.registeredDate.isNotEmpty
              ? item.registeredDate.toDayMonthYearFormat()
              : '-',
          'Status': item.statusName.isNotEmpty ? item.statusName : '-',
          'Amount': '₹ ${item.amount}',
          'Assigned Staff': item.toUserName.isNotEmpty ? item.toUserName : '-',
        };
      }).toList(),
      fileName: 'Followup_Amount_Report',
    );
  }

  final List<String> _dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
