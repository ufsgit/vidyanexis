import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
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
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, provider),
            const SizedBox(height: 16),
            _buildFilters(context, provider, isSmallScreen),
            const SizedBox(height: 16),
            _buildSummaryCard(provider),
            const SizedBox(height: 16),
            Expanded(
              child: _buildExpenseTable(provider, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Expense Report',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlue800,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            List<String> headers = [
              "Sl No",
              "Reference ID",
              "Entry Date",
              "Expense Head",
              "Category",
              "Project Type",
              "Amount"
            ];

            List<Map<String, dynamic>> data = [];

            for (int i = 0; i < provider.expenseModelList.length; i++) {
              var item = provider.expenseModelList[i];
              data.add({
                "Sl No": (i + 1).toString(),
                "Reference ID": item.userName ?? "",
                "Entry Date": item.entryDate ?? "",
                "Expense Head": item.expenseTypeName ?? "",
                "Category": item.projectName ?? "",
                "Project Type": item.projectTypeName ?? "",
                "Amount": item.amount.toString()
              });
            }

            await exportToExcel(
                headers: headers,
                data: data,
                fileName:
                    'Expense_Report_${DateFormat('dd-MM-yyyy').format(DateTime.now())}');
          },
          icon: const Icon(Icons.download),
          label: const Text('Export to Excel'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(
      BuildContext context, ExpenseProvider provider, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date Filter
              SizedBox(
                width: isSmallScreen ? double.infinity : 300,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.formattedFromDate.isEmpty
                                ? 'From Date'
                                : provider.formattedFromDate,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.formattedToDate.isEmpty
                                ? 'To Date'
                                : provider.formattedToDate,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildAssignedToFilter(provider),
              // _buildClientFilter(provider), // Commented out as list population is unclear
              _buildProjectTypeFilter(provider),
              _buildExpenseTypeFilter(provider),

              // Action Buttons
              ElevatedButton(
                onPressed: () => provider.getExpenseReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Filter'),
              ),
              OutlinedButton(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedToFilter(ExpenseProvider expenseProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: expenseProvider.selectedUser == 0
                ? null
                : expenseProvider.selectedUser,
            hint: const Text('Assigned To'),
            underline: const SizedBox(),
            items: settingsProvider.searchUserDetails
                .map((user) => DropdownMenuItem<int>(
                      value: user.userDetailsId,
                      child: Text(user.userDetailsName ?? ''),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) expenseProvider.setUserFilter(val);
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectTypeFilter(ExpenseProvider expenseProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: expenseProvider.selectedProjectTypeId == 0
                ? null
                : expenseProvider.selectedProjectTypeId,
            hint: const Text('Project Type'),
            underline: const SizedBox(),
            items: settingsProvider.projectTypeList
                .map((item) => DropdownMenuItem<int>(
                      value: item.projectTypeId,
                      child: Text(item.projectTypeName ?? ''),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) expenseProvider.setProjectTypeFilter(val);
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseTypeFilter(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: expenseProvider.selectedExpenseTypeId == 0
            ? null
            : expenseProvider.selectedExpenseTypeId,
        hint: const Text('Expense Type'),
        underline: const SizedBox(),
        items: expenseProvider.expenseTypeList
            .map((item) => DropdownMenuItem<int>(
                  value: item.expenseTypeId,
                  child: Text(item.expenseTypeName ?? ''),
                ))
            .toList(),
        onChanged: (val) {
          if (val != null) expenseProvider.setSelectedExpenseTypeId(val);
        },
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Received Amount',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${provider.correlationbox.receivedAmount?.toStringAsFixed(2) ?? "0.00"}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expense Amount',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${provider.correlationbox.totalExpenseAmount?.toStringAsFixed(2) ?? "0.00"}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${provider.correlationbox.totalBalance?.toStringAsFixed(2) ?? "0.00"}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTable(ExpenseProvider provider, bool isSmallScreen) {
    if (provider.expenseModelList.isEmpty) {
      return Center(
          child:
              Text('No records found', style: GoogleFonts.plusJakartaSans()));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              columns: [
                DataColumn(
                    label: Text('Sl No',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Reference ID',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Entry Date',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Expense Head',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Category',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Project Type',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Amount',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(provider.expenseModelList.length, (index) {
                final item = provider.expenseModelList[index];
                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(item.userName ?? '-')),
                  DataCell(Text(item.entryDate ?? '-')),
                  DataCell(Text(item.expenseTypeName ?? '-')),
                  DataCell(Text(item.projectName ?? '-')),
                  DataCell(Text(item.projectTypeName ?? '-')),
                  DataCell(
                      Text('₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
}
