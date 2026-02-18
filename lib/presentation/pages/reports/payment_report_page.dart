import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
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
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PaymentReportProvider>(context, listen: false);
      provider.getPaymentReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentReportProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    bool isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildWebHeader(provider)),
          if (provider.isFilter)
            SliverToBoxAdapter(child: _buildWebFilter(provider)),
          SliverToBoxAdapter(child: _buildWebTableHeader()),
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.paymentReportList.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No data found')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = provider.paymentReportList[index];
                  return _buildWebTableRow(item, index);
                },
                childCount: provider.paymentReportList.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(PaymentReportProvider provider) {
    return Container(
      color: Colors.grey[50], // Match header bg
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Payment Report',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF152D70),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
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
                provider.setSearch(query);
                provider.getPaymentReport(context);
              },
              decoration: InputDecoration(
                hintText: 'Search here....',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    provider.setSearch(searchController.text);
                    provider.getPaymentReport(context);
                  },
                  child: const Text('Search'),
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
            label:
                Text(MediaQuery.of(context).size.width > 860 ? 'Filter' : ''),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  provider.isFilter ? Colors.white : AppColors.primaryBlue,
              backgroundColor:
                  provider.isFilter ? const Color(0xFF5499D9) : Colors.white,
              side: BorderSide(
                  color: provider.isFilter
                      ? const Color(0xFF5499D9)
                      : AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _exportData(provider),
            icon: const Icon(Icons.download),
            label: Text(MediaQuery.of(context).size.width > 860
                ? 'Export To Excel'
                : ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month'
  ];

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
                        onPressed: () {
                          Navigator.pop(context);
                          provider.formatDate();
                          // You might want to refresh data here or let the user click "Apply" on the main screen
                          // provider.getPaymentReport(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                          provider.selectDateFilterOption(null);
                          // provider.getPaymentReport(context);
                          // Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textRed,
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 1.5),
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
}
