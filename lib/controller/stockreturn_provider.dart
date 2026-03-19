import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/models/expense_type_model.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/controller/models/item_lists_model.dart';
import 'package:vidyanexis/controller/models/payment_model.dart';

import 'package:vidyanexis/controller/models/purchase_item_model.dart';
import 'package:vidyanexis/controller/models/purchase_model.dart';
import 'package:vidyanexis/controller/models/stock_list_model.dart';
import 'package:vidyanexis/controller/models/stock_model.dart';
import 'package:vidyanexis/controller/models/stock_return_model.dart';

import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/utils/extensions.dart';

class StockreturnProvider extends ChangeNotifier {
  String _selectedMenu = 'Item';
  String get selectedMenu => _selectedMenu;
  final TextEditingController customerController = TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController paymentNetTotalController =
      TextEditingController();
  final TextEditingController paymentTaxPercentageController =
      TextEditingController();
  //expense management
  final TextEditingController expenseTypeController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController searchExpenseController = TextEditingController();
  final TextEditingController projectTypeController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController expenseHeadController = TextEditingController();
  final TextEditingController taxSlabController = TextEditingController();
  final TextEditingController amountWithTaxController = TextEditingController();
  final TextEditingController amountWithoutTaxController =
      TextEditingController();
  final TextEditingController taxPercentageController = TextEditingController();

  final TextEditingController taskController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController itemUnitPriceController = TextEditingController();
  final TextEditingController itemHSNController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
//suspense entry
  final TextEditingController suspenseTypeController = TextEditingController();

  final TextEditingController suspenseAmountController =
      TextEditingController();
  final TextEditingController suspensePayedToController =
      TextEditingController();
  final TextEditingController suspensePaymentModeController =
      TextEditingController();
  final TextEditingController suspenseDateController = TextEditingController();
  final TextEditingController suspenseUserMailController =
      TextEditingController();
  final TextEditingController suspensePercentageController =
      TextEditingController();
  final TextEditingController suspenseAmountWithoutTaxController =
      TextEditingController();
  final TextEditingController suspenseHeadController = TextEditingController();
  final TextEditingController suspenseCommentController =
      TextEditingController();

  final TextEditingController paymentAmountGstController =
      TextEditingController();
  final TextEditingController paymentCommentController =
      TextEditingController();
  final TextEditingController paymenttaxSlabController =
      TextEditingController();
  final TextEditingController paymenttaxIncludedController =
      TextEditingController();
  final TextEditingController paymentModeController = TextEditingController();
  final TextEditingController paymentProjectController =
      TextEditingController();
  final TextEditingController receiptDateController = TextEditingController();
  final TextEditingController paymentEntryDateController =
      TextEditingController();
  final List<Uint8List> _images = []; // List to store images
  final List<Uint8List> _pdfs = [];
  List<Uint8List> get images => _images;
  List<Uint8List> get pdfs => _pdfs;
  List<Map<String, String>> uploadedFilePaths = [];
  ScrollController scrollController = ScrollController();
  final TextEditingController suDateController = TextEditingController();
  final TextEditingController suStockIdController = TextEditingController();
  final TextEditingController suDescriptionController = TextEditingController();
  final TextEditingController suQuantityController = TextEditingController();
  final TextEditingController suUnitPriceController = TextEditingController();
  final TextEditingController suItemNameController = TextEditingController();
  final TextEditingController suAmountController = TextEditingController();

  //stock return controllers
  final TextEditingController returnStockIdController = TextEditingController();

  final TextEditingController returnDateController = TextEditingController();
  final TextEditingController returnItemController = TextEditingController();
  final TextEditingController returnQuantityController =
      TextEditingController();
  final TextEditingController returnSaleRateController =
      TextEditingController();

  final TextEditingController returnCategoryController =
      TextEditingController();
  final TextEditingController returnDescriptionController =
      TextEditingController();

  final TextEditingController searchSuspenseController =
      TextEditingController();
  final TextEditingController searchPaymentController = TextEditingController();
  int? _selectedItemStockUseId;
  int? get selectedItemStockUseId => _selectedItemStockUseId;
  final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(
      navigatorKey.currentState!.context,
      listen: false);
  int? _selectedItemReturnId;
  int? get selectedItemReturnId => _selectedItemReturnId;
  List<StockUseModel> _stockUseList = [];
  List<StockUseModel> get stockUseList => _stockUseList;
  List<StockUseItems> _stockUseItems = [];
  List<StockUseItems> get stockUseItems => _stockUseItems;
  List<StockReturnModel> _stockReturnList = [];
  List<StockReturnModel> get stockReturnList => _stockReturnList;
  List<StockReturnItems> _stockReturnItems = [];
  List<StockReturnItems> get stockReturnItems => _stockReturnItems;
  ExpenseHeaderModel _expenseHeaderModel = ExpenseHeaderModel();
  ExpenseHeaderModel get expenseHeaderModel => _expenseHeaderModel;
  List<ExpenseModel> _expenseModelList = [];
  List<ExpenseModel> get expenseModelList => _expenseModelList;

