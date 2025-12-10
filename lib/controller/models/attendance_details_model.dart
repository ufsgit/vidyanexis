import 'package:flutter/material.dart';

class AttendanceDetails {
  final int attendanceDetailsId;
  final int attendanceMasterId;
  final int userDetailsId;
  final int status;
  final String userDetailsName;
  final String photo;
  final String employeeCode;
  final String checkInTime;
  final String checkOutTime;
  final String location;
  final String latitude;
  final String longitude;
  final String checkInDate;
  final String checkInTimeOnly;
  final String checkOutDate;
  final String checkOutTimeOnly;

  TextEditingController checkInDateControllers;
  TextEditingController checkOutDateControllers;
  TextEditingController checkInTimeControllers;
  TextEditingController checkOutTimeControllers;

  bool isEdited;
  bool isSelected;

  AttendanceDetails({
    required this.attendanceDetailsId,
    required this.attendanceMasterId,
    required this.userDetailsId,
    required this.status,
    required this.userDetailsName,
    required this.photo,
    required this.employeeCode,
    required this.checkInTime,
    required this.checkOutTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.checkInDate,
    required this.checkInTimeOnly,
    required this.checkOutDate,
    required this.checkOutTimeOnly,
    required this.checkInDateControllers,
    required this.checkOutDateControllers,
    required this.checkInTimeControllers,
    required this.checkOutTimeControllers,
    this.isEdited = false,
    this.isSelected = false,
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    String checkInDate = json['Check_In_Date']?.toString() ?? '';
    String checkOutDate = json['Check_Out_Date']?.toString() ?? '';
    String checkInTimeOnly = json['Check_In_Time_Only']?.toString() ?? '';
    String checkOutTimeOnly = json['Check_Out_Time_Only']?.toString() ?? '';

    return AttendanceDetails(
      attendanceDetailsId: json['Attendance_Details_Id'] ?? 0,
      attendanceMasterId: json['Attendance_Master_Id'] ?? 0,
      userDetailsId: json['User_Details_Id'] ?? 0,
      status: json['Status'] ?? 0,
      userDetailsName: json['User_Details_Name']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      employeeCode: json['Employee_Code']?.toString() ?? '',
      checkInTime: json['Check_In_Time']?.toString() ?? '',
      checkOutTime: json['Check_Out_Time']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      checkInDate: checkInDate,
      checkInTimeOnly: checkInTimeOnly,
      checkOutDate: checkOutDate,
      checkOutTimeOnly: checkOutTimeOnly,
      checkInDateControllers: TextEditingController(text: checkInDate),
      checkOutDateControllers: TextEditingController(text: checkOutDate),
      checkInTimeControllers: TextEditingController(text: checkInTimeOnly),
      checkOutTimeControllers: TextEditingController(text: checkOutTimeOnly),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Attendance_Details_Id': attendanceDetailsId,
      'Attendance_Master_Id': attendanceMasterId,
      'User_Details_Id': userDetailsId,
      'Status': status,
      'User_Details_Name': userDetailsName,
      'Employee_Code': employeeCode,
      'Check_In_Time': checkInTime,
      'Check_Out_Time': checkOutTime,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'Check_In_Date': checkInDate,
      'Check_In_Time_Only': checkInTimeOnly,
      'Check_Out_Date': checkOutDate,
      'Check_Out_Time_Only': checkOutTimeOnly,
    };
  }
}
