import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

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

      // Initialize filters
      settingsProvider.getUserDetails('', context);
      provider.getExpenseType(context);
      settingsProvider.searchProjectTypes('', context);

      // Initial fetch
      provider.getExpenseReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Text(
                  'Expense Report',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF152D70),
                  ),
                ),
                const SizedBox(width: 32),
                const Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: provider.searchExpenseController,
                    textAlignVertical: TextAlignVertical.center,
                    onSubmitted: (query) {
                      provider.searchExpense(query, context);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search here....',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (provider.searchExpenseController.text.isNotEmpty) {
                              provider.searchExpenseController.clear();
                              provider.searchExpense('', context);
                            } else {
                              String query =
                                  provider.searchExpenseController.text;
                              provider.searchExpense(query, context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            provider.searchExpenseController.text.isNotEmpty
                                ? 'Cancel'
                                : 'Search',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    provider.toggleFilter();
                  },
                  icon: const Icon(Icons.filter_list),
                  label: Text(MediaQuery.of(context).size.width > 860
                      ? 'Filter'
                      : ''),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: provider.isFilter
                        ? Colors.white
                        : AppColors.textBlue800,
                    backgroundColor: provider.isFilter
                        ? const Color(0xFF5499D9)
                        : Colors.white,
                    side: BorderSide(
                        color: provider.isFilter
                            ? const Color(0xFF5499D9)
                            : AppColors.textBlue800),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildExportButton(provider),
              ],
            ),
          ),
          if (provider.isFilter) _buildFilters(context, provider, isSmallScreen),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(provider, isSmallScreen),
                  const SizedBox(height: 16),
                  _buildExpenseTable(provider, isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(ExpenseProvider provider) {
    return CustomElevatedButton(
      onPressed: () async {
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
      },
      buttonText: 'Export to Excel',
      prefixIcon: Icons.download,
      backgroundColor: AppColors.primaryBlue,
      borderColor: AppColors.primaryBlue,
      textColor: Colors.white,
      radius: 30, // Updated to match other report buttons
      textSize: 13,
    );
  }

  Widget _buildFilters(
      BuildContext context, ExpenseProvider provider, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Date Filter
            _buildFilterWrapper(
              onTap: () => provider.selectDate(context, true),
              label: provider.formattedFromDate.isEmpty
                  ? 'From Date'
                  : provider.formattedFromDate,
              icon: Icons.calendar_today,
            ),
            const SizedBox(width: 10),
            _buildFilterWrapper(
              onTap: () => provider.selectDate(context, false),
              label: provider.formattedToDate.isEmpty
                  ? 'To Date'
                  : provider.formattedToDate,
              icon: Icons.calendar_today,
            ),
            const SizedBox(width: 10),
            _buildAssignedToFilter(provider, isSmallScreen),
            const SizedBox(width: 10),
            _buildProjectTypeFilter(provider, isSmallScreen),
            const SizedBox(width: 10),
            _buildExpenseTypeFilter(provider, isSmallScreen),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => provider.getExpenseReport(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Apply'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                provider.setFromDate(DateTime.now());
                provider.setToDate(DateTime.now());
                provider.clearUserFilter();
                provider.clearClientFilter();
                provider.clearProjectTypeFilter();
                provider.clearExpenseTypeFilter();
                provider.getExpenseReport(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: const BorderSide(color: AppColors.textRed),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterWrapper(
      {required VoidCallback onTap,
      required String label,
      required IconData icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textGrey3),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedToFilter(
      ExpenseProvider expenseProvider, bool isSmallScreen) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: expenseProvider.selectedUser == 0
                  ? null
                  : expenseProvider.selectedUser,
              hint: Text('Assigned To',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textBlack)),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isExpanded: true,
              items: settingsProvider.searchUserDetails
                  .map((user) => DropdownMenuItem<int>(
                        value: user.userDetailsId,
                        child: Text(user.userDetailsName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) expenseProvider.setUserFilter(val);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectTypeFilter(
      ExpenseProvider expenseProvider, bool isSmallScreen) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: expenseProvider.selectedProjectTypeId == 0
                  ? null
                  : expenseProvider.selectedProjectTypeId,
              hint: Text('Project Type',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textBlack)),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isExpanded: true,
              items: settingsProvider.projectTypeList
                  .map((item) => DropdownMenuItem<int>(
                        value: item.projectTypeId,
                        child: Text(item.projectTypeName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) expenseProvider.setProjectTypeFilter(val);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseTypeFilter(
      ExpenseProvider expenseProvider, bool isSmallScreen) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: expenseProvider.selectedExpenseTypeId == 0
              ? null
              : expenseProvider.selectedExpenseTypeId,
          hint: Text('Expense Type',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textBlack)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isExpanded: true,
          items: expenseProvider.expenseTypeList
              .map((item) => DropdownMenuItem<int>(
                    value: item.expenseTypeId,
                    child: Text(item.expenseTypeName ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) expenseProvider.setSelectedExpenseTypeId(val);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isSmallScreen
          ? Column(
              children: [
                _buildSummaryItem(
                    'Received Amount', provider.correlationbox.receivedAmount, isSmallScreen),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildSummaryItem('Total Expense Amount',
                    provider.correlationbox.totalExpenseAmount, isSmallScreen),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildSummaryItem(
                    'Total Balance', provider.correlationbox.totalBalance, isSmallScreen),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                    'Received Amount', provider.correlationbox.receivedAmount, isSmallScreen,
                    expand: true),
                Container(width: 1, height: 60, color: Colors.white30),
                _buildSummaryItem('Total Expense Amount',
                    provider.correlationbox.totalExpenseAmount, isSmallScreen,
                    expand: true),
                Container(width: 1, height: 60, color: Colors.white30),
                _buildSummaryItem(
                    'Total Balance', provider.correlationbox.totalBalance, isSmallScreen,
                    expand: true),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, double? amount, bool isSmallScreen,
      {bool expand = false}) {
    final content = Column(
      crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.95),
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '₹ ${amount?.toStringAsFixed(2) ?? "0.00"}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
    return expand
        ? Expanded(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: content,
          ))
        : SizedBox(width: double.infinity, child: content);
  }

  Widget _buildExpenseTable(ExpenseProvider provider, bool isSmallScreen) {
    if (provider.expenseModelList.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text('No records found',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600)),
        ],
      ));
    }

    if (isSmallScreen) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.expenseModelList.length,
        padding: const EdgeInsets.only(bottom: 24),
        itemBuilder: (context, index) {
          final item = provider.expenseModelList[index];
          return _buildExpenseCard(context, provider, item, index);
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width < 1500
                ? 1500
                : MediaQuery.of(context).size.width - 64,
            child: Column(
              children: [
                // Header Row
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildTableHeaderCell('Sl No', width: 60),
                      _buildTableHeaderCell('User Name', width: 160),
                      _buildTableHeaderCell('Entry Date', width: 130),
                      _buildTableHeaderCell('Expense Head', width: 220),
                      _buildTableHeaderCell('Category', width: 180),
                      _buildTableHeaderCell('Project Name', width: 220),
                      _buildTableHeaderCell('Amount', width: 140),
                      _buildTableHeaderCell('Action', width: 100),
                    ],
                  ),
                ),
                // Data Rows
                ...List.generate(
                  provider.expenseModelList.length,
                  (index) {
                    final item = provider.expenseModelList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : const Color(0xFFF6F7F9),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildTableDataCell('${index + 1}', width: 60),
                          _buildTableDataCell(item.userName ?? '-', width: 160, isBlue: true),
                          _buildTableDataCell(item.entryDate ?? '-',
                              width: 130),
                          _buildTableDataCell(item.expenseHead ?? '-',
                              width: 220, isBold: true),
                          _buildTableDataCell(item.expenseTypeName ?? '-',
                              width: 180),
                          _buildTableDataCell(item.projectName ?? '-',
                              width: 220),
                          SizedBox(
                            width: 140,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textBlue800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.textRed, size: 22),
                                onPressed: () {
                                  showConfirmationDialog(
                                    context: context,
                                    title: 'Delete Expense',
                                    content:
                                        'Are you sure you want to delete this expense?',
                                    onCancel: () => Navigator.of(context).pop(),
                                    onConfirm: () async {
                                      Navigator.of(context).pop();
                                      provider.deleteExpense(context,
                                          item.expenseManagementId ?? 0);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String label, {double? width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF607185),
          ),
        ),
      ),
    );
  }

  Widget _buildTableDataCell(String text, {double? width, bool isBlue = false, bool isBold = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBlue ? Colors.blue : AppColors.textBlack,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseProvider provider,
      ExpenseModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => showConfirmationDialog(
                    context: context,
                    title: 'Delete Expense',
                    content: 'Are you sure you want to delete this expense?',
                    onCancel: () => Navigator.of(context).pop(),
                    onConfirm: () async {
                      Navigator.of(context).pop();
                      provider.deleteExpense(
                          context, item.expenseManagementId ?? 0);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.expenseHead ?? "No Title",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textBlue800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.expenseTypeName ?? "Uncategorized",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textGrey3,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildCardRow(Icons.person_outline, 'User', item.userName),
            const SizedBox(height: 8),
            _buildCardRow(
                Icons.calendar_today_outlined, 'Date', item.entryDate),
            const SizedBox(height: 8),
            _buildCardRow(Icons.work_outline, 'Project', item.projectName),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textGrey4),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textGrey4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value ?? "-",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