  // List<SuspenseModel> _suspenseModelList = [];
  // List<SuspenseModel> get suspenseModelList => _suspenseModelList;

  // List<ReceiptModel> _paymentModelList = [];
  // List<ReceiptModel> get paymentModelList => _paymentModelList;
  //item add
  final TextEditingController searchitemNameController =
      TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCategoryController = TextEditingController();
  final TextEditingController itemUnitController = TextEditingController();
  int _selectedItemCategory = 0;
  int get selectedItemCategory => _selectedItemCategory;
  int _selectedItemUnit = 0;
  int get selectedItemUnit => _selectedItemUnit;
  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();
  final TextEditingController igstController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController itemMaterialController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  int? _editIndex;
  int? get editIndex => _editIndex;
  List<ItemListModel> _itemList = [];
  List<ItemListModel> get itemList => _itemList;

  //stock
  List<StockEntry> _stockList = [];
  List<StockEntry> get stockList => _stockList;
  int? _selectedCustomerId;
  int? get selectedCustomerId => _selectedCustomerId;

  int? _selectedExpenseTypeId;
  int? get selectedExpenseTypeId => _selectedExpenseTypeId;

  int? _selectedItemStockId;
  int? get selectedItemId => _selectedItemStockId;
  String _totalStockAmount = "";
  String get totalStockAmount => _totalStockAmount;
  int? selectedUnitId;
  int? selectedCategoryId;
  int _isChecked = 0;
  int get isChecked => _isChecked;

  int _isPrimaryItem = 0;
  int get isPrimaryItem => _isPrimaryItem;
  int? _editStockIndex;
  int? _editReturnIndex;

  String _search = '';
  String _fromDateS = '';
  String _supplier = '';
  final String _enquiryForS = '';

  String get search => _search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get status => _supplier;
  String get enquiryForS => _enquiryForS;
  String _toDateS = '';
  final TextEditingController customerNameStockController =
      TextEditingController();
  final TextEditingController itemNameStockController = TextEditingController();
  final TextEditingController itemUnitStockController = TextEditingController();
  final TextEditingController itemCategoryStockController =
      TextEditingController();
  final TextEditingController itemRateStockController = TextEditingController();
  final TextEditingController itemGstStockontroller = TextEditingController();
  final TextEditingController itemQuantityStockController =
      TextEditingController(text: '1');
  final TextEditingController categoryPurchaseController =
      TextEditingController();

  final TextEditingController addressPurchaseController =
      TextEditingController();
  final TextEditingController invoiceNoPurchaseController =
      TextEditingController();
  final TextEditingController invoiceDatePurchaseController =
      TextEditingController();

  final TextEditingController itemNamePurchaseController =
      TextEditingController();
  final TextEditingController unitPurchaseController = TextEditingController();
  final TextEditingController hsnPurchaseController = TextEditingController();
  final TextEditingController quantityPurchaseController =
      TextEditingController();
  final TextEditingController pricePurchaseController = TextEditingController();
  final TextEditingController amountPurchaseController =
      TextEditingController();
  final TextEditingController discountPurchaseController =
      TextEditingController();
  final TextEditingController discountAmountPurchaseController =
      TextEditingController();
  final TextEditingController netValuePurchaseController =
      TextEditingController();
  final TextEditingController descriptionPurchaseController =
      TextEditingController();
  final TextEditingController cgstPurchaseController = TextEditingController();
  final TextEditingController sgstPurchaseController = TextEditingController();
  final TextEditingController gstPurchaseController = TextEditingController();
  final TextEditingController igstPurchaseController = TextEditingController();
  final TextEditingController cgstPerPurchaseController =
      TextEditingController();
  final TextEditingController sgstPerPurchaseController =
      TextEditingController();
  final TextEditingController gstPerPurchaseController =
      TextEditingController();
  final TextEditingController igstPerPurchaseController =
      TextEditingController();
  final TextEditingController totalAmountPurchaseController =
      TextEditingController();
  List<ItemListModel> _itemListPurchase = [];
  List<ItemListModel> get itemListPurchase => _itemListPurchase;
  List<ItemListStock> _itemListStock = [];
  List<ItemListStock> get itemListStock => _itemListStock;
//purchase
  final List<PurchaseModel> _purchaseList = [];
  List<PurchaseModel> get purchaseList => _purchaseList;
  List<PurchaseItemModel> purchaseItems = [];
  List<PurchaseItemModel> _purchaseDetails = [];
  List<PurchaseItemModel> get purchaseDetails => _purchaseDetails;
  double grandTotal = 0.0;
  double totalCGST = 0.0;
  double totalSGST = 0.0;
  double totalGST = 0.0;
  double totalDiscount = 0.0;
  double totalTaxableAmount = 0.0;
  double finalGrandTotal = 0.0;
  int? _selectedSupplierId;
  int? get selectedSupplierId => _selectedSupplierId;
  int? _itemDrop;
  int? get itemDrop => _itemDrop;

