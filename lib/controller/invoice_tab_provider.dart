import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/hsn_model.dart';
import 'package:vidyanexis/controller/models/invoice_print_item_model.dart';
import 'package:vidyanexis/controller/models/invoice_tab_model.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/loader.dart';

import '../http/http_urls.dart';

class InvoiceTabProvider extends ChangeNotifier {
  // invoice master
  final TextEditingController invoiceNoInvoiceController =
      TextEditingController();
  final TextEditingController invoiceDateInvoiceController =
      TextEditingController();
  final TextEditingController addressInvoiceController =
      TextEditingController();

  //invoice details
  final TextEditingController itemNameInvoiceController =
      TextEditingController();
  final TextEditingController hsnInvoiceController = TextEditingController();
  final TextEditingController quantityInvoiceController =
      TextEditingController();
  final TextEditingController priceInvoiceController = TextEditingController();
  final TextEditingController amountInvoiceController = TextEditingController();
  final TextEditingController discountInvoiceController =
      TextEditingController();
  final TextEditingController discountAmountInvoiceController =
      TextEditingController();
  final TextEditingController netValueInvoiceController =
      TextEditingController();
  final TextEditingController descriptionInvoiceController =
      TextEditingController();
  final TextEditingController cgstInvoiceController = TextEditingController();
  final TextEditingController sgstInvoiceController = TextEditingController();
  final TextEditingController gstInvoiceController = TextEditingController();
  final TextEditingController igstInvoiceController = TextEditingController();
  final TextEditingController cgstPerInvoiceController =
      TextEditingController();
  final TextEditingController sgstPerInvoiceController =
      TextEditingController();
  final TextEditingController gstPerInvoiceController = TextEditingController();
  final TextEditingController igstPerInvoiceController =
      TextEditingController();
  final TextEditingController totalAmountInvoiceController =
      TextEditingController();
  final TextEditingController quotationNoController = TextEditingController();

  final TextEditingController ewayInvoiceNoController = TextEditingController();
  final TextEditingController modeOfPaymentController = TextEditingController();
  final TextEditingController referenceNoController = TextEditingController();
  final TextEditingController buyerOrderNoController = TextEditingController();
  final TextEditingController dispatchedDocumentNoController =
      TextEditingController();
  final TextEditingController otherReferenceController =
      TextEditingController();
  final TextEditingController deliveryNoteDateController =
      TextEditingController();
  final TextEditingController datedController = TextEditingController();
  final TextEditingController dispatchedThroughController =
      TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController billOfLadingController = TextEditingController();
  final TextEditingController motorVehicleNoController =
      TextEditingController();
  final TextEditingController referenceDateController = TextEditingController();
  final TextEditingController termsOfDeliveryController =
      TextEditingController();
  int? _editItemIndex;
  final List<InvoiceItemModel> _invoiceItem = [];
  List<InvoiceItemModel> get invoiceItem => _invoiceItem;
  set invoiceItem(List<InvoiceItemModel> items) {
    _invoiceItem
      ..clear()
      ..addAll(items);
  }

  List<InvoiceTabModel> _invoiceList = [];
  List<InvoiceTabModel> get invoiceList => _invoiceList;
  List<InvoiceTabModel> _invoiceDetails = [];
  List<InvoiceTabModel> get invoiceDetails => _invoiceDetails;
  double grandTotal = 0.0;
  double totalCGST = 0.0;
  double totalSGST = 0.0;
  double totalGST = 0.0;
  double totalDiscount = 0.0;
  double totalTaxableAmount = 0.0;
  double finalGrandTotal = 0.0;
  HSNResponse? _hsnDetails;
  HSNResponse? get hsnDetails => _hsnDetails;

  List<ItemListModel> _itemListPurchase = [];
  List<ItemListModel> get itemListPurchase => _itemListPurchase;
  int? _itemId;
  int? get itemId => _itemId;
  int? _stockId;
  int? get stockId => _stockId;
  int? _invoiceDetailsId;
  int? get invoiceDetailsId => _invoiceDetailsId;
  int? _quotationNoId;
  int? get quotationNoId => _quotationNoId;

  List<InvoicePrintItemModel> _invoicePrintItems = [];
  List<InvoicePrintItemModel> get invoicePrintItems => _invoicePrintItems;

  List<GetQuotationbyMasterIdmodel> _quotaionNoData = [];
  List<GetQuotationbyMasterIdmodel> get quotaionNoData => _quotaionNoData;

