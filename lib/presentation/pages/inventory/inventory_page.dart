import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';

import 'package:vidyanexis/presentation/widgets/inventory/add_item.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_supplier_page.dart';
import 'package:vidyanexis/presentation/widgets/inventory/purchase_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/sales_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_category_widget.dart';
import 'package:vidyanexis/presentation/pages/settings/add_unit_page.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_customer_page.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_stock_use.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_stock_return_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _purchaseSearchController = TextEditingController();
  final TextEditingController _salesSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _purchaseSearchController.dispose();
    _salesSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,

      drawer: isMobile ? const SidebarDrawer() : null,


      body: isMobile
          ? _buildMobileLayout(expenseProvider, settingsProvider)
          : _buildDesktopLayout(expenseProvider, settingsProvider),
    );
  }

  Widget _buildMobileLayout(ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    final List<String> menuItems = _getMenuItems(settingsProvider);
    return Column(
      children: [
        // Premium Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sort_rounded,
                    color: Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Inventory',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              _buildAddButton(context, expenseProvider, settingsProvider),
            ],
          ),
        ),
        // Futuristic Tab Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              return Container(
                height: 44, // Increased height for a better touch target
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(menuItems.length, (index) {
                      final title = menuItems[index];
                      final isSelected = expenseProvider.selectedMenu == title;
                      return GestureDetector(
                        onTap: () => expenseProvider.setSelectedMenu(title),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected ? Colors.white : Colors.transparent,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? AppColors.textBlue800 : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
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
                    const SizedBox(width: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (expenseProvider.selectedMenu == 'Purchase' || expenseProvider.selectedMenu == 'Sales')
                      _buildDesktopSearchAndFilter(expenseProvider),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildAddButton(context, expenseProvider, settingsProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
    if (settingsProvider.menuIsViewMap[143].toString() == '1') items.add('Customer');
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

  Widget _buildDesktopSearchAndFilter(ExpenseProvider provider) {
    bool isPurchase = provider.selectedMenu == 'Purchase';
    bool isSales = provider.selectedMenu == 'Sales';

    if (!isPurchase && !isSales) return const SizedBox.shrink();

    TextEditingController controller = isPurchase ? _purchaseSearchController : _salesSearchController;

    // Sync clear if reset from filter panel
    if (isPurchase && provider.search.isEmpty && controller.text.isNotEmpty && !FocusScope.of(context).hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clear();
      });
    } else if (isSales && provider.searchSales.isEmpty && controller.text.isNotEmpty && !FocusScope.of(context).hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clear();
      });
    }

    return Row(
      children: [
        Container(
          width: 250,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            onSubmitted: (query) {
              if (isPurchase) {
                provider.setSearchCriteria(
                    query, provider.fromDateS, provider.toDateS, provider.status, provider.enquiryForS);
                provider.getPurchaseDataMaster(context);
              } else if (isSales) {
                provider.setSearchCriteriaSales(
                    query, provider.fromDateSSales, provider.toDateSSales, provider.status, provider.enquiryForS);
                provider.getSalesMaster(context);
              }
            },
            onChanged: (val) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                      onPressed: () {
                        controller.clear();
                        if (isPurchase) {
                          provider.setSearchCriteria(
                              '', provider.fromDateS, provider.toDateS, provider.status, provider.enquiryForS);
                          provider.getPurchaseDataMaster(context);
                        } else {
                          provider.setSearchCriteriaSales(
                              '', provider.fromDateSSales, provider.toDateSSales, provider.status, provider.enquiryForS);
                          provider.getSalesMaster(context);
                        }
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        CustomFilterButton(
          onPressed: () {
            if (isPurchase) {
              provider.toggleFilter();
            } else if (isSales) {
              provider.toggleFilterSales();
            }
          },
          isFilter: isPurchase ? provider.isFilter : provider.isFilterSales,
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, ExpenseProvider expenseProvider,
      SettingsProvider settingsProvider) {
    // Determine the action based on selected tab
    VoidCallback? onTap;
    int menuId = 0;

    switch (expenseProvider.selectedMenu) {
      case 'Item':
        menuId = 43;
        onTap = () => _showAddItemDialog(context);
        break;
      case 'Purchase':
        menuId = 44;
        onTap = () => _showAddPurchaseDialog(context);
        break;
      case 'Supplier':
        menuId = 45;
        onTap = () => _showAddSupplierDialog(context);
        break;
      case 'Category':
        menuId = 46;
        onTap = () => _showAddCategoryDialog(context);
        break;
      case 'Unit':
        menuId = 47;
        onTap = () => _showAddUnitDialog(context);
        break;
      case 'Customer':
        menuId = 143; // Inventory Customer
        onTap = () => _showAddCustomerDialog(context);
        break;
      case 'Stock Use':
        menuId = 78;
        onTap = () => _showAddStockUseDialog(context);
        break;
      case 'Stock Return':
        menuId = 79;
        onTap = () => _showAddStockReturnDialog(context);
        break;
      case 'Sales':
        menuId = 87;
        onTap = () => _showAddSalesDialog(context);
        break;
    }

    if (onTap == null || (menuId != 0 && settingsProvider.menuIsSaveMap[menuId] == 0)) {
      return const SizedBox(width: 44, height: 44);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.secondaryBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // Helper dialog launchers
  void _showAddItemDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemWidget(
          isEdit: false,
          editId: 0,
          item: null,
        ),
      ),
    );
  }

  void _showAddPurchaseDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PurchaseWidget(
          isEdit: false,
          editId: '0',
        ),
      ),
    );
  }

  void _showAddSalesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalesWidget(
          isEdit: false,
          editId: '0',
        ),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplier(
          editId: '0',
          isEdit: false,
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCategoryWidget(
          editId: '0',
          isEdit: false,
        ),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddUnitWidget(
          editId: '0',
          isEdit: false,
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomer(
          editId: '0',
          isEdit: false,
        ),
      ),
    );
  }

  void _showAddStockUseDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStockUseWidget(
          isEdit: false,
          editId: 0,
          customerId: 0,
        ),
      ),
    );
  }

  void _showAddStockReturnDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddStockReturnPage(
          isEdit: false,
          editId: 0,
          customerId: 0,
        ),
      ),
    );
  }
}
