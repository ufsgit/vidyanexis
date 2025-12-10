class ServiceReportModel {
  final int serviceId;
  final String serviceNo;
  final String serviceName;
  final String createDate;
  final int serviceTypeId;
  final String serviceTypeName;
  final String description;
  final int assignedTo;
  final int serviceStatusId;
  final String serviceStatusName;
  final int createdBy;
  final String serviceDate;
  final int customerId;
  final int deleteStatus;
  final String assignedToName;
  final String amount;
  final String createdByName;
  final String customerName;
  final String mobile;
  final String address1;

  ServiceReportModel({
    required this.serviceId,
    required this.serviceNo,
    required this.serviceName,
    required this.createDate,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.description,
    required this.assignedTo,
    required this.serviceStatusId,
    required this.serviceStatusName,
    required this.createdBy,
    required this.serviceDate,
    required this.customerId,
    required this.deleteStatus,
    required this.assignedToName,
    required this.amount,
    required this.createdByName,
    required this.customerName,
    required this.mobile,
    required this.address1,
  });

  factory ServiceReportModel.fromJson(Map<String, dynamic> json) {
    return ServiceReportModel(
      serviceId: json['Service_Id'] ?? 0, // Default to 0 if null
      serviceNo: json['Service_No'] ?? '', // Nullable field
      serviceName:
          json['Service_Name'] ?? '', // Default to empty string if null
      createDate: json['Create_Date'] ?? '', // Default to empty string if null
      serviceTypeId: json['Service_Type_Id'] ?? 0, // Default to 0 if null
      serviceTypeName:
          json['Service_Type_Name'] ?? '', // Default to empty string if null
      description: json['Description'] ?? '', // Default to empty string if null
      assignedTo: json['Assigned_To'] ?? 0, // Default to 0 if null
      serviceStatusId: json['Service_Status_Id'] ?? 0, // Default to 0 if null
      serviceStatusName:
          json['Service_Status_Name'] ?? '', // Default to empty string if null
      createdBy: json['Created_By'] ?? 0, // Default to 0 if null
      serviceDate:
          json['Service_Date'] ?? '', // Default to empty string if null
      customerId: json['Customer_Id'] ?? 0, // Default to 0 if null
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if null
      assignedToName: json['Assigned_To_Name'] ?? '', // Nullable field
      amount: json['Amount'] ?? '', // Nullable field
      createdByName:
          json['Created_By_Name'] ?? '', // Default to empty string if null
      customerName:
          json['Customer_Name'] ?? '', // Default to empty string if null
      mobile: json['Contact_Number'] ?? '',
      address1: json['Address1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Service_Id': serviceId,
      'Service_No': serviceNo,
      'Service_Name': serviceName,
      'Create_Date': createDate,
      'Service_Type_Id': serviceTypeId,
      'Service_Type_Name': serviceTypeName,
      'Description': description,
      'Assigned_To': assignedTo,
      'Service_Status_Id': serviceStatusId,
      'Service_Status_Name': serviceStatusName,
      'Created_By': createdBy,
      'Service_Date': serviceDate,
      'Customer_Id': customerId,
      'DeleteStatus': deleteStatus,
      'Assigned_To_Name': assignedToName,
      'Amount': amount,
      'Created_By_Name': createdByName,
      'Customer_Name': customerName,
      'Contact_Number': mobile,
      'Address1': address1,
    };
  }
}
