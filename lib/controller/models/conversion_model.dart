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
  final String address2;
  final String address3;
  final String address4;
  final String enquirySourceName;
  final String byUserName;
  final String toUserName;
  final DateTime? nextFollowUpDate;
  final String remark;

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
    required this.address2,
    required this.address3,
    required this.address4,
    required this.enquirySourceName,
    required this.byUserName,
    required this.toUserName,
    required this.nextFollowUpDate,
    required this.remark,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString() == 'null') return DateTime.now();
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

    DateTime? parseDateNullable(dynamic value) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString() == 'null') return null;
      String dateStr = value.toString();
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        try {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (_) {
          return null;
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
      colorCode: (json["Color_Code"] == null ||
              json["Color_Code"].toString() == 'null')
          ? ''
          : json["Color_Code"].toString(),
      customerId: json["Customer_Id"] ?? 0,
      mobile: (json['Contact_Number']?.toString() ?? '').trim(),
      address1: (json['Address1']?.toString() ?? '').trim() == '0'
          ? ''
          : (json['Address1']?.toString() ?? ''),
      address2: (json['Address2']?.toString() ?? '').trim() == '0'
          ? ''
          : (json['Address2']?.toString() ?? ''),
      address3: (json['Address3']?.toString() ?? '').trim() == '0'
          ? ''
          : (json['Address3']?.toString() ?? ''),
      address4: (json['Address4']?.toString() ?? '').trim() == '0'
          ? ''
          : (json['Address4']?.toString() ?? ''),
      enquirySourceName: json['Enquiry_Source_Name'] ?? '',
      byUserName: json['By_User_Name'] ?? json['RegisterdBy'] ?? '',
      toUserName: json['To_User_Name'] ?? '',
      nextFollowUpDate: parseDateNullable(json['Next_FollowUp_date']),
      remark: json['remark']?.toString() ?? '',
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
        'Address2': address2,
        'Address3': address3,
        'Address4': address4,
        'Enquiry_Source_Name': enquirySourceName,
        'By_User_Name': byUserName,
        'To_User_Name': toUserName,
        'Next_FollowUp_date': nextFollowUpDate?.toIso8601String(),
        'remark': remark,
      };
}
