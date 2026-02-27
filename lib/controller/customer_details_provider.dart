import 'dart:developer';
import 'dart:math' as math;

import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/commercial_item_model.dart';
import 'package:vidyanexis/controller/models/get_refund_model.dart';
import 'package:vidyanexis/controller/models/maintenance_model.dart';
import 'package:vidyanexis/controller/models/quotation_type_model.dart';
import 'package:vidyanexis/controller/models/scope_of_work_model.dart';
import 'package:vidyanexis/controller/models/user_location_model.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/bill_of_material_model.dart';
import 'package:vidyanexis/controller/models/customer_invoice_model.dart';
import 'package:vidyanexis/controller/models/document_list_model.dart';

import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart'
    as ql;
import 'package:vidyanexis/controller/models/item_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/models/reciept_list_model.dart';
import 'package:vidyanexis/controller/models/serive_report_model.dart';

import 'package:vidyanexis/controller/models/service_detail_model.dart';
import 'package:vidyanexis/controller/models/solar_panel_details_model.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/controller/models/task_details_model.dart';
import 'package:vidyanexis/controller/models/task_document_model.dart';
import 'package:vidyanexis/controller/models/task_user_list_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/loader.dart';

import 'package:vidyanexis/utils/extensions.dart';

import '../http/http_urls.dart';
import 'models/production_chart_item.dart';
import 'package:vidyanexis/controller/models/payment_model.dart';
import 'package:vidyanexis/controller/models/follow_up_history_model.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/models/expense_type_model.dart';
import 'package:vidyanexis/controller/models/dashboard_task_model.dart';

class CustomerDetailsProvider extends ChangeNotifier {
  AddTaskModel addTaskModel = AddTaskModel();

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  bool get isLoading => _isLoading;

  //expense
  List<ExpenseModel> _expenseList = [];
  List<ExpenseModel> get expenseList => _expenseList;
  List<ExpenseTypeModel> _expenseTypeList = [];
  List<ExpenseTypeModel> get expenseTypeList => _expenseTypeList;
  final TextEditingController expenseDescriptionController =
      TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController expenseTypeController = TextEditingController();
  int? _selectedExpenseType;
  int? get selectedExpenseType => _selectedExpenseType;

  bool get isLoadingDetails => _isLoadingDetails;
  bool _isDeleteLoading = false;
  bool get isDeleteLoading => _isDeleteLoading;
  int? _selectedTaskType;
  int? get selectedTaskType => _selectedTaskType;
  int? _selectedAssignWorker;
  int? get selectedAssignWorker => _selectedAssignWorker;
  String _selectedAssignWorkerName = '';
  String get selectedAssignWorkerName => _selectedAssignWorkerName;
  int? _selectedServiceStatus;
  int? get selectedServiceStatus => _selectedServiceStatus;
  int? _selectedServiceTypeId;
  int? get selectedServiceTypeId => _selectedServiceTypeId;
  bool _isQuotationListLoading = false;
  bool get isQuotationListLoading => _isQuotationListLoading;
  bool _isAmcListLoading = false;
  bool get isAmcListLoading => _isAmcListLoading;
  bool _isLoadingQuotationCustomFields = false;
  bool get isLoadingQuotationCustomFields => _isLoadingQuotationCustomFields;
  List<CustomFieldByStatusId> _customFieldQuotation = [];
  List<CustomFieldByStatusId> get customFieldQuotation => _customFieldQuotation;
  String customerId = '';
  String _selectedTaskTypeName = '';

  List<LeadDetails> _leadDetails = [];
  List<LeadDetails>? get leadDetails => _leadDetails;

  List<TaskCustomerModel> _taskList = [];
  List<TaskCustomerModel> get taskList => _taskList;

  List<TaskDetails> _taskDetails = [];
  List<TaskDetails> get taskDetails => _taskDetails;

  List<TaskUserListModel> _taskUsers = [];
  List<TaskUserListModel> get taskUsers => _taskUsers;

  List<ServiceReportModel> _serviceList = [];
  List<ServiceReportModel> get serviceList => _serviceList;

  List<AmcReportModeld> _amcList = [];
  List<AmcReportModeld> get amcList => _amcList;

  List<ServiceDetailsModel> _serviceDetails = [];
  List<ServiceDetailsModel> get serviceDetails => _serviceDetails;

  List<QuatationListModel> _quotationList = [];
  List<QuatationListModel> get quotationList => _quotationList;

  List<DocumentListModel> _documentList = [];
  List<DocumentListModel> get documentList => _documentList;

  List<TaskDocumentList> _taskDocuments = [];
  List<TaskDocumentList> get taskDocuments => _taskDocuments;

  List<ql.GetQuotationbyMasterIdmodel> _quotationListByMaster = [];
  List<ql.GetQuotationbyMasterIdmodel> get quotationListByMaster =>
      _quotationListByMaster;

  List<FollowUpHistoryModel> _followUpHistory = [];
  List<FollowUpHistoryModel> get followUpHistory => _followUpHistory;
  bool _isFollowUpHistoryLoading = false;
  bool get isFollowUpHistoryLoading => _isFollowUpHistoryLoading;

  List<PaymentModel> _paymentList = [];
  List<PaymentModel> get paymentList => _paymentList;
  bool _isPaymentListLoading = false;
  bool get isPaymentListLoading => _isPaymentListLoading;

  Future<void> getPaymentListApi(
      String customerId, BuildContext context) async {
    try {
      _isPaymentListLoading = true;
      notifyListeners();
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getPaymentByCustomer}/$customerId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _paymentList = data.map((e) => PaymentModel.fromJson(e)).toList();
        } else {
          _paymentList = [];
        }
      } else {
        _paymentList = [];
      }
    } catch (e) {
      print('Exception occurred: $e');
      _paymentList = [];
    } finally {
      _isPaymentListLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePaymentApi(
      PaymentModel payment, BuildContext context) async {
    try {
      Loader.showLoader(context);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ??
          prefs.getString('UserId') ??
          prefs.getInt('user_id')?.toString() ??
          '1';
      payment.byUserId = int.tryParse(userId);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.savePayment, bodyData: payment.toJson());

      if (!context.mounted) return;
      Loader.stopLoader(context);
      if (response?.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Saved Successfully')),
        );
        getPaymentListApi(payment.customerId.toString(), context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save payment')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
      print('Exception occurred: $e');
    }
  }

  Future<void> deletePaymentApi(
      String paymentId, String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deletePayment}/$paymentId');

      if (!context.mounted) return;
      Loader.stopLoader(context);
      if (response?.statusCode == 200) {
        getPaymentListApi(customerId, context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Deleted Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete payment: ${response?.statusCode} ${response?.statusMessage}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      print('Exception occurred: $e');
    }
  }

  Future<void> getFollowUpHistory(
      String customerId, BuildContext context) async {
    try {
      _isFollowUpHistoryLoading = true;
      notifyListeners();
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.followUpHistory}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _followUpHistory =
              data.map((e) => FollowUpHistoryModel.fromJson(e)).toList();
        } else {
          _followUpHistory = [];
        }
      } else {
        _followUpHistory = [];
      }
    } catch (e) {
      print('Exception occurred: $e');
      _followUpHistory = [];
    } finally {
      _isFollowUpHistoryLoading = false;
      notifyListeners();
    }
  }

  String? _selectedStockStatus;
  String? get selectedStockStatus => _selectedStockStatus;
  String? _selectedStockStatusName;
  String? get selectedStockStatusName => _selectedStockStatusName;

