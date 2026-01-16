class QuatationListModel {
  int quotationMasterId;
  int customerId;
  dynamic entryDate;
  String quotationNo;
  int paymentTerms;
  String paymentTermDescription;
  final String workCompletionPercentage;

  final String onDeliveryPercentage;

  final String advancePercentage;
  String totalAmount;
  String subsidyAmount;
  String netTotal;
  String productName;
  String warranty;
  String termsAndConditions;
  int isConfirm;
  String orderNo;
  DateTime? orderDate;
  int confirmedBy;
  int quotationStatusId;
  String quotationStatusName;
  int activeStatus;
  int createdBy;
  String description;
  int deleteStatus;
  String createdByName;
  List<QuotationDetail>? quotationDetails;
  List<BillOfMaterial>? billOfMaterials;
  List<ProductionChartModel>? productionChartModel;
  int quotationTypeId;

  QuatationListModel({
    required this.quotationMasterId,
    required this.customerId,
    this.entryDate,
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
    required this.orderNo,
    required this.workCompletionPercentage,
    required this.onDeliveryPercentage,
    required this.advancePercentage,
    this.orderDate,
    required this.confirmedBy,
    required this.quotationStatusId,
    required this.quotationStatusName,
    required this.activeStatus,
    required this.createdBy,
    required this.description,
    required this.deleteStatus,
    required this.createdByName,
    this.quotationDetails,
    this.billOfMaterials,
    this.productionChartModel,
    required this.quotationTypeId,
  });

  factory QuatationListModel.fromMap(Map<String, dynamic> json) =>
      QuatationListModel(
        advancePercentage: json["advance_percentage"] ?? "",
        onDeliveryPercentage: json["onmaterialdelivery_percentage"] ?? "",
        workCompletionPercentage: json["onWork_completetion_percentage"] ?? "",
        quotationMasterId: json["Quotation_Master_Id"] ?? 0,
        customerId: json["Customer_Id"] ?? 0,
        entryDate: json["EntryDate"],
        quotationNo: json["Quotation_No"] ?? '',
        paymentTerms: json["PaymentTerms"] ?? 0,
        paymentTermDescription: json["Payment_Term_Description"] ?? '',
        totalAmount: json["TotalAmount"] ?? '0.0',
        subsidyAmount: json["Subsidy_Amount"] ?? '0.0',
        netTotal: json["NetTotal"] ?? '0.0',
        productName: json["Product_Name"] ?? '',
        warranty: json["Warranty"] ?? '',
        termsAndConditions: json["Terms_And_Conditions"] ?? '',
        isConfirm: json["Is_Confirm"] ?? 0,
        orderNo: json["Order_No"] ?? '',
        orderDate: json["Order_Date"] != null
            ? DateTime.tryParse(json["Order_Date"])
            : null,
        confirmedBy: json["Confirmed_By"] ?? 0,
        quotationStatusId: json["Quotation_Status_Id"] ?? 0,
        quotationStatusName: json["Quotation_Status_Name"] ?? '',
        activeStatus: json["Active_Status"] ?? 0,
        createdBy: json["Created_By"] ?? 0,
        description: json["Description"] ?? '',
        deleteStatus: json["DeleteStatus"] ?? 0,
        createdByName: json["Created_By_Name"] ?? '',
        quotationTypeId: json["QuotationTypeId"] ?? 0,
        quotationDetails: json["quotation_details"] == null
            ? []
            : List<QuotationDetail>.from(json["quotation_details"]!
                .map((x) => QuotationDetail.fromMap(x))),
        billOfMaterials: json["bill_of_materials"] == null
            ? []
            : List<BillOfMaterial>.from(json["bill_of_materials"]
                .map((x) => BillOfMaterial.fromMap(x))),
        productionChartModel: json["production_chart"] == null
            ? []
            : List<ProductionChartModel>.from(json["production_chart"]
                .map((x) => ProductionChartModel.fromJson(x))),
      );

  Map<String, dynamic> toMap() => {
        "Quotation_Master_Id": quotationMasterId,
        "Customer_Id": customerId,
        "EntryDate": entryDate,
        "Quotation_No": quotationNo,
        "PaymentTerms": paymentTerms,
        "Payment_Term_Description": paymentTermDescription,
        "TotalAmount": totalAmount,
        "Subsidy_Amount": subsidyAmount,
        "NetTotal": netTotal,
        "Product_Name": productName,
        "Warranty": warranty,
        "Terms_And_Conditions": termsAndConditions,
        "Is_Confirm": isConfirm,
        "Order_No": orderNo,
        "Order_Date": orderDate != null
            ? "${orderDate!.year.toString().padLeft(4, '0')}-${orderDate!.month.toString().padLeft(2, '0')}-${orderDate!.day.toString().padLeft(2, '0')}"
            : null,
        "Confirmed_By": confirmedBy,
        "Quotation_Status_Id": quotationStatusId,
        "Quotation_Status_Name": quotationStatusName,
        "Active_Status": activeStatus,
        "Created_By": createdBy,
        "Description": description,
        "DeleteStatus": deleteStatus,
        "Created_By_Name": createdByName,
        "quotation_details": quotationDetails == null
            ? []
            : List<dynamic>.from(quotationDetails!.map((x) => x.toMap())),
        "bill_of_materials": billOfMaterials == null
            ? []
            : List<dynamic>.from(billOfMaterials!.map((x) => x.toMap())),
        "production_chart": productionChartModel == null
            ? []
            : List<dynamic>.from(productionChartModel!.map((x) => x.toJson())),
      };
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

  factory BillOfMaterial.fromMap(Map<String, dynamic> json) => BillOfMaterial(
        make: json["make"] ?? '',
        quantity: json["Quantity"] ?? 0,
        invoiceNo: json["Invoice_No"] ?? '',
        distributor: json["Distributor"] ?? '',
        billOfMaterialsId: json["Bill_Of_Materials_Id"] ?? 0,
        itemsAndDescription: json["Items_And_Description"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "make": make,
        "Quantity": quantity,
        "Invoice_No": invoiceNo,
        "Distributor": distributor,
        "Bill_Of_Materials_Id": billOfMaterialsId,
        "Items_And_Description": itemsAndDescription,
      };
}

class ProductionChartModel {
  String unitProduction;
  String dailyTotal;
  String monthlyTotal;
  int productionChartId;
  String remark;

  ProductionChartModel(
      {required this.unitProduction,
      required this.dailyTotal,
      required this.monthlyTotal,
      required this.remark,
      required this.productionChartId});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unit_production': unitProduction,
      'daily_total': dailyTotal,
      'monthly_total': monthlyTotal,
      'Remark': remark,
      "Production_Chart_Id": productionChartId
    };
  }

  // Create from JSON
  factory ProductionChartModel.fromJson(Map<String, dynamic> json) {
    return ProductionChartModel(
        unitProduction: json['unit_production'],
        dailyTotal: json['daily_total'],
        monthlyTotal: json['monthly_total'],
        remark: json['Remark'],
        productionChartId: json["Production_Chart_Id"]);
  }
}

class QuotationDetail {
  double amount;
  int itemId;
  String itemName;
  int quantity;
  double unitPrice;
  int quotationDetailsId;
  String MRP;

  QuotationDetail({
    required this.amount,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.quotationDetailsId,
    required this.MRP,
  });

  factory QuotationDetail.fromMap(Map<String, dynamic> json) => QuotationDetail(
        amount: json["Amount"] ?? 0,
        itemId: json["ItemId"] ?? 0,
        itemName: json["ItemName"] ?? '',
        quantity: json["Quantity"] ?? 0,
        unitPrice: json["UnitPrice"] ?? 0,
        MRP: json["MRP"]?.toString() ?? '',
        quotationDetailsId: json["Quotation_Details_Id"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "Amount": amount,
        "ItemId": itemId,
        "ItemName": itemName,
        "Quantity": quantity,
        "UnitPrice": unitPrice,
        "MRP": MRP,
        "Quotation_Details_Id": quotationDetailsId,
      };
}
