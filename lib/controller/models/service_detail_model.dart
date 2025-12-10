class ServiceDetailsModel {
  final int serviceId;
  final String serviceNo;
  final String serviceName;
  final String createDate;
  final String serviceDate;
  final int serviceTypeId;
  final String serviceTypeName;
  final String description;
  final String amount;
  final int assignedTo;
  final int serviceStatusId;
  final String serviceStatusName;
  final int createdBy;

  ServiceDetailsModel({
    required this.serviceId,
    required this.serviceNo,
    required this.serviceName,
    required this.createDate,
    required this.serviceDate,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.description,
    required this.amount,
    required this.assignedTo,
    required this.serviceStatusId,
    required this.serviceStatusName,
    required this.createdBy,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      serviceId: json['Service_Id'] ?? 0,
      serviceNo: json['Service_No'] ?? '',
      serviceName: json['Service_Name'] ?? '',
      createDate: json['Create_Date'] ?? '',
      serviceDate: json['Service_Date'] ?? '',
      serviceTypeId: json['Service_Type_Id'] ?? 0,
      serviceTypeName: json['Service_Type_Name'] ?? '',
      description: json['Description'] ?? '',
      amount: json['Amount'] ?? '',
      assignedTo: json['Assigned_To'] ?? 0,
      serviceStatusId: json['Service_Status_Id'] ?? 0,
      serviceStatusName: json['Service_Status_Name'] ?? '',
      createdBy: json['Created_By'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Service_Id': serviceId,
      'Service_No': serviceNo,
      'Service_Name': serviceName,
      'Create_Date': createDate,
      'Service_Date': serviceDate,
      'Service_Type_Id': serviceTypeId,
      'Service_Type_Name': serviceTypeName,
      'Description': description,
      'Amount': amount,
      'Assigned_To': assignedTo,
      'Service_Status_Id': serviceStatusId,
      'Service_Status_Name': serviceStatusName,
      'Created_By': createdBy,
    };
  }
}