  void setSelectedQuotationNoId(int id) {
    _quotationNoId = id;
    notifyListeners();
  }

  void setSelectedPurchaseItemId(int id) {
    _itemId = id;
    notifyListeners();
  }

  void setSelectedStockId(int id) {
    _stockId = id;
    notifyListeners();
  }

  void setSelectedInvoiceDetailsId(int id) {
    _invoiceDetailsId = id;
    notifyListeners();
  }

  void updateCalculations() {
    double quantity = double.tryParse(quantityInvoiceController.text) ?? 0;
    double price = double.tryParse(priceInvoiceController.text) ?? 0;
    double discountAmount =
        double.tryParse(discountInvoiceController.text) ?? 0;

    double amount = quantity * price;
    amountInvoiceController.text = amount.toStringAsFixed(2);

    double netValue = amount - discountAmount;
    netValueInvoiceController.text = netValue.toStringAsFixed(2);

    double cgstPer = (double.tryParse(gstPerInvoiceController.text) ?? 0.0) / 2;
    double sgstPer = (double.tryParse(gstPerInvoiceController.text) ?? 0.0) / 2;
    sgstPerInvoiceController.text = sgstPer.toStringAsFixed(2);
    cgstPerInvoiceController.text = cgstPer.toStringAsFixed(2);

    double cgst = (netValue * cgstPer) / 100;
    double sgst = (netValue * sgstPer) / 100;
    cgstInvoiceController.text = cgst.toStringAsFixed(2);
    sgstInvoiceController.text = sgst.toStringAsFixed(2);

    double totalGst = cgst + sgst;
    gstInvoiceController.text = totalGst.toStringAsFixed(2);

    totalAmountInvoiceController.text =
        (netValue + totalGst).toStringAsFixed(2);
  }

  void addOrUpdateInvoiceItem(InvoiceItemModel item) {
    if (_editItemIndex != null &&
        _editItemIndex! >= 0 &&
        _editItemIndex! < _invoiceItem.length) {
      // Edit existing item
      _invoiceItem[_editItemIndex!] = item;
      setSelectedInvoiceDetailsId(item.invoiceDetailsId);
    } else {
      // Add new item
      _invoiceItem.add(item);
      setSelectedInvoiceDetailsId(item.invoiceDetailsId);
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

    for (var item in _invoiceItem) {
      grandTotal += double.tryParse(item.amount) ?? 0.0;
      totalCGST += double.tryParse(item.cgstAmount) ?? 0.0;
      totalSGST += double.tryParse(item.sgstAmount) ?? 0.0;
      totalGST += double.tryParse(item.gstAmount) ?? 0.0;
      totalTaxableAmount += double.tryParse(item.taxableAmount) ?? 0.0;
      totalDiscount += double.tryParse(item.discount) ?? 0.0;
      finalGrandTotal += double.tryParse(item.totalAmount) ?? 0.0;
    }

    notifyListeners();
  }

  void editInvoiceItem(int index) {
    if (index >= 0 && index < _invoiceItem.length) {
      InvoiceItemModel item = _invoiceItem[index];
      _editItemIndex = index;

      // Populate fields with existing data
      itemNameInvoiceController.text = item.itemName;
      // _itemId = item.itemId;
      hsnInvoiceController.text = item.hsnCode;
      gstInvoiceController.text = item.gstAmount;
      cgstInvoiceController.text = item.cgstAmount;
      sgstInvoiceController.text = item.sgstAmount;
      priceInvoiceController.text = item.rate;
      quantityInvoiceController.text = item.quantity;
      amountInvoiceController.text = item.amount;
      discountInvoiceController.text = item.discount;
      discountAmountInvoiceController.text = item.discount;
      netValueInvoiceController.text = item.taxableAmount;
      totalAmountInvoiceController.text = item.totalAmount;
      _invoiceDetailsId = item.invoiceDetailsId;
      // _stockId = item.stockId;

      notifyListeners();
    }
  }

  void removeInvoiceItem(int index) {
    if (index >= 0 && index < _invoiceItem.length) {
      _invoiceItem.removeAt(index);
      calculateGrandTotal();
      notifyListeners();
    }
  }

  void resetInvoiceItems() {
    _invoiceItem.clear();
    grandTotal = 0.0;
    totalCGST = 0.0;
    totalSGST = 0.0;
    totalGST = 0.0;
    totalDiscount = 0.0;
    totalTaxableAmount = 0.0;
    finalGrandTotal = 0.0;
    notifyListeners();
  }

  void clearInvoiceItemFields() {
    itemNameInvoiceController.clear();
    cgstInvoiceController.clear();
    sgstInvoiceController.clear();
    gstInvoiceController.clear();
    priceInvoiceController.clear();
    quantityInvoiceController.clear();
    amountInvoiceController.clear();
    discountInvoiceController.clear();
    discountAmountInvoiceController.clear();
    netValueInvoiceController.clear();
    totalAmountInvoiceController.clear();
    hsnInvoiceController.clear();

    _itemId = null;
    _invoiceDetailsId = null;
    _stockId = null;
  }

  void resetInvoiceValues() {
    addressInvoiceController.clear();
    invoiceNoInvoiceController.clear();
    invoiceDateInvoiceController.clear();
    descriptionInvoiceController.clear();
    quotationNoController.clear();

    // Missing controllers added
    ewayInvoiceNoController.clear();
    modeOfPaymentController.clear();
    referenceNoController.clear();
    buyerOrderNoController.clear();
    dispatchedDocumentNoController.clear();
    otherReferenceController.clear();
    deliveryNoteDateController.clear();
    datedController.clear();
    dispatchedThroughController.clear();
    destinationController.clear();
    billOfLadingController.clear();
    motorVehicleNoController.clear();
    referenceDateController.clear();
    termsOfDeliveryController.clear();

    _quotationNoId = null;

    resetEditState();
    notifyListeners();
  }

  void resetEditState() {
    _editItemIndex = null;
    clearInvoiceItemFields();
    notifyListeners();
  }

  void saveInvoiceTab(
      {required String customerId,
      required BuildContext context,
      required var data}) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveInvoiceTab, bodyData: data);

