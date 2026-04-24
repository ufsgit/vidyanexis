class SearchLeadByContactModel {
  int? customerId;
  String? customerName;
  String? contactNumber;
  String? entryDate;
  String? statusName;
  String? departmentName;
  String? toUserName;
  String? remark;
  String? nextFollowUpDate;
  String? branchName;

  SearchLeadByContactModel({
    this.customerId,
    this.customerName,
    this.contactNumber,
    this.entryDate,
    this.statusName,
    this.departmentName,
    this.toUserName,
    this.remark,
    this.nextFollowUpDate,
    this.branchName,
  });

  SearchLeadByContactModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'];
    customerName = json['Customer_Name'];
    contactNumber = json['Contact_Number'];
    entryDate = json['Entry_Date'];
    statusName = json['Status_Name'];
    departmentName = json['Department_Name'];
    toUserName = json['To_User_Name'];
    remark = json['remark'];
    nextFollowUpDate = json['Next_FollowUp_date'];
    branchName = json['Branch_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer_Id'] = customerId;
    data['Customer_Name'] = customerName;
    data['Contact_Number'] = contactNumber;
    data['Entry_Date'] = entryDate;
    data['Status_Name'] = statusName;
    data['Department_Name'] = departmentName;
    data['To_User_Name'] = toUserName;
    data['remark'] = remark;
    data['Next_FollowUp_date'] = nextFollowUpDate;
    data['Branch_Name'] = branchName;
    return data;
  }
}
