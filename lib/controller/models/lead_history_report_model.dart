class LeadHistoryReportModel {
  String? leadHistoryId;
  String? customerId;
  String? customerName;
  String? phoneNumber;
  String? userId;
  String? fieldName;
  String? customFieldId;
  String? oldValue;
  String? entryDate;
  String? userName;

  LeadHistoryReportModel({
    this.leadHistoryId,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.userId,
    this.fieldName,
    this.customFieldId,
    this.oldValue,
    this.entryDate,
    this.userName,
  });

  LeadHistoryReportModel.fromJson(Map<String, dynamic> json) {
    leadHistoryId = json['Lead_History_Id']?.toString() ?? '';
    customerId = json['Customer_Id']?.toString() ?? '';
    customerName = json['Customer_Name']?.toString() ?? '';
    phoneNumber = json['Phone_Number']?.toString() ?? '';
    userId = json['User_Id']?.toString() ?? '';
    fieldName = json['Field_Name']?.toString() ?? '';
    customFieldId = json['Custom_Field_Id']?.toString() ?? '';
    oldValue = json['Old_Value']?.toString() ?? '';
    entryDate = json['Entry_Date']?.toString() ?? '';
    userName = json['User_Details_Name']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Lead_History_Id'] = leadHistoryId;
    data['Customer_Id'] = customerId;
    data['Customer_Name'] = customerName;
    data['Phone_Number'] = phoneNumber;
    data['User_Id'] = userId;
    data['Field_Name'] = fieldName;
    data['Custom_Field_Id'] = customFieldId;
    data['Old_Value'] = oldValue;
    data['Entry_Date'] = entryDate;
    data['User_Name'] = userName;
    return data;
  }
}
