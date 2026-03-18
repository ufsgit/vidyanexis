import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/menu_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_category_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_item_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_type.dart';
import 'package:vidyanexis/presentation/pages/settings/company_details.dart';
import 'package:vidyanexis/presentation/pages/settings/department_page.dart';
import 'package:vidyanexis/presentation/pages/settings/document_type.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_for_content.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_source_content.dart';
import 'package:vidyanexis/presentation/pages/settings/expense_type.dart';
import 'package:vidyanexis/presentation/pages/settings/lead_users_content.dart';
import 'package:vidyanexis/presentation/pages/settings/task_type.dart';
import 'package:vidyanexis/presentation/pages/settings/user_content_page.dart';
import 'package:vidyanexis/presentation/pages/settings/version_page.dart';
import 'package:provider/provider.dart';

class SidebarProvider extends ChangeNotifier {
  SettingsProvider? _settingsProvider;
  int _selectedIndexMobile = 0;
  int get selectedIndexMobile => _selectedIndexMobile;
  void setSelectedIndexMobile(int index) {
    _selectedIndexMobile = index;
    notifyListeners();
  }

  List<MenuModel> menuList = [
    MenuModel(
        menuId: 1, menuName: "UsersContent", widget: const UsersContent()),
    MenuModel(
        menuId: 5,
        menuName: "LeadUsersContent",
        widget: const LeadUsersContent()),
    MenuModel(
        menuId: 6,
        menuName: "EnquirySourceContent",
        widget: const EnquirySourceContent()),
    MenuModel(
        menuId: 17,
        menuName: "EnquiryForContent",
        widget: const EnquiryForContent()),
    MenuModel(
        menuId: 20,
        menuName: "BulkImportScreen",
        widget: const BulkImportScreen()),
    MenuModel(
        menuId: 22,
        menuName: "CheckListContent",
        widget: const CheckListContent()),
    MenuModel(
        menuId: 23,
        menuName: "DocumentTypeContent",
        widget: const DocumentTypeContent()),
    MenuModel(
        menuId: 27, menuName: "CompanyDetails", widget: const CompanyDetails()),
    MenuModel(menuId: 28, menuName: "VersionPage", widget: const VersionPage()),
    MenuModel(
        menuId: 38,
        menuName: "CheckListItemPage",
        widget: const CheckListItemPage()),
    MenuModel(
        menuId: 39,
        menuName: "CheckListCategoryPage",
        widget: const CheckListCategoryPage()),
    MenuModel(
        menuId: 41,
        menuName: "TaskTypeContent",
        widget: const TaskTypeContent()),
    MenuModel(
        menuId: 42, menuName: "DepartmentPage", widget: const DepartmentPage()),
    MenuModel(menuId: 64, menuName: "ExpenseType", widget: const ExpenseType()),
  ];