      if (response!.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final message = data['message']?.toString() ?? "";
          final error = data['error']?.toString() ?? "";
          if (error == 'true') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.toString())),
            );
          } else {
            getInvoiceByCustomer(customerId, context);
            Navigator.pop(context);
          }
        }
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

  Future<void> getInvoiceByCustomer(
      String customerId, BuildContext context) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getInvoiceByCustomer}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _invoiceList = (data as List<dynamic>)
              .map((item) => InvoiceTabModel.fromJson(item))
              .toList();
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
    } finally {
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<void> getInvoiceDetails(
      String invoiceMasterId, BuildContext context) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getInvoiceDetails}?invoice_master_id=$invoiceMasterId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data[0];
          _invoiceDetails = (newData as List<dynamic>)
              .map((item) => InvoiceTabModel.fromJson(item))
              .toList();
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
    } finally {
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<void> deleteInvoice(
      String invoiceId, String customerId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteInvoiceTab}/$invoiceId');

      if (response != null && response.statusCode == 200) {
        print('invoice deleted successfully');

        getInvoiceByCustomer(customerId, context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Complaint')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> getHSNDetails(
      String invoiceMasterId, BuildContext context) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getHSNDetails}/$invoiceMasterId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // final newData = data[0];
          _hsnDetails = HSNResponse.fromJson(data);
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
    } finally {
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<void> getInvoicePrintItems(
      String invoiceMasterId, BuildContext context) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getInvoicePrintItems}?invoice_master_id=$invoiceMasterId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _invoicePrintItems = (data as List<dynamic>)
              .map((item) => InvoicePrintItemModel.fromJson(item))
              .toList();
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
    } finally {
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<void> searchItemListPurchase(BuildContext context) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getAllItemsInvoice);

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

  Future<void> searchQutationNo(BuildContext context, String customerId) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getQuotationDropDown}/$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'][0];
          _quotaionNoData = (dataitem as List<dynamic>)
              .map((item) => GetQuotationbyMasterIdmodel.fromJson(item))
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

  Future<void> getItemsFromQuotation(String id) async {
    try {
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getQuotationItems}/$id');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataitem = data['data'][0]['invoice_details'] ?? [];
          List<InvoiceItemModel> itemFromQuotation = (dataitem as List<dynamic>)
              .map((item) => InvoiceItemModel.fromJson(item))
              .toList();
          for (var item in itemFromQuotation) {
            addOrUpdateInvoiceItem(item);
          }
          calculateGrandTotal();

          notifyListeners();
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
