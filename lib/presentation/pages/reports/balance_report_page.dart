import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/balance_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

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
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Balance Reports',
              onSearchTap: () {
                sideProvider.startSearch();
              },
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
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_outlined,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No balance reports found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                ScaffoldState? parent;
                context.visitAncestorElements((element) {
                  if (element is StatefulElement &&
                      element.state is ScaffoldState) {
                    ScaffoldState scaffold =
                        element.state as ScaffoldState;
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
                  borderRadius: BorderRadius.circular(12),
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
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      provider.setSearch(searchController.text);
                      provider.getBalanceReport(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textGrey4,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    child:
                        Text(provider.search.isNotEmpty ? 'Cancel' : 'Search'),
                  ),
                ),
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
            CommonReportDateFilter(
              fromDate:
                  provider.formattedDate, // provider uses a single date here
              toDate: null,
              formattedFromDate: provider.formattedDate,
              formattedToDate: '',
              onTap: () => provider.selectDate(context),
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
            CommonReportResetButton(
              onReset: () {
                provider.setSearch('');
                searchController.clear();
                provider.setDate(DateTime.now());
                provider.getBalanceReport(context);
              },
              label: 'Reset',
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
                  data: Tooltip(
                    message: item.address,
                    child: Text(item.address,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
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
    return Column(
      children: [
        if (provider.isFilter)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CustomText('Date Range',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack),
                  const SizedBox(height: 8),
                  CommonReportDateFilter(
                    fromDate: provider.formattedDate,
                    toDate: null,
                    formattedFromDate: provider.formattedDate,
                    formattedToDate: '',
                    onTap: () => provider.selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  if (provider.search.isNotEmpty || provider.isFilter)
                    SizedBox(
                      width: double.infinity,
                      child: CommonReportResetButton(
                        label: 'Reset All Filters',
                        onReset: () {
                          provider.setSearch('');
                          searchController.clear();
                          provider.setDate(DateTime.now());
                          provider.getBalanceReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          elevation: 0,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (!provider.isFilter)
          Expanded(
            child: provider.balanceReportList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No balance reports found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      CommonReportSummaryBar(
                        totalLabel: 'Total Records',
                        totalCount: provider.balanceReportList.length,
                        showingLabel: 'Showing',
                        showingCount: provider.balanceReportList.length,
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.balanceReportList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = provider.balanceReportList[index];
                            return ReportListItem(
                              title: item.customerName,
                              subtitle: item.phone,
                              status: '₹ ${item.balance.toStringAsFixed(2)}',
                              statusColor: item.balance > 0
                                  ? AppColors.textRed
                                  : AppColors.primaryBlue,
                              description: item.address,
                              bottomLeftIcon: Icons.payments_outlined,
                              bottomLeftText:
                                  'Sch: ₹${item.totalPaymentSchedule.toStringAsFixed(0)}',
                              bottomRightText:
                                  'Rec: ₹${item.totalReceipt.toStringAsFixed(0)}',
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
