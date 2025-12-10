class LeadReportModel {
  int customerId;
  String customerName;
  String contactNumber;
  String contactPerson;
  String email;
  String address1;
  String address2;
  String address3;
  String address4;
  String followUpId;
  String nextFollowUpDate;
  String toUserId;
  String toUserName;
  String followUp;
  String quotationCount;
  String taskCount;
  String requestCount;
  String createdBy;
  String createdByName;
  String entryDate;
  String statusId;
  String statusName;
  String byUserId;
  String byUserName;
  String consumerNo;
  String subDistrict;
  String village;
  String section;
  String subDivision;
  String division;
  String circle;
  String connectedLoad;
  String proposedKw;
  String roofType;
  String orderNo;
  String description;
  String remark;
  String deleteStatus;
  String lateFollowUp;
  String colorCode;
  String enquiryFor;
  String enquirySourceId;
  String enquirySourceName;

  LeadReportModel({
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
    required this.consumerNo,
    required this.subDistrict,
    required this.village,
    required this.section,
    required this.subDivision,
    required this.division,
    required this.circle,
    required this.connectedLoad,
    required this.proposedKw,
    required this.roofType,
    required this.orderNo,
    required this.description,
    required this.remark,
    required this.deleteStatus,
    required this.lateFollowUp,
    required this.colorCode,
    required this.enquiryFor,
    required this.enquirySourceId,
    required this.enquirySourceName,
  });

  LeadReportModel copyWith({
    int? customerId,
    String? customerName,
    String? contactNumber,
    String? contactPerson,
    String? email,
    String? address1,
    String? address2,
    String? address3,
    String? address4,
    String? followUpId,
    String? nextFollowUpDate,
    String? toUserId,
    String? toUserName,
    String? followUp,
    String? quotationCount,
    String? taskCount,
    String? requestCount,
    String? createdBy,
    String? createdByName,
    String? entryDate,
    String? statusId,
    String? statusName,
    String? byUserId,
    String? byUserName,
    String? consumerNo,
    String? subDistrict,
    String? village,
    String? section,
    String? subDivision,
    String? division,
    String? circle,
    String? connectedLoad,
    String? proposedKw,
    String? roofType,
    String? orderNo,
    String? description,
    String? remark,
    String? deleteStatus,
    String? lateFollowUp,
    String? colorCode,
    String? enquiryFor,
    String? enquirySourceId,
    String? enquirySourceName,
  }) {
    return LeadReportModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      address4: address4 ?? this.address4,
      followUpId: followUpId ?? this.followUpId,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      followUp: followUp ?? this.followUp,
      quotationCount: quotationCount ?? this.quotationCount,
      taskCount: taskCount ?? this.taskCount,
      requestCount: requestCount ?? this.requestCount,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      entryDate: entryDate ?? this.entryDate,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      byUserId: byUserId ?? this.byUserId,
      byUserName: byUserName ?? this.byUserName,
      consumerNo: consumerNo ?? this.consumerNo,
      subDistrict: subDistrict ?? this.subDistrict,
      village: village ?? this.village,
      section: section ?? this.section,
      subDivision: subDivision ?? this.subDivision,
      division: division ?? this.division,
      circle: circle ?? this.circle,
      connectedLoad: connectedLoad ?? this.connectedLoad,
      proposedKw: proposedKw ?? this.proposedKw,
      roofType: roofType ?? this.roofType,
      orderNo: orderNo ?? this.orderNo,
      description: description ?? this.description,
      remark: remark ?? this.remark,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      lateFollowUp: lateFollowUp ?? this.lateFollowUp,
      colorCode: colorCode ?? this.colorCode,
      enquiryFor: enquiryFor ?? this.enquiryFor,
      enquirySourceId: enquirySourceId ?? this.enquirySourceId,
      enquirySourceName: enquirySourceName ?? this.enquirySourceName,
    );
  }

  factory LeadReportModel.fromJson(Map<String, dynamic> json) =>
      LeadReportModel(
          customerId: json["Customer_Id"] ?? 0,
          customerName: json["Customer_Name"]?.toString() ?? '',
          contactNumber: json["Phone_Number"]?.toString() ??
              '', // Note: API uses Phone_Number not Contact_Number
          contactPerson: json["Contact_Person"]?.toString() ?? '',
          email: json["Email"]?.toString() ?? '',
          address1: json["Address1"]?.toString() ?? '',
          address2: json["Address2"]?.toString() ?? '',
          address3: json["Address3"]?.toString() ?? '',
          address4: json["Address4"]?.toString() ?? '',
          followUpId: json["FollowUp_Id"]?.toString() ?? '0',
          nextFollowUpDate: json["Next_FollowUp_date"]?.toString() ?? '',
          toUserId: json["To_User_Id"]?.toString() ?? '0',
          toUserName: json["To_User_Name"]?.toString() ?? '',
          followUp: json["FollowUp"]?.toString() ?? '0',
          quotationCount: json["Quotation_Count"]?.toString() ?? '0',
          taskCount: json["Task_Count"]?.toString() ?? '0',
          requestCount: json["Request_Count"]?.toString() ?? '0',
          createdBy: json["Created_By"]?.toString() ?? '0',
          createdByName: json["Created_By_Name"]?.toString() ?? '',
          entryDate: json["Entry_Date"]?.toString() ?? '',
          statusId: json["Status_Id"]?.toString() ?? '0',
          statusName: json["Status_Name"]?.toString() ?? '',
          byUserId: json["By_User_Id"]?.toString() ?? '0',
          byUserName: json["By_User_Name"]?.toString() ?? '',
          consumerNo: json["Consumer_No"]?.toString() ?? '',
          subDistrict: json["Sub_District"]?.toString() ?? '',
          village: json["Village"]?.toString() ?? '',
          section: json["Section"]?.toString() ?? '',
          subDivision: json["Sub_Division"]?.toString() ?? '',
          division: json["Division"]?.toString() ?? '',
          circle: json["Circle"]?.toString() ?? '',
          connectedLoad: json["Connected_Load"]?.toString() ?? '',
          proposedKw: json["Proposed_KW"]?.toString() ?? '',
          roofType: json["Roof_Type"]?.toString() ?? '',
          orderNo: json["Order_No"]?.toString() ?? '',
          description: json["Description"]?.toString() ?? '',
          remark: json["Remark"]?.toString() ?? '',
          deleteStatus: json["DeleteStatus"]?.toString() ?? '0',
          lateFollowUp: json["Late_Followup"]?.toString() ?? '0',
          colorCode: json["Color_Code"]?.toString() ?? "Color(0xff34c759)",
          enquiryFor: json["Enquiry_For_Name"]?.toString() ?? "",
          enquirySourceName: json["Enquiry_Source_Name"]?.toString() ?? '',
          enquirySourceId: json["Enquiry_Source_Id"]?.toString() ?? '');

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone_Number": contactNumber, // Using Phone_Number to match API
        "Contact_Person": contactPerson,
        "Email": email,
        "Address1": address1,
        "Address2": address2,
        "Address3": address3,
        "Address4": address4,
        "FollowUp_Id": followUpId,
        "Next_FollowUp_date": nextFollowUpDate,
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
        "Consumer_No": consumerNo,
        "Sub_District": subDistrict,
        "Village": village,
        "Section": section,
        "Sub_Division": subDivision,
        "Division": division,
        "Circle": circle,
        "Connected_Load": connectedLoad,
        "Proposed_KW": proposedKw,
        "Roof_Type": roofType,
        "Order_No": orderNo,
        "Description": description,
        "Remark": remark,
        "DeleteStatus": deleteStatus,
        "Late_Followup": lateFollowUp,
        "Color_Code": colorCode,
        "Enquiry_For_Name": enquiryFor,
        "Enquiry_Source_Id": enquirySourceId,
        "Enquiry_Source_Name": enquirySourceName,
      };
}
