import 'package:techtify/controller/models/quotaion_list_model.dart';

class GetQuotationbyMasterIdmodel {
  final int quotationMasterId;
  final int customerId;
  final String entryDate;
  final String quotationNo;
  final int paymentTerms;
  final String paymentTermDescription;
  final String totalAmount;
  final String subsidyAmount;
  final String netTotal;
  final String productName;
  final String workCompletionPercentage;

  final String onDeliveryPercentage;

  final String advancePercentage;

  final String warranty;
  final String termsAndConditions;
  final String ksebRegistrationFee;
  final String ksebFeasibilityFee;
  final String additionalStructure;
  final String ksebSystemPrice;
  final int isConfirm;
  final String? orderNo;
  final String? orderDate;
  final int confirmedBy;
  final int quotationStatusId;
  final String quotationStatusName;
  final int activeStatus;
  final int createdBy;
  final String description;
  final int deleteStatus;
  final String createdByName;
  final String taxableAmount;
  final String gstAmount;
  final String gstPer;
  final String adCess;
  final List<QuotationDetail> quotationDetails;
  final List<ProductionChartModel> productionChart;

  final List<BillOfMaterial> billOfMaterials;

  GetQuotationbyMasterIdmodel(
      {required this.quotationMasterId,
      required this.workCompletionPercentage,
      required this.onDeliveryPercentage,
      required this.advancePercentage,
      required this.customerId,
      required this.entryDate,
      required this.quotationNo,
      required this.paymentTerms,
      required this.paymentTermDescription,
      required this.totalAmount,
      required this.subsidyAmount,
      required this.netTotal,
      required this.productName,
      required this.warranty,
      required this.termsAndConditions,
      required this.isConfirm,
      this.orderNo,
      this.orderDate,
      required this.confirmedBy,
      required this.quotationStatusId,
      required this.quotationStatusName,
      required this.activeStatus,
      required this.createdBy,
      required this.description,
      required this.deleteStatus,
      required this.createdByName,
      required this.ksebFeasibilityFee,
      required this.ksebRegistrationFee,
      required this.ksebSystemPrice,
      required this.additionalStructure,
      required this.taxableAmount,
      required this.gstAmount,
      required this.gstPer,
      required this.adCess,
      required this.quotationDetails,
      required this.billOfMaterials,
      required this.productionChart});

  factory GetQuotationbyMasterIdmodel.fromJson(Map<String, dynamic> json) {
    // Handle quotation_details
    List<QuotationDetail> details = [];
    if (json['quotation_details'] != null) {
      if (json['quotation_details'] is List) {
        details = (json['quotation_details'] as List)
            .map((detail) => QuotationDetail.fromJson(detail))
            .toList();
      }
    }
    List<ProductionChartModel> productionChart = [];
    if (json['production_chart'] != null) {
      if (json['production_chart'] is List) {
        productionChart = (json['production_chart'] as List)
            .map((detail) => ProductionChartModel.fromJson(detail))
            .toList();
      }
    }
    // Handle bill_of_materials
    List<BillOfMaterial> materials = [];
    if (json['bill_of_materials'] != null) {
      if (json['bill_of_materials'] is List) {
        materials = (json['bill_of_materials'] as List)
            .map((material) => BillOfMaterial.fromJson(material))
            .toList();
      }
    }

    return GetQuotationbyMasterIdmodel(
        advancePercentage: json["advance_percentage"] ?? "",
        onDeliveryPercentage: json["onmaterialdelivery_percentage"] ?? "",
        workCompletionPercentage: json["onWork_completetion_percentage"] ?? "",
        quotationMasterId: json['Quotation_Master_Id'] ?? 0,
        customerId: json['Customer_Id'] ?? 0,
        entryDate: json['EntryDate'] ?? '',
        quotationNo: json['Quotation_No'] ?? '',
        paymentTerms: json['PaymentTerms'] ?? 0,
        paymentTermDescription: json['Payment_Term_Description'] ?? '',
        totalAmount: json['TotalAmount'] ?? '0.000',
        subsidyAmount: json['Subsidy_Amount'] ?? '0.000',
        netTotal: json['NetTotal'] ?? '0.000',
        productName: json['Product_Name'] ?? '',
        warranty: json['Warranty'] ?? '',
        termsAndConditions: json['Terms_And_Conditions'] ?? '',
        isConfirm: json['Is_Confirm'] ?? 0,
        orderNo: json['Order_No'] ?? '',
        orderDate: json['Order_Date'] ?? '',
        confirmedBy: json['Confirmed_By'] ?? 0,
        quotationStatusId: json['Quotation_Status_Id'] ?? 0,
        quotationStatusName: json['Quotation_Status_Name'] ?? '',
        activeStatus: json['Active_Status'] ?? 0,
        createdBy: json['Created_By'] ?? 0,
        description: json['Description'] ?? '',
        deleteStatus: json['DeleteStatus'] ?? 0,
        createdByName: json['Created_By_Name'] ?? '',
        ksebSystemPrice:
            json['System_Price_Excluding_KSEB_Paperwork']?.toString() ?? '0',
        ksebRegistrationFee:
            json['KSEB_Registration_Fees_KW']?.toString() ?? '0',
        ksebFeasibilityFee:
            json['KSEB_Feasibility_Study_Fees']?.toString() ?? '0',
        additionalStructure:
            json['Additional_Structure_Work']?.toString() ?? '',
        taxableAmount: json['TaxableAmount']?.toString() ?? '',
        gstAmount: json['TotalGSTAmount']?.toString() ?? '',
        gstPer: json['TotalGSTPercent']?.toString() ?? '',
        adCess: json['TotalAdCESS']?.toString() ?? '',
        quotationDetails: details,
        billOfMaterials: materials,
        productionChart: productionChart);
  }
}

