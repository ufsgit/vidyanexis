import 'package:intl/intl.dart';

class DuplicateEntryAttemptsModel {
  final int? attemptId;
  final String? duplicateType;
  final String? phoneNumber;
  final String? consumerNumber;
  final String? aadhaarNo;
  final int? existingCustomerId;
  final String? existingCustomerName;
  final String? existingPhoneNumber;
  final int? userDetailsId;
  final String? attemptedBy;
  final String? attemptDate;

  DuplicateEntryAttemptsModel({
    this.attemptId,
    this.duplicateType,
    this.phoneNumber,
    this.consumerNumber,
    this.aadhaarNo,
    this.existingCustomerId,
    this.existingCustomerName,
    this.existingPhoneNumber,
    this.userDetailsId,
    this.attemptedBy,
    this.attemptDate,
  });

  factory DuplicateEntryAttemptsModel.fromJson(Map<String, dynamic> json) {
    return DuplicateEntryAttemptsModel(
      attemptId: json['Attempt_Id'] != null
          ? int.tryParse(json['Attempt_Id'].toString())
          : null,
      duplicateType: json['Duplicate_Type']?.toString(),
      phoneNumber: json['Phone_Number']?.toString(),
      consumerNumber: json['Consumer_Number']?.toString(),
      aadhaarNo: json['Aadhaar_No']?.toString(),
      existingCustomerId: json['Existing_Customer_Id'] != null
          ? int.tryParse(json['Existing_Customer_Id'].toString())
          : null,
      existingCustomerName: json['Existing_Customer_Name']?.toString(),
      existingPhoneNumber: json['Existing_Phone_Number']?.toString(),
      userDetailsId: json['User_Details_Id'] != null
          ? int.tryParse(json['User_Details_Id'].toString())
          : null,
      attemptedBy: json['Attempted_By']?.toString(),
      attemptDate: json['Attempt_Date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Attempt_Id': attemptId,
      'Duplicate_Type': duplicateType,
      'Phone_Number': phoneNumber,
      'Consumer_Number': consumerNumber,
      'Aadhaar_No': aadhaarNo,
      'Existing_Customer_Id': existingCustomerId,
      'Existing_Customer_Name': existingCustomerName,
      'Existing_Phone_Number': existingPhoneNumber,
      'User_Details_Id': userDetailsId,
      'Attempted_By': attemptedBy,
      'Attempt_Date': attemptDate,
    };
  }

  DateTime? get _parsedDateTime {
    if (attemptDate == null || attemptDate!.isEmpty || attemptDate == 'null') {
      return null;
    }
    try {
      return DateTime.parse(attemptDate!);
    } catch (_) {}
    try {
      return DateFormat('dd-MM-yyyy HH:mm:ss').parse(attemptDate!);
    } catch (_) {}
    return null;
  }

  String get formattedDate {
    final dt = _parsedDateTime;
    if (dt != null) {
      return DateFormat('dd-MM-yyyy').format(dt);
    }
    return 'N/A';
  }

  String get formattedTime {
    final dt = _parsedDateTime;
    if (dt != null) {
      return DateFormat('hh:mm a').format(dt);
    }
    return 'N/A';
  }
}
