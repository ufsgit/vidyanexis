import 'dart:convert';
import 'package:intl/intl.dart';

List<ConversionModel> conversionModelFromJson(String str) =>
    List<ConversionModel>.from(
        json.decode(str).map((x) => ConversionModel.fromJson(x)));

String conversionModelToJson(List<ConversionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConversionModel {
  String customerName;
  String registerdBy;
  DateTime creationDate;
  DateTime registeredDate;
  String statusName;
  String colorCode;
  int customerId;
  dynamic enquiryForName;
  final String mobile;
  final String address1;

  ConversionModel({
    required this.customerName,
    required this.registerdBy,
    required this.creationDate,
    required this.registeredDate,
    required this.statusName,
    required this.enquiryForName,
    required this.colorCode,
    required this.customerId,
    required this.mobile,
    required this.address1,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return DateTime.now();
      String dateStr = value.toString();
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        try {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (_) {
          return DateTime.now();
        }
      }
    }

    return ConversionModel(
      customerName: json["Customer_Name"] ?? '',
      registerdBy: json["RegisterdBy"] ?? '',
      creationDate: parseDate(json["creationDate"]),
      registeredDate: parseDate(json["Registered_Date"]),
      statusName: json["Status_Name"] ?? '',
      enquiryForName: json["Enquiry_For_Name"] ?? '',
      colorCode: json["Color_Code"] ?? '',
      customerId: json["Customer_Id"] ?? 0,
      mobile: json['Contact_Number'] ?? '',
      address1: json['Address1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "Customer_Name": customerName,
        "RegisterdBy": registerdBy,
        "creationDate": creationDate.toIso8601String(),
        "Registered_Date": registeredDate.toIso8601String(),
        "Status_Name": statusName,
        "Enquiry_For_Name": enquiryForName,
        "Color_Code": colorCode,
        "Customer_Id": customerId,
        'Contact_Number': mobile,
        'Address1': address1,
      };
}

