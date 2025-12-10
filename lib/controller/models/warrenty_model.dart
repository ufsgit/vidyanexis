class WarrentyModel {
  final String customerId;
  final String customerName;
  final String contactNumber;
  final String contactPerson;
  final String email;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String followUpId;
  final String nextFollowUpDate;
  final String lateFollowUp;
  final String toUserId;
  final String toUserName;
  final String followUp;
  final String quotationCount;
  final String taskCount;
  final String requestCount;
  final String createdBy;
  final String createdByName;
  final String entryDate;
  final String statusId;
  final String statusName;
  final String byUserId;
  final String byUserName;
  final String enquirySourceId;
  final String enquirySourceName;
  final String mapLink;
  final String pincode;
  final String refPerson;
  final String refContactNo;
  final String description;
  final String orderNo;
  final String registeredBy;
  final String registeredDate;
  final String registrationNo;
  final String installationDate;
  final String expiryDate;

  WarrentyModel({
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.contactPerson,
    required this.email,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.followUpId,
    required this.nextFollowUpDate,
    required this.lateFollowUp,
    required this.toUserId,
    required this.toUserName,
    required this.followUp,
    required this.quotationCount,
    required this.taskCount,
    required this.requestCount,
    required this.createdBy,
    required this.createdByName,
    required this.entryDate,
    required this.statusId,
    required this.statusName,
    required this.byUserId,
    required this.byUserName,
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.mapLink,
    required this.pincode,
    required this.refPerson,
    required this.refContactNo,
    required this.description,
    required this.orderNo,
    required this.registeredBy,
    required this.registeredDate,
    required this.registrationNo,
    required this.installationDate,
    required this.expiryDate,
  });

  /// Convert JSON to Model (Ensuring Everything is a String)
  factory WarrentyModel.fromJson(Map<String, dynamic> json) {
    return WarrentyModel(
      customerId: json['Customer_Id']?.toString() ?? "0",
      customerName: json['Customer_Name']?.toString() ?? "",
      contactNumber: json['Contact_Number']?.toString() ?? "",
      contactPerson: json['Contact_Person']?.toString() ?? "",
      email: json['Email']?.toString() ?? "",
      address1: json['Address1']?.toString() ?? "",
      address2: json['Address2']?.toString() ?? "",
      address3: json['Address3']?.toString() ?? "",
      address4: json['Address4']?.toString() ?? "",
      followUpId: json['FollowUp_Id']?.toString() ?? "0",
      nextFollowUpDate: json['Next_FollowUp_date']?.toString() ?? "",
      lateFollowUp: json['Late_Followup']?.toString() ?? "0",
      toUserId: json['To_User_Id']?.toString() ?? "0",
      toUserName: json['To_User_Name']?.toString() ?? "",
      followUp: json['FollowUp']?.toString() ?? "0",
      quotationCount: json['Quotation_Count']?.toString() ?? "0",
      taskCount: json['Task_Count']?.toString() ?? "0",
      requestCount: json['Request_Count']?.toString() ?? "0",
      createdBy: json['Created_By']?.toString() ?? "0",
      createdByName: json['Created_By_Name']?.toString() ?? "",
      entryDate: json['Entry_Date']?.toString() ?? "",
      statusId: json['Status_Id']?.toString() ?? "0",
      statusName: json['Status_Name']?.toString() ?? "",
      byUserId: json['By_User_Id']?.toString() ?? "0",
      byUserName: json['By_User_Name']?.toString() ?? "",
      enquirySourceId: json['Enquiry_Source_Id']?.toString() ?? "0",
      enquirySourceName: json['Enquiry_Source_Name']?.toString() ?? "",
      mapLink: json['Map_Link']?.toString() ?? "",
      pincode: json['Pincode']?.toString() ?? "",
      refPerson: json['Ref_Person']?.toString() ?? "",
      refContactNo: json['Ref_Contact_No']?.toString() ?? "",
      description: json['Description']?.toString() ?? "",
      orderNo: json['Order_No']?.toString() ?? "",
      registeredBy: json['Registered_By']?.toString() ?? "",
      registeredDate: json['Registered_Date']?.toString() ?? "",
      registrationNo: json['Registration_No']?.toString() ?? "",
      installationDate: json['Installation_Date']?.toString() ?? "",
      expiryDate: json['Expiry_Date']?.toString() ?? "",
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      "Customer_Id": customerId,
      "Customer_Name": customerName,
      "Contact_Number": contactNumber,
      "Contact_Person": contactPerson,
      "Email": email,
      "Address1": address1,
      "Address2": address2,
      "Address3": address3,
      "Address4": address4,
      "FollowUp_Id": followUpId,
      "Next_FollowUp_date": nextFollowUpDate,
      "Late_Followup": lateFollowUp,
      "To_User_Id": toUserId,
      "To_User_Name": toUserName,
      "FollowUp": followUp,
      "Quotation_Count": quotationCount,
      "Task_Count": taskCount,
      "Request_Count": requestCount,
      "Created_By": createdBy,
      "Created_By_Name": createdByName,
      "Entry_Date": entryDate,
      "Status_Id": statusId,
      "Status_Name": statusName,
      "By_User_Id": byUserId,
      "By_User_Name": byUserName,
      "Enquiry_Source_Id": enquirySourceId,
      "Enquiry_Source_Name": enquirySourceName,
      "Map_Link": mapLink,
      "Pincode": pincode,
      "Ref_Person": refPerson,
      "Ref_Contact_No": refContactNo,
      "Description": description,
      "Order_No": orderNo,
      "Registered_By": registeredBy,
      "Registered_Date": registeredDate,
      "Registration_No": registrationNo,
    };
  }
}