//task
  final TextEditingController taskChoosedateController =
      TextEditingController();
  final TextEditingController taskChoosetimeController =
      TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController taskTypeController = TextEditingController();
  final TextEditingController amcStatusNameController = TextEditingController();

  //service
  final TextEditingController serviceTypeController = TextEditingController();
  final TextEditingController serviceStatusNameController =
      TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController serviceAmountController = TextEditingController();
  //amc
  final TextEditingController amcProductNameController =
      TextEditingController();
  final TextEditingController amcServiceController = TextEditingController();
  final TextEditingController amcDescriptionController =
      TextEditingController();

  final TextEditingController amcAmountController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController amcTotalDurationController =
      TextEditingController();
  final TextEditingController amcPeriodIntervalController =
      TextEditingController();
  final TextEditingController amcCategoryController = TextEditingController();

  int? _selectedAMCStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? _selectedAMCCategory;
  int? get selectedAMCCategory => _selectedAMCCategory;
  String? _selectedAMCStatusName;
  String? get selectedAMCStatusName => _selectedAMCStatusName;
  List<MaintenanceDate> _maintenanceDates = [];
  List<MaintenanceDate> get maintenanceDates => _maintenanceDates;
  int _monthInterval = 0;
  int _yearInterval = 0;
  int get monthInterval => _monthInterval;
  int get yearInterval => _yearInterval;

  //quotations
  final TextEditingController qproductnameController = TextEditingController();
  final TextEditingController qsubsidyAmountController =
      TextEditingController(text: '0');

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final TextEditingController itemMrpController = TextEditingController();
  final TextEditingController itemTotalController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemGstController = TextEditingController();
  final TextEditingController itemGstPercentController =
      TextEditingController(text: '18');
  final TextEditingController itemAdCessController = TextEditingController();
  final TextEditingController itemUnitController = TextEditingController();
  final TextEditingController gstTaxableAmountController =
      TextEditingController();
  final TextEditingController cgstTaxableAmountController =
      TextEditingController();
  final TextEditingController sgstTaxableAmountController =
      TextEditingController();
  final TextEditingController totalGstAmountController =
      TextEditingController();
  final TextEditingController totalCgstAmountController =
      TextEditingController();
  final TextEditingController totalSgstAmountController =
      TextEditingController();
  final TextEditingController totalGstPerController = TextEditingController();
  final TextEditingController totalCgstPerController = TextEditingController();
  final TextEditingController totalSgstPerController = TextEditingController();
  final TextEditingController totalAdCESSController = TextEditingController();
  final TextEditingController shippingChargesController =
      TextEditingController(text: '0');
  TextEditingController subtotalController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  final TextEditingController qtermsConditionsController =
      TextEditingController();
  final TextEditingController qwarrentyController = TextEditingController();
  final TextEditingController billdescriptionController =
      TextEditingController();
  final TextEditingController billmakeController = TextEditingController();
  final TextEditingController billquantityController = TextEditingController();
  final TextEditingController billdistributorController =
      TextEditingController();
  final TextEditingController billinvoiceController = TextEditingController();
  TextEditingController quotationStatusController = TextEditingController();
  TextEditingController systemPriceController = TextEditingController();
  TextEditingController additionalStructureController = TextEditingController();
  TextEditingController feasibilityFeeController = TextEditingController();
  TextEditingController registrationFeeController = TextEditingController();

  List<QuotationTypeModel> _quotationTypeData = [];
  List<QuotationTypeModel> get quotationTypeData => _quotationTypeData;
  set quotationTypeData(List<QuotationTypeModel> value) {
    _quotationTypeData = value;
    notifyListeners();
  }

  TextEditingController quotationTypeController = TextEditingController();
  int _selectedQuotationType = 0;
  int get selectedQuotationType => _selectedQuotationType;
  set selectedQuotationType(int value) {
    _selectedQuotationType = value;
    notifyListeners();
  }

  final TextEditingController quotationDescriptionController =
      TextEditingController();
  final TextEditingController quotationDescription2Controller =
      TextEditingController();
  final TextEditingController quotationDescription3Controller =
      TextEditingController();

  int? _selectedBranchId;
  int? get selectedBranchId => _selectedBranchId;
  set selectedBranchId(int? value) {
    _selectedBranchId = value;
    notifyListeners();
  }

  //commercial
  TextEditingController commercialDescriptionController =
      TextEditingController();
  TextEditingController commercialDCCapacityController =
      TextEditingController();
  TextEditingController commercialACCapacityController =
      TextEditingController();
  TextEditingController commercialUnitPriceController = TextEditingController();
  TextEditingController commercialTotalController = TextEditingController();
  List<CommercialItemModel> _commercialItems = [];
  List<CommercialItemModel> get commercialItems => _commercialItems;
  set commercialItems(List<CommercialItemModel> value) {
    _commercialItems = value;
    notifyListeners();
  }

  int? _editCommercialIndex;
  int? get editCommercialIndex => _editCommercialIndex;

  void setEditCommercialItemIndex(int? index) {
    _editCommercialIndex = index;
    notifyListeners();
  }

  //scope of work
  TextEditingController designAndEngineeringController =
      TextEditingController();
  TextEditingController a3SScopeController = TextEditingController();
  TextEditingController clientScopeController = TextEditingController();
  List<ScopeOfWorkModel> _scopeOfWorkItems = [];
  List<ScopeOfWorkModel> get scopeOfWorkItems => _scopeOfWorkItems;
  set scopeOfWorkItems(List<ScopeOfWorkModel> value) {
    _scopeOfWorkItems = value;
    notifyListeners();
  }

  int? _editScopeOfWorkIndex;
  int? get editScopeOfWorkIndex => _editScopeOfWorkIndex;

  void setEditScopeOfWorkItemIndex(int? index) {
    _editScopeOfWorkIndex = index;
    notifyListeners();
  }

  //cableDetails
  final TextEditingController cableStructureController =
      TextEditingController();
  final TextEditingController cableTypeController = TextEditingController();
  final TextEditingController cableShortCircuitTempController =
      TextEditingController();
  final TextEditingController cableStandardController = TextEditingController();
  final TextEditingController cableConductorClassController =
      TextEditingController();
  final TextEditingController cableMaterialController = TextEditingController();
  final TextEditingController cableProtectionController =
      TextEditingController();
  final TextEditingController cableWarrantyController = TextEditingController();
  final TextEditingController cableTensileStrengthController =
      TextEditingController();

  //solarPV
  final TextEditingController plantCapacityController = TextEditingController();
  final TextEditingController moduleTechnologiesController =
      TextEditingController();
  final TextEditingController mountingStructureTechnologiesController =
      TextEditingController();
  final TextEditingController projectSchemeController = TextEditingController();
  final TextEditingController powerEvacuationController =
      TextEditingController();
  final TextEditingController areaApproximateController =
      TextEditingController();
  final TextEditingController solarPlantOutputConnectionController =
      TextEditingController();
  final TextEditingController schemeController = TextEditingController();

//financial controllers
  final TextEditingController qvalidityController = TextEditingController();
  final TextEditingController qtendorNumberController = TextEditingController();
  final TextEditingController paymentTermsController = TextEditingController();
  final TextEditingController incoTermsController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController deliveryController = TextEditingController();
  final TextEditingController workCompletionController =
      TextEditingController();
