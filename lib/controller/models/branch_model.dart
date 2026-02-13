class BranchModel {
  int? branchId;
  String? branchName;
  String? logo;
  String? address;
  String? phone;
  String? pincode;
  String? email;
  String? contactPerson;
  String? gstNo;
  String? panCardNo;
  String? bankName;
  String? bankHolderName;
  String? bankAccountNo;
  String? ifscCode;
  int? deleteStatus;

  BranchModel({
    this.branchId,
    this.branchName,
    this.logo,
    this.address,
    this.phone,
    this.pincode,
    this.email,
    this.contactPerson,
    this.gstNo,
    this.panCardNo,
    this.bankName,
    this.bankHolderName,
    this.bankAccountNo,
    this.ifscCode,
    this.deleteStatus,
  });

  BranchModel copyWith({
    int? branchId,
    String? branchName,
    String? logo,
    String? address,
    String? phone,
    String? pincode,
    String? email,
    String? contactPerson,
    String? gstNo,
    String? panCardNo,
    String? bankName,
    String? bankHolderName,
    String? bankAccountNo,
    String? ifscCode,
    int? deleteStatus,
  }) =>
      BranchModel(
        branchId: branchId ?? this.branchId,
        branchName: branchName ?? this.branchName,
        logo: logo ?? this.logo,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        pincode: pincode ?? this.pincode,
        email: email ?? this.email,
        contactPerson: contactPerson ?? this.contactPerson,
        gstNo: gstNo ?? this.gstNo,
        panCardNo: panCardNo ?? this.panCardNo,
        bankName: bankName ?? this.bankName,
        bankHolderName: bankHolderName ?? this.bankHolderName,
        bankAccountNo: bankAccountNo ?? this.bankAccountNo,
        ifscCode: ifscCode ?? this.ifscCode,
        deleteStatus: deleteStatus ?? this.deleteStatus,
      );

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        branchId: json["Branch_Id"],
        branchName: json["Branch_Name"],
        logo: json["logo"],
        address: json["address"],
        phone: json["phone"],
        pincode: json["pincode"],
        email: json["email"],
        contactPerson: json["contact_person"],
        gstNo: json["gst_no"],
        panCardNo: json["pan_card_no"],
        bankName: json["bank_name"],
        bankHolderName: json["bank_holder_name"],
        bankAccountNo: json["bank_account_no"],
        ifscCode: json["ifsc_code"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "Branch_Id": branchId,
        "Branch_Name": branchName,
        "logo": logo,
        "address": address,
        "phone": phone,
        "pincode": pincode,
        "email": email,
        "contact_person": contactPerson,
        "gst_no": gstNo,
        "pan_card_no": panCardNo,
        "bank_name": bankName,
        "bank_holder_name": bankHolderName,
        "bank_account_no": bankAccountNo,
        "ifsc_code": ifscCode,
        "delete_status": deleteStatus,
      };
}