class BillOfMaterial {
  String make;
  int quantity;
  String invoiceNo;
  String distributor;
  int billOfMaterialsId;
  String itemsAndDescription;

  BillOfMaterial({
    required this.make,
    required this.quantity,
    required this.invoiceNo,
    required this.distributor,
    required this.billOfMaterialsId,
    required this.itemsAndDescription,
  });

  factory BillOfMaterial.fromJson(Map<String, dynamic> json) => BillOfMaterial(
        make: json["make"] ?? '',
        quantity: json["Quantity"] ?? 0,
        invoiceNo: json["Invoice_No"] ?? '',
        distributor: json["Distributor"] ?? '',
        billOfMaterialsId: json["Bill_Of_Materials_Id"] ?? 0,
        itemsAndDescription: json["Items_And_Description"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "make": make,
        "Quantity": quantity,
        "Invoice_No": invoiceNo,
        "Distributor": distributor,
        "Bill_Of_Materials_Id": billOfMaterialsId,
        "Items_And_Description": itemsAndDescription,
      };
}

class QuotationDetail {
  double amount;
  dynamic itemId;
  String itemName;
  int quantity;
  double unitPrice;
  int quotationDetailsId;
  double MRP;
  double GST;
  double GSTPercent;
  double AdCESS;
  String Unit;

  QuotationDetail({
    required this.amount,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.quotationDetailsId,
    required this.MRP,
    this.GST = 0.0,
    this.GSTPercent = 0.0,
    this.AdCESS = 0.0,
    this.Unit = '',
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) =>
      QuotationDetail(
        amount: json["Amount"] ?? 0,
        itemId: json["ItemId"],
        itemName: json["ItemName"] ?? '',
        quantity: json["Quantity"] ?? 0,
        unitPrice: json["UnitPrice"] ?? 0,
        quotationDetailsId: json["Quotation_Details_Id"] ?? 0,
        MRP: json["MRP"] ?? 0,
        GST: json["GST"] ?? 0,
        GSTPercent: json["GSTPercent"] ?? 0,
        AdCESS: json["AdCESS"] ?? 0,
        Unit: json["Unit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Amount": amount,
        "ItemId": itemId,
        "ItemName": itemName,
        "Quantity": quantity,
        "UnitPrice": unitPrice,
        "Quotation_Details_Id": quotationDetailsId,
        "MRP": MRP,
        "GST": GST,
        "GSTPercent": GSTPercent,
        "AdCESS": AdCESS,
        "Unit": Unit,
      };
}
