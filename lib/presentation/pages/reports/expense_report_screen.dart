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

class ExpenseReportScreen extends StatefulWidget {
  static const String route = "/expense_report";
  const ExpenseReportScreen({Key? key}) : super(key: key);

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
      backgroundColor:
          Colors.grey[50], // Slightly grey background for better contrast
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, provider),
              const SizedBox(height: 16),
              _buildFilters(context, provider, isSmallScreen),
              const SizedBox(height: 16),
              _buildSummaryCard(provider, isSmallScreen),
              const SizedBox(height: 16),
              Expanded(
                child: _buildExpenseTable(provider, isSmallScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider provider) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isWeb = AppStyles.isWebScreen(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (!isWeb)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back,
                              size: 20, color: AppColors.textBlue800),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      'Expense Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlue800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!isSmallScreen) _buildExportButton(provider),
          ],
        ),
        if (isSmallScreen)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SizedBox(
                width: double.infinity, child: _buildExportButton(provider)),
          ),
      ],
    );
  }

  Widget _buildExportButton(ExpenseProvider provider) {
    return ElevatedButton.icon(
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
      icon: const Icon(Icons.download, size: 18),
      label: const Text('Export to Excel'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context, ExpenseProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date Filter
              SizedBox(
                width: isSmallScreen ? double.infinity : 300,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterWrapper(
                        onTap: () => provider.selectDate(context, true),
                        label: provider.formattedFromDate.isEmpty
                            ? 'From Date'
                            : provider.formattedFromDate,
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterWrapper(
                        onTap: () => provider.selectDate(context, false),
                        label: provider.formattedToDate.isEmpty
                            ? 'To Date'
                            : provider.formattedToDate,
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ),

              _buildAssignedToFilter(provider, isSmallScreen),
              _buildProjectTypeFilter(provider, isSmallScreen),
              _buildExpenseTypeFilter(provider, isSmallScreen),

              // Action Buttons
              if (isSmallScreen)
                const SizedBox(width: double.infinity, height: 4),

              SizedBox(
                width: isSmallScreen ? double.infinity : null,
                child: ElevatedButton(
                  onPressed: () => provider.getExpenseReport(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Filter'),
                ),
              ),

              SizedBox(
                width: isSmallScreen ? double.infinity : null,
                child: OutlinedButton(
                  onPressed: () {
                    provider.setFromDate(DateTime.now());
                    provider.setToDate(DateTime.now());
                    provider.clearUserFilter();
                    provider.clearClientFilter();
                    provider.clearProjectTypeFilter();
                    provider.clearExpenseTypeFilter();
                    provider.getExpenseReport(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textGrey3,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterWrapper(
      {required VoidCallback onTap,
      required String label,
      required IconData icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textGrey3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
          width: isSmallScreen ? double.infinity : 200,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: expenseProvider.selectedUser == 0
                  ? null
                  : expenseProvider.selectedUser,
              hint: Text('Assigned To',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textGrey3)),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isExpanded: true,
              items: settingsProvider.searchUserDetails
                  .map((user) => DropdownMenuItem<int>(
                        value: user.userDetailsId,
                        child: Text(user.userDetailsName ?? '',
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
          width: isSmallScreen ? double.infinity : 200,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: expenseProvider.selectedProjectTypeId == 0
                  ? null
                  : expenseProvider.selectedProjectTypeId,
              hint: Text('Project Type',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textGrey3)),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isExpanded: true,
              items: settingsProvider.projectTypeList
                  .map((item) => DropdownMenuItem<int>(
                        value: item.projectTypeId,
                        child: Text(item.projectTypeName ?? '',
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
      width: isSmallScreen ? double.infinity : 200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: expenseProvider.selectedExpenseTypeId == 0
              ? null
              : expenseProvider.selectedExpenseTypeId,
          hint: Text('Expense Type',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textGrey3)),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          isExpanded: true,
          items: expenseProvider.expenseTypeList
              .map((item) => DropdownMenuItem<int>(
                    value: item.expenseTypeId,
                    child: Text(item.expenseTypeName ?? '',
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isSmallScreen
          ? Column(
              children: [
                _buildSummaryItem(
                    'Received Amount', provider.correlationbox.receivedAmount),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildSummaryItem('Total Expense Amount',
                    provider.correlationbox.totalExpenseAmount),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildSummaryItem(
                    'Total Balance', provider.correlationbox.totalBalance),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                    'Received Amount', provider.correlationbox.receivedAmount,
                    expand: true),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem('Total Expense Amount',
                    provider.correlationbox.totalExpenseAmount,
                    expand: true),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem(
                    'Total Balance', provider.correlationbox.totalBalance,
                    expand: true),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, double? amount,
      {bool expand = false}) {
    final widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹ ${amount?.toStringAsFixed(2) ?? "0.00"}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
    return expand
        ? Expanded(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: widget,
          ))
        : SizedBox(width: double.infinity, child: widget);
  }

  Widget _buildExpenseTable(ExpenseProvider provider, bool isSmallScreen) {
    if (provider.expenseModelList.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No records found',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ));
    }

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: provider.expenseModelList.length,
        padding: const EdgeInsets.only(bottom: 24),
        itemBuilder: (context, index) {
          final item = provider.expenseModelList[index];
          return _buildExpenseCard(context, provider, item, index);
        },
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              horizontalMargin: 24,
              columnSpacing: 24,
              columns: [
                DataColumn(
                    label: Text('Sl No',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('User Name',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Entry Date',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Expense Head',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Category',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Project Name',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Amount',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                DataColumn(
                    label: Text('Action',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 13))),
              ],
              rows: List.generate(provider.expenseModelList.length, (index) {
                final item = provider.expenseModelList[index];
                return DataRow(cells: [
                  DataCell(Text('${index + 1}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(item.userName ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(item.entryDate ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(item.expenseHead ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(item.expenseTypeName ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(item.projectName ?? '-',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  DataCell(Text(
                      '₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue))),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () {
                      provider.deleteExpense(
                          context, item.expenseManagementId ?? 0);
                    },
                  )),
                ]);
              }),
            ),
          ),
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
                  onPressed: () => provider.deleteExpense(
                      context, item.expenseManagementId ?? 0),
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
