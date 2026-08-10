import 'package:flutter/material.dart';

class TravelAllowanceModel {
  int? taId;
  int? userId;
  String? userName;
  String? travelDate;
  String? travelMode;
  String? fromLocation;
  String? toLocation;
  double? startOdometer;
  double? endOdometer;
  double? totalKm;
  double? ratePerKm;
  double? otherExpenses;
  String? otherExpenseRemark;
  double? totalAmount;
  String? purpose;
  String? status; // 'Pending', 'Approved', 'Rejected', 'Paid'
  String? attachmentUrl;
  String? adminRemark;
  String? createdDate;
  String? updatedDate;
  String? approvedBy;
  String? approvedAt;
  String? deleteStatus;

  TravelAllowanceModel({
    this.taId,
    this.userId,
    this.userName,
    this.travelDate,
    this.travelMode,
    this.fromLocation,
    this.toLocation,
    this.startOdometer,
    this.endOdometer,
    this.totalKm,
    this.ratePerKm,
    this.otherExpenses,
    this.otherExpenseRemark,
    this.totalAmount,
    this.purpose,
    this.status,
    this.attachmentUrl,
    this.adminRemark,
    this.createdDate,
    this.updatedDate,
    this.approvedBy,
    this.approvedAt,
    this.deleteStatus,
  });

