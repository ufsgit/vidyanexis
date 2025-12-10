class ServiceCustomerModel {
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
  final String toUserName;
  final String amount;

  // Constructor
  ServiceCustomerModel({
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
    required this.toUserName,
    required this.amount,
  });

  // Factory method to create a ServiceCustomerModel instance from JSON
  factory ServiceCustomerModel.fromJson(Map<String, dynamic> json) {
    return ServiceCustomerModel(
      serviceId: json['Service_Id'] ?? 0, // Default to 0 if null
      serviceNo: json['Service_No'] ?? '', // Default to empty string if null
      serviceName:
          json['Service_Name'] ?? '', // Default to empty string if null
      createDate: json['Create_Date'] ?? '',
      serviceTypeId: json['Service_Type_Id'] ?? 0, // Default to 0 if null
      serviceTypeName:
          json['Service_Type_Name'] ?? '', // Default to empty string if null
      description: json['Description'] ?? '', // Default to empty string if null
      assignedTo: json['Assigned_To'] ?? 0, // Default to 0 if null
      serviceStatusId: json['Service_Status_Id'] ?? 0, // Default to 0 if null
      serviceStatusName:
          json['Service_Status_Name'] ?? '', // Default to empty string if null
      createdBy: json['Created_By'] ?? 0, // Default to 0 if null
      serviceDate: json['Service_Date'] ?? '',
      customerId: json['Customer_Id'] ?? 0, // Default to 0 if null
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if null
      toUserName: json['To_User_Name'] ?? '', // Default to empty string if null
      amount: json['Amount'] ?? '', // Default to empty string if null
    );
  }

  // Method to convert ServiceCustomerModel instance to JSON
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
      'To_User_Name': toUserName,
      'Amount': amount,
    };
  }
}
