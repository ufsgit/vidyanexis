import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:go_router/go_router.dart';

class ExpenseReportScreen extends StatefulWidget {
  static const String route = "/expense_report";
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.getUserDetails('', context);
      provider.getExpenseType(context);
      settingsProvider.searchProjectTypes('', context);
      provider.getExpenseReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Expense Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        leadingWidget: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textGrey4),
          iconSize: 24,
        ),
        onFilterTap: () => provider.toggleFilter(),
        showExcel: true,
        onExcelTap: () => _handleExport(provider),
        showSearch: true,
        onSearch: (query) => provider.searchExpense(query, context),
        searchController: provider.searchExpenseController,
      ),
      body: Column(
        children: [
          if (provider.isFilter)
            _buildFilterPanel(context, provider, settingsProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(provider, isSmallScreen),
                  const SizedBox(height: 24),
                  _buildExpenseList(provider, isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(ExpenseProvider provider) async {
    List<String> headers = [
      "Sl No",
      "User Name",
      "Entry Date",
      "Expense Head",
      "Category",
      "Project Name",
      "Amount"
    ];

    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < provider.expenseModelList.length; i++) {
      var item = provider.expenseModelList[i];
      data.add({
        "Sl No": (i + 1).toString(),
        "User Name": item.userName ?? "",
        "Entry Date": item.entryDate ?? "",
        "Expense Head": item.expenseHead ?? "",
        "Category": item.expenseTypeName ?? "",
        "Project Name": item.projectName ?? "",
        "Amount": item.amount.toString()
      });
    }

    await exportToExcel(
        headers: headers,
        data: data,
        fileName:
            'Expense_Report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}');
  }

  Widget _buildFilterPanel(BuildContext context, ExpenseProvider provider,
      SettingsProvider settingsProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Filter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: provider.fromDate?.toString(),
              toDate: provider.toDate?.toString(),
              formattedFromDate: provider.formattedFromDate,
              formattedToDate: provider.formattedToDate,
              onTap: () => _showDateDialog(context, provider),
            ),
            const SizedBox(height: 24),
            CustomText('User Filter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: provider.selectedUser == null ||
                      provider.selectedUser == 0,
                  onTap: () => provider.setUserFilter(0),
                ),
                ...settingsProvider.searchUserDetails.map((user) =>
                    FilterChipWidget(
                      label: user.userDetailsName ?? '',
                      isSelected: provider.selectedUser == user.userDetailsId,
                      onTap: () => provider.setUserFilter(user.userDetailsId!),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            CustomText('Expense Type',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: provider.selectedExpenseTypeId == null ||
                      provider.selectedExpenseTypeId == 0,
                  onTap: () => provider.setSelectedExpenseTypeId(0),
                ),
                ...provider.expenseTypeList.map((type) => FilterChipWidget(
                      label: type.expenseTypeName ?? '',
                      isSelected:
                          provider.selectedExpenseTypeId == type.expenseTypeId,
                      onTap: () => provider
                          .setSelectedExpenseTypeId(type.expenseTypeId!),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.getExpenseReport(context);
                      provider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    provider.setFromDate(DateTime.now());
                    provider.setToDate(DateTime.now());
                    provider.clearUserFilter();
                    provider.clearExpenseTypeFilter();
                    provider.clearProjectTypeFilter();
                    provider.getExpenseReport(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDateDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (contextx) => Consumer<ExpenseProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose Date',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Yesterday',
                      'Today',
                      'Tomorrow',
                      'This Week',
                      'This Month'
                    ]
                        .asMap()
                        .entries
                        .map((e) => ActionChip(
                              label: Text(e.value),
                              onPressed: () {
                                reportsProvider.setDateFilter(e.value);
                                reportsProvider.selectDateFilterOption(e.key);
                              },
                              backgroundColor:
                                  reportsProvider.selectedDateFilterIndex ==
                                          e.key
                                      ? AppColors.primaryBlue
                                      : Colors.white,
                              labelStyle: TextStyle(
                                  color:
                                      reportsProvider.selectedDateFilterIndex ==
                                              e.key
                                          ? Colors.white
                                          : Colors.black),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    onTap: () => reportsProvider.selectDate(context, true),
                    decoration: InputDecoration(
                      labelText: 'Pick a date',
                      hintText: reportsProvider.fromDate != null
                          ? reportsProvider.formattedFromDate
                          : 'Select',
                      suffixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        reportsProvider.getExpenseReport(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider provider, bool isSmallScreen) {
    final amountColor = Colors.white;
    final labelColor = Colors.white.withOpacity(0.85);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue, // This is yellow in this project
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem('Received Amount',
              provider.correlationbox.receivedAmount, labelColor, amountColor),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          _buildSummaryItem(
              'Total Expense Amount',
              provider.correlationbox.totalExpenseAmount,
              labelColor,
              amountColor),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          _buildSummaryItem('Total Balance',
              provider.correlationbox.totalBalance, labelColor, amountColor),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, double? amount, Color labelColor, Color amountColor) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: labelColor,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹ ${amount?.toStringAsFixed(2) ?? "0.00"}',
          style: GoogleFonts.plusJakartaSans(
            color: amountColor,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList(ExpenseProvider provider, bool isSmallScreen) {
    if (provider.expenseModelList.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No expenses found',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.expenseModelList.length,
      itemBuilder: (context, index) {
        final item = provider.expenseModelList[index];
        return ReportListItem(
          title: item.expenseHead ?? 'No Title',
          subtitle: item.expenseTypeName ?? 'Uncategorized',
          description: '${item.userName ?? "-"} • ${item.entryDate ?? "-"}',
          trailingText: '₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
          onDelete: () => _confirmDelete(context, provider, item),
          statusColor: AppColors.primaryBlue,
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseProvider provider, ExpenseModel item) {
    showConfirmationDialog(
      context: context,
      title: 'Delete Expense',
      content: 'Are you sure you want to delete this expense?',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () async {
        Navigator.of(context).pop();
        provider.deleteExpense(context, item.expenseManagementId ?? 0);
      },
    );
  }
}