  factory TravelAllowanceModel.fromJson(Map<String, dynamic> json) {
    return TravelAllowanceModel(
      taId: json['taId'] != null
          ? int.tryParse(json['taId'].toString())
          : json['TA_Master_Id'] != null
              ? int.tryParse(json['TA_Master_Id'].toString())
              : json['ta_master_id'] != null
                  ? int.tryParse(json['ta_master_id'].toString())
                  : json['id'] != null
                      ? int.tryParse(json['id'].toString())
                      : null,
      userId: json['userId'] != null
          ? int.tryParse(json['userId'].toString())
          : json['User_Id'] != null
              ? int.tryParse(json['User_Id'].toString())
              : json['staff_id'] != null
                  ? int.tryParse(json['staff_id'].toString())
                  : null,
      userName: json['userName'] ?? json['User_Name'] ?? json['staff_name'] ?? json['user'] ?? '',
      travelDate: json['travelDate'] ?? json['Travel_Date'] ?? json['travel_date'] ?? json['date'] ?? '',
      travelMode: json['travelMode'] ?? json['Travel_Mode'] ?? json['travel_mode'] ?? 'Bike',
      fromLocation: json['fromLocation'] ?? json['From_Location'] ?? json['from_location'] ?? '',
      toLocation: json['toLocation'] ?? json['To_Location'] ?? json['to_location'] ?? '',
      startOdometer: json['startOdometer'] != null
          ? double.tryParse(json['startOdometer'].toString())
          : json['Start_Odometer'] != null
              ? double.tryParse(json['Start_Odometer'].toString())
              : json['start_odometer'] != null
                  ? double.tryParse(json['start_odometer'].toString())
                  : 0.0,
      endOdometer: json['endOdometer'] != null
          ? double.tryParse(json['endOdometer'].toString())
          : json['End_Odometer'] != null
              ? double.tryParse(json['End_Odometer'].toString())
              : json['end_odometer'] != null
                  ? double.tryParse(json['end_odometer'].toString())
                  : 0.0,
      totalKm: json['totalKm'] != null
          ? double.tryParse(json['totalKm'].toString())
          : json['Total_Km'] != null
              ? double.tryParse(json['Total_Km'].toString())
              : json['distance_travelled'] != null
                  ? double.tryParse(json['distance_travelled'].toString())
                  : 0.0,
      ratePerKm: json['ratePerKm'] != null
          ? double.tryParse(json['ratePerKm'].toString())
          : json['Rate_Per_Km'] != null
              ? double.tryParse(json['Rate_Per_Km'].toString())
              : 0.0,
      otherExpenses: json['otherExpenses'] != null
          ? double.tryParse(json['otherExpenses'].toString())
          : json['Other_Expenses'] != null
              ? double.tryParse(json['Other_Expenses'].toString())
              : 0.0,
      otherExpenseRemark: json['otherExpenseRemark'] ??
          json['Other_Expense_Remark'] ??
          '',
      totalAmount: json['totalAmount'] != null
          ? double.tryParse(json['totalAmount'].toString())
          : json['Total_Amount'] != null
              ? double.tryParse(json['Total_Amount'].toString())
              : json['ta_amount'] != null
                  ? double.tryParse(json['ta_amount'].toString())
                  : 0.0,
      purpose: json['purpose'] ?? json['Purpose'] ?? json['description'] ?? '',
      status: json['status'] ?? json['Status'] ?? json['approval_status'] ?? 'Pending',
      attachmentUrl:
          json['attachmentUrl'] ?? json['Attachment_Url'] ?? json['file'] ?? '',
      adminRemark: json['adminRemark'] ?? json['Admin_Remark'] ?? json['rejection_reason'] ?? '',
      createdDate: json['createdDate'] ?? json['Created_Date'] ?? json['created_at'] ?? '',
      updatedDate: json['updatedDate'] ?? json['Updated_Date'] ?? json['updated_at'] ?? '',
      approvedBy: json['approvedBy'] ?? json['Approved_By'] ?? json['approved_by'] ?? '',
      approvedAt: json['approvedAt'] ?? json['Approved_At'] ?? json['approved_at'] ?? '',
      deleteStatus: json['deleteStatus'] ?? json['Delete_Status'] ?? json['delete_status'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': taId ?? 0,
      'taId': taId ?? 0,
      'TA_Master_Id': taId ?? 0,
      'ta_master_id': taId ?? 0,
      'staff_id': userId ?? 0,
      'userId': userId ?? 0,
      'User_Id': userId ?? 0,
      'userName': userName ?? '',
      'User_Name': userName ?? '',
      'travel_date': travelDate ?? '',
      'travelDate': travelDate ?? '',
      'Travel_Date': travelDate ?? '',
      'travelMode': travelMode ?? 'Bike',
      'from_location': fromLocation ?? '',
      'fromLocation': fromLocation ?? '',
      'From_Location': fromLocation ?? '',
      'to_location': toLocation ?? '',
      'toLocation': toLocation ?? '',
      'To_Location': toLocation ?? '',
      'startOdometer': startOdometer ?? 0.0,
      'Start_Odometer': startOdometer ?? 0.0,
      'endOdometer': endOdometer ?? 0.0,
      'End_Odometer': endOdometer ?? 0.0,
      'distance_travelled': computedTotalKm,
      'totalKm': computedTotalKm,
      'Total_Km': computedTotalKm,
      'ratePerKm': ratePerKm ?? 0.0,
      'Rate_Per_Km': ratePerKm ?? 0.0,
      'otherExpenses': otherExpenses ?? 0.0,
      'Other_Expenses': otherExpenses ?? 0.0,
      'otherExpenseRemark': otherExpenseRemark ?? '',
      'Other_Expense_Remark': otherExpenseRemark ?? '',
      'ta_amount': computedTotalAmount,
      'totalAmount': computedTotalAmount,
      'Total_Amount': computedTotalAmount,
      'purpose': purpose ?? '',
      'Purpose': purpose ?? '',
      'approval_status': status ?? 'Pending',
      'status': status ?? 'Pending',
      'Status': status ?? 'Pending',
      'attachmentUrl': attachmentUrl ?? '',
      'Attachment_Url': attachmentUrl ?? '',
      'rejection_reason': adminRemark ?? '',
      'adminRemark': adminRemark ?? '',
      'Admin_Remark': adminRemark ?? '',
      'created_at': createdDate ?? '',
      'createdDate': createdDate ?? '',
      'Created_Date': createdDate ?? '',
      'updated_at': updatedDate ?? '',
      'updatedDate': updatedDate ?? '',
      'Updated_Date': updatedDate ?? '',
      'approved_by': approvedBy ?? '',
      'approvedBy': approvedBy ?? '',
      'Approved_By': approvedBy ?? '',
      'approved_at': approvedAt ?? '',
      'approvedAt': approvedAt ?? '',
      'Approved_At': approvedAt ?? '',
      'delete_status': deleteStatus ?? '0',
      'deleteStatus': deleteStatus ?? '0',
      'Delete_Status': deleteStatus ?? '0',
    };
  }

  double get computedTotalKm {
    if (totalKm != null && totalKm! > 0) return totalKm!;
    if (endOdometer != null && startOdometer != null && endOdometer! > startOdometer!) {
      return endOdometer! - startOdometer!;
    }
    return 0.0;
  }

  double get computedTotalAmount {
    if (totalAmount != null && totalAmount! > 0) return totalAmount!;
    final kmAmount = computedTotalKm * (ratePerKm ?? 0.0);
    return kmAmount + (otherExpenses ?? 0.0);
  }

  Color get statusColor {
    switch ((status ?? 'Pending').toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A); // Green
      case 'rejected':
        return const Color(0xFFDC2626); // Red
      case 'paid':
      case 'settled':
        return const Color(0xFF2563EB); // Blue
      case 'pending':
      default:
        return const Color(0xFFD97706); // Amber / Orange
    }
  }

  IconData get travelModeIcon {
    switch ((travelMode ?? 'bike').toLowerCase()) {
      case 'bike':
      case 'motorcycle':
      case 'two wheeler':
        return Icons.two_wheeler_rounded;
      case 'car':
      case 'four wheeler':
        return Icons.directions_car_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'flight':
      case 'airplane':
        return Icons.flight_rounded;
      case 'auto':
      case 'taxi':
      case 'cab':
        return Icons.local_taxi_rounded;
      default:
        return Icons.commute_rounded;
    }
  }
}
