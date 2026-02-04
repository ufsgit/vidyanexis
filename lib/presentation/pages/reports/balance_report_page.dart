import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/balance_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class BalanceReportPage extends StatefulWidget {
  const BalanceReportPage({super.key});

  @override
  State<BalanceReportPage> createState() => _BalanceReportPageState();
}

class _BalanceReportPageState extends State<BalanceReportPage> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
              showExcel: true,
              onExcelTap: () => _exportData(balanceProvider),
            ),
      body: isWeb
          ? _buildWebBody(balanceProvider)
          : _buildMobileBody(balanceProvider),
    );
  }

  Widget _buildWebBody(BalanceReportProvider provider) {
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
          if (provider.balanceReportList.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No data found')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = provider.balanceReportList[index];
                  return _buildWebTableRow(item, index);
                },
                childCount: provider.balanceReportList.length,
              ),
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

  Widget _buildWebFilter(BalanceReportProvider provider) {
    return Container(
      color: Colors.grey[50], // Match header bg
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => provider.selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBlue),
                ),
                child: Row(
                  children: [
                    Text(
                      'Date: ${provider.formattedDate}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => provider.getBalanceReport(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
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
              TableWidget(
                  title: 'Customer Name', flex: 2, color: Color(0xFF607185)),
              TableWidget(title: 'Phone', width: 130, color: Color(0xFF607185)),
              TableWidget(title: 'Address', flex: 3, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Total Schedule',
                  width: 150,
                  color: Color(0xFF607185)),
              TableWidget(
                  title: 'Total Receipt', width: 150, color: Color(0xFF607185)),
              TableWidget(
                  title: 'Balance', width: 130, color: Color(0xFF607185)),
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
              TableWidget(
                  data: Text(item.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  flex: 2),
              TableWidget(data: Text(item.phone), width: 130),
              TableWidget(
                  data: Text(item.address,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  flex: 3),
              TableWidget(
                  data:
                      Text('₹ ${item.totalPaymentSchedule.toStringAsFixed(2)}'),
                  width: 150),
              TableWidget(
                  data: Text('₹ ${item.totalReceipt.toStringAsFixed(2)}'),
                  width: 150),
              TableWidget(
                data: Text(
                  '₹ ${item.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.balance > 0
                        ? AppColors.textRed
                        : AppColors.primaryBlue,
                  ),
                ),
                width: 130,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBody(BalanceReportProvider provider) {
    if (provider.balanceReportList.isEmpty) {
      return const Center(child: Text('No data found'));
    }
    return Container(
      color: Colors.grey[50],
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.balanceReportList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = provider.balanceReportList[index];
          return _buildMobileCard(item);
        },
      ),
    );
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: item.balance > 0
                    ? AppColors.textRed
                    : AppColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
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
                          '₹ ${item.balance.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.balance > 0
                                ? AppColors.textRed
                                : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.textGrey3),
                        const SizedBox(width: 4),
                        Text(
                          item.phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ],
                    ),
                    if (item.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textGrey3),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textGrey3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      children: [
                        _buildMobileStat('Schedule', item.totalPaymentSchedule),
                        const SizedBox(width: 24),
                        _buildMobileStat('Receipt', item.totalReceipt),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStat(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textGrey3,
          ),
        ),
        Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }

  void _exportData(BalanceReportProvider provider) {
    exportToExcel(
      headers: [
        'Customer Name',
        'Phone',
        'Address',
        'Total Schedule',
        'Total Receipt',
        'Balance',
      ],
      data: provider.balanceReportList.map((item) {
        return {
          'Customer Name': item.customerName,
          'Phone': item.phone,
          'Address': item.address,
          'Total Schedule': '₹ ${item.totalPaymentSchedule.toStringAsFixed(2)}',
          'Total Receipt': '₹ ${item.totalReceipt.toStringAsFixed(2)}',
          'Balance': '₹ ${item.balance.toStringAsFixed(2)}',
        };
      }).toList(),
      fileName: 'Balance_Report',
    );
  }
}
