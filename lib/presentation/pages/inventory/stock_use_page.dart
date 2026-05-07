import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/stock_use_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_stock_use.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

class StockUsePage extends StatefulWidget {
  final int customerId;

  const StockUsePage({super.key, required this.customerId});

  @override
  State<StockUsePage> createState() => _StockUsePageState();
}

class _StockUsePageState extends State<StockUsePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final stockuseprovider = Provider.of<StockUseProvider>(context, listen: false);
      stockuseprovider.searchItemListStock(context);
      stockuseprovider.searchStockUseList(
          context: context, customerId: widget.customerId.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stockuseprovider = Provider.of<StockUseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, stockuseprovider, settingsProvider, isMobile),
        if (stockuseprovider.isFilter) _buildFilterPanel(context, stockuseprovider),
        const SizedBox(height: 20),
        stockuseprovider.stockUseList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stockuseprovider.stockUseList.length,
                itemBuilder: (context, index) {
                  final stockUse = stockuseprovider.stockUseList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportListItem(
                      title: stockUse.description.isNotEmpty ? stockUse.description : 'Stock Use Entry',
                      subtitle: 'Date: ${stockUse.date}',
                      description: 'ID: ${stockUse.stockUseId}',
                      statusColor: AppColors.primaryBlue,
                      onEdit: settingsProvider.menuIsEditMap[78] == 1 ? () async {
                        stockuseprovider.getStockUseDetails(
                            context: context,
                            masterId: stockUse.stockUseId.toString());
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddStockUseWidget(
                                customerId: widget.customerId,
                                isEdit: true,
                                editId: stockUse.stockUseId,
                                stockUse: stockUse);
                          },
                        );
                      } : null,
                      onDelete: settingsProvider.menuIsDeleteMap[78] == 1 ? () {
                        _showDeleteDialog(context, stockuseprovider, stockUse.stockUseId);
                      } : null,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, StockUseProvider provider, SettingsProvider settings, bool isMobile) {
    return Row(
      children: [
        Text(
          'Stock Use',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlue800),
        ),
        const Spacer(),
        CustomFilterButton(
          onPressed: () => provider.toggleFilter(),
          isFilter: provider.isFilter,
        ),
        const SizedBox(width: 12),
        if (settings.menuIsSaveMap[78] == 1)
          CustomOutlinedSvgButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AddStockUseWidget(
                    isEdit: false,
                    editId: 0,
                    customerId: widget.customerId,
                  );
                },
              );
            },
            svgPath: 'assets/images/Plus.svg',
            label: isMobile ? 'Add' : 'Add Stock Use',
            breakpoint: 600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryBlue,
            borderSide: BorderSide(color: AppColors.primaryBlue),
          ),
      ],
    );
  }

  Widget _buildFilterPanel(BuildContext context, StockUseProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    provider.searchStockUseList(context: context, customerId: widget.customerId.toString());
                    provider.toggleFilter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 12),
              CommonReportResetButton(
                onReset: () {
                  provider.selectDateFilterOption(null);
                  provider.setSearchCriteria('', '', '', '', '');
                  provider.searchStockUseList(context: context, customerId: widget.customerId.toString());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDateDialog(BuildContext context, StockUseProvider provider) {
    showDialog(
      context: context,
      builder: (contextx) => Consumer<StockUseProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      reportsProvider.searchStockUseList(context: context, customerId: widget.customerId.toString());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No stock use entries found',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StockUseProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this stock use entry?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                provider.deleteStockUse(context, id, widget.customerId);
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
