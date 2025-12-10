import 'package:vidyanexis/controller/models/task_customer_model.dart';

class SearchLeadModel {
  // ─────────────────── Core Fields ───────────────────
  final int customerId;
  final String customerName;
  final String contactNumber;
  final String contactPerson;
  final String email;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final int followUpId;
  final String nextFollowUpDate;
  final int toUserId;
  final String toUserName;
  final int followUp;
  final int quotationCount;
  final int taskCount;
  final int requestCount;
  final int createdBy;
  final String createdByName;
  final String entryDate;
  final int statusId;
  final String statusName;
  final int byUserId;
  final String byUserName;
  final String consumerNo;
  final String subDistrict;
  final String village;
  final String section;
  final String subDivision;
  final String division;
  final String circle;
  final String connectedLoad;
  final String proposedKw;
  final String roofType;
  final String orderNo;
  final String description;
  final String remark;
  final int deleteStatus;
  final int lateFollowUp;
  final String colorCode;
  final String enquiryFor;
  final int enquirySourceId;
  final String enquirySourceName;

  // ─────────────────── Additional Fields ───────────────────
  final int tp;
  final String address;
  final String phoneNumber;
  final int isRegistered;
  final String registeredBy;
  final String registeredDate;
  final String registrationNo;
  final int enquiryForId;
  final String stageId;
  final String stageName;
  final String sourceCategoryId;
  final String sourceCategoryName;
  final String districtId;
  final String departmentId;
  final String departmentName;
  final String referenceName;
  final String branchName;
  final int branchId;
  final int rowNo;
  final List<AudioFileLead> audioFiles;

  String? appointmentDate;
  int? appointment;
  int? siteVisit;
  String? siteVisitDate;
  String? quoteProvidedDate;
  int? quoteProvidedToCustomer;
  String? revisitDate;
  int? revisitDone;
  int? leadTypeId;
  String? leadTypeName;
  String? age;
  String? peName;
  String? peId;
  String? creId;
  String? creName;
  SearchLeadModel({
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
    required this.tp,
    required this.address,
    required this.phoneNumber,
    required this.isRegistered,
    required this.registeredBy,
    required this.registeredDate,
    required this.registrationNo,
    required this.enquiryForId,
    required this.stageId,
    required this.stageName,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.districtId,
    required this.departmentId,
    required this.departmentName,
    required this.referenceName,
    required this.branchName,
    required this.branchId,
    required this.rowNo,
    required this.audioFiles,
    this.appointmentDate,
    this.appointment,
    this.siteVisit,
    this.siteVisitDate,
    this.quoteProvidedDate,
    this.quoteProvidedToCustomer,
    this.revisitDate,
    this.revisitDone,
    this.leadTypeId,
    this.leadTypeName,
    this.age,
    this.peName,
    this.peId,
    this.creId,
    this.creName,
  });

