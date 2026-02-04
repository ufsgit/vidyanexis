import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/balance_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class BalanceReportPage extends StatefulWidget {
  const BalanceReportPage({super.key});

  @override
  State<BalanceReportPage> createState() => _BalanceReportPageState();
}

class _BalanceReportPageState extends State<BalanceReportPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final balanceProvider =
          Provider.of<BalanceReportProvider>(context, listen: false);
      balanceProvider.getBalanceReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceReportProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    bool isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Balance Reports',
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
                balanceProvider.setSearch(query);
                balanceProvider.getBalanceReport(context);
              },
              onClearTap: () {
                searchController.clear();
                sideProvider.stopSearch();
                balanceProvider.setSearch('');
                balanceProvider.getBalanceReport(context);
              },
              searchController: searchController,
            ),
      body: Column(
        children: [
          if (isWeb) _buildWebHeader(balanceProvider),
          if (isWeb && balanceProvider.isFilter)
            _buildWebFilter(balanceProvider),
          Expanded(
            child: balanceProvider.balanceReportList.isEmpty
                ? const Center(child: Text('No data found'))
                : isWeb
                    ? _buildWebTable(balanceProvider)
                    : _buildMobileList(balanceProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BalanceReportProvider provider) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Balance Report',
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
                provider.getBalanceReport(context);
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
                    provider.getBalanceReport(context);
                  },
                  child: const Text('Search'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (!AppStyles.isWebScreen(context) == false)
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebFilter(BalanceReportProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Row(
                children: [
                  CustomText(
                    'Date: ${provider.formattedDate}',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black45,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              provider.getBalanceReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Apply'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              provider.setSearch('');
              searchController.clear();
              provider.setDate(DateTime.now());
              provider.getBalanceReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textRed,
              side: BorderSide(color: AppColors.textRed),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTable(BalanceReportProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceGrey),
          columns: [
            DataColumn(
                label:
                    CustomText('Customer Name', fontWeight: FontWeight.w600)),
            DataColumn(label: CustomText('Phone', fontWeight: FontWeight.w600)),
            DataColumn(
                label: CustomText('Address', fontWeight: FontWeight.w600)),
            DataColumn(
                label:
                    CustomText('Total Schedule', fontWeight: FontWeight.w600)),
            DataColumn(
                label:
                    CustomText('Total Receipt', fontWeight: FontWeight.w600)),
            DataColumn(
                label: CustomText('Balance', fontWeight: FontWeight.w600)),
          ],
          rows: provider.balanceReportList.map((item) {
            return DataRow(cells: [
              DataCell(CustomText(item.customerName)),
              DataCell(CustomText(item.phone)),
              DataCell(SizedBox(
                  width: 200, child: CustomText(item.address, softWrap: true))),
              DataCell(CustomText(
                  '₹ ${item.totalPaymentSchedule.toStringAsFixed(2)}')),
              DataCell(CustomText('₹ ${item.totalReceipt.toStringAsFixed(2)}')),
              DataCell(CustomText('₹ ${item.balance.toStringAsFixed(2)}',
                  color: AppColors.bluebutton, fontWeight: FontWeight.w600)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BalanceReportProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.balanceReportList.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = provider.balanceReportList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      item.customerName,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText(
                    '₹ ${item.balance.toStringAsFixed(2)}',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluebutton,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              CustomText(item.phone, fontSize: 12, color: AppColors.textGrey4),
              const SizedBox(height: 4),
              CustomText(item.address,
                  fontSize: 12, color: AppColors.textGrey4),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniInfo('Schedule', item.totalPaymentSchedule),
                  _buildMiniInfo('Receipt', item.totalReceipt),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniInfo(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, fontSize: 10, color: AppColors.textGrey4),
        CustomText('₹ ${amount.toStringAsFixed(2)}',
            fontSize: 12, fontWeight: FontWeight.w500),
      ],
    );
  }
}
