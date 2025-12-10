class WorkReportModel {
  final String customer;
  final String mobile;
  final String address1;
  final String followUp;
  final String entryDate;
  final String followUpBy;
  final String assignedTo;
  final String remark;
  final int customerId;
  final int statusId;
  final String statusName;
  final String colorCode;

  WorkReportModel(
      {required this.customer,
      required this.mobile,
      required this.address1,
      required this.followUp,
      required this.entryDate,
      required this.followUpBy,
      required this.assignedTo,
      required this.remark,
      required this.customerId,
      required this.statusId,
      required this.statusName,
      required this.colorCode});

  // Factory constructor for creating a new object from a JSON map
  factory WorkReportModel.fromJson(Map<String, dynamic> json) {
    return WorkReportModel(
      customer: json['Customer'] ?? '',
      mobile: json['Mobile'] ?? '',
      address1: json['address'] ?? '',
      followUp: json['Follow_Up'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      followUpBy: json['Follow_Up_By'] ?? '',
      assignedTo: json['Assigned_To'] ?? '',
      remark: json['Remark'] ?? '',
      customerId: json['Customer_Id'] ?? 0,
      statusId: json['Status_Id'] ?? 0,
      statusName: json['Status_Name'] ?? '',
      colorCode: json['Color_Code'] ?? 'Color(0xff34c759)',
    );
  }

  // Method to convert the object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Customer': customer,
      'Mobile': mobile,
      'Address1': address1,
      'Follow_Up': followUp,
      'Entry_Date': entryDate,
      'Follow_Up_By': followUpBy,
      'Assigned_To': assignedTo,
      'Remark': remark,
      'Customer_Id': customerId,
      'Status_Id': statusId,
      'Status_Name': statusName,
      'Color_Code': colorCode,
    };
  }
}