  factory SearchLeadModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) => value?.toString() ?? '';

    return SearchLeadModel(
      customerId: parseInt(json['Customer_Id']),
      customerName: parseString(json['Customer_Name']),
      contactNumber: parseString(json['Contact_Number']),
      contactPerson: parseString(json['Contact_Person']),
      email: parseString(json['Email']),
      branchName: parseString(json['Branch_Name']),
      branchId: parseInt(json['Branch_Id']),
      address1: parseString(json['Address1']),
      address2: parseString(json['Address2']),
      address3: parseString(json['Address3']),
      address4: parseString(json['Address4']),
      followUpId: parseInt(json['FollowUp_Id']),
      nextFollowUpDate: parseString(json['Next_FollowUp_date']),
      toUserId: parseInt(json['To_User_Id']),
      toUserName: parseString(json['To_User_Name']),
      followUp: parseInt(json['FollowUp']),
      quotationCount: parseInt(json['Quotation_Count']),
      taskCount: parseInt(json['Task_Count']),
      requestCount: parseInt(json['Request_Count']),
      createdBy: parseInt(json['Created_By']),
      createdByName: parseString(json['Created_By_Name']),
      entryDate: parseString(json['Entry_Date']),
      statusId: parseInt(json['Status_Id']),
      statusName: parseString(json['Status_Name']),
      byUserId: parseInt(json['By_User_Id']),
      byUserName: parseString(json['By_User_Name']),
      consumerNo: parseString(json['Consumer_No']),
      subDistrict: parseString(json['Sub_District']),
      village: parseString(json['Village']),
      section: parseString(json['Section']),
      subDivision: parseString(json['Sub_Division']),
      division: parseString(json['Division']),
      circle: parseString(json['Circle']),
      connectedLoad: parseString(json['Connected_Load']),
      proposedKw: parseString(json['Proposed_KW']),
      roofType: parseString(json['Roof_Type']),
      orderNo: parseString(json['Order_No']),
      description: parseString(json['Description']),
      remark: parseString(json['Remark']),
      deleteStatus: parseInt(json['DeleteStatus']),
      lateFollowUp: parseInt(json['Late_Followup']),
      colorCode: parseString(json['Color_Code']),
      enquiryFor: parseString(json['Enquiry_For_Name']),
      enquirySourceId: parseInt(json['Enquiry_Source_Id']),
      enquirySourceName: parseString(json['Enquiry_Source_Name']),
      tp: parseInt(json['tp']),
      address: parseString(json['address']),
      phoneNumber: parseString(json['Phone_Number']),
      isRegistered: parseInt(json['Is_Registered']),
      registeredBy: parseString(json['Registered_By']),
      registeredDate: parseString(json['Registered_Date']),
      registrationNo: parseString(json['Registration_No']),
      enquiryForId: parseInt(json['Enquiry_For_Id']),
      stageId: parseString(json['Stage_Id']),
      stageName: parseString(json['Stage_Name']),
      sourceCategoryId: parseString(json['Source_Category_Id']),
      sourceCategoryName: parseString(json['Source_Category_Name']),
      districtId: parseString(json['District_Id']),
      departmentId: parseString(json['Department_Id']),
      departmentName: parseString(json['Department_Name']),
      referenceName: parseString(json['Reference_Name']),
      rowNo: parseInt(json['RowNo']),
      appointmentDate: json["Appointment_Date"] ?? "",
      appointment: int.tryParse(json["Appointment"]?.toString() ?? "0") ?? 0,
      siteVisit: int.tryParse(json["Site_Visit"]?.toString() ?? "0") ?? 0,
      siteVisitDate: json["Site_Visit_Date"] ?? "",
      quoteProvidedDate: json["Quote_Provided_Date"] ?? "",
      quoteProvidedToCustomer:
          int.tryParse(json["Quote_Provided_To_Customer"]?.toString() ?? "0") ??
              0,
      revisitDate: json["Revisit_Date"] ?? "",
      revisitDone: int.tryParse(json["Revisit_Done"]?.toString() ?? "0") ?? 0,
      leadTypeId: int.tryParse(json["Lead_Type_Id"]?.toString() ?? "0") ?? 0,
      leadTypeName: json["Lead_Type_Name"],
      age: json["Age"],
      peName: json["PE_Name"],
      peId: json["PE_Id"],
      creId: json["CRE_Id"],
      creName: json["CRE_Name"],
      audioFiles: (json['Audio_Files'] != null && json['Audio_Files'] is List)
          ? (json['Audio_Files'] as List<dynamic>)
              .map((item) => AudioFileLead.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Contact_Number': contactNumber,
      'Branch_Id': branchId,
      'Contact_Person': contactPerson,
      'Email': email,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'Address4': address4,
      'FollowUp_Id': followUpId,
      'Next_FollowUp_date': nextFollowUpDate,
      'To_User_Id': toUserId,
      'To_User_Name': toUserName,
      'FollowUp': followUp,
      'Quotation_Count': quotationCount,
      'Task_Count': taskCount,
      'Request_Count': requestCount,
      'Created_By': createdBy,
      'Created_By_Name': createdByName,
      'Entry_Date': entryDate,
      'Status_Id': statusId,
      'Status_Name': statusName,
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
      'Consumer_No': consumerNo,
      'Sub_District': subDistrict,
      'Village': village,
      'Section': section,
      'Sub_Division': subDivision,
      'Division': division,
      'Circle': circle,
      'Connected_Load': connectedLoad,
      'Proposed_KW': proposedKw,
      'Roof_Type': roofType,
      'Order_No': orderNo,
      'Description': description,
      'Remark': remark,
      'DeleteStatus': deleteStatus,
      'Late_Followup': lateFollowUp,
      'Color_Code': colorCode,
      'Enquiry_For_Name': enquiryFor,
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'tp': tp,
      'address': address,
      'Phone_Number': phoneNumber,
      'Is_Registered': isRegistered,
      'Registered_By': registeredBy,
      'Registered_Date': registeredDate,
      'Registration_No': registrationNo,
      'Enquiry_For_Id': enquiryForId,
      'Stage_Id': stageId,
      'Stage_Name': stageName,
      'Source_Category_Id': sourceCategoryId,
      'Source_Category_Name': sourceCategoryName,
      'District_Id': districtId,
      'Department_Id': departmentId,
      'Department_Name': departmentName,
      'Reference_Name': referenceName,
      'Branch_Name': branchName,
      'RowNo': rowNo,
      "Appointment_Date": appointmentDate,
      "Appointment": appointment,
      "Site_Visit": siteVisit,
      "Site_Visit_Date": siteVisitDate,
      "Quote_Provided_Date": quoteProvidedDate,
      "Quote_Provided_To_Customer": quoteProvidedToCustomer,
      "Revisit_Date": revisitDate,
      "Revisit_Done": revisitDone,
      "Lead_Type_Id": leadTypeId,
      "Lead_Type_Name": leadTypeName,
      "Age": age,
      "PE_Name": peName,
      "PE_Id": peId,
      "CRE_Id": creId,
      "CRE_Name": creName,
    };
  }

  SearchLeadModel copyWith({
    int? customerId,
    String? customerName,
    String? contactNumber,
    String? contactPerson,
    String? email,
    String? address1,
    String? address2,
    String? address3,
    String? address4,
    int? followUpId,
    String? nextFollowUpDate,
    int? toUserId,
    String? toUserName,
    int? followUp,
    int? quotationCount,
    int? taskCount,
    int? requestCount,
    int? createdBy,
    String? createdByName,
    String? entryDate,
    int? statusId,
    String? statusName,
    int? byUserId,
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
    int? deleteStatus,
    int? lateFollowUp,
    String? colorCode,
    String? enquiryFor,
    int? enquirySourceId,
    String? enquirySourceName,
    int? tp,
    String? address,
    String? phoneNumber,
    int? isRegistered,
    String? registeredBy,
    String? registeredDate,
    String? registrationNo,
    int? enquiryForId,
    String? stageId,
    String? stageName,
    String? sourceCategoryId,
    String? sourceCategoryName,
    String? districtId,
    String? departmentId,
    String? departmentName,
    String? referenceName,
    String? branchName,
    int? branchId,
    int? rowNo,
    String? appointmentDate,
    int? appointment,
    int? siteVisit,
    String? siteVisitDate,
    String? quoteProvidedDate,
    int? quoteProvidedToCustomer,
    String? revisitDate,
    int? revisitDone,
    int? leadTypeId,
    String? leadTypeName,
    String? age,
    String? peName,
    String? peId,
    String? creId,
    String? creName,
    List<AudioFileLead>? audioFiles,
  }) {
    return SearchLeadModel(
      audioFiles: audioFiles ?? this.audioFiles,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      branchId: branchId ?? this.branchId,
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
      tp: tp ?? this.tp,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isRegistered: isRegistered ?? this.isRegistered,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredDate: registeredDate ?? this.registeredDate,
      registrationNo: registrationNo ?? this.registrationNo,
      enquiryForId: enquiryForId ?? this.enquiryForId,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      sourceCategoryId: sourceCategoryId ?? this.sourceCategoryId,
      sourceCategoryName: sourceCategoryName ?? this.sourceCategoryName,
      districtId: districtId ?? this.districtId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      referenceName: referenceName ?? this.referenceName,
      branchName: branchName ?? this.branchName,
      rowNo: rowNo ?? this.rowNo,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointment: appointment ?? this.appointment,
      siteVisit: siteVisit ?? this.siteVisit,
      siteVisitDate: siteVisitDate ?? this.siteVisitDate,
      quoteProvidedDate: quoteProvidedDate ?? this.quoteProvidedDate,
      quoteProvidedToCustomer:
          quoteProvidedToCustomer ?? this.quoteProvidedToCustomer,
      revisitDate: revisitDate ?? this.revisitDate,
      revisitDone: revisitDone ?? this.revisitDone,
      leadTypeId: leadTypeId ?? this.leadTypeId,
      leadTypeName: leadTypeName ?? this.leadTypeName,
      age: age ?? this.age,
      peName: peName ?? this.peName,
      peId: peId ?? this.peId,
      creId: creId ?? this.creId,
      creName: creName ?? this.creName,
    );
  }

  @override
  String toString() {
    return 'SearchLeadModel(${toJson().toString()})';
  }
}

class AudioFileLead {
  String? filePath;
  String? fileName;
  String? fileType;

  AudioFileLead({
    this.filePath,
    this.fileName,
    this.fileType,
  });

  // Factory constructor with null checks
  factory AudioFileLead.fromJson(Map<String, dynamic> json) {
    return AudioFileLead(
      filePath: json['File_Path'] ?? 0,
      fileName: json['File_Name'] ?? '',
      fileType: json['File_Type'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        "File_Path": filePath,
        "File_Name": fileName,
        "File_Type": fileType,
      };
}
