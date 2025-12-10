class BranchModel {
  int? branchId;
  String? branchName;
  String? address;
  String? phone;
  String? pincode;
  String? email;
  String? contactPerson;
  int? deleteStatus;

  BranchModel({
    this.branchId,
    this.branchName,
    this.address,
    this.phone,
    this.pincode,
    this.email,
    this.contactPerson,
    this.deleteStatus,
  });

  BranchModel copyWith({
    int? branchId,
    String? branchName,
    String? address,
    String? phone,
    String? pincode,
    String? email,
    String? contactPerson,
    int? deleteStatus,
  }) =>
      BranchModel(
        branchId: branchId ?? this.branchId,
        branchName: branchName ?? this.branchName,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        pincode: pincode ?? this.pincode,
        email: email ?? this.email,
        contactPerson: contactPerson ?? this.contactPerson,
        deleteStatus: deleteStatus ?? this.deleteStatus,
      );

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        branchId: json["Branch_Id"],
        branchName: json["Branch_Name"],
        address: json["address"],
        phone: json["phone"],
        pincode: json["pincode"],
        email: json["email"],
        contactPerson: json["contact_person"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "Branch_Id": branchId,
        "Branch_Name": branchName,
        "address": address,
        "phone": phone,
        "pincode": pincode,
        "email": email,
        "contact_person": contactPerson,
        "delete_status": deleteStatus,
      };
}