  // Don't access Provider in constructor
  // Instead, provide a method to access it when needed
  SettingsProvider? get settingsProvider {
    if (_settingsProvider == null &&
        navigatorKey.currentState?.context != null) {
      _settingsProvider = Provider.of<SettingsProvider>(
          navigatorKey.currentState!.context,
          listen: false);
    }
    return _settingsProvider;
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int _selectedIndex = 0;
  int _menuId = 12; // setting dashboard as default screen
  int _subMenuId = 0;

  bool _replaceLead = true;
  bool _replaceCustomer = true;
  String _customerId = '';
  String _name = '/';
  String _selectedName = 'Leads';
  // int _selectedBottomIndex = 0;
  // String _currentTitle =
  //     'Leads'; // Changed default to 'Leads' since Home might not be available

  int get menuId => _menuId;
  int get subMenuId => _subMenuId;

  // Getters
  int get selectedIndex => _selectedIndex;
  String get selectedName => _selectedName;
  String get customerId => _customerId;
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  bool get replaceLead => _replaceLead;
  bool get replaceCustomer => _replaceCustomer;
  // int get selectedBottomIndex => _selectedBottomIndex;
  // String get currentTitle => _currentTitle;

  // Get current page based on context
  // Widget getCurrentPage(BuildContext context) {
  //   final settingsProvider =
  //       Provider.of<SettingsProvider>(context, listen: false);
  //   final hasDashboardAccess =
  //       settingsProvider.menuIsViewMap[12].toString() == '1';

  //   switch (_currentTitle) {
  //     case 'Home':
  //       return hasDashboardAccess
  //           ? const DashBoardPage()
  //           : const LeadPagePhone();
  //     case 'Leads':
  //       return AppStyles.isWebScreen(context)
  //           ? const LeadPage()
  //           : const LeadPagePhone();
  //     case 'Customers':
  //       return AppStyles.isWebScreen(context)
  //           ? const CustomerPage()
  //           : const CustomerPagePhone();
  //     case 'Profile':
  //       return const CustomerPage();
  //     default:
  //       return const LeadPagePhone(); // Default to leads page
  //   }
  // }

  // void onBottomItemTapped(int index, BuildContext context) {
  //   final settingsProvider =
  //       Provider.of<SettingsProvider>(context, listen: false);
  //   final customerProvider =
  //       Provider.of<CustomerProvider>(context, listen: false);
  //   final hasDashboardAccess =
  //       settingsProvider.menuIsViewMap[12].toString() == '1';
  //   final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);

  //   // Adjust index based on dashboard access
  //   if (_currentTitle == 'Leads') {
  //     leadsProvider.resetExpansion();
  //   }
  //   if (_currentTitle == 'Customers') {
  //     customerProvider.resetExpansion();
  //   }
  //   int adjustedIndex = hasDashboardAccess ? index : index + 1;
  //   if (_currentTitle == 'Leads' || _currentTitle == 'Customers') {
  //     _selectedIndex = index;
  //     _selectedBottomIndex = index;
  //   }

  //   switch (adjustedIndex) {
  //     case 0:
  //       _currentTitle = 'Home';
  //       break;
  //     case 1:
  //       _currentTitle = 'Leads';
  //       break;
  //     case 2:
  //       _currentTitle = 'Customers';
  //       break;
  //     case 3:
  //       _currentTitle = 'Profile';
  //       break;
  //     default:
  //       _currentTitle = 'Leads';
  //   }
  //   _selectedName = _currentTitle;
  //   notifyListeners();
  // }

  void setMenuId(int index, int menuId) {
    _menuId = menuId;
    if (menuId == 2) {
      _subMenuId = menuList[0].menuId;
    }
    notifyListeners();
  }

  void setSubMenuId(subMenuId) {
    _subMenuId = subMenuId;
    notifyListeners();
  }

  void updateSelectedName(String name) {
    _selectedName = name;
    notifyListeners();
  }

  void replaceWidget(bool value, String string) {
    _customerId = string;
    _replaceLead = value;
    _name = 'Lead /';
    notifyListeners();
  }

  void replaceWidgetCustomer(bool value, String string) {
    _customerId = string;
    _replaceCustomer = value;
    _name = 'Customer /';
    notifyListeners();
  }

  // void onDrawerItemTapped(int index, BuildContext context) {
  //   final settingsProvider =
  //       Provider.of<SettingsProvider>(context, listen: false);
  //   final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
  //   final customerProvider =
  //       Provider.of<CustomerProvider>(context, listen: false);

  //   final hasDashboardAccess =
  //       settingsProvider.menuIsViewMap[12].toString() == '1';
  //   if (_currentTitle == 'Leads') {
  //     leadsProvider.resetExpansion();
  //   }
  //   if (_currentTitle == 'Customers') {
  //     customerProvider.resetExpansion();
  //   }
  //   // Adjust index based on dashboard access
  //   int adjustedIndex = hasDashboardAccess ? index : index + 1;

  //   if (_currentTitle == 'Leads' || _currentTitle == 'Customers') {
  //     _selectedIndex = index;
  //   }
  //   switch (adjustedIndex) {
  //     case 0:
  //       _currentTitle = 'Home';
  //       break;
  //     case 1:
  //       _currentTitle = 'Leads';
  //       break;
  //     case 2:
  //       _currentTitle = 'Customers';
  //       break;
  //     case 3:
  //       _currentTitle = 'Profile';
  //       break;
  //     default:
  //       _currentTitle = 'Leads';
  //   }
  //   _selectedName = _currentTitle;
  //   notifyListeners();
  //   Navigator.pop(context);
  // }

  // getTitle() {
  //   return _selectedName;
  // }

  //mobile

  // int _selectedIndexMobile = 0;
  // int get selectedIndexMobile => _selectedIndexMobile;

  bool _isSearching = false;
  String _searchQuery = '';

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // notifyListeners();
  }

  // void setSelectedIndexMobile(int index) {
  //   _selectedIndexMobile = index;
  //   notifyListeners();
  // }
}
