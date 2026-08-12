import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';


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
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Expense Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onFilterTap: () => provider.toggleFilter(),
              showExcel: true,
              onExcelTap: () => _handleExport(provider),
              showSearch: true,
              onSearch: (query) => provider.searchExpense(query, context),
              searchController: provider.searchExpenseController,
            ),
      body: isWeb
          ? _buildWebBody(context, provider, settingsProvider)
          : _buildMobileBody(context, provider, settingsProvider),
    );
  }

  Widget _buildWebBody(BuildContext context, ExpenseProvider provider,
      SettingsProvider settingsProvider) {
    return Column(
      children: [
        // Web Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
                'Expense Report',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const Spacer(),
              // Search Bar
              Container(
                width: 280,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: provider.searchExpenseController,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (query) => provider.searchExpense(query, context),
                  decoration: InputDecoration(
                    hintText: 'Search here....',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    suffixIcon: const Icon(Icons.search,
                        color: Color(0xFF64748B), size: 18),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CustomFilterButton(
                onPressed: () => provider.toggleFilter(),
                isFilter: provider.isFilter,
              ),
              const SizedBox(width: 16),
              CommonReportExportButton(
                      onPressed: () => _handleExport(provider),
                      label: 'Export',
                    ),
              const SizedBox(width: 16),
            ],
          ),
        ),

        // Web Filter Panel
        if (provider.isFilter) ...[
          _buildWebFilter(provider, settingsProvider),
          const SizedBox(height: 16),
        ],

        // Main Content (Summary Cards & Table)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCardsRow(provider),
                const SizedBox(height: 24),
                _buildWebTable(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context, ExpenseProvider provider,
      SettingsProvider settingsProvider) {
    return Column(
      children: [
        if (provider.isFilter)
          _buildFilterPanel(context, provider, settingsProvider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileSummaryCard(provider),
                const SizedBox(height: 24),
                _buildExpenseList(provider, true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebFilter(
      ExpenseProvider provider, SettingsProvider settingsProvider) {
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
          CommonReportDateFilter(
            fromDate: provider.fromDate?.toString(),
            toDate: provider.toDate?.toString(),
            formattedFromDate: provider.formattedFromDate,
            formattedToDate: provider.formattedToDate,
            onTap: () => _showDateDialog(context, provider),
          ),
          const SizedBox(width: 16),
          // User dropdown
          Container(
            height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'User: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                DropdownButton<int?>(
                  value: settingsProvider.searchUserDetails.any((element) =>
                          element.userDetailsId == provider.selectedUser)
                      ? provider.selectedUser
                      : null,
                  hint: const Text('All'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('All', style: TextStyle(fontSize: 14)),
                    ),
                    ...settingsProvider.searchUserDetails
                        .map((user) => DropdownMenuItem<int?>(
                              value: user.userDetailsId,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  user.userDetailsName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )),
                  ],
                  onChanged: (int? newValue) {
                    provider.setUserFilter(newValue ?? 0);
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Expense Type dropdown
          Container(
            height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: provider.selectedExpenseTypeId != null &&
                        provider.selectedExpenseTypeId != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Type: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                DropdownButton<int?>(
                  value: provider.expenseTypeList.any((element) =>
                          element.expenseTypeId ==
                          provider.selectedExpenseTypeId)
                      ? provider.selectedExpenseTypeId
                      : null,
                  hint: const Text('All'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('All', style: TextStyle(fontSize: 14)),
                    ),
                    ...provider.expenseTypeList
                        .map((type) => DropdownMenuItem<int?>(
                              value: type.expenseTypeId,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  type.expenseTypeName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )),
                  ],
                  onChanged: (int? newValue) {
                    provider.setSelectedExpenseTypeId(newValue ?? 0);
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              provider.getExpenseReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          CommonReportResetButton(
            onReset: () {
              provider.setFromDate(DateTime.now());
              provider.setToDate(DateTime.now());
              provider.clearUserFilter();
              provider.clearExpenseTypeFilter();
              provider.clearProjectTypeFilter();
              provider.getExpenseReport(context);
            },
            label: 'Reset',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardsRow(ExpenseProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleSummaryCard(
            'Received Amount',
            provider.correlationbox.receivedAmount,
            const Color(0xFFEFF6FF),
            const Color(0xFF1E40AF),
            Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSingleSummaryCard(
            'Total Expense Amount',
            provider.correlationbox.totalExpenseAmount,
            const Color(0xFFFEF2F2),
            const Color(0xFF991B1B),
            Icons.payment_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSingleSummaryCard(
            'Total Balance',
            provider.correlationbox.totalBalance,
            const Color(0xFFECFDF5),
            const Color(0xFF065F46),
            Icons.account_balance_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSummaryCard(ExpenseProvider provider) {
    return Column(
      children: [
        _buildSingleSummaryCard(
          'Received Amount',
          provider.correlationbox.receivedAmount,
          const Color(0xFFEFF6FF),
          const Color(0xFF1E40AF),
          Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _buildSingleSummaryCard(
          'Total Expense Amount',
          provider.correlationbox.totalExpenseAmount,
          const Color(0xFFFEF2F2),
          const Color(0xFF991B1B),
          Icons.payment_outlined,
        ),
        const SizedBox(height: 12),
        _buildSingleSummaryCard(
          'Total Balance',
          provider.correlationbox.totalBalance,
          const Color(0xFFECFDF5),
          const Color(0xFF065F46),
          Icons.account_balance_outlined,
        ),
      ],
    );
  }

  Widget _buildSingleSummaryCard(String label, double? amount, Color bgColor,
      Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor.withOpacity(0.7),
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹ ${amount?.toStringAsFixed(2) ?? "0.00"}',
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTable(ExpenseProvider provider) {
    if (provider.expenseModelList.isEmpty) {
      return const CommonEmptyState(
        message: 'No expenses found',
        icon: Icons.receipt_long_outlined,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWebTableHeader(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.expenseModelList.length,
            itemBuilder: (context, index) {
              final item = provider.expenseModelList[index];
              return _buildWebTableRow(item, index, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showAttachmentViewer(BuildContext context, String url) {
    bool isPdf = url.toLowerCase().endsWith('.pdf');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expense Attachment',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Center(
                    child: isPdf
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Open PDF Document'),
                              ),
                            ],
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image,
                                      size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text('Unable to load receipt image'),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    child: const Text('Open Link'),
                                  )
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFF2F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: const Row(
        children: [
          TableWidget(title: 'No', width: 60, color: Color(0xFF607185)),
          TableWidget(title: 'User / Lead', flex: 2, color: Color(0xFF607185)),
          TableWidget(
              title: 'Entry Date', width: 130, color: Color(0xFF607185)),
          TableWidget(title: 'Expense Head / Description', flex: 3, color: Color(0xFF607185)),
          TableWidget(title: 'Category', flex: 2, color: Color(0xFF607185)),
          TableWidget(title: 'Amount', width: 120, color: Color(0xFF607185)),
          TableWidget(title: 'Receipt', width: 110, color: Color(0xFF607185), alignment: Alignment.center),
          TableWidget(
              title: 'Actions',
              width: 90,
              color: Color(0xFF607185),
              alignment: Alignment.center),
        ],
      ),
    );
  }

  Widget _buildWebTableRow(
      ExpenseModel item, int index, ExpenseProvider provider) {
    bool hasAttachment = item.filePath != null && item.filePath!.isNotEmpty;
    String displayUser = (item.userName != null && item.userName!.isNotEmpty)
        ? item.userName!
        : (item.entryByName ?? (item.customerName ?? '-'));

    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          TableWidget(
            data: Text(
              (index + 1).toString(),
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            width: 60,
          ),
          TableWidget(
            data: Text(
              displayUser,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
            ),
            flex: 2,
          ),
          TableWidget(
            data: Text(
              item.entryDate ?? '-',
              style: GoogleFonts.plusJakartaSans(),
            ),
            width: 130,
          ),
          TableWidget(
            data: Text(
              (item.description != null && item.description!.isNotEmpty)
                  ? item.description!
                  : (item.expenseHead ?? '-'),
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            flex: 3,
          ),
          TableWidget(
            data: Text(
              item.expenseTypeName ?? 'Uncategorized',
              style: GoogleFonts.plusJakartaSans(),
            ),
            flex: 2,
          ),
          TableWidget(
            data: Text(
              '₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            width: 120,
          ),
          TableWidget(
            data: hasAttachment
                ? IconButton(
                    icon: const Icon(Icons.receipt_long,
                        color: AppColors.secondaryBlue, size: 20),
                    tooltip: 'View Receipt',
                    onPressed: () =>
                        _showAttachmentViewer(context, item.filePath!),
                  )
                : const Text('-', style: TextStyle(color: Colors.grey)),
            width: 110,
            alignment: Alignment.center,
          ),
          TableWidget(
            data: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textRed, size: 20),
              onPressed: () => _confirmDelete(context, provider, item),
            ),
            width: 90,
            alignment: Alignment.center,
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
                      label: user.userDetailsName,
                      isSelected: provider.selectedUser == user.userDetailsId,
                      onTap: () => provider.setUserFilter(user.userDetailsId),
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
                      label: type.expenseTypeName,
                      isSelected:
                          provider.selectedExpenseTypeId == type.expenseTypeId,
                      onTap: () =>
                          provider.setSelectedExpenseTypeId(type.expenseTypeId),
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
                          borderRadius: BorderRadius.circular(4)),
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

  final List<String> _dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  void _showDateDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<ExpenseProvider>(
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
                    Center(
                      child: Text(
                        'Choose Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(_dateButtonTitles.length,
                          (index) {
                        final String title = _dateButtonTitles[index];
                        final bool isSelected =
                            reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.selectDateFilterOption(index);
                            reportsProvider.setDateFilter(title);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pick a custom date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(contextx, true),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(contextx, false),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          if (reportsProvider.fromDate != null &&
                              reportsProvider.toDate != null &&
                              reportsProvider.fromDate!
                                  .isAfter(reportsProvider.toDate!)) {
                            ScaffoldMessenger.of(contextx).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'From Date cannot be after To Date')),
                            );
                            return;
                          }
                          Navigator.pop(contextx);
                          reportsProvider.getExpenseReport(contextx);
                        },

                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(contextx);
                          reportsProvider.setFromDate(DateTime.now());
                          reportsProvider.setToDate(DateTime.now());
                          reportsProvider.clearUserFilter();
                          reportsProvider.clearExpenseTypeFilter();
                          reportsProvider.clearProjectTypeFilter();
                          reportsProvider.getExpenseReport(contextx);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.08),
                          foregroundColor: AppColors.textRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Clear Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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

  Widget _buildExpenseList(ExpenseProvider provider, bool isSmallScreen) {
    if (provider.expenseModelList.isEmpty) {
      return const CommonEmptyState(
        message: 'No expenses found',
        icon: Icons.receipt_long_outlined,
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
        await provider.deleteExpense(context, item.expenseManagementId ?? 0);
        provider.getExpenseReport(context);
      },
    );
  }
}
