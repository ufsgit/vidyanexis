class GetUserModel {
  int userDetailsId;
  String userDetailsName;
  String password;
  String workingStatus;
  String allowAppLogin;
  String userType;
  String roleId;
  String address1;
  String address2;
  String address3;
  String address4;
  String mobile;
  String email;
  String? otp;
  String countryCodeId;
  String countryCodeName;
  String departmentName;
  String departmentId;
  String branchName;
  String branchId;
  String deleteStatus;
  String empCode;
  String designation;
  String doj;

  GetUserModel(
      {required this.userDetailsId,
      required this.userDetailsName,
      required this.password,
      required this.workingStatus,
      required this.userType,
      required this.roleId,
      required this.address1,
      required this.address2,
      required this.address3,
      required this.address4,
      required this.mobile,
      required this.email,
      required this.otp,
      required this.countryCodeId,
      required this.countryCodeName,
      required this.deleteStatus,
      required this.departmentId,
      required this.departmentName,
      required this.branchId,
      required this.branchName,
      required this.empCode,
      required this.designation,
      required this.doj,
      required this.allowAppLogin});

  factory GetUserModel.fromJson(Map<String, dynamic> json) => GetUserModel(
      userDetailsId: json["User_Details_Id"] ?? 0,
      userDetailsName: json["User_Details_Name"] ?? '',
      password: json["Password"]?.toString() ?? '0',
      workingStatus: json["Working_Status"]?.toString() ?? '0',
      userType: json["User_Type"]?.toString() ?? '0',
      roleId: json["Role_Id"]?.toString() ?? '0',
      address1: json["Address1"] ?? '',
      address2: json["Address2"] ?? '',
      address3: json["Address3"] ?? '',
      address4: json["Address4"] ?? '',
      mobile: json["Mobile"]?.toString() ?? '',
      email: json["Email"] ?? '',
      otp: json["OTP"]?.toString() ?? '0',
      countryCodeId: json["Country_Code_Id"]?.toString() ?? '0',
      countryCodeName: json["Country_Code_Name"]?.toString() ?? '',
      deleteStatus: json["DeleteStatus"]?.toString() ?? '0',
      allowAppLogin: json["Allow_App_Login"]?.toString() ?? '0',
      empCode: json["Employee_Code"]?.toString() ?? "",
      designation: json["Designation"]?.toString() ?? "",
      doj: json["DOJ"]?.toString() ?? "",
      branchId: json["Branch_Id"]?.toString() ?? '0',
      branchName: json["Branch_Name"] ?? '',
      departmentId: json["Department_Id"]?.toString() ?? '0',
      departmentName: json["Department_Name"]?.toString() ?? '');

  Map<String, dynamic> toJson() => {
        "User_Details_Id": userDetailsId,
        "User_Details_Name": userDetailsName,
        "Password": password,
        "Working_Status": workingStatus,
        "User_Type": userType,
        "Role_Id": roleId,
        "Address1": address1,
        "Address2": address2,
        "Address3": address3,
        "Address4": address4,
        "Mobile": mobile,
        "Email": email,
        "OTP": otp,
        "Country_Code_Id": countryCodeId,
        "Country_Code_Name": countryCodeName,
        "DeleteStatus": deleteStatus,
        "Allow_App_Login": allowAppLogin,
        "Department_Id": departmentId,
      };
}
