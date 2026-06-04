import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stockreturn_provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_stock_return_page.dart';
import 'package:vidyanexis/presentation/widgets/inventory/inventory_list_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

class StockReturnPage extends StatefulWidget {
  final int customerId;

  const StockReturnPage({super.key, required this.customerId});

  @override
  State<StockReturnPage> createState() => _StockReturnPageState();
}

class _StockReturnPageState extends State<StockReturnPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final stockReturnProvider = Provider.of<StockreturnProvider>(context, listen: false);
      stockReturnProvider.searchItemListStock(context);
      stockReturnProvider.searchStockReturnList(
          context: context, customerId: widget.customerId.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stockReturnProvider = Provider.of<StockreturnProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, stockReturnProvider, settingsProvider, isMobile),
        if (stockReturnProvider.isFilter) _buildFilterPanel(context, stockReturnProvider),
        const SizedBox(height: 12),
        stockReturnProvider.stockReturnList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stockReturnProvider.stockReturnList.length,
                itemBuilder: (context, index) {
                  final stockReturn = stockReturnProvider.stockReturnList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InventoryListItem(
                      title: stockReturn.description.isNotEmpty ? stockReturn.description : 'Stock Return Entry',
                      subtitle: 'Date: ${stockReturn.returnDate}',
                      description: 'Return ID: ${stockReturn.stockReturnId}',
                      onEdit: settingsProvider.menuIsEditMap[79] == 1 ? () async {
                        stockReturnProvider.getStockReturnDetails(
                            context: context,
                            masterId: stockReturn.stockReturnId.toString());
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddStockReturnPage(
                                customerId: widget.customerId,
                                isEdit: true,
                                editId: stockReturn.stockReturnId,
                                stockUse: stockReturn);
                          },
                        );
                      } : null,
                      onDelete: settingsProvider.menuIsDeleteMap[79] == 1 ? () {
                        _showDeleteDialog(context, stockReturnProvider, stockReturn.stockReturnId);
                      } : null,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, StockreturnProvider provider, SettingsProvider settings, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFilterButton(
            onPressed: () => provider.toggleFilter(),
            isFilter: provider.isFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, StockreturnProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date Filter', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CommonReportDateFilter(
            fromDate: provider.fromDate?.toString(),
            toDate: provider.toDate?.toString(),
            formattedFromDate: provider.formattedFromDate,
            formattedToDate: provider.formattedToDate,
            onTap: () => _showDateDialog(context, provider),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.searchStockReturnList(context: context, customerId: widget.customerId.toString());
                    provider.toggleFilter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 12),
              CommonReportResetButton(
                onReset: () {
                  provider.selectDateFilterOption(null);
                  provider.setSearchCriteria('', '', '', '', '');
                  provider.searchStockReturnList(context: context, customerId: widget.customerId.toString());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDateDialog(BuildContext context, StockreturnProvider provider) {
    showDialog(
      context: context,
      builder: (contextx) => Consumer<StockreturnProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: ['Yesterday', 'Today', 'Tomorrow', 'This Week', 'This Month']
                      .asMap()
                      .entries
                      .map((e) => ActionChip(
                            label: Text(e.value),
                            onPressed: () {
                              reportsProvider.setDateFilter(e.value);
                              reportsProvider.selectDateFilterOption(e.key);
                            },
                            backgroundColor: reportsProvider.selectedDateFilterIndex == e.key ? AppColors.primaryBlue : Colors.white,
                            labelStyle: TextStyle(color: reportsProvider.selectedDateFilterIndex == e.key ? Colors.white : Colors.black),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  onTap: () => reportsProvider.selectDate(context, true),
                  decoration: InputDecoration(
                    labelText: 'Pick a date',
                    hintText: reportsProvider.fromDate != null ? reportsProvider.formattedFromDate : 'Select',
                    suffixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      reportsProvider.searchStockReturnList(context: context, customerId: widget.customerId.toString());
                    },
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    child: const Text('Apply'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No stock return entries found');
  }

  void _showDeleteDialog(BuildContext context, StockreturnProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this stock return entry?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                provider.deleteStockReturn(context, id, widget.customerId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
