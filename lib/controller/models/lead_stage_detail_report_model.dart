class LeadStageDetailReportModel {
  int? customerId;
  String? customerName;
  String? entryDate;
  String? phoneNumber;
  String? stageName;
  String? enquiryForName;
  String? enquirySourceName;
  String? sourceCategoryName;
  String? staffName;

  LeadStageDetailReportModel({
    this.customerId,
    this.customerName,
    this.entryDate,
    this.phoneNumber,
    this.stageName,
    this.enquiryForName,
    this.enquirySourceName,
    this.sourceCategoryName,
    this.staffName,
  });

  LeadStageDetailReportModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'];
    customerName = json['Customer_Name'];
    entryDate = json['Entry_Date'];
    phoneNumber = json['Phone_Number'];
    stageName = json['Stage_Name'];
    enquiryForName = json['Enquiry_For_Name'];
    enquirySourceName = json['Enquiry_Source_Name'];
    sourceCategoryName = json['Source_Category_Name'];
    staffName = json['Staff_Name'] ?? json['Assigned_To'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer_Id'] = customerId;
    data['Customer_Name'] = customerName;
    data['Entry_Date'] = entryDate;
    data['Phone_Number'] = phoneNumber;
    data['Stage_Name'] = stageName;
    data['Enquiry_For_Name'] = enquiryForName;
    data['Enquiry_Source_Name'] = enquirySourceName;
    data['Source_Category_Name'] = sourceCategoryName;
    data['Staff_Name'] = staffName;
    return data;
  }
}
