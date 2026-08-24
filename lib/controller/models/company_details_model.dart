class CompanyPermission {
  final int companyPermissionId;
  final String caption;
  final int value;

  CompanyPermission({
    required this.companyPermissionId,
    required this.caption,
    required this.value,
  });

  String get displayCaption {
    if (caption.isNotEmpty) return caption;
    switch (companyPermissionId) {
      case 16:
        return "Document Button Task Status";
      case 17:
      case 40:
        return "Lead Permission ME and ALL";
      case 18:
      case 41:
        return "Customer Permission ME and ALL";
      case 19:
      case 42:
        return "Task Permission ME and ALL";
      case 20:
        return "Hide Warranty";
      case 23:
        return "Task Duplicate Button";
      default:
        return "Permission $companyPermissionId";
    }
  }

  factory CompanyPermission.fromJson(Map<String, dynamic> json) {
    int id = json['Company_Permission_Id'] ??
        json['company_permission_id'] ??
        json['Company_Permission_ID'] ??
        json['Permission_Id'] ??
        json['permission_id'] ??
        0;
    String cap = json['Caption'] ??
        json['caption'] ??
        json['CAPTION'] ??
        json['Caption_Name'] ??
        json['permission_name'] ??
        '';
    if (cap.isEmpty) {
      switch (id) {
        case 16:
          cap = "Document Button Task Status";
          break;
        case 17:
        case 40:
          cap = "Lead Permission ME and ALL";
          break;
        case 18:
        case 41:
          cap = "Customer Permission ME and ALL";
          break;
        case 19:
        case 42:
          cap = "Task Permission ME and ALL";
          break;
        case 20:
          cap = "Hide Warranty";
          break;
        case 23:
          cap = "Task_Duplicate_Button";
          break;
      }
    }
    return CompanyPermission(
      companyPermissionId: id,
      caption: cap,
      value: json['Value'] ?? json['value'] ?? json['VALUE'] ?? json['Status'] ?? json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Company_Permission_Id': companyPermissionId,
      'Caption': displayCaption,
      'Value': value,
    };
  }
}

class Company {
  final int companyId;
  final String companyName;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String mobileNumber;
  final String phoneNumber;
  final String email;
  final String website;
  final String logo;
  final String gstNo;
  final String panNo;
  final String cinNo;
  final String companyCode;
  final String userCount;
  final int deleteStatus;
  final int isLocation;
  final String notificationTopic;
  final int enquiryForMandatory;
  final int enquirySourceMandatory;
  final int consumerNameMandatory;
  final int consumerContactNoMandatory;
  final int leadInSales;
  final int quotationItemValue;
  final int additionalExpense;
  final int commercialProposal;
  final int districtCityMandatory;
  final int leadMobileExistedCheck;
  final int taskRemarkMandatory;
  final int residentialScopeOfWork;
  final int commercialScopeOfWork;
  final List<CompanyPermission> permissions;

  Company({
    required this.companyId,
    required this.companyName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.mobileNumber,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.logo,
    required this.gstNo,
    required this.panNo,
    required this.cinNo,
    required this.companyCode,
    required this.userCount,
    required this.deleteStatus,
    required this.isLocation,
    required this.notificationTopic,
    required this.enquiryForMandatory,
    required this.enquirySourceMandatory,
    required this.consumerNameMandatory,
    required this.consumerContactNoMandatory,
    required this.leadInSales,
    required this.quotationItemValue,
    required this.additionalExpense,
    required this.commercialProposal,
    required this.districtCityMandatory,
    required this.leadMobileExistedCheck,
    required this.taskRemarkMandatory,
    required this.residentialScopeOfWork,
    required this.commercialScopeOfWork,
    this.permissions = const [],
  });

  // Factory constructor for creating an instance from JSON with null checks
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['Company_Id'] ?? 0,
      companyName: json['Company_Name'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      address3: json['Address3'] ?? '',
      address4: json['Address4'] ?? '',
      mobileNumber: json['Mobile_Number'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      email: json['Email'] ?? '',
      website: json['Website'] ?? '',
      logo: json['Logo'] ?? '',
      gstNo: json['Gst_No'] ?? '',
      panNo: json['Pan_No'] ?? '',
      cinNo: json['Cin_No'] ?? '',
      companyCode: json['Company_Code'] ?? '',
      userCount: json['User_Count']?.toString() ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      isLocation: json['Is_Location'] ?? 0,
      notificationTopic: json['notification_topic'] ?? '',
      enquiryForMandatory: json['Enquiry_For_Mandatory'] ?? 0,
      enquirySourceMandatory: json['Enquiry_Source_Mandatory'] ?? 0,
      consumerNameMandatory: json['Consumer_Name_Mandatory'] ?? 0,
      consumerContactNoMandatory: json['Contact_Number_Mandatory'] ?? 0,
      leadInSales: json['Lead_In_Sales'] ?? 0,
      quotationItemValue: json['Quotation_Item_Value'] ?? 0,
      additionalExpense: json['Additional_Expense'] ?? 0,
      commercialProposal: json['Commercial_Proposal'] ?? 0,
      districtCityMandatory: json['District_City_Mandatory'] ?? 0,
      leadMobileExistedCheck: json['Lead_Mobile_Existed_Check'] ?? 0,
      taskRemarkMandatory: json['Task_Remark_Mandatory'] ?? 0,
      residentialScopeOfWork: json['Residential_Scope_Of_Work'] ?? 0,
      commercialScopeOfWork: json['Commercial_Scope_Of_Work'] ?? 0,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => CompanyPermission.fromJson(e))
              .toList() ??
          const [],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Company_Id': companyId,
      'Company_Name': companyName,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'Address4': address4,
      'Mobile_Number': mobileNumber,
      'Phone_Number': phoneNumber,
      'Email': email,
      'Website': website,
      'Logo': logo,
      'Gst_No': gstNo,
      'Pan_No': panNo,
      'Cin_No': cinNo,
      'Company_Code': companyCode,
      'User_Count': userCount,
      'DeleteStatus': deleteStatus,
      'Is_Location': isLocation,
      'notification_topic': notificationTopic,
      'Enquiry_For_Mandatory': enquiryForMandatory,
      'Enquiry_Source_Mandatory': enquirySourceMandatory,
      'Consumer_Name_Mandatory': consumerNameMandatory,
      'Contact_Number_Mandatory': consumerContactNoMandatory,
      'Lead_In_Sales': leadInSales,
      'Quotation_Item_Value': quotationItemValue,
      'Additional_Expense': additionalExpense,
      'Commercial_Proposal': commercialProposal,
      'District_City_Mandatory': districtCityMandatory,
      'Lead_Mobile_Existed_Check': leadMobileExistedCheck,
      'Task_Remark_Mandatory': taskRemarkMandatory,
      'Residential_Scope_Of_Work': residentialScopeOfWork,
      'Commercial_Scope_Of_Work': commercialScopeOfWork,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}
