import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/payment_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart'; // Ensure this exists or use local
import 'package:vidyanexis/utils/csv_function.dart'; // Ensure this exists

class PaymentReportPage extends StatefulWidget {
  const PaymentReportPage({super.key});

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController customerFilterController =
      TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PaymentReportProvider>(context, listen: false);
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      provider.getPaymentReport(context);

      // Initialize customer fetch
      customerProvider.setLimit();
      customerProvider.setSearchCriteria('', '', '', '0');
      // Ensure we fetch all or enough customers for the dropdown
      // For a dropdown, ideally we want ALL, but getSearchCustomers uses pagination.
      // We might need to handle this limits or fetch more.
      // For now, let's just fetch the default page.
      customerProvider.getSearchCustomers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentReportProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    bool isWeb = AppStyles.isWebScreen(context);

    // Sync controllers if needed, but here we just ensure if provider searchText is empty, clear controllers
    if (provider.searchText.isEmpty &&
        (searchController.text.isNotEmpty ||
            customerFilterController.text.isNotEmpty)) {
      searchController.clear();
      customerFilterController.clear();
    } else if (provider.searchText.isNotEmpty &&
        customerFilterController.text != provider.searchText) {
      // Optional: Keep them in sync if you want bidirectional update
      // customerFilterController.text = provider.searchText;
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
// ... existing app bar code
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Payment Reports',
              onSearchTap: () {
                sideProvider.startSearch();
              },
              leadingWidth: 40,
              leadingWidget: IconButton(
                onPressed: () {
                  sideProvider.stopSearch();
                  context.pop();
                },
                icon: Icon(Icons.arrow_back, color: AppColors.textGrey4),
              ),
              onSearch: (query) {
                provider.setSearch(query);
                provider.getPaymentReport(context);
              },
              onClearTap: () {
                searchController.clear();
                customerFilterController.clear();
                sideProvider.stopSearch();
                provider.setSearch('');
                provider.getPaymentReport(context);
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(provider),
            ),
      body: isWeb ? _buildWebBody(provider) : _buildMobileBody(provider),
    );
  }

  Widget _buildWebBody(PaymentReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Report',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  provider.toggleFilter();
                },
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.isFilter) ...[
          _buildWebFilter(provider),
          const SizedBox(height: 16),
        ],
        _buildWebTableHeader(),
        Expanded(
          child: provider.paymentReportList.isEmpty
              ? const Center(child: Text('No data found'))
              : ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: provider.paymentReportList.length,
                  itemBuilder: (context, index) {
                    final item = provider.paymentReportList[index];
                    return _buildWebTableRow(item, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWebFilter(PaymentReportProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onClickTopButton(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Row(
                children: [
                  if (provider.fromDate == null && provider.toDate == null)
                    const Text('Date: All'),
                  if (provider.fromDate != null && provider.toDate != null)
                    Text(
                      'Date: ${provider.formattedFromDate} - ${provider.formattedToDate}',
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black45,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Customer Name Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: provider.selectedCustomerId != null
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!),
            ),
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Customer Name: '),
                    DropdownButton<int?>(
                      value: customerProvider.customerData.any((element) =>
                              element.customerId == provider.selectedCustomerId)
                          ? provider.selectedCustomerId
                          : null,
                      hint: const Text('All'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: 0,
                          child: Text(
                            'All',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        ...customerProvider.customerData
                            .map((customer) => DropdownMenuItem<int?>(
                                  value: customer.customerId,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      customer.customerName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ],
                      onChanged: (int? newValue) {
                        if (newValue == 0 || newValue == null) {
                          provider.setCustomer(null, '');
                          provider.setSearch('');
                        } else {
                          final selectedCustomer = customerProvider.customerData
                              .firstWhere((c) => c.customerId == newValue);
                          provider.setCustomer(
                              newValue, selectedCustomer.customerName);
                          provider.setSearch(selectedCustomer.customerName);
                        }
                        // Optionally trigger search immediately
                        // provider.getPaymentReport(context);
                      },
                      underline: Container(),
                      isDense: true,
                      iconSize: 18,
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => provider.getPaymentReport(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: const Text('Apply'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              provider.setSearch('');
              searchController.clear();
              customerFilterController.clear();
              provider.selectDateFilterOption(null);
              provider.getPaymentReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textRed,
              side: BorderSide(color: AppColors.textRed),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: const Text('Reset'),
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 70,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Text('No',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF607185))),
                ),
              ),
              TableWidget(title: 'Date', width: 120, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Customer Name', flex: 2, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Payment Mode', width: 150, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Amount', width: 150, color: Color(0xFF607185)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebTableRow(dynamic item, int index) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Text((index + 1).toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TableWidget(data: Text(item.paymentDate), width: 120),
              TableWidget(
                  data: Text(item.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  flex: 2),
              TableWidget(data: Text(item.paymentModeName), width: 150),
              TableWidget(
                  data: Text('₹ ${item.payingAmount.toStringAsFixed(2)}'),
                  width: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBody(PaymentReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.paymentReportList.isEmpty) {
      return const Center(child: Text('No data found'));
    }
    return Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => onClickTopButton(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (provider.fromDate == null && provider.toDate == null)
                        const Text('Date: All'),
                      if (provider.fromDate != null && provider.toDate != null)
                        Text(
                          'Date: ${provider.formattedFromDate} - ${provider.formattedToDate}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.paymentReportList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = provider.paymentReportList[index];
                  return _buildMobileCard(item);
                },
              ),
            ),
          ],
        ));
  }

  Widget _buildMobileCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  '₹ ${item.payingAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.paymentDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textGrey3,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.paymentModeName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(PaymentReportProvider provider) {
    exportToExcel(
      headers: [
        'Date',
        'Customer Name',
        'Payment Mode',
        'Amount',
      ],
      data: provider.paymentReportList.map((item) {
        return {
          'Date': item.paymentDate,
          'Customer Name': item.customerName,
          'Payment Mode': item.paymentModeName,
          'Amount': '₹ ${item.payingAmount.toStringAsFixed(2)}',
        };
      }).toList(),
      fileName: 'Payment_Report',
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<PaymentReportProvider>(
        builder: (context, provider, child) {
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
                            provider.setDateFilter(title);
                            provider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
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
                            onTap: () => provider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
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
                                borderRadius: BorderRadius.circular(15),
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
                        onPressed: () async {
                          await provider.getPaymentReport(context);
                          Navigator.pop(context);
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
