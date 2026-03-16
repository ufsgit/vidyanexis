import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/inventory/category_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/inventory_Customer_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/item_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/purchase_screen.dart';
import 'package:vidyanexis/presentation/pages/inventory/sales_screen.dart';
import 'package:vidyanexis/presentation/pages/inventory/supplier_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/unit_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/stock_use_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/stock_return_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Inventory',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF152D70),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (settingsProvider.menuIsViewMap[43].toString() == '1')
                  _buildMenuItem(context, 'Item', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[44].toString() == '1')
                  _buildMenuItem(context, 'Purchase', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[45].toString() == '1')
                  _buildMenuItem(context, 'Supplier', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[46].toString() == '1')
                  _buildMenuItem(context, 'Category', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[47].toString() == '1')
                  _buildMenuItem(context, 'Unit', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[87].toString() == '1')
                  _buildMenuItem(context, 'Sales', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[78].toString() == '1')
                  _buildMenuItem(context, 'Stock Use', Icons.document_scanner),
                if (settingsProvider.menuIsViewMap[79].toString() == '1')
                  _buildMenuItem(context, 'Stock Return', Icons.document_scanner),
                _buildMenuItem(context, 'Customer', Icons.document_scanner),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 72,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    return Consumer<ExpenseProvider>(
      builder: (context, settings, child) {
        final isSelected = settings.selectedMenu == title;

        return InkWell(
          onTap: () {
            settings.setSelectedMenu(title);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? const Color(0xFFE5F0FF) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Icon(
                    //   icon,
                    //   color: isSelected ? AppColors.primaryBlue : Colors.grey,
                    //   size: 20,
                    // ),
                    // const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
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
          // case 'Stock':
          //   return const StockScreen(
          //     editId: 0,
          //     isEdit: false,
          //   );
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