  int? _editItemIndex;
  bool _isFilter = false;
  bool get isFilter => _isFilter;

  List<ItemListModel> _filteredItemList = [];
  //item type dropdown
  String get selectedType => _selectedType;
  final String _selectedType = 'service';
//expense
  String _formattedFromDate = '';
  String _formattedToDate = '';
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedSupplier;
  int? get selectedSupplier => _selectedSupplier;
  int? _subItemId;
  int? get subItemId => _subItemId;

  int? _itemMaterialId;
  int? get itemMaterialId => _itemMaterialId;
  List<ExpenseTypeModel> _expenseTypeList = [];
  List<ExpenseTypeModel> get expenseTypeList => _expenseTypeList;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  void setSelectedCustomerId(int id) {
    _selectedCustomerId = id;
    notifyListeners();
  }

  void setSubId(int id) {
    _subItemId = id;
    notifyListeners();
  }

  void setMaterialId(int id) {
    _itemMaterialId = id;
    notifyListeners();
  }

  void setSupplier(int newSupplier) {
    _selectedSupplier = newSupplier;
    print(_selectedSupplier.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      // If the index is null, we are clearing the filter
      _selectedDateFilterIndex = null; // Reset to the default "no filter" state
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
    } else {
      _selectedDateFilterIndex = index; // Set the new selected filter index
      formatDate();
    }
    notifyListeners();
  }

  void formatDate() {
    if (fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    } else {
      _formattedFromDate = '';
    }

    if (toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      _formattedToDate = '';
    }
  }

  void removeSupplier() {
    _selectedSupplier = null;
    notifyListeners();
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    // selectDateFilterOption(null);
    // removeSupplier();
    notifyListeners();
  }