//production Chart
  final TextEditingController unitProductionChartController =
      TextEditingController();
  final TextEditingController dailyController = TextEditingController();
  final TextEditingController monthlyController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  int? _selectedQuotationStatus;
  int? get selectedQuotationStatus => _selectedQuotationStatus;
  String? _selectedQuotationStatusName;
  String? get selectedQuotationStatusName => _selectedQuotationStatusName;

  //profile
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController maplinkController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  List<BillOfMaterialItem> _bomItems = [];
  List<BillOfMaterialItem> get bomItems => _bomItems;

  List<ProductionChartItem> _productionItems = [];
  List<ProductionChartItem> get productionItems => _productionItems;
  List<Item> _items = [];
  List<Item> get items => _items;
  int? _editIndex;
  int? get editIndex => _editIndex;
  int? _editBomIndex;
  int? _editProductionIndex;

  int? _totalAmount;
  int get totalAmount => _totalAmount ?? 0;
  int? get editBomIndex => _editBomIndex;
  int? get editProductionIndex => _editProductionIndex;

  ScrollController imageScrollController = ScrollController();
  ScrollController imageScrollControllerList = ScrollController();
  ScrollController taskScrollController = ScrollController();
  ScrollController taskScrollControllerList = ScrollController();

  //refund
  final TextEditingController electricalsectioncontroller =
      TextEditingController();
  final TextEditingController electricalsectionplacecontroller =
      TextEditingController();
  final TextEditingController consumernumbercontroller =
      TextEditingController();
  final TextEditingController kwcapacitycontroller = TextEditingController();
  final TextEditingController accountnamecontroller = TextEditingController();
  final TextEditingController accountnumbercontroller = TextEditingController();
  final TextEditingController banknamecontroller = TextEditingController();
  final TextEditingController ifsccontroller = TextEditingController();
  final TextEditingController refundamountcontroller = TextEditingController();
  final TextEditingController reasoncontroller = TextEditingController();

  List<RefundData> _refundList = [];
  List<RefundData> get refundList => _refundList;

  //reciept
  List<ReceiptListModel> _receiptList = [];
  List<ReceiptListModel> get receiptList => _receiptList;
  final TextEditingController recieptDescriptionController =
      TextEditingController();
  final TextEditingController recieptAmountController = TextEditingController();

  //payment
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController();
  final TextEditingController paymentModeController = TextEditingController();
  final TextEditingController paymentDescriptionController =
      TextEditingController();

  //invoice
  List<CustomerInvoice> _invoiceList = [];
  List<CustomerInvoice> get invoiceList => _invoiceList;
  final TextEditingController invoiceDescriptionController =
      TextEditingController();
  final TextEditingController invoiceAmountController = TextEditingController();

  String invoiceTotal = '';
  String recieptTotal = '';
  String balanceTotal = '';

  //job sheet
  List<SolarPanelDetails> _formDetails = [];
  List<SolarPanelDetails> get formDetails => _formDetails;

  set monthInterval(int value) {
    _monthInterval = value;
  }

  set yearInterval(int value) {
    _yearInterval = value;
  }

  // Task Overview Tab Data
  List<Department> _customerTaskDepartments = [];
  List<Department> get customerTaskDepartments => _customerTaskDepartments;
  bool _isTaskOverviewLoading = false;
  bool get isTaskOverviewLoading => _isTaskOverviewLoading;

  Future<void> getCustomerTaskOverview(String customerId) async {
    try {
      _isTaskOverviewLoading = true;
      notifyListeners();

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.getTaskByCustomer,
        bodyData: {
          "Customer_Id": customerId,
        },
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          final List<TaskCustomerModel> tasks =
              data.map((e) => TaskCustomerModel.fromJson(e)).toList();

          // Aggregate tasks by Type
          Map<String, int> taskTypeCounts = {};
          for (var task in tasks) {
            final typeName = task.taskTypeName;
            taskTypeCounts[typeName] = (taskTypeCounts[typeName] ?? 0) + 1;
          }

          List<Task> overviewTasks = [];
          taskTypeCounts.forEach((key, value) {
            overviewTasks.add(Task(
              taskTypeName: key,
              subTaskCount: value,
              taskTypeId: 0, // Not strictly needed for display
            ));
          });

          // Create a single "Overview" department for this customer
          _customerTaskDepartments = [
            Department(
              departmentName: 'Task Summary',
              taskCount: tasks.length,
              tasks: overviewTasks,
            )
          ];
        } else {
          _customerTaskDepartments = [];
        }
      } else {
        _customerTaskDepartments = [];
      }
    } catch (e) {
      print('Exception occurred in getCustomerTaskOverview: $e');
      _customerTaskDepartments = [];
    } finally {
      _isTaskOverviewLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCustomFieldsByQuotationId(BuildContext context) async {
    try {
      _isLoadingQuotationCustomFields = true;
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getCustomFieldQuotation}');

      if (response.statusCode == 200) {
        _isLoadingQuotationCustomFields = false;

        final data = response.data;
        print('Custom fields by quotation ID: ${data}');
        if (data != null && data.isNotEmpty) {
          _customFieldQuotation = (data as List<dynamic>)
              .map((e) => CustomFieldByStatusId.fromJson(e))
              .toList();
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred')));
    } finally {
      _isLoadingQuotationCustomFields = false;
      notifyListeners();
    }
  }

  set selectedExpenseType(int? value) {
    _selectedExpenseType = value;
    notifyListeners();
  }

  void updateAMCCategory(int? value, String categoryName) {
    _selectedAMCCategory = value;
    amcCategoryController.text = categoryName;
    notifyListeners();
  }

  void updateStockStatus(String value) {
    _selectedStockStatus = value;
    print(_selectedStockStatus);
    notifyListeners();
  }

  Future<void> getExpenseListApi(
      String customerId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getExpenseByCustomer}/$customerId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _expenseList = data.map((e) => ExpenseModel.fromJson(e)).toList();
        } else {
          _expenseList = [];
        }
      } else {
        _expenseList = [];
      }
      notifyListeners();
    } catch (e) {
      print('Exception occurred: $e');
      _expenseList = [];
      notifyListeners();
    }
  }

  Future<void> getExpenseTypeApi(BuildContext context) async {
    try {
      // Matches logic in SettingsProvider
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getExpenseTypes}?Expense_Type_Name=');
      if (response.statusCode == 200) {
        final data = response.data["data"];
        if (data != null &&
            data is List &&
            data.isNotEmpty &&
            data[0] is List) {
          List<dynamic> expenseDataList = data[0];
          _expenseTypeList =
              expenseDataList.map((e) => ExpenseTypeModel.fromJson(e)).toList();
        } else {
          _expenseTypeList = [];
        }
      } else {
        _expenseTypeList = [];
      }
      notifyListeners();
    } catch (e) {
      print('Exception occurred: $e');
      _expenseTypeList = [];
      notifyListeners();
    }
  }

  Future<void> saveExpenseApi(
      String expenseId, String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      Loader.showLoader(context);
      // final prefs = await SharedPreferences.getInstance();
      // final userId = prefs.getString('user_id') ??
      //     prefs.getString('UserId') ??
      //     prefs.getInt('user_id')?.toString() ??
      //     '1';

      if (_selectedExpenseType == null) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expense type')),
        );
        return;
      }

      // Find the selected expense type name
      String expenseTypeName = '';
      try {
        expenseTypeName = _expenseTypeList
                .firstWhere(
                    (element) => element.expenseTypeId == _selectedExpenseType)
                .expenseTypeName ??
            '';
      } catch (e) {
        print('Error finding expense type name: $e');
      }

      final body = {
        "Expense_Id": expenseId == 'null' ? 0 : int.parse(expenseId),
        "Expense_Type_Id": selectedExpenseType,
        "Customer_Id": int.tryParse(customerId),
        "Expense_Type_Name": expenseTypeName,
        "Date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "Amount": double.tryParse(expenseAmountController.text) ?? 0,
        "Description": expenseDescriptionController.text,
      };

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveExpense, bodyData: body);

      if (!context.mounted) return;
      Loader.stopLoader(context);
      if (response?.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Saved Successfully')),
        );
        getExpenseListApi(customerId, context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save expense')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
      print('Exception occurred: $e');
    }
  }

  Future<void> deleteExpenseApi(
      String expenseId, String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      // Parse expenseId to int, default to 0 if parsing fails
      final expenseIdInt = int.tryParse(expenseId) ?? 0;

      final response = await HttpRequest.httpDeleteRequest(
        endPoint: HttpUrls.deleteExpense,
        bodyData: {"Expense_Id": expenseIdInt},
      );

      if (!context.mounted) return;
      Loader.stopLoader(context);
      if (response?.statusCode == 200) {
        getExpenseListApi(customerId, context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense Deleted Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete expense: ${response?.statusCode} ${response?.statusMessage}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      print('Exception occurred: $e');
    }
  }

  Future<void> getExpenseByIdApi(String expenseId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getExpenseById}/$expenseId');
      if (response.statusCode == 200) {
        var data = response.data;
        ExpenseModel? expense;

        if (data is List && data.isNotEmpty) {
          expense = ExpenseModel.fromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') &&
              data['data'] is List &&
              (data['data'] as List).isNotEmpty) {
            expense = ExpenseModel.fromJson(data['data'][0]);
          } else {
            // Direct Map response
            try {
              expense = ExpenseModel.fromJson(data);
            } catch (e) {
              print('Error parsing direct map: $e');
            }
          }
        }

        if (expense != null) {
          // Populate form fields
          expenseAmountController.text = expense.amount?.toString() ?? '';
          expenseDescriptionController.text = expense.description ?? '';
          _selectedExpenseType = expense.expenseTypeId;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Exception occurred in getExpenseByIdApi: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load expense details')),
        );
      }
    }
  }

  void clearExpenseDetails() {
    expenseAmountController.clear();
    expenseDescriptionController.clear();
    expenseTypeController.clear();
    _selectedExpenseType = null;
    notifyListeners();
  }

  set selectedQuotationStatus(int? value) {
    // Add any necessary validation or logic here
    if (_selectedQuotationStatus != value) {
      _selectedQuotationStatus = value;
      // If you're using a state management solution like Provider, call notifyListeners()
      // Example: notifyListeners();
    }
  }

  set selectedQuotationStatusName(String? value) {
    // Add any necessary validation or logic here
    if (_selectedQuotationStatusName != value) {
      _selectedQuotationStatusName = value;
      // Notify listeners if using Provider or any other state management solution
      // Example: notifyListeners();
    }
  }

  set maintenanceDates(List<MaintenanceDate> newDates) {
    _maintenanceDates = List.from(newDates);
  }

  updateTotalAmount(int total) {
    _totalAmount = total;
    notifyListeners();
  }

  void setEditItemIndex(int? index) {
    _editIndex = index;
    notifyListeners();
  }

  void setEditBomIndex(int? index) {
    _editBomIndex = index;
    notifyListeners();
  }

  void setProductionIndex(int? index) {
    _editProductionIndex = index;
    notifyListeners();
  }

  void addOrEditItem(BuildContext context) {
    // Validate input fields
    if (itemNameController.text.isEmpty || itemPriceController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.appViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Missing Details',
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
      return;
    }

    calculateTotalAmount();

    // Create the new item
    final unitPrice = double.tryParse(itemPriceController.text) ?? 0.0;
    final mrp = itemMrpController.text;
    final gstPercent = double.tryParse(itemGstPercentController.text) ?? 0.0;
    final adCess = double.tryParse(itemAdCessController.text) ?? 0.0;
    final gst = double.tryParse(itemGstController.text) ?? 0.0;
    final quantity = int.tryParse(itemQuantityController.text) ?? 1;
    final amount = double.tryParse(itemTotalController.text) ?? 0.0;

    final newItem = Item(
      ItemName: itemNameController.text,
      UnitPrice: unitPrice,
      Quantity: quantity,
      MRP: mrp,
      GST: gst,
      GSTPercent: gstPercent,
      AdCESS: adCess,
      Unit: itemUnitController.text,
      Amount: amount,
    );

    if (_editIndex != null && _editIndex! >= 0 && _editIndex! < _items.length) {
      // Edit existing item
      _items[_editIndex!] = newItem;
    } else {
      // Add new item
      _items.add(newItem);
    }

    // Clear the text fields
    _editIndex = null;
    updateSubtotal();
    clearItemFields();
    notifyListeners(); // Trigger UI updates
  }

  void updateSubtotal() {
    double total = items.fold(0.0, (total, item) => total + item.Amount);
    subtotalController.text =
        total.toStringAsFixed(2); // Update controller with formatted subtotal

    // Calculate total GST amount and GST percent
    final gstAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + item.GST,
    );

    double totalGstPerc = items.fold<double>(
      0.0,
      (sum, item) => sum + item.GSTPercent,
    );
    final gstPerc = items.isNotEmpty ? totalGstPerc / items.length : 0.0;

    final taxableAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + ((item.UnitPrice) * (item.Quantity)),
    );
    final adCess = items.fold<double>(
      0.0,
      (sum, item) => sum + item.AdCESS,
    );

    gstTaxableAmountController.text = taxableAmount.toStringAsFixed(2);
    cgstTaxableAmountController.text = (taxableAmount / 2).toStringAsFixed(2);
    sgstTaxableAmountController.text = (taxableAmount / 2).toStringAsFixed(2);
    totalGstAmountController.text = gstAmount.toStringAsFixed(2);
    totalCgstAmountController.text = (gstAmount / 2).toStringAsFixed(2);
    totalSgstAmountController.text = (gstAmount / 2).toStringAsFixed(2);
    totalGstPerController.text = gstPerc.toStringAsFixed(2);
    totalCgstPerController.text = (gstPerc / 2).toStringAsFixed(2);
    totalSgstPerController.text = (gstPerc / 2).toStringAsFixed(2);
    totalAdCESSController.text = adCess.toStringAsFixed(2);
    updateTotal();
    notifyListeners();
  }

  void updateTotal() {
    double total = 0;

    final subtotal = double.tryParse(subtotalController.text);
    final subsidy = double.tryParse(qsubsidyAmountController.text);
    final shippingCharges =
        double.tryParse(shippingChargesController.text) ?? 0.0;

    if (subtotal != null && subsidy != null) {
      total = subtotal - subsidy + shippingCharges;
    } else {
      print("Invalid input for price or quantity");
    }
    totalController.text =
        total.toStringAsFixed(2); // Update controller with formatted subtotal
    notifyListeners();
  }

  // Common function to calculate total amount
  void calculateTotalAmount() {
    final unitPrice = double.tryParse(itemPriceController.text) ?? 0.0;
    final quantity = int.tryParse(itemQuantityController.text) ?? 1;
    final gstPercent = double.tryParse(itemGstPercentController.text) ?? 0.0;
    final otherTax = double.tryParse(itemAdCessController.text) ?? 0.0;

    // GST should be calculated on the total price (unitPrice * quantity)
    final gst = ((unitPrice * quantity) * gstPercent) / 100;
    itemGstController.text = gst.toStringAsFixed(2);

    final total = (unitPrice * quantity) + gst + otherTax;
    itemTotalController.text = total.toStringAsFixed(2);
  }

  void clearItemFields() {
    itemNameController.clear();
    itemPriceController.clear();
    itemQuantityController.clear();
    itemMrpController.clear();
    itemTotalController.clear();
    itemGstController.clear();
    itemGstPercentController.text = '18';
    itemAdCessController.clear();
    itemUnitController.clear();
    _totalAmount = 0;
    notifyListeners();
  }

  void populateItemFieldsForEditing(int index) {
    // Populate text fields with existing item's data for editing
    if (index >= 0 && index < _items.length) {
      final itemToEdit = _items[index];

      itemNameController.text = itemToEdit.ItemName;
      itemPriceController.text = itemToEdit.UnitPrice.toString();
      itemQuantityController.text = itemToEdit.Quantity.toString();
      itemMrpController.text = itemToEdit.MRP.toString();
      itemGstPercentController.text = itemToEdit.GSTPercent.toString();
      itemAdCessController.text = itemToEdit.AdCESS.toString();
      itemUnitController.text = itemToEdit.Unit;
      itemGstController.text = itemToEdit.GST.toString();

      calculateTotalAmount();
      _totalAmount = itemToEdit.Amount.toInt();
      setEditItemIndex(index);
      notifyListeners();
    }
  }

  void deleteItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      updateSubtotal();
      notifyListeners();
    }
  }

  double getTotalAmount() {
    double total = 0.0;
    for (var item in _items) {
      total += item.Amount;
    }
    return total;
  }

  void addOrEditBOMItem() {
    // Validate input fields
    // if (billdescriptionController.text.isEmpty ||
    //     billmakeController.text.isEmpty ||
    //     billquantityController.text.isEmpty ||
    //     billdistributorController.text.isEmpty ||
    //     billinvoiceController.text.isEmpty) {
    //   return;
    // }

    // Create the BOM item
    final newBOMItem = BillOfMaterialItem(
      itemsAndDescription: billdescriptionController.text,
      make: billmakeController.text,
      quantity: int.tryParse(billquantityController.text) ?? 0,
      distributor: billdistributorController.text,
      invoiceNo: billinvoiceController.text,
    );

    // Check if we're editing an existing item or adding a new one
    if (editBomIndex != null &&
        editBomIndex! >= 0 &&
        editBomIndex! < _bomItems.length) {
      // Edit existing item
      _bomItems[editBomIndex!] = newBOMItem;
    } else {
      // Add new item
      _bomItems.add(newBOMItem);
    }

    // Clear the text fields
    _editBomIndex = null;
    clearBOMFields();
    notifyListeners();
  }

  void addOrEditProductionChart() {
    // Validate input fields
    if (unitProductionChartController.text.isEmpty ||
        dailyController.text.isEmpty ||
        monthlyController.text.isEmpty ||
        remarksController.text.isEmpty) {
      return;
    }

    // Create the BOM item
    final newProductionItem = ProductionChartItem(
      unitProduction: unitProductionChartController.text,
      dailyTotal: dailyController.text,
      monthlyTotal: monthlyController.text,
      remark: remarksController.text,
    );

    // Check if we're editing an existing item or adding a new one
    if (editProductionIndex != null &&
        editProductionIndex! >= 0 &&
        editProductionIndex! < _productionItems.length) {
      // Edit existing item
      _productionItems[editProductionIndex!] = newProductionItem;
    } else {
      // Add new item
      _productionItems.add(newProductionItem);
    }

    // Clear the text fields
    _editProductionIndex = null;
    clearProductionFieldsFields();
    notifyListeners();
  }

  void clearProductionFieldsFields() {
    unitProductionChartController.clear();
    dailyController.clear();
    monthlyController.clear();
    remarksController.clear();
    notifyListeners();
  }

  void clearBOMFields() {
    billdescriptionController.clear();
    billmakeController.clear();
    billquantityController.clear();
    billdistributorController.clear();
    billinvoiceController.clear();
    notifyListeners();
  }

  void populateProductionFieldsForEditing(int index) {
    // Populate text fields with existing item's data for editing
    if (index >= 0 && index < _productionItems.length) {
      final itemToEdit = _productionItems[index];

      dailyController.text = itemToEdit.dailyTotal;
      monthlyController.text = itemToEdit.monthlyTotal;
      remarksController.text = itemToEdit.remark.toString();
      unitProductionChartController.text = itemToEdit.unitProduction;

      setProductionIndex(index);
      notifyListeners();
    }
  }

  void populateBOMFieldsForEditing(int index) {
    // Populate text fields with existing item's data for editing
    if (index >= 0 && index < _bomItems.length) {
      final itemToEdit = _bomItems[index];

      billdescriptionController.text = itemToEdit.itemsAndDescription;
      billmakeController.text = itemToEdit.make;
      billquantityController.text = itemToEdit.quantity.toString();
      billdistributorController.text = itemToEdit.distributor;
      billinvoiceController.text = itemToEdit.invoiceNo;
      setEditBomIndex(index);
      notifyListeners();
    }
  }

  void deleteProduction(int index) {
    if (index >= 0 && index < _productionItems.length) {
      _productionItems.removeAt(index);
      notifyListeners();
    }
  }

  void deleteBOMItem(int index) {
    if (index >= 0 && index < _bomItems.length) {
      _bomItems.removeAt(index);
      notifyListeners();
    }
  }

  //

  void clearAmcControllers() {
    fromDateController.clear();
    toDateController.clear();
    amcAmountController.clear();
    amcDescriptionController.clear();
    amcServiceController.clear();
    amcProductNameController.clear();
  }

  void updateTaskType(int value, String taskTypeName) {
    _selectedTaskType = value;
    _selectedTaskTypeName = taskTypeName;
    print(_selectedTaskType);
    notifyListeners();
  }

  void updateAMCStatus(int value, String amcStatusName) {
    _selectedAMCStatus = value;
    _selectedAMCStatusName = amcStatusName;
    print(_selectedAMCStatus);
    notifyListeners();
  }

  void updateQuotationStatus(int value) {
    _selectedQuotationStatus = value;
    // _selectedQuotationStatusName = quotationStatusName;
    if (value == 1) {
      _selectedQuotationStatusName = "Pending";
    } else if (value == 2) {
      _selectedQuotationStatusName = "Approved";
    } else if (value == 3) {
      _selectedQuotationStatusName = "Rejected";
    }
    print(_selectedQuotationStatusName);
    notifyListeners();
  }

  void updateAssignWorker(int value, DropDownProvider dropDownProvider) {
    _selectedAssignWorkerName = dropDownProvider.searchUserDetails
        .firstWhere((status) => status.userDetailsId == value)
        .userDetailsName!;
    // _selectedAssignWorker = value;
    bool userExists = false;
    print('1');
    addTaskModel.taskUser ??= [];

    print('2');
    userExists = addTaskModel.taskUser!
        .any((taskUser) => taskUser.userDetailsId == value);

    print(_selectedAssignWorker);

    print(addTaskModel.taskUser);
    if (!userExists) {
      print('3');
      addTaskModel.taskUser?.add(UserInTaskModel(
          userDetailsId: value, userDetailsName: _selectedAssignWorkerName));
    }
    print(addTaskModel.taskUser);
    notifyListeners();
  }

  void updateTaskUser(List<TaskUserListModel> taskUsers) {
    if (taskUsers.isNotEmpty) {
      // Ensure addTaskModel.taskUser is initialized
      addTaskModel.taskUser ??= [];

      // Add all TaskUser objects to addTaskModel.taskUser
      for (var taskUser in taskUsers) {
        addTaskModel.taskUser!.add(UserInTaskModel(
          userDetailsId: taskUser.toUserId,
          userDetailsName: taskUser.userDetailsName,
        ));
      }

      print('All users added to addTaskModel.taskUser.');
    } else {
      print('No users available to add.');
    }
    notifyListeners(); // Notify listeners about the change
  }

  void updateServiceStatus(int value) {
    if (value == 1) {
      serviceStatusNameController.text = "Pending";
    } else if (value == 2) {
      serviceStatusNameController.text = "Completed";
    }
    // else if (value == 3) {
    //   serviceTypeController.text = "Completed";
    // }
    _selectedServiceStatus = value;
    print(_selectedServiceStatus);
    notifyListeners();
  }

  void updateServiceTypeId(int value) {
    if (value == 1) {
      serviceTypeController.text = "Paid";
    } else if (value == 2) {
      serviceTypeController.text = "Free";
    }
    _selectedServiceTypeId = value;
    print(_selectedServiceTypeId);
    notifyListeners();
  }

  // Method to fetch search leads
  Future<void> fetchLeadDetails(String customerId, BuildContext context) async {
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.leadDetails}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _leadDetails = (data as List<dynamic>)
              .map((item) => LeadDetails.fromJson(item))
              .toList();
        }
      } else {
        throw Exception('Failed to load lead details');
      }
    } catch (error) {
      print('Exception occurred: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  getTaskList(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getTaskByCustomer}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          print(data.toString());

          _taskList = (data as List<dynamic>)
              .map((item) => TaskCustomerModel.fromJson(item))
              .toList();
          notifyListeners(); // Notify listeners to rebuild with fetched data
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  getTaskDetails(String taskId, BuildContext context) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getTaskDetails}/$taskId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _taskDetails = [TaskDetails.fromJson(data)];
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
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  saveTask(
    String taskId,
    String taskType,
    String description,
    String date,
    String time,
    String assignedWorker,
    BuildContext context,
    bool isEdit,
    List<Map<String, String>>? audioFiles, // Add this parameter
  ) async {
    print(taskType);
    print(description);
    print(date);
    print(time);
    print(assignedWorker);
    print(customerId);
    try {
      if (date.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(date);
        } catch (e) {
          parsedDate = DateTime.parse(date);
        }
        date = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        date = '';
      }
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";
      // Add this before setting addTaskModel properties:
      if (audioFiles != null && audioFiles.isNotEmpty) {
        addTaskModel.taskFiles = audioFiles
            .map((file) => TaskFile(
                  filePath: file['File_Path'],
                  fileName: file['File_Name'],
                  fileType: file['File_Type'],
                ))
            .toList();
      }
      addTaskModel.taskMasterId = int.parse(taskId);
      addTaskModel.taskStatusId = _selectedAMCStatus ?? 1;
      addTaskModel.taskStatusName = _selectedAMCStatusName ?? 'Not Started';
      addTaskModel.customerId = int.parse(customerId);
      addTaskModel.createdBy = int.parse(userId);
      addTaskModel.taskDate = DateTime.parse(date);
      addTaskModel.taskTypeId = int.parse(taskType);
      addTaskModel.taskTypeName = _selectedTaskTypeName.toString();
      addTaskModel.description = description.toString();
      addTaskModel.taskTime = DateFormat('HH:mm').format(DateTime.now());
      addTaskModel.completionDate = "";
      addTaskModel.completionTime = "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveTask, bodyData: addTaskModel.toJson()
          // {
          //   "Task_Id": taskId,
          //   "Task_Status_Id": _selectedAMCStatus ?? 1,
          //   "Task_Status_Name": _selectedAMCStatusName ?? 'Not Started',
          //   // "To_User_Id": assignedWorker,
          //   "Task_user": addTaskModel.taskUser,
          //   "Customer_Id": customerId,
          //   "Created_By": userId,
          //   "Task_Date": date,
          //   "Task_Type_Id": taskType,
          //   "Task_Type_Name": _selectedTaskTypeName.toString(),
          //   "Description": description,
          //   "Task_Time": time,
          //   "Completion_Date": "",
          //   "Completion_Time": ""
          // },
          );

      if (response!.statusCode == 200) {
        final data = response.data;
        print('Success');

        // _selectedTaskType = null;
        // _selectedAssignWorker = null;
        // _selectedAssignWorkerName = '';
        // taskDescriptionController.clear();
        // taskChoosedateController.clear();
        // taskChoosetimeController.clear();
        clearTaskDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getTaskList(customerId, context);
        if (isEdit) {
          getTaskDetails(taskId, context);
        }
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

  getServiceList(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getServiceByCustomer}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _serviceList = (data as List<dynamic>)
              .map((item) => ServiceReportModel.fromJson(item))
              .toList();
          notifyListeners(); // Notify listeners to rebuild with fetched data
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  getServiceDetails(String serviceId, BuildContext context) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getServiceDetails}/$serviceId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // var listData = data[0];
          // print(listData);

          // _serviceDetails = (listData as List)
          //     .map((item) => ServiceDetailsModel.fromJson(item))
          //     .toList();
          _serviceDetails = [ServiceDetailsModel.fromJson(data)];

          // // Check if data is a List and map it to TaskDetails objects
          // if (data is List) {
          //   _taskDetails =
          //       data.map((item) => TaskDetails.fromJson(item)).toList();
          // } else if (data is Map) {
          //   // Handle Map data if needed
          //   if (data['task_notes'] != null && data['task_notes'] is List) {
          //     var taskNotesList = data['task_notes'] as List<dynamic>;
          //     _taskDetails = taskNotesList
          //         .map((item) => TaskDetails.fromJson(item))
          //         .toList();
          //   }
          // }
          notifyListeners();
          // Notify listeners to update the UI
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
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void saveService(
      String serviceId,
      String customerId,
      String description,
      String serviceType,
      String service,
      BuildContext context,
      bool isEdit) async {
    print(description);
    print(customerId);
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      if (serviceStatusNameController.text.isEmpty) {
        serviceStatusNameController.text = "Pending";
      }

      String amount = serviceAmountController.text.toString();
      if (amount.isEmpty) {
        amount = '0';
      }
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveService,
        bodyData: {
          "Service_Id": serviceId,
          "Service_Name": service,
          "Service_Type_Id": selectedServiceTypeId,
          "Service_Type_Name": serviceType,
          // "Create_Date": "",
          "Service_Date": "",
          "Amount": amount,
          "Description": description,
          "Service_Status_Id": _selectedServiceStatus ?? 1,
          "Service_Status_Name": serviceStatusNameController.text.toString(),
          "Assigned_To": 0,
          "Created_By": userId,
          "Customer_Id": customerId
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        clearServiceDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getServiceList(customerId, context);
        if (isEdit) {
          getServiceDetails(serviceId, context);
        }
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

  getAmc(String customerId, String amcId, BuildContext context) async {
    _isAmcListLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getAmc}?Customer_Id=$customerId&AMC_Status_Id=$amcId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _amcList = (data as List<dynamic>)
              .map((item) => AmcReportModeld.fromJson(item))
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
    } finally {
      _isAmcListLoading = false;

      notifyListeners();
    }
  }

  saveAmc(
      {required String description,
      required String fromDate,
      required String toDate,
      required String serviceName,
      required String productName,
      required String amount,
      required String cusId,
      required String amcId,
      required BuildContext context}) async {
    print(description);
    print(customerId);
    // print(_selectedAMCStatus.toString());
    // print(_selectedAMCStatusName.toString());
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveAmcDetails,
          bodyData: {
            "AMC_Id": amcId,
            "AMC_No": "",
            "Date": fromDate,
            "AMC_Status_Id": _selectedAMCStatus ?? 1,
            "AMC_Status_Name": _selectedAMCStatusName ?? 'Not Started',
            "Product_Name": productName,
            "Service_Name": serviceName,
            "Description": description,
            "Amount": amount,
            "Created_By": userId,
            "From_Date": fromDate,
            "To_Date": toDate,
            "Customer_Id": cusId,
            "Interval_Id": dropDownProvider.amcPeriodIntervalId,
            "Intervals_No": monthInterval,
            "Duration_Id": dropDownProvider.amcTotalDurationlId,
            "Duration_No": yearInterval,
            "interval_details":
                _maintenanceDates.map((e) => e.toJson()).toList(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');
        getAmc(cusId, '0', context);
        clearAmcControllers();
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

  getQuatationList(String customerId, BuildContext context) async {
    _isQuotationListLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getQuatationByCustomer}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _quotationList = (data as List)
              .map((item) =>
                  QuatationListModel.fromMap(item as Map<String, dynamic>))
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
      _isQuotationListLoading = false;
      // _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<void> getQuatationListByMasterId(
      String masterId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getQuotationByMasterId}/$masterId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log('API Response: ${data.toString()}');

          try {
            // Handle single object response
            if (data is Map<String, dynamic>) {
              _quotationListByMaster = [
                ql.GetQuotationbyMasterIdmodel.fromJson(data)
              ];
            }
            // Handle list response
            else if (data is List) {
              _quotationListByMaster = data
                  .map((item) => ql.GetQuotationbyMasterIdmodel.fromJson(item))
                  .toList();
            }

            log('Parsed Quotations: ${_quotationListByMaster.length}');
          } catch (parseError) {
            log('Data parsing error: $parseError');
            // Don't show error to user, just log it
          }
        }
      } else {
        log('Server Error: ${response.statusCode}');
        // Optional: Show error only for non-200 status codes
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to load data. Please try again.')),
          );
        }
      }
    } catch (e) {
      log('Network error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection error. Please check your internet.')),
        );
      }
    }

    // Notify listeners only once at the end
    notifyListeners();
  }

  void saveQuotation(String quotationId, String customerId,
      BuildContext context, bool isEdit) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";
      // double totalAmount = getTotalAmount();

      // Before API call: upload any pending files from quotation custom fields
      final quotationWidgetState = customFieldQuotationKey.currentState;
      if (quotationWidgetState != null) {
        final pendingBytes = quotationWidgetState.getPendingFileBytes();
        final pendingTypes = quotationWidgetState.getPendingFileContentTypes();
        if (pendingBytes.isNotEmpty) {
          for (final entry in pendingBytes.entries) {
            final fieldId = entry.key;
            final bytes = entry.value;
            final contentType =
                pendingTypes[fieldId] ?? 'application/octet-stream';
            final uploadKey = await CloudflareUpload.uploadToCloudflare(
                bytes, contentType, '$fieldId', context);
            if (uploadKey != null) {
              final fullUrl = HttpUrls.imgBaseUrl + uploadKey;
              quotationWidgetState.updateFieldValue(fieldId, fullUrl);
            }
          }
        }
      }
      // print("Total Amount: Rs$totalAmount");
      // double netTotal =
      //     totalAmount - double.parse(qsubsidyAmountController.text.toString());
      // print("Total Amount: Rs$netTotal");

      final response = await HttpRequest
          .httpPostRequest(endPoint: HttpUrls.saveQuotationMaster, bodyData: {
        "Quotation_Master_Id": quotationId,
        "Customer_Id": customerId,
        "Quotation_No": "",
        "Branch_Id": _selectedBranchId ?? 0,
        "PaymentTerms": 0,
        "Payment_Term_Description": "",
        "TotalAmount": subtotalController.text,
        "Subsidy_Amount":
            double.tryParse(qsubsidyAmountController.text.toString()) ?? 0,
        "NetTotal": totalController.text,
        "Product_Name": qproductnameController.text.toString(),
        "Warranty": qwarrentyController.text.toString(),
        "Terms_And_Conditions": qtermsConditionsController.text.toString(),
        "Quotation_Status_Id": _selectedQuotationStatus ?? 1,
        "Quotation_Status_Name": _selectedQuotationStatusName ?? "Pending",
        "Created_By": userId,
        "Description": quotationDescriptionController.text.toString(),
        'items': _items.map((item) => item.toJson()).toList(),
        'bill_of_materials': _bomItems.map((item) => item.toJson()).toList(),
        'production_chart':
            _productionItems.map((item) => item.toJson()).toList(),
        "advance_percentage": advanceController.text,
        "onmaterialdelivery_percentage": deliveryController.text,
        "onWork_completetion_percentage": workCompletionController.text,
        "System_Price_Excluding_KSEB_Paperwork":
            systemPriceController.text.isNotEmpty
                ? systemPriceController.text
                : "0",
        "KSEB_Registration_Fees_KW": registrationFeeController.text.isNotEmpty
            ? registrationFeeController.text
            : "0",
        "KSEB_Feasibility_Study_Fees": feasibilityFeeController.text.isNotEmpty
            ? feasibilityFeeController.text
            : "0",
        "Additional_Structure_Work":
            additionalStructureController.text.isNotEmpty
                ? additionalStructureController.text
                : "0",
        "TaxableAmount":
            double.tryParse(gstTaxableAmountController.text) ?? 0.0,
        "TotalGSTAmount": double.tryParse(totalGstAmountController.text) ?? 0.0,
        "TotalGSTPercent": double.tryParse(totalGstPerController.text) ?? 0.0,
        "TotalAdCESS": double.tryParse(totalAdCESSController.text) ?? 0.0,
        //
        "QuotationTypeId": _selectedQuotationType,
        "QuotationTypeName": quotationTypeController.text,
        "CommercialItems": _commercialItems.map((e) => e.toJson()).toList(),
        "CableStructure": cableStructureController.text,
        "CableType": cableTypeController.text,
        "CableShortCircuitTemp": cableShortCircuitTempController.text,
        "CableStandard": cableStandardController.text,
        "CableConductorClass": cableConductorClassController.text,
        "CableMaterial": cableMaterialController.text,
        "CableProtection": cableProtectionController.text,
        "CableWarranty": cableWarrantyController.text,
        "CableTensileStrength": cableTensileStrengthController.text,
        "PlantCapacity": plantCapacityController.text,
        "ModuleTechnologies": moduleTechnologiesController.text,
        "MountingStructureTechnologies":
            mountingStructureTechnologiesController.text,
        "ProjectScheme": projectSchemeController.text,
        "PowerEvacuation": powerEvacuationController.text,
        "AreaApproximate": areaApproximateController.text,
        "SolarPlantOutputConnection": solarPlantOutputConnectionController.text,
        "Scheme": schemeController.text,
        "Validity": qvalidityController.text,
        "TendorNumber": qtendorNumberController.text,
        "Payment_Terms_Name": paymentTermsController.text,
        "IncoTerms": incoTermsController.text,
        "totalOther_Tax": totalAdCESSController.text,
        "Total_CGST_Amount": totalCgstAmountController.text,
        "Total_SGST_Amount": totalSgstAmountController.text,
        "Total_IGST_Amount": "0",
        "Shipping_Charges":
            double.tryParse(shippingChargesController.text) ?? 0.0,
        "ScopeOfWorkItems": scopeOfWorkItems.map((e) => e.toJson()).toList(),
        "customFields":
            customFieldQuotationKey.currentState?.getFieldValuesAsJson(),
        "Description_2": quotationDescription2Controller.text.toString(),
        "Description_3": quotationDescription3Controller.text.toString(),
      });

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');
        getQuatationList(customerId, context);
        clearQuotationDetails();
        if (isEdit) {
          getQuatationListByMasterId(quotationId, context);
        }
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

  void clearTaskDetails() {
    _selectedTaskType = null;
    _selectedAssignWorker = null;
    taskDescriptionController.clear();
    taskChoosedateController.clear();
    taskChoosetimeController.clear();
    amcStatusNameController.clear();
    taskTypeController.clear();
    _selectedAssignWorkerName = '';
    _selectedAMCStatusName = null;
    _selectedAMCStatus = null;
    addTaskModel.taskUser = [];
  }

  void clearServiceDetails() {
    _selectedServiceStatus = null;
    _selectedServiceTypeId = null;
    taskDescriptionController.clear();
    serviceTypeController.clear();
    serviceController.clear();
    serviceStatusNameController.clear();
    serviceAmountController.clear();
  }

  void setServiceEditDropDown(int serviceTypeId, String serviceTypeName,
      int serviceStatusId, String serviceStatusName) {
    _selectedServiceStatus = serviceStatusId;
    _selectedServiceTypeId = serviceTypeId;
    serviceStatusNameController.text = serviceStatusName;
    serviceTypeController.text = serviceTypeName;
  }

  void setTaskEditDropDown(int taskTypeId, String taskTypeName, int toUserId,
      String toUserName, int taskStatusId, String taskStatusName) {
    _selectedTaskType = taskTypeId;
    _selectedAssignWorker = toUserId;
    _selectedAssignWorkerName = toUserName;
    _selectedTaskTypeName = taskTypeName;
    _selectedAMCStatus = taskStatusId;
    _selectedAMCStatusName = taskStatusName;
  }

  void clearQuotationDetails() {
    qproductnameController.clear();
    workCompletionController.clear();
    advanceController.clear();
    deliveryController.clear();
    quotationStatusController.clear();
    qsubsidyAmountController.text = '0';
    qtermsConditionsController.clear();
    qwarrentyController.clear();
    itemNameController.clear();
    itemQuantityController.clear();
    itemPriceController.clear();
    itemGstController.clear();
    itemGstPercentController.text = '18';
    itemAdCessController.clear();
    itemUnitController.clear();
    billmakeController.clear();
    billquantityController.clear();
    billdistributorController.clear();
    billinvoiceController.clear();
    billdescriptionController.clear();
    systemPriceController.clear();
    additionalStructureController.clear();
    feasibilityFeeController.clear();
    registrationFeeController.clear();
    itemMrpController.clear();
    itemTotalController.clear();
    _totalAmount = 0;
    subtotalController.clear();
    totalController.clear();
    _items = [];
    _bomItems = [];
    _productionItems = [];
    _selectedQuotationStatus = null;
    _selectedQuotationStatusName = null;
    gstTaxableAmountController.clear();
    cgstTaxableAmountController.clear();
    sgstTaxableAmountController.clear();
    totalGstAmountController.clear();
    totalCgstAmountController.clear();
    totalSgstAmountController.clear();
    totalGstPerController.clear();
    totalCgstPerController.clear();
    totalSgstPerController.clear();
    totalAdCESSController.clear();
    _selectedQuotationType = 0;
    quotationTypeController.clear();
    _commercialItems = [];
    cableStructureController.clear();
    cableTypeController.clear();
    cableShortCircuitTempController.clear();
    cableStandardController.clear();
    cableConductorClassController.clear();
    cableMaterialController.clear();
    cableProtectionController.clear();
    cableWarrantyController.clear();
    cableTensileStrengthController.clear();
    plantCapacityController.clear();
    moduleTechnologiesController.clear();
    mountingStructureTechnologiesController.clear();
    projectSchemeController.clear();
    powerEvacuationController.clear();
    areaApproximateController.clear();
    solarPlantOutputConnectionController.clear();
    schemeController.clear();
    qvalidityController.clear();
    qtendorNumberController.clear();
    paymentTermsController.clear();
    incoTermsController.clear();
    shippingChargesController.text = '0';
    designAndEngineeringController.clear();
    a3SScopeController.clear();
    clientScopeController.clear();
    _scopeOfWorkItems.clear();
    _customFieldQuotation.clear();
    customFieldQuotationKey.currentState?.resetForm();
    quotationDescriptionController.clear();
    quotationDescription2Controller.clear();
    quotationDescription3Controller.clear();
    _selectedBranchId = null;
  }

  void setAmcDropDown(int amcStatusId, String amcStatusName) {
    _selectedAMCStatus = amcStatusId;
    _selectedAMCStatusName = amcStatusName;
  }

  // void updateItemsFromQuotationDetails(
  //     List<QuotationDetail> quotationDetails,
  //     List<BillOfMaterial> billOfMaterials,
  //     List<ProductionChartModel> productionChart) {
  //   //items
  //   _items = List.generate(
  //     quotationDetails.length,
  //     (index) => Item(
  //         ItemName: '',
  //         UnitPrice: 0,
  //         Quantity: 0,
  //         MRP: 0,
  //         GST: 0,
  //         GSTPercent: 0,
  //         AdCESS: 0,
  //         Unit: ''),
  //   );

  //   print("Quotation Details Length: ${quotationDetails.length}");

  //   for (int i = 0; i < quotationDetails.length; i++) {
  //     // Update the item fields
  //     items[i].ItemName = quotationDetails[i].itemName;
  //     items[i].Quantity = quotationDetails[i].quantity;
  //     items[i].UnitPrice = (quotationDetails[i].unitPrice).toDouble();
  //     items[i].Amount = quotationDetails[i].amount.toDouble();
  //     items[i].MRP = quotationDetails[i].MRP.toDouble();
  //   }

  //   // Notify listeners about the change
  //   notifyListeners();

  //   // Final debug print to confirm the updates
  //   print("Final Items List: ${items.map((e) => e.toJson()).toList()}");

  //   //bill of materails
  //   _bomItems = List.generate(
  //     billOfMaterials.length,
  //     (index) => BillOfMaterialItem(
  //         itemsAndDescription: '',
  //         make: '',
  //         quantity: 0,
  //         distributor: '',
  //         invoiceNo: ''),
  //   );
  //   for (int i = 0; i < billOfMaterials.length; i++) {
  //     // Update the item fields
  //     bomItems[i].itemsAndDescription = billOfMaterials[i].itemsAndDescription;
  //     bomItems[i].quantity = billOfMaterials[i].quantity;
  //     bomItems[i].make = billOfMaterials[i].make;
  //     bomItems[i].distributor = billOfMaterials[i].distributor;
  //     bomItems[i].invoiceNo = billOfMaterials[i].invoiceNo;
  //   }
  //   _productionItems = List.generate(
  //     productionChart.length,
  //     (index) => ProductionChartItem(
  //         dailyTotal: '', monthlyTotal: '', remark: '', unitProduction: ''),
  //   );

  //   for (int i = 0; i < productionChart.length; i++) {
  //     // Update the item fields
  //     productionItems[i].unitProduction = productionChart[i].unitProduction;
  //     productionItems[i].dailyTotal = productionChart[i].dailyTotal;
  //     productionItems[i].monthlyTotal = productionChart[i].monthlyTotal;
  //     productionItems[i].remark = productionChart[i].remark;
  //   }
  //   print("Bill Details Length: ${billOfMaterials.length}");

  //   // Notify listeners about the change
  //   notifyListeners();

  //   // Final debug print to confirm the updates
  //   print("Final Bill List: ${bomItems.map((e) => e.toJson()).toList()}");
  // }

  void updateItemsFromQuotationDetailsNew(
      List<ql.QuotationDetail> quotationDetails,
      List<ql.BillOfMaterial> billOfMaterials,
      List<ProductionChartModel> productionChart) {
    //items
    _items = List.generate(
      quotationDetails.length,
      (index) => Item(
          ItemName: '',
          UnitPrice: 0,
          Quantity: 0,
          MRP: "",
          GST: 0,
          GSTPercent: 0,
          AdCESS: 0,
          Unit: '',
          Amount: 0),
    );

    print("Quotation Details Length: ${quotationDetails.length}");

    for (int i = 0; i < quotationDetails.length; i++) {
      // Update the item fields
      items[i].ItemName = quotationDetails[i].itemName;
      items[i].Quantity = quotationDetails[i].quantity;
      items[i].UnitPrice = (quotationDetails[i].unitPrice).toDouble();
      items[i].Amount = quotationDetails[i].amount.toDouble();
      items[i].MRP = quotationDetails[i].MRP;
      items[i].GST = quotationDetails[i].GST.toDouble();
      items[i].GSTPercent = quotationDetails[i].GSTPercent.toDouble();
      items[i].AdCESS = quotationDetails[i].AdCESS.toDouble();
      items[i].Unit = quotationDetails[i].Unit;
    }

    // Notify listeners about the change
    notifyListeners();

    // Final debug print to confirm the updates
    print("Final Items List: ${items.map((e) => e.toJson()).toList()}");

    //bill of materails
    _bomItems = List.generate(
      billOfMaterials.length,
      (index) => BillOfMaterialItem(
          itemsAndDescription: '',
          make: '',
          quantity: 0,
          distributor: '',
          invoiceNo: ''),
    );

    print("Bill Details Length: ${billOfMaterials.length}");

    for (int i = 0; i < billOfMaterials.length; i++) {
      // Update the item fields
      bomItems[i].itemsAndDescription = billOfMaterials[i].itemsAndDescription;
      bomItems[i].quantity = billOfMaterials[i].quantity;
      bomItems[i].make = billOfMaterials[i].make;
      bomItems[i].distributor = billOfMaterials[i].distributor;
      bomItems[i].invoiceNo = billOfMaterials[i].invoiceNo;
    }

    // Notify listeners about the change
    notifyListeners();

    // Final debug print to confirm the updates
    print("Final Bill List: ${bomItems.map((e) => e.toJson()).toList()}");
  }

  void updateProfile(String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      final response = await HttpRequest.httpPutRequest(
        endPoint: HttpUrls.saveCustomer,
        bodyData: {
          "Customer_Id": customerId,
          "Customer_Name": nameController.text,
          "Contact_Number": phoneController.text,
          "Email": emailController.text,
          "Address1": addressController.text,
          "Address2": cityController.text,
          "Address3": districtController.text,
          "Address4": stateController.text,
          "Map_Link": maplinkController.text,
          "Pincode": pincodeController.text
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        // _selectedTaskType = null;
        // _selectedAssignWorker = null;
        // _selectedAssignWorkerName = '';
        // taskDescriptionController.clear();
        // taskChoosedateController.clear();
        // taskChoosetimeController.clear();
        nameController.clear();
        phoneController.clear();
        emailController.clear();
        addressController.clear();
        cityController.clear();
        districtController.clear();
        stateController.clear();
        maplinkController.clear();
        pincodeController.clear();

        Navigator.pop(context);
        Loader.stopLoader(context);
        fetchLeadDetails(customerId, context);
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

  getDocument(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getDocumentList}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _documentList = (data as List<dynamic>)
              .map((item) => DocumentListModel.fromJson(item))
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  getRecieptListApi(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getRecieptList}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _receiptList = (data as List<dynamic>)
              .map((item) => ReceiptListModel.fromJson(item))
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  saveReciept(String recieptId, String customerId, BuildContext context) async {
    print(customerId);
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      // Format date and time
      String dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveRecieptUrl,
        bodyData: {
          "Receipt_Id": recieptId,
          "Entry_Date": dateTime,
          "Description": recieptDescriptionController.text.toString(),
          "Amount": recieptAmountController.text.toString(),
          "Customer_Id": customerId,
          "By_User_Id": int.parse(userId),
          "By_User_Name": userName
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        clearRecieptDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getRecieptListApi(customerId, context);
        getInvoiceRecieptTotal(customerId, context);
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

  void clearRecieptDetails() {
    recieptAmountController.clear();
    recieptDescriptionController.clear();
  }

  void clearPaymentDetails() {
    paymentDateController.clear();
    paymentAmountController.clear();
    paymentModeController.clear();
    paymentDescriptionController.clear();
  }

  savePayment(String recieptId, String customerId, BuildContext context) async {
    print(customerId);
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      // Format date and time
      String dateTime = paymentDateController.text.isNotEmpty
          ? paymentDateController.text
          : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      String description =
          "${paymentModeController.text} - ${paymentDescriptionController.text}";

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveRecieptUrl,
        bodyData: {
          "Receipt_Id": recieptId,
          "Entry_Date": dateTime,
          "Description": description,
          "Amount": paymentAmountController.text.toString(),
          "Customer_Id": customerId,
          "By_User_Id": int.parse(userId),
          "By_User_Name": userName
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        clearPaymentDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getRecieptListApi(customerId, context);
        getInvoiceRecieptTotal(customerId, context);
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

  saveRefund(String refundId, String customerId, BuildContext context) async {
    print(customerId);
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveRefund,
        bodyData: {
          "Refund_Id": refundId,
          "Customer_Id": customerId,
          "Electrical_Section": electricalsectioncontroller.text.toString(),
          "Place": electricalsectionplacecontroller.text.toString(),
          "Consumer_Number": consumernumbercontroller.text.toString(),
          "KW_Capacity": kwcapacitycontroller.text.toString(),
          "Account_Holder_Name": accountnamecontroller.text.toString(),
          "Account_Number": accountnumbercontroller.text.toString(),
          "Bank_Name": banknamecontroller.text.toString(),
          "IFSC_Code": ifsccontroller.text.toString(),
          "By_User_Id": int.parse(userId),
          "By_User_Name": userName
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        clearRefundDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getRefundDetails(customerId, context);
        getInvoiceRecieptTotal(customerId, context);
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

  void clearRefundDetails() {
    refundamountcontroller.clear();
    electricalsectioncontroller.clear();
    electricalsectionplacecontroller.clear();
  }

  getRefundDetails(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getRefundDetails}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _refundList = (data as List<dynamic>)
              .map((item) => RefundData.fromJson(item))
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  getInvoiceListApi(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getInvoiceList}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _invoiceList = (data as List<dynamic>)
              .map((item) => CustomerInvoice.fromJson(item))
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  saveInvoice(String recieptId, String customerId, BuildContext context) async {
    print(customerId);
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      // Format date and time
      String dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveInvoiceUrl,
        bodyData: {
          "customer_invoice_id": recieptId,
          "Entry_Date": dateTime,
          "Invoice_Description": invoiceDescriptionController.text.toString(),
          "Invoice_Amount": invoiceAmountController.text.toString(),
          "Customer_Id": int.parse(customerId),
          "By_User_Id": int.parse(userId),
          "By_User_Name": userName
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        clearInvoiceDetails();

        Navigator.pop(context);
        Loader.stopLoader(context);
        getInvoiceListApi(customerId, context);
        getInvoiceRecieptTotal(customerId, context);
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

  void clearInvoiceDetails() {
    invoiceAmountController.clear();
    invoiceDescriptionController.clear();
  }

  Future<void> deleteImage(
      BuildContext context, String imageId, String customerId) async {
    try {
      _isDeleteLoading = true;
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteImage}/$imageId');

      if (response != null && response.statusCode == 200) {
        log('Image deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getDocument(customerId, context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Image')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isDeleteLoading = false;
    }
  }

  Future<void> removeRegister(String customerId, BuildContext context) async {
    try {
      // Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      final response = await HttpRequest.httpPutParamRequest(
          endPoint: '${HttpUrls.unregisterCustomer}?Customer_Id=$customerId');

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        final sideprovider =
            Provider.of<SidebarProvider>(context, listen: false);
        final customerProvider =
            Provider.of<CustomerProvider>(context, listen: false);
        sideprovider.replaceWidgetCustomer(true, '');
        customerProvider.customerData.clear();
        await customerProvider.getSearchCustomers(context);
        // Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        // Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      // Loader.stopLoader(context);
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteTask(
      String taskId, String customerId, BuildContext context) async {
    try {
      _isDeleteLoading = true;
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteTask}/$taskId');

      if (response != null && response.statusCode == 200) {
        log('Task deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getTaskList(customerId, context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Task')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isDeleteLoading = false;
    }
  }

  Future<void> deleteService(
      String serviceId, String customerId, BuildContext context) async {
    try {
      _isDeleteLoading = true;
      notifyListeners();
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteService}/$serviceId');

      if (response != null && response.statusCode == 200) {
        log('Service deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getServiceList(customerId, context);
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
      _isDeleteLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAMC(
      String amcId, String customerId, BuildContext context) async {
    try {
      _isDeleteLoading = true;
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteAMC}/$amcId');

      if (response != null && response.statusCode == 200) {
        log('AMC deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getAmc(customerId, '0', context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Periodic Service')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isDeleteLoading = false;
    }
  }

  Future<void> deleteQuotation(
      String amcId, String customerId, BuildContext context) async {
    try {
      _isDeleteLoading = true;
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteQuotation}/$amcId');

      if (response != null && response.statusCode == 200) {
        log('AMC deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getQuatationList(customerId, context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Quotation')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isDeleteLoading = false;
    }
  }

  Future<void> deleteReciept(
      String recieptId, String customerId, BuildContext context) async {
    try {
      _isDeleteLoading = true;
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteReciept}/$recieptId');

      if (response != null && response.statusCode == 200) {
        log('Reciept deleted successfully');
        // _leadData.removeWhere((lead) => lead.toUserId == leadId);

        getRecieptListApi(customerId, context);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Reciept')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isDeleteLoading = false;
    }
  }

  getTaskDocument(String customerId, BuildContext context) async {
    // _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getTaskDocumetsByCustomer}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _taskDocuments = (data as List<dynamic>)
              .map((item) => TaskDocumentList.fromJson(item))
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
      // _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  removeAssignedWorker(UserInTaskModel taskUser) {
    addTaskModel.taskUser?.remove(taskUser);
    notifyListeners();
  }

  Future<void> getForm(BuildContext context, String taskId) async {
    try {
      print(taskId);
      Loader.showLoader(context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getFormPrint}?Task_Id_=$taskId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data != null && data['data'] != null && data['data'].isNotEmpty) {
            try {
              final dataItem = data['data'][0];
              print(dataItem);
              _formDetails = (dataItem as List<dynamic>)
                  .map((item) => SolarPanelDetails.fromJson(item))
                  .toList();
            } catch (e) {
              print("Error: $e");
            }
          } else {
            print("Data is empty or not available");
          }
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
      Loader.stopLoader(context);
    } catch (e) {
      // Catch and handle any exceptions that occur during the request
      Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> getTaskUsers(int taskMasterId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getTaskUsers}/$taskMasterId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());

          _taskUsers = (data as List<dynamic>)
              .map((item) => TaskUserListModel.fromJson(item))
              .toList();

          updateTaskUser(_taskUsers);
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      // _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  getInvoiceRecieptTotal(String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.invoiceRecieptTotal}?Customer_Id=$customerId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data.toString());
          invoiceTotal = data[0]['Total_Invoice_Amount'] ?? '0';
          recieptTotal = data[0]['Total_Receipt_Amount'] ?? '0';
          balanceTotal = data[0]['Balance_Amount'] ?? '0';

          // _invoiceList = (data as List<dynamic>)
          //     .map((item) => CustomerInvoice.fromJson(item))
          //     .toList();
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
      _isLoading = false; // Set loading to false once the request completes
      notifyListeners(); // Notify listeners to rebuild with the final state
    }
  }

  Future<List<UserLocationModel>> getUserLocationDetails(
      BuildContext context, String query) async {
    List<UserLocationModel> dataList = [];

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              HttpUrls.getUserLocationDetails + "?User_Details_Name=" + query);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          var response = data["data"];
          dataList = (response as List<dynamic>)
              .map((item) => UserLocationModel.fromJson(item))
              .toList();
        }
      } else {
        throw Exception('Failed to load location details');
      }
      return dataList;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return dataList;

      print('Exception occurred: $error');
    }
  }

  void addOrEditCommercialItem(BuildContext context) {
    // Validate input fields
    if (commercialDescriptionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.appViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Missing Details',
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
      return;
    }

    // Create the new commercial item
    final newItem = CommercialItemModel(
      description: commercialDescriptionController.text,
      dcCapacity: commercialDCCapacityController.text,
      acCapacity: commercialACCapacityController.text,
      unitPrice: commercialUnitPriceController.text,
      total: commercialTotalController.text,
    );

    if (_editCommercialIndex != null &&
        _editCommercialIndex! >= 0 &&
        _editCommercialIndex! < _commercialItems.length) {
      // Edit existing item
      _commercialItems[_editCommercialIndex!] = newItem;
    } else {
      // Add new item
      _commercialItems.add(newItem);
    }

    // Clear the text fields
    _editCommercialIndex = null;
    clearCommercialItemFields();
    print(_commercialItems.map((e) => e.toJson()).toList());
    commercialTotalCalculator();
    notifyListeners(); // Trigger UI updates
  }

  void clearCommercialItemFields() {
    commercialDescriptionController.clear();
    commercialDCCapacityController.clear();
    commercialACCapacityController.clear();
    commercialUnitPriceController.clear();
    commercialTotalController.clear();
  }

  void populateCommercialItemFieldsForEditing(int index) {
    // Populate text fields with existing item's data for editing
    if (index >= 0 && index < _commercialItems.length) {
      final itemToEdit = _commercialItems[index];

      commercialDescriptionController.text = itemToEdit.description ?? '';
      commercialDCCapacityController.text = itemToEdit.dcCapacity ?? '';
      commercialACCapacityController.text = itemToEdit.acCapacity ?? '';
      commercialUnitPriceController.text = itemToEdit.unitPrice ?? '';
      commercialTotalController.text = itemToEdit.total ?? '';

      setEditCommercialItemIndex(index);
      notifyListeners();
    }
  }

  void deleteCommercialItem(int index) {
    if (index >= 0 && index < _commercialItems.length) {
      _commercialItems.removeAt(index);
      notifyListeners();
    }
  }

  void commercialTotalCalculator() {
    double total = 0;
    for (var item in _commercialItems) {
      total += double.tryParse(item.total ?? '0') ?? 0;
    }
    totalController.text = total.toStringAsFixed(2);
  }

  void addOrEditScopeOfWorkItem(BuildContext context) {
    // Validate input fields
    if (designAndEngineeringController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.appViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Missing Details',
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
      return;
    }

    // Create the new commercial item
    final newItem = ScopeOfWorkModel(
      designAndEngineering: designAndEngineeringController.text,
      a3SScope: a3SScopeController.text,
      clientScope: clientScopeController.text,
    );

    if (_editScopeOfWorkIndex != null &&
        _editScopeOfWorkIndex! >= 0 &&
        _editScopeOfWorkIndex! < _scopeOfWorkItems.length) {
      // Edit existing item
      _scopeOfWorkItems[_editScopeOfWorkIndex!] = newItem;
    } else {
      // Add new item
      _scopeOfWorkItems.add(newItem);
    }

    // Clear the text fields
    _editScopeOfWorkIndex = null;
    clearScopeOfWorkItemFields();
    print(_scopeOfWorkItems.map((e) => e.toJson()).toList());
    notifyListeners(); // Trigger UI updates
  }

  void clearScopeOfWorkItemFields() {
    designAndEngineeringController.clear();
    a3SScopeController.clear();
    clientScopeController.clear();
  }

  void populateScopeOfWorkItemFieldsForEditing(int index) {
    // Populate text fields with existing item's data for editing
    if (index >= 0 && index < _scopeOfWorkItems.length) {
      final itemToEdit = _scopeOfWorkItems[index];

      designAndEngineeringController.text =
          itemToEdit.designAndEngineering ?? '';
      a3SScopeController.text = itemToEdit.a3SScope ?? '';
      clientScopeController.text = itemToEdit.clientScope ?? '';

      setEditScopeOfWorkItemIndex(index);
      notifyListeners();
    }
  }

  void deleteScopeOfWorkItem(int index) {
    if (index >= 0 && index < _scopeOfWorkItems.length) {
      _scopeOfWorkItems.removeAt(index);
      notifyListeners();
    }
  }

  void calculateMaintenanceDates({
    required String installationDate,
    required int totalDuration,
    required int monthInterval,
    required BuildContext context,
  }) {
    _maintenanceDates = [];

    if (installationDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Installation date is required"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (monthInterval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select Periodic Interval"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (totalDuration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select Total Duration"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    DateTime installDate;
    try {
      installDate = DateTime.parse(installationDate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid date format"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    DateTime expDate = DateTime(
        installDate.year + totalDuration, installDate.month, installDate.day);

    final formattedExpiry = "${expDate.year.toString().padLeft(4, '0')}-"
        "${expDate.month.toString().padLeft(2, '0')}-"
        "${expDate.day.toString().padLeft(2, '0')}";
    toDateController.text = formattedExpiry.toDDMMYYYY();

    // int maintenanceId = 1;

    // Add installation date
    _maintenanceDates.add(MaintenanceDate(
      // id: (maintenanceId++).toString(),
      date: "${installDate.year.toString().padLeft(4, '0')}-"
          "${installDate.month.toString().padLeft(2, '0')}-"
          "${installDate.day.toString().padLeft(2, '0')}",
    ));

    DateTime currentDate = installDate;

    while (true) {
      int newYear = currentDate.year;
      int newMonth = currentDate.month + monthInterval;

      // Handle year overflow
      newYear += (newMonth - 1) ~/ 12;
      newMonth = ((newMonth - 1) % 12) + 1;

      // Handle day overflow (e.g., Jan 31 + 1 month)
      int lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
      int newDay = math.min(currentDate.day, lastDayOfMonth);

      DateTime nextDate = DateTime(newYear, newMonth, newDay);

      // Stop if we've reached or passed the expiration date
      if (!nextDate.isBefore(expDate)) break;

      _maintenanceDates.add(MaintenanceDate(
        // id: (maintenanceId++).toString(),
        date: "${nextDate.year.toString().padLeft(4, '0')}-"
            "${nextDate.month.toString().padLeft(2, '0')}-"
            "${nextDate.day.toString().padLeft(2, '0')}",
      ));

      currentDate = nextDate;
    }

    // Add expiration date if it's not already in the list
    if (_maintenanceDates.isEmpty ||
        !_datesEqual(_maintenanceDates.last.date, formattedExpiry)) {
      _maintenanceDates.add(MaintenanceDate(
        // id: maintenanceId.toString(),
        date: formattedExpiry,
      ));
    }

    notifyListeners();
  }

  bool _datesEqual(String date1, String date2) {
    try {
      return DateTime.parse(date1) == DateTime.parse(date2);
    } catch (e) {
      return false;
    }
  }

  void getQuotationTypes(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getQuotationTypes}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'] ?? [];
          _quotationTypeData = (newData as List<dynamic>)
              .map((item) => QuotationTypeModel.fromJson(item))
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

  Future<void> loadQuotationFromCustomFields(
      BuildContext context, String type) async {
    try {
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.loadQuotationFromCustomFields,
          bodyData: {
            "custom_fields":
                customFieldQuotationKey.currentState?.getFieldValuesAsJson() ??
                    [],
            "type": type
          });

      if (response?.statusCode == 200) {
        final data = response?.data;

        if (data != null) {
          log('API Response: ${data.toString()}');

          try {
            // Handle single object response
            if (data is Map<String, dynamic>) {
              _quotationListByMaster = [
                ql.GetQuotationbyMasterIdmodel.fromJson(data)
              ];
            }
            // Handle list response
            else if (data is List) {
              _quotationListByMaster = data
                  .map((item) => ql.GetQuotationbyMasterIdmodel.fromJson(item))
                  .toList();
            }

            log('Parsed Quotations: ${_quotationListByMaster.length}');
          } catch (parseError) {
            log('Data parsing error: $parseError');
            // Don't show error to user, just log it
          }
        }
      } else {
        log('Server Error: ${response?.statusCode}');
        // Optional: Show error only for non-200 status codes
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to load data. Please try again.')),
          );
        }
      }
    } catch (e) {
      log('Network error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection error. Please check your internet.')),
        );
      }
    }

    // Notify listeners only once at the end
    notifyListeners();
  }

  Future<void> getQuotationMasterPdf(
      String masterId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getQuotationMasterPdf}?quotation_master_id=$masterId',
          returnBytes: true);

      if (response.statusCode == 200) {
        final data = response.data;
        print("getQuotationMasterPdf response received");

        if (data is List<int>) {
          if (kIsWeb) {
            final blob =
                html.Blob([Uint8List.fromList(data)], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor = html.AnchorElement(href: url)
              ..setAttribute("download", "Quotation_$masterId.pdf")
              ..click();

            // Delay cleanup to ensure download starts
            await Future.delayed(const Duration(seconds: 2));
            html.Url.revokeObjectUrl(url);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading PDF...')));
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'PDF data received (Download supported on Web only currently)')));
            }
          }
        } else {
          // Check if it's a JSON response (like a URL) despite requesting bytes
          // or if valid PDF handling failed.
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Invalid PDF data received. Please try again.')));
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }
}
