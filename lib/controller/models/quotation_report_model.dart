import 'dart:convert';

List<QuotationReportModel> quotationReportModelFromJson(String str) =>
    List<QuotationReportModel>.from(
        json.decode(str).map((x) => QuotationReportModel.fromJson(x)));

String quotationReportModelToJson(List<QuotationReportModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuotationReportModel {
  int? customerId;
  String? customerName;
  String? phoneNumber;
  String? productName;
  int? quotationMasterId;
  String? entryDate;
  int? quotationNo;
  double? totalAmount;
  double? subsidyAmount;
  double? netTotal;
  int? quotationStatusId;
  String? quotationStatusName;

  QuotationReportModel({
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.productName,
    this.quotationMasterId,
    this.entryDate,
    this.quotationNo,
    this.totalAmount,
    this.subsidyAmount,
    this.netTotal,
    this.quotationStatusId,
    this.quotationStatusName,
  });

  QuotationReportModel copyWith({
    int? customerId,
    String? customerName,
    String? phoneNumber,
    String? productName,
    int? quotationMasterId,
    String? entryDate,
    int? quotationNo,
    double? totalAmount,
    double? subsidyAmount,
    double? netTotal,
    int? quotationStatusId,
    String? quotationStatusName,
  }) =>
      QuotationReportModel(
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        productName: productName ?? this.productName,
        quotationMasterId: quotationMasterId ?? this.quotationMasterId,
        entryDate: entryDate ?? this.entryDate,
        quotationNo: quotationNo ?? this.quotationNo,
        totalAmount: totalAmount ?? this.totalAmount,
        subsidyAmount: subsidyAmount ?? this.subsidyAmount,
        netTotal: netTotal ?? this.netTotal,
        quotationStatusId: quotationStatusId ?? this.quotationStatusId,
        quotationStatusName: quotationStatusName ?? this.quotationStatusName,
      );

  // Helper method to safely parse integers
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  // Helper method to safely parse doubles
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  factory QuotationReportModel.fromJson(Map<String, dynamic> json) =>
      QuotationReportModel(
        customerId: _parseInt(json["Customer_Id"]),
        customerName: json["Customer_Name"]?.toString(),
        phoneNumber: json["Phone_Number"]?.toString(),
        productName: json["Product_Name"]?.toString(),
        quotationMasterId: _parseInt(json["Quotation_Master_Id"]),
        entryDate: json["EntryDate"]?.toString(),
        quotationNo: _parseInt(json["Quotation_No"]),
        totalAmount: _parseDouble(json["TotalAmount"]),
        subsidyAmount: _parseDouble(json["Subsidy_Amount"]),
        netTotal: _parseDouble(json["NetTotal"]),
        quotationStatusId: _parseInt(json["Quotation_Status_Id"]),
        quotationStatusName: json["Quotation_Status_Name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone_Number": phoneNumber,
        "Product_Name": productName,
        "Quotation_Master_Id": quotationMasterId,
        "EntryDate": entryDate,
        "Quotation_No": quotationNo,
        "TotalAmount": totalAmount,
        "Subsidy_Amount": subsidyAmount,
        "NetTotal": netTotal,
        "Quotation_Status_Id": quotationStatusId,
        "Quotation_Status_Name": quotationStatusName,
      };
}