  void setSelectedSupplierId(int id) {
    _selectedSupplierId = id;
    notifyListeners();
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Set selected purchase item ID
  void setSelectedPurchaseItemId(int id) {
    _itemDrop = id;
    notifyListeners();
  }

  void _filterItems() {
    _filteredItemList = _itemList
        .where((item) => _selectedType == 'service'
            ? item.serviceCheckbox == 1
            : item.serviceCheckbox == 0)
        .toList();
  }

  Future<void> searchItemList(
      {required BuildContext context, required bool isFilter}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getItemList);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'];
          _itemList = (dataitem as List<dynamic>)
              .map((item) => ItemListModel.fromJson(item))
              .toList();
          if (isFilter) {
            _filterItems();
          }
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> searchPurchaseDetails(String purchaseMasterId, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getPurchaseDetails}/$purchaseMasterId");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final rawDataList = data['data'];

          // Handle nested list safely
          final purchaseMasterList = rawDataList[0];
          if (purchaseMasterList != null && purchaseMasterList.isNotEmpty) {
            final purchaseMaster = purchaseMasterList[0];
            final dataitem = purchaseMaster['purchase_details'] ?? [];

            print('-------- $dataitem');

            _purchaseDetails = (dataitem as List<dynamic>)
                .map((item) => PurchaseItemModel.fromJson(item))
                .toList();

            notifyListeners();
          } else {
            print('No purchase master data found');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2101), // Maximum date
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setFromDate(pickedDate); // Set the 'from' date in provider
      } else {
        setToDate(pickedDate); // Set the 'to' date in provider
      }
    }
    notifyListeners();
  }

  void setDateFilter(String title) {
    final now = DateTime.now();

    switch (title) {
      case 'Yesterday':
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        _fromDate = now;
        _toDate = now;
        break;
      case 'Tomorrow':
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        _fromDate = null;
        _toDate = null;
        break;
    }

    notifyListeners(); // Notify listeners to rebuild the UI
  }

  void updateCalculations() {
    double quantity = double.tryParse(quantityPurchaseController.text) ?? 0;
    double price = double.tryParse(pricePurchaseController.text) ?? 0;
    double discountPer = double.tryParse(discountPurchaseController.text) ?? 0;

    double amount = quantity * price;
    amountPurchaseController.text = amount.toStringAsFixed(2);

    double discount = (discountPer * amount) / 100;
    discountAmountPurchaseController.text = discount.toStringAsFixed(2);

    double netValue = amount - discount;
    netValuePurchaseController.text = netValue.toStringAsFixed(2);
    double cgstPer = double.tryParse(cgstPerPurchaseController.text) ?? 0.0;
    double sgstPer = double.tryParse(sgstPerPurchaseController.text) ?? 0.0;
    double cgst = (netValue * cgstPer) / 100;
    double sgst = (netValue * sgstPer) / 100;
    cgstPurchaseController.text = cgst.toStringAsFixed(2);
    sgstPurchaseController.text = sgst.toStringAsFixed(2);

    double totalGst = cgst + sgst;
    gstPurchaseController.text = totalGst.toStringAsFixed(2);

    totalAmountPurchaseController.text =
        (netValue + totalGst).toStringAsFixed(2);
  }

  void addOrUpdatePurchaseItem(PurchaseItemModel item) {
    if (_editItemIndex != null &&
        _editItemIndex! >= 0 &&
        _editItemIndex! < purchaseItems.length) {
      // Edit existing item
      purchaseItems[_editItemIndex!] = item;
    } else {
      // Add new item
      purchaseItems.add(item);
    }

    // Reset edit index
    _editItemIndex = null;

    // Recalculate totals
    calculateGrandTotal();
    notifyListeners();
  }

  void calculateGrandTotal() {
    grandTotal = 0.0;
    totalCGST = 0.0;
    totalSGST = 0.0;
    totalGST = 0.0;
    totalDiscount = 0.0;
    totalTaxableAmount = 0.0;
    finalGrandTotal = 0.0;

    for (var item in purchaseItems) {
      grandTotal += item.amount;
      totalCGST += item.cgstAmount;
      totalSGST += item.sgstAmount;
      totalGST += item.gstAmount;
      totalTaxableAmount += item.netValue;
      totalDiscount += item.discount;
      finalGrandTotal += item.totalAmount;
    }

    notifyListeners();
  }

  void editPurchaseItem(int index) {
    if (index >= 0 && index < purchaseItems.length) {
      PurchaseItemModel item = purchaseItems[index];
      _editItemIndex = index;

      // Populate fields with existing data
      itemNamePurchaseController.text = item.itemName;
      categoryPurchaseController.text = item.categoryName;
      unitPurchaseController.text = item.unitName;
      cgstPurchaseController.text = item.cgstAmount.toString();
      sgstPurchaseController.text = item.sgstAmount.toString();
      gstPurchaseController.text = item.gstAmount.toString();
      pricePurchaseController.text = item.price.toString();
      quantityPurchaseController.text = item.quantity.toString();
      amountPurchaseController.text = item.amount.toString();
      discountPurchaseController.text = item.discountPercentage.toString();
      discountAmountPurchaseController.text = item.discount.toString();
      netValuePurchaseController.text = item.netValue.toString();
      totalAmountPurchaseController.text = item.totalAmount.toString();
      selectedCategoryId = int.tryParse(item.categoryId) ?? 0;
      selectedUnitId = int.tryParse(item.unitId) ?? 0;
      hsnPurchaseController.text = item.hsnCode;

      // Ensure the selected item ID is updated
      setSelectedPurchaseItemId(int.tryParse(item.itemId) ?? 0);
      notifyListeners();
    }
  }

  void removePurchaseItem(int index) {
    if (index >= 0 && index < purchaseItems.length) {
      purchaseItems.removeAt(index);
      calculateGrandTotal();
      notifyListeners();
    }
  }

  void resetPurchaseItems() {
    purchaseItems.clear();
    grandTotal = 0.0;
    totalCGST = 0.0;
    totalSGST = 0.0;
    totalGST = 0.0;
    totalDiscount = 0.0;
    totalTaxableAmount = 0.0;
    finalGrandTotal = 0.0;
    _selectedSupplierId = null;
    notifyListeners();
  }

  void clearPurchaseItemFields() {
    itemNamePurchaseController.clear();
    categoryPurchaseController.clear();
    unitPurchaseController.clear();
    cgstPurchaseController.clear();
    sgstPurchaseController.clear();
    gstPurchaseController.clear();
    pricePurchaseController.clear();
    quantityPurchaseController.clear();
    amountPurchaseController.clear();
    discountPurchaseController.clear();
    discountAmountPurchaseController.clear();
    netValuePurchaseController.clear();
    totalAmountPurchaseController.clear();
    hsnPurchaseController.clear();
    _itemDrop = null;
    selectedCategoryId = null;
    selectedUnitId = null;
  }

  void resetEditState() {
    _editItemIndex = null;
    clearPurchaseItemFields();
    notifyListeners();
  }

  void resetPurchaseValues() {
    addressPurchaseController.clear();
    invoiceNoPurchaseController.clear();
    invoiceDatePurchaseController.clear();
    descriptionPurchaseController.clear();
    resetEditState();
    notifyListeners();
  }

  Future<void> searchItemListPurchase(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getItemListPurchase);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'];
          _itemListPurchase = (dataitem as List<dynamic>)
              .map((item) => ItemListModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void addOrEditStockUseItem(BuildContext context) {
    if (suItemNameController.text.trim().isEmpty ||
        suQuantityController.text.trim().isEmpty ||
        suUnitPriceController.text.trim().isEmpty) {
      _showAlertDialog(
          context, 'Cannot Save', 'Please fill in all required fields.');
      return;
    }

    final quantity = double.tryParse(suQuantityController.text.trim()) ?? 0.0;
    final unitPrice = double.tryParse(suUnitPriceController.text.trim()) ?? 0.0;
    final amount = unitPrice * quantity;

    final newItem = StockUseItems(
      stockId: int.tryParse(suStockIdController.text) ?? 0,
      itemId: selectedItemStockUseId ?? 0,
      itemName: suItemNameController.text.trim(),
      categoryId: selectedCategoryId ?? 0,
      categoryName: categoryPurchaseController.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      amount: amount,
    );

    if (_editStockIndex != null &&
        _editStockIndex! >= 0 &&
        _editStockIndex! < stockUseItems.length) {
      stockUseItems[_editStockIndex!] = newItem;
    } else {
      stockUseItems.add(newItem);
    }

    resetStockUseForm();
    notifyListeners();
  }

  void addOrEditStockReturnItem(BuildContext context) {
    if (returnItemController.text.trim().isEmpty ||
        returnQuantityController.text.trim().isEmpty ||
        returnSaleRateController.text.trim().isEmpty) {
      _showAlertDialog(
          context, 'Cannot Save', 'Please fill in all required fields.');
      return;
    }

    final quantity =
        double.tryParse(returnQuantityController.text.trim()) ?? 0.0;
    final unitPrice =
        double.tryParse(returnSaleRateController.text.trim()) ?? 0.0;
    final amount = unitPrice * quantity;

    final newItem = StockReturnItems(
      stockReturnId: int.tryParse(returnStockIdController.text) ?? 0,
      itemId: selectedItemReturnId ?? 0,
      itemName: returnItemController.text.trim(),
      categoryId: selectedCategoryId ?? 0,
      categoryName: returnCategoryController.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      amount: amount,
    );

    if (_editReturnIndex != null &&
        _editReturnIndex! >= 0 &&
        _editReturnIndex! < stockReturnItems.length) {
      stockReturnItems[_editReturnIndex!] = newItem;
    } else {
      stockReturnItems.add(newItem);
      print('list/////$stockReturnItems');
    }

    resetStockReturnForm();
    notifyListeners();
  }

  set stockUseItems(List<StockUseItems> items) {
    _stockUseItems = items;
    notifyListeners();
  }

  set stockReturnItems(List<StockReturnItems> items) {
    _stockReturnItems = items;
    notifyListeners();
  }

  void setSelectedStockUseItemId(int id) {
    _selectedItemStockUseId = id;
    notifyListeners();
  }

  void setSelectedStockReturnItemId(int id) {
    _selectedItemReturnId = id;
    notifyListeners();
  }

  void resetStockUseForm() {
    _editStockIndex = null;
    suItemNameController.clear();
    suQuantityController.clear();
    suUnitPriceController.clear();
    categoryPurchaseController.clear();
    selectedCategoryId = null;
    _selectedItemStockUseId = null;
  }

  void resetStockReturnForm() {
    _editReturnIndex = null;
    returnItemController.clear();
    returnQuantityController.clear();
    returnCategoryController.clear();
    returnSaleRateController.clear();
    _selectedItemReturnId = null;
  }

  void populateStockUseFieldsForEditing(int index) {
    if (index < 0 || index >= stockUseItems.length) return;

    final item = stockUseItems[index];
    _editStockIndex = index;
    suItemNameController.text = item.itemName;
    suQuantityController.text = item.quantity.toStringAsFixed(2);
    suUnitPriceController.text = item.unitPrice.toStringAsFixed(2);
    _selectedItemStockUseId = item.itemId;
    selectedCategoryId = item.categoryId;
    suStockIdController.text = item.stockId.toString();
    categoryPurchaseController.text = item.categoryName;
    notifyListeners();
  }

  void populateStockReturnForm(int index) {
    if (index < 0 || index >= stockReturnItems.length) return;
    final item = stockReturnItems[index];
    returnItemController.text = item.itemName;
    returnSaleRateController.text = item.unitPrice.toStringAsFixed(2);
    returnCategoryController.text = item.categoryName;
    returnStockIdController.text = item.stockReturnId.toString();
    returnQuantityController.text = item.quantity.toStringAsFixed(2);
    _selectedItemReturnId = item.itemId;
    _editReturnIndex = index;
    selectedCategoryId = item.categoryId;
    notifyListeners();
  }

  void deleteStockUseItem(int index) {
    if (index >= 0 && index < stockUseItems.length) {
      stockUseItems.removeAt(index);
      notifyListeners();
    }
  }

  void deleteStockReturnItem(int index) {
    if (index >= 0 && index < stockReturnItems.length) {
      stockReturnItems.removeAt(index);
      notifyListeners();
    }
  }

  void toggleCheckbox(bool value) {
    _isChecked = value ? 1 : 0;
    notifyListeners();
  }

  void togglePrimaryCheckbox(bool value) {
    _isPrimaryItem = value ? 1 : 0;
    notifyListeners();
  }

  void setSelectedExpenseTypeId(int id) {
    _selectedExpenseTypeId = id;
    notifyListeners();
  }

  void setSelectedStockItemId(int id) {
    _selectedItemStockId = id;
    notifyListeners();
  }

  void getTotalAmount({required String rate, required String quantity}) {
    try {
      double parsedRate = double.tryParse(rate) ?? 0.0;
      double parsedQuantity = double.tryParse(quantity) ?? 0.0;

      _totalStockAmount = (parsedRate * parsedQuantity).toStringAsFixed(2);
      print(_totalStockAmount);
      notifyListeners();
    } catch (e) {
      print('Error calculating total amount: $e');
    }
  }

  void setSelectedMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  //item-----------------------------------
  void setItemCategory(int value) {
    _selectedItemCategory = value;
    notifyListeners();
  }

  void setItemUnit(int value) {
    _selectedItemUnit = value;
    notifyListeners();
  }

  Future<void> searchItemListStock(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getItemListStock);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'];
          _itemListStock = (dataitem as List<dynamic>)
              .map((item) => ItemListStock.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  //-----------------------------------------
  //Expense Management

  //File Upload
  Future<void> addFile() async {
    if (!kIsWeb) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      for (var platformFile in result.files) {
        Uint8List? fileData;

        // Handle Web and Mobile/Platform paths
        if (platformFile.bytes != null) {
          // For Web
          fileData = platformFile.bytes;
        } else if (platformFile.path != null) {
          // For Android/iOS
          fileData = await File(platformFile.path!).readAsBytes();
        }

        if (fileData != null) {
          // Determine the file type using its content (byte data)
          String fileType = '';
          if (platformFile.bytes != null) {
            fileType = determineFileType(fileData);
          } else if (platformFile.path != null) {
            fileType =
                lookupMimeType(platformFile.path!, headerBytes: fileData) ?? '';
          }
          print(fileType);

          if (fileType == 'application/pdf') {
            _pdfs.add(fileData);
            print('PDF file added: ${platformFile.name}');
          } else if (fileType.startsWith('image/')) {
            _images.add(fileData);
            print('Image file added: ${platformFile.name}');
          } else {
            print('Unsupported file type: ${platformFile.name}');
          }

          // Notify listeners if applicable
          notifyListeners();
        } else {
          print('Unable to read file data for ${platformFile.name}');
        }
      }
    } else {
      print('No file selected.');
    }
  }

  void saveStockUse(int editId, int customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveStockUse,
          bodyData: {
            'Customer_Id': customerId,
            'Stock_Use_Master_Id': editId,
            'EntryDate': suDateController.text.toyyyymmdd(),
            'User_Id': userId,
            'Description': suDescriptionController.text,
            'stock_use_details': stockUseItems.map((e) => e.toJson()).toList(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        print(data);
        searchStockUseList(context: context, customerId: customerId.toString());
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
    }
  }

  void saveStockReturn(int editId, int customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveStockReturn,
          bodyData: {
            "Customer_Id": customerId,
            'Stock_Return_Master_Id': editId,
            'ReturnDate': returnDateController.text.toyyyymmdd(),
            'User_Id': userId,
            'Description': returnDescriptionController.text,
            'stock_return_details':
                stockReturnItems.map((e) => e.toJson()).toList(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        print(data);
        searchStockReturnList(
            context: context, customerId: customerId.toString());
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
    }
  }

  Future<void> searchStockUseList(
      {required BuildContext context, required String customerId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            "${HttpUrls.getStockUse}?s_EntryDate_From=$_fromDateS&s_EntryDate_To=$_toDateS&Is_Date_Check=$isDate&Customer_Id=$customerId",
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'][0] ?? [];

          _stockUseList = (dataitem as List<dynamic>)
              .map((item) => StockUseModel.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> searchStockReturnList(
      {required BuildContext context, required String customerId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            "${HttpUrls.getStockReturn}?s_ReturnDate_From=$_fromDateS&s_RetrunDate_To=$_toDateS&Is_Date_Check=$isDate&Customer_Id=$customerId",
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['data'] != null && data['data'] is List) {
          final dataArray = data['data'] as List<dynamic>;

          if (dataArray.isNotEmpty && dataArray[0] is List) {
            final stockReturnData = dataArray[0] as List<dynamic>;

            _stockReturnList = stockReturnData
                .map((item) =>
                    StockReturnModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            _stockReturnList = [];
          }

          notifyListeners();
        } else {
          _stockReturnList = [];
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      _stockReturnList = [];
      notifyListeners();
    }
  }

  String determineFileType(Uint8List data) {
    if (data.length >= 4) {
      if (data[0] == 0x25 &&
          data[1] == 0x50 &&
          data[2] == 0x44 &&
          data[3] == 0x46) {
        return 'application/pdf'; // PDF
      } else if (data[0] == 0xFF &&
          data[1] == 0xD8 &&
          data[data.length - 2] == 0xFF &&
          data[data.length - 1] == 0xD9) {
        return 'image/jpeg'; // JPEG
      } else if (data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return 'image/png'; // PNG
      }
    }
    return 'unknown';
  }

  void removeImage(Uint8List image) {
    _images.remove(image);
    notifyListeners();
  }

  void removePdf(Uint8List pdf) {
    _pdfs.remove(pdf);
    notifyListeners();
  }

  void clearStockFormFields() {
    customerNameStockController.clear();
    itemNameStockController.clear();
    itemUnitStockController.clear();
    itemCategoryStockController.clear();
    itemRateStockController.clear();
    itemGstStockontroller.clear();
    itemQuantityStockController.clear();

    // Reset selected IDs and calculated values
    _selectedCustomerId = 0;
    _selectedItemStockId = 0;
    selectedUnitId = 0;
    selectedCategoryId = 0;
    _totalStockAmount = '';
  }

  // Upload images to AWS
  Future<void> uploadImagesToAws(String taskId, BuildContext context) async {
    await _uploadFilesToAws(_images, 'image/jpeg', taskId, context);
  }

  // Upload PDFs to AWS
  Future<void> uploadPdfsToAws(String taskId, BuildContext context) async {
    await _uploadFilesToAws(_pdfs, 'application/pdf', taskId, context);
  }

  // Common method to upload files to AWS
  Future<void> _uploadFilesToAws(List<Uint8List> files, String fileType,
      String taskId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      for (var fileData in files) {
        String? uploadedFilePath =
            await saveToAws(fileData, fileType, taskId, context);
        if (uploadedFilePath != null) {
          print('$fileType uploaded: $uploadedFilePath');
          uploadedFilePaths.add({'File_Path': uploadedFilePath});
        } else {
          print('Upload failed for $fileType');
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Documents uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading $fileType')),
      );
      print('Error uploading $fileType: $e');
    } finally {
      Loader.stopLoader(context);
    }
  }

  // Save a single file to AWS
  Future<String?> saveToAws(Uint8List fileData, String fileType, String taskId,
      BuildContext context) async {
    try {
      final String? uploadedFilePath =
          await CloudflareUpload.uploadToCloudflare(
              fileData, fileType, taskId, context);
      return uploadedFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      print('Error uploading to AWS: $e');

      return null;
    }
  }

  

  Future<void> getExpenseType(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getExpenseTypes);

      if (response.statusCode == 200) {
        if (response.data != null) {
          final Map<String, dynamic> responseMap = response.data;

          if (responseMap['success'] == true && responseMap['data'] != null) {
            final List<dynamic> dataArray = responseMap['data'];

            if (dataArray.isNotEmpty && dataArray[0] is List) {
              _expenseTypeList = (dataArray[0] as List)
                  .map((item) =>
                      ExpenseTypeModel.fromJson(item as Map<String, dynamic>))
                  .toList();
              notifyListeners();
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void clearItemAdd() {
    searchitemNameController.clear();
    itemNameController.clear();
    itemCategoryController.clear();
    itemUnitController.clear();
    itemUnitPriceController.clear();
    itemHSNController.clear();
    cgstController.clear();
    sgstController.clear();
    igstController.clear();
    gstController.clear();
  }

  void saveItem(int editId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveItem,
          bodyData: {
            "itemId": editId,
            "itemName": itemNameController.text.toString(),
            "categoryId": _selectedItemCategory,
            "categoryName": itemCategoryController.text.toString(),
            "unitId": _selectedItemUnit,
            "unitName": itemUnitController.text.toString(),
            "Unit_Price": itemUnitPriceController.text.toString(),
            "cgst": cgstController.text,
            "sgst": sgstController.text,
            "gst": gstController.text,
            "igst": igstController.text,
            "Service_CheckBox": _isChecked,
            "Is_Primary": _isPrimaryItem,
            "HSNCode": itemHSNController.text.toString(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        searchItemList(context: context, isFilter: false);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void saveExpense(ExpenseModel expenseModel, BuildContext context) async {
    try {
      Loader.showLoader(context);

      var data = expenseModel.toJson();
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveExpense, bodyData: data);

      if (response!.statusCode == 200) {
        final data = response.data;
        searchExpense('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void saveStock(int editId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveStock,
          bodyData: {
            "Stock_Id": editId,
            "Customer_Id": _selectedCustomerId,
            "Customer_Name": customerNameStockController.text,
            "Entry_Date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
            "Item_Id": _selectedItemStockId,
            "Item_Name": itemNameStockController.text,
            "Unit_Id": selectedUnitId,
            "Unit_Name": itemUnitStockController.text,
            "Category_Id": selectedCategoryId,
            "Category_Name": itemCategoryStockController.text,
            "Rate": itemRateStockController.text.toString(),
            "GST": itemGstStockontroller.text.toString(),
            "Quantity": itemQuantityStockController.text.toString(),
            "Amount": totalStockAmount.toString()
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        searchStockList(context);
        clearStockFormFields();
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  

  void deleteItemApi(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.deleteItem}/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Item \n that is currently in use on the Purchase page!");
        } else {
          searchItemList(context: context, isFilter: false);

          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Item')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  

  Future<void> deleteStockUse(BuildContext context, int userId, int customerId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteStockUse}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Stock_Use_Master_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Stock use \n that is currently in use on the Stock use page!");
        } else {
          searchStockUseList(
              context: context, customerId: customerId.toString());
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock use deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete stock use')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> deleteStockReturn(BuildContext context, int userId, int customerId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteStockReturn}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Stock_Return_Master_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Stock return \n that is currently in use on the Stock return page!");
        } else {
          searchStockReturnList(
              context: context, customerId: customerId.toString());
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock return deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete stock use')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void setSearchCriteria(String search, String fromDate, String toDate,
      String status, String enquiryFor) {
    _search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _supplier = status;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Unable to Delete:',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> searchStockList(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getStockList);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'];
          _stockList = (dataitem as List<dynamic>)
              .map((item) => StockEntry.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> getStockUseDetails(
      {required BuildContext context, required String masterId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: "${HttpUrls.getStockUseDetails}/$masterId",
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'][0][0]['stock_use_details'] ?? [];

          print("--------- $dataitem");

          _stockUseItems = (dataitem as List<dynamic>)
              .map((item) => StockUseItems.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> getStockReturnDetails(
      {required BuildContext context, required String masterId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: "${HttpUrls.getStockreturnDetails}/$masterId",
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'][0][0]['stock_return_details'] ?? [];

          print("--------- $dataitem");

          _stockReturnItems = (dataitem as List<dynamic>)
              .map((item) => StockReturnItems.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future deleteExpense(BuildContext context, int id) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
        endPoint: "${HttpUrls.deleteExpenseManagement}/$id",
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        searchExpense('', context);
        searchExpenseController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
        Loader.stopLoader(context);

        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete expense')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<List<ExpenseModel>> searchExpense(
      String query, BuildContext context) async {
    _expenseModelList = [];
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getExpenseManagement}?Expense_Head=$query');

      if (response.statusCode == 200) {
        final data = response.data["data"];

        if (data != null) {
          _expenseModelList = (data as List<dynamic>)
              .map((item) => ExpenseModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
    return _expenseModelList;
  }

  Future<List<ExpenseModel>> getExpenseReport(BuildContext context) async {
    _expenseModelList = [];
    _expenseHeaderModel = ExpenseHeaderModel();
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userId = preferences.getString('userId') ?? "";

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              "${HttpUrls.getExpenseReport}?reference_id=$userId&from_date=$_fromDateS&to_date=$_toDateS");

      if (response.statusCode == 200) {
        final data = response.data["expense_data"];
        final headerData = response.data["header_data"] as List<dynamic>?;

        if (data != null) {
          _expenseModelList = (data as List<dynamic>)
              .map((item) => ExpenseModel.fromJson(item))
              .toList();
          notifyListeners();
        }
        if (headerData != null) {
          _expenseHeaderModel = ExpenseHeaderModel.fromJson(headerData[0]);
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
    return _expenseModelList;
  }

  void savePayment(PaymentModel paymentModel, BuildContext context) async {
    try {
      Loader.showLoader(context);

      var data = paymentModel.toJson();
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.savePayment, bodyData: data);

      if (response!.statusCode == 200) {
        final data = response.data;
        customerDetailsProvider.getPaymentListApi('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

// void savePayment(ReceiptModel paymentModel, BuildContext context) async {
  //   try {
  //     Loader.showLoader(context);
  //
  //     var data = paymentModel.toJson();
  //     final response = await HttpRequest.httpPostRequest(
  //         endPoint: HttpUrls.saveReceiptUrl, bodyData: data);
  //
  //     if (response!.statusCode == 200) {
  //       final data = response.data;
  //       searchPayment('', context);
  //       Navigator.pop(context);
  //       Loader.stopLoader(context);
  //       print(data);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Server Error')),
  //       );
  //       Loader.stopLoader(context);
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred')),
  //     );
  //     Loader.stopLoader(context);
  //   }
  // }

  // Future<List<ReceiptModel>> searchPayment(
  //     String query, BuildContext context) async {
  //   _paymentModelList = [];
  //   notifyListeners();
  //
  //   // try {
  //     final response = await HttpRequest.httpGetRequest(
  //         endPoint: '${HttpUrls.getReceiptList}?Customer_Name=$query');
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data["data"];
  //
  //       if (data != null) {
  //         _paymentModelList = (data as List<dynamic>)
  //             .map((item) => ReceiptModel.fromJson(item))
  //             .toList();
  //         notifyListeners();
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Server Error')),
  //       );
  //     }
  //   // } catch (e) {
  //   //   print('Exception occurred: $e');
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     const SnackBar(content: Text('An error occurred')),
  //   //   );
  //   // }
  //   return _paymentModelList;
  // }

  // Future deletePayment(BuildContext context, int id) async {
  //   try {
  //     Loader.showLoader(context);
  //     final response = await HttpRequest.httpPostRequest(
  //       endPoint: "${HttpUrls.deletePaymentManagement}/$id",
  //     );
  //
  //     if (response != null && response.statusCode == 200) {
  //       final data = response.data;
  //
  //       searchPayment('', context);
  //       searchPaymentController.clear();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment deleted successfully')),
  //       );
  //       Loader.stopLoader(context);
  //
  //       notifyListeners();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to delete Payment')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred')),
  //     );
  //   }
  // }
}
