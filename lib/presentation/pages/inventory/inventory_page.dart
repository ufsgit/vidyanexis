import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/inventory/category_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/inventory_Customer_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/item_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/purchase_screen.dart';
import 'package:vidyanexis/presentation/pages/inventory/sales_screen.dart';
import 'package:vidyanexis/presentation/pages/inventory/supplier_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/unit_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/stock_use_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/stock_return_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: isMobile
          ? CustomAppBar(
              title: 'Inventory',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              leadingWidget: IconButton(
                onPressed: () {
                  final sideProvider =
                      Provider.of<SidebarProvider>(context, listen: false);
                  if (sideProvider.reportPage != null) {
                    sideProvider.setReportPage(null);
                  } else {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.arrow_back, color: AppColors.textGrey4),
                iconSize: 24,
              ),
              showSearch: false,
              onSearch: (q) {},
            )
          : null,
      body: isMobile
          ? _buildMobileLayout(settingsProvider)
          : _buildDesktopLayout(settingsProvider),
    );
  }

  Widget _buildMobileLayout(SettingsProvider settingsProvider) {
    final List<String> menuItems = _getMenuItems(settingsProvider);
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 50,
          child: Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final title = menuItems[index];
                  final isSelected = expenseProvider.selectedMenu == title;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(title),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          expenseProvider.setSelectedMenu(title);
                        }
                      },
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textGrey4,
                      ),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(SettingsProvider settingsProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        final sideProvider = Provider.of<SidebarProvider>(
                            context,
                            listen: false);
                        sideProvider.setSelectedIndex(0);
                        sideProvider.updateSelectedName('DashBoard');
                      },
                    ),
                    Text(
                      'Inventory',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        color: const Color(0xFF152D70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ..._getMenuItems(settingsProvider).map((title) => _buildMenuItem(title)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 72),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getMenuItems(SettingsProvider settingsProvider) {
    List<String> items = [];
    if (settingsProvider.menuIsViewMap[43].toString() == '1') items.add('Item');
    if (settingsProvider.menuIsViewMap[44].toString() == '1') items.add('Purchase');
    if (settingsProvider.menuIsViewMap[45].toString() == '1') items.add('Supplier');
    if (settingsProvider.menuIsViewMap[46].toString() == '1') items.add('Category');
    if (settingsProvider.menuIsViewMap[47].toString() == '1') items.add('Unit');
    if (settingsProvider.menuIsViewMap[87].toString() == '1') items.add('Sales');
    if (settingsProvider.menuIsViewMap[78].toString() == '1') items.add('Stock Use');
    if (settingsProvider.menuIsViewMap[79].toString() == '1') items.add('Stock Return');
    items.add('Customer');
    return items;
  }

  Widget _buildMenuItem(String title) {
    return Consumer<ExpenseProvider>(
      builder: (context, settings, child) {
        final isSelected = settings.selectedMenu == title;
        return InkWell(
          onTap: () => settings.setSelectedMenu(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? const Color(0xFFE5F0FF) : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<ExpenseProvider>(
      builder: (context, settings, child) {
        switch (settings.selectedMenu) {
          case 'Item':
            return const ItemPage();
          case 'Purchase':
            return const PurchaseScreen();
          case 'Supplier':
            return const SupplierPage();
          case 'Sales':
            return const SalesScreen();
          case 'Stock Use':
            return const StockUsePage(customerId: 0);
          case 'Stock Return':
            return const StockReturnPage(customerId: 0);
          case 'Category':
            return const CategoryPage();
          case 'Unit':
            return const UnitPage();
          case 'Customer':
            return const CustomerPage();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
