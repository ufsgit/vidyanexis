import 'package:vidyanexis/controller/models/search_leads_model.dart';

class LeadDetails {
  // Core Fields
  final int customerId;
  final String customerName;
  final String address;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? address4;
  final String contactNumber;
  final String phoneNumber;
  final String email;
  final int followUpId;
  final String nextFollowUpDate;
  final int toUserId;
  final String toUserName;
  final int followUp;
  final int? createdBy;
  final String? createdByName;
  final String? entryDate;
  final int statusId;
  final String statusName;
  final int byUserId;
  final String byUserName;
  final dynamic isRegistered;
  final int? registeredBy;
  final String? registeredDate;
  final String? registrationNo;
  final int enquiryForId;
  final String enquiryForName;
  final int enquirySourceId;
  final String enquirySourceName;
  final String remark;
  final String colorCode;
  final int deleteStatus;
  final int leadDetailsId;
  final String consumerNumber;
  final String electricalSection;
  final double inverterCapacity;
  final int inverterTypeId;
  final String inverterTypeName;
  final double panelCapacity;
  final int panelTypeId;
  final String panelTypeName;
  final int phaseId;
  final String phaseName;
  final int roofTypeId;
  final String roofTypeName;
  final double projectCost;
  final double additionalCost;
  final double advanceAmount;
  final int amountPaidThroughId;
  final String amountPaidThroughName;
  final String upiTransferPhoto;
  final int costIncludesId;
  final String costIncName;
  final String electricityBillPhoto;
  final String cancelledChequePassbook;
  final String adhaarCardBack;
  final String passportSizePhoto;
  final double connectedLoad;
  final String rep;
  final String leadBy;
  final int workTypeId;
  final String workTypeName;
  final String location;
  final int subsidyTypeId;
  final String subsidyTypeName;
  final String additionalComments;
  final int totalTask;
  final int completedTask;
  final String? locations;
  final String? devices;
  final String? latitude;
  final String? longitude;
  final String? pinCode;
  final int branchId;
  final String branchName;
  final int departmentId;
  final String departmentName;
  final String referenceName;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final int? districtId;
  final String? districtName;
  final String? invoiceNo;
  final String? invoiceDate;
  final double? invoiceAmount;
  final String? mapLink;
  final String? panelSerialNo;
  final int? stageId;
  final String? stageName;
  final int activeTaskCount;
  final String KsebExpense;
  final String actualRTSCapacity;
  final String totalProjectCost;
  final String PMSuryaShakthiPortalid;
  final String JanSamarthid;
  final String bankbranch;
  final String inverterBrandName;
  final String panelBrandName;
  final String noOfPanels;
  final String Efficiency;

  // New Additional Fields
  final int age;
  final int peId;
  final String peName;
  final int creId;
  final String creName;
  final int leadTypeId;
  final String leadTypeName;
  final List<AudioFileLead> audioFiles;

  LeadDetails({
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.location,
    required this.audioFiles,
    this.latitude,
    this.longitude,
    this.pinCode,
    this.address1,
    this.address2,
    this.address3,
    this.address4,
    required this.contactNumber,
    required this.phoneNumber,
    required this.email,
    required this.followUpId,
    required this.nextFollowUpDate,
    required this.toUserId,
    required this.toUserName,
    required this.followUp,
    this.createdBy,
    this.createdByName,
    this.entryDate,
    required this.statusId,
    required this.statusName,
    required this.byUserId,
    required this.byUserName,
    required this.isRegistered,
    this.registeredBy,
    this.registeredDate,
    this.registrationNo,
    required this.enquiryForId,
    required this.enquiryForName,
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.remark,
    required this.colorCode,
    required this.deleteStatus,
    required this.leadDetailsId,
    required this.consumerNumber,
    required this.electricalSection,
    required this.inverterCapacity,
    required this.inverterTypeId,
    required this.inverterTypeName,
    required this.panelCapacity,
    required this.panelTypeId,
    required this.panelTypeName,
    required this.phaseId,
    required this.phaseName,
    required this.roofTypeId,
    required this.roofTypeName,
    required this.projectCost,
    required this.additionalCost,
    required this.advanceAmount,
    required this.amountPaidThroughId,
    required this.amountPaidThroughName,
    required this.upiTransferPhoto,
    required this.costIncludesId,
    required this.costIncName,
    required this.electricityBillPhoto,
    required this.cancelledChequePassbook,
    required this.adhaarCardBack,
    required this.passportSizePhoto,
    required this.connectedLoad,
    required this.rep,
    required this.leadBy,
    required this.workTypeId,
    required this.workTypeName,
    required this.subsidyTypeId,
    required this.subsidyTypeName,
    required this.additionalComments,
    required this.branchId,
    required this.totalTask,
    required this.completedTask,
    this.locations,
    this.devices,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.branchName,
    required this.departmentId,
    required this.departmentName,
    required this.referenceName,
    this.districtId,
    this.districtName,
    this.invoiceNo,
    this.invoiceDate,
    this.invoiceAmount,
    this.mapLink,
    this.panelSerialNo,
    this.stageId,
    this.stageName,
    required this.activeTaskCount,
    required this.KsebExpense,
    required this.actualRTSCapacity,
    required this.totalProjectCost,
    required this.PMSuryaShakthiPortalid,
    required this.JanSamarthid,
    required this.bankbranch,
    required this.inverterBrandName,
    required this.panelBrandName,
    required this.noOfPanels,
    required this.Efficiency,
    // New Additional Parameters
    required this.age,
    required this.peId,
    required this.peName,
    required this.creId,
    required this.creName,
    required this.leadTypeId,
    required this.leadTypeName,
  });

  factory LeadDetails.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) => value?.toString() ?? '';

    return LeadDetails(
      customerId: parseInt(json['Customer_Id']),
      customerName: parseString(json['Customer_Name']),
      address: parseString(json['address']),
      location: parseString(json['location']),
      latitude: parseString(json['Latitude']),
      longitude: parseString(json['Longitude']),
      pinCode: parseString(json['Pincode']),
      address1: parseString(json['Address1']),
      address2: parseString(json['Address2']),
      address3: parseString(json['Address3']),
      address4: parseString(json['Address4']),
      contactNumber: parseString(json['Contact_Number']),
      phoneNumber: parseString(json['Phone_Number']),
      email: parseString(json['Email']),
      followUpId: parseInt(json['FollowUp_Id']),
      nextFollowUpDate: parseString(json['Next_FollowUp_date']),
      toUserId: parseInt(json['To_User_Id']),
      toUserName: parseString(json['To_User_Name']),
      followUp: parseInt(json['FollowUp']),
      createdBy: parseInt(json['Created_By']),
      createdByName: parseString(json['Created_By_Name']),
      entryDate: parseString(json['Entry_Date']),
      statusId: parseInt(json['Status_Id']),
      statusName: parseString(json['Status_Name']),
      byUserId: parseInt(json['By_User_Id']),
      byUserName: parseString(json['By_User_Name']),
      isRegistered: json['Is_Registered'],
      registeredBy: parseInt(json['Registered_By']),
      registeredDate: parseString(json['Registered_Date']),
      registrationNo: parseString(json['Registration_No']),
      enquiryForId: parseInt(json['Enquiry_For_Id']),
      enquiryForName: parseString(json['Enquiry_For_Name']),
      enquirySourceId: parseInt(json['Enquiry_Source_Id']),
      enquirySourceName: parseString(json['Enquiry_Source_Name']),
      remark: parseString(json['Remark']),
      colorCode: parseString(json['Color_Code']),
      deleteStatus: parseInt(json['DeleteStatus']),
      leadDetailsId: parseInt(json['Lead_Details_Id']),
      consumerNumber: parseString(json['consumer_number']),
      electricalSection: parseString(json['electrical_section']),
      inverterCapacity: parseDouble(json['inverter_capacity']),
      inverterTypeId: parseInt(json['inverter_type_id']),
      inverterTypeName: parseString(json['inverter_type_name']),
      panelCapacity: parseDouble(json['panel_capacity']),
      panelTypeId: parseInt(json['panel_type_id']),
      panelTypeName: parseString(json['panel_type_name']),
      phaseId: parseInt(json['phase_id']),
      phaseName: parseString(json['phase_name']),
      roofTypeId: parseInt(json['roof_type_id']),
      roofTypeName: parseString(json['roof_type_name']),
      projectCost: parseDouble(json['project_cost']),
      additionalCost: parseDouble(json['additional_cost']),
      advanceAmount: parseDouble(json['advance_amount']),
      amountPaidThroughId: parseInt(json['amount_paid_through_id']),
      amountPaidThroughName: parseString(json['amount_paid_through_name']),
      upiTransferPhoto: parseString(json['upi_transfer_photo']),
      costIncludesId: parseInt(json['cost_includes_id']),
      costIncName: parseString(json['cost_includes_name']),
      electricityBillPhoto: parseString(json['electricity_bill_photo']),
      cancelledChequePassbook: parseString(json['cancelled_cheque_passbook']),
      adhaarCardBack: parseString(json['adhaar_card_back']),
      passportSizePhoto: parseString(json['passport_size_photo']),
      connectedLoad: parseDouble(json['connected_load']),
      rep: parseString(json['rep']),
      leadBy: parseString(json['lead_by']),
      workTypeId: parseInt(json['work_type_id']),
      workTypeName: parseString(json['work_type_name']),
      subsidyTypeId: parseInt(json['subsidy_type_id']),
      subsidyTypeName: parseString(json['subsidy_type_name']),
      additionalComments: parseString(json['additional_comments']),
      branchId: parseInt(json['branch_id']),
      totalTask: parseInt(json['total_task']),
      completedTask: parseInt(json['completed_task']),
      activeTaskCount: parseInt(json['active_task_count']),
      locations: parseString(json['locations']),
      devices: parseString(json['devices']),
      sourceCategoryId: parseInt(json['Source_Category_Id']),
      sourceCategoryName: parseString(json['Source_Category_Name']),
      branchName: parseString(json['Branch_Name']),
      departmentId: parseInt(json['Department_Id']),
      departmentName: parseString(json['Department_Name']),
      referenceName: parseString(json['Reference_Name']),
      districtId: parseInt(json['District_Id']),
      districtName: parseString(json['District']),
      invoiceNo: parseString(json['Invoice_No']),
      invoiceDate: parseString(json['Invoice_Date']),
      invoiceAmount: parseDouble(json['Invoice_Amount']),
      mapLink: parseString(json['Map_Link']),
      panelSerialNo: parseString(json['panel_serial_no']),
      stageId: parseInt(json['Stage_Id']),
      stageName: parseString(json['Stage_Name']),
      KsebExpense: parseString(json['Kseb_Expense']),
      actualRTSCapacity: parseString(json['Actual_RTS_Capacity']),
      totalProjectCost: parseString(json['Total_Project_Cost']),
      PMSuryaShakthiPortalid: parseString(json['PM_SuryaShakthi_Portal_Id']),
      JanSamarthid: parseString(json['Jan_Samarth_Id']),
      bankbranch: parseString(json['bankbranch']),
      inverterBrandName: parseString(json['inverterBrandName']),
      panelBrandName: parseString(json['panelBrandName']),
      noOfPanels: parseString(json['noOfPanels']),
      Efficiency: parseString(json['Efficiency']),
      // New Additional Fields
      age: parseInt(json['Age']),
      peId: parseInt(json['PE_Id']),
      peName: parseString(json['PE_Name']),
      creId: parseInt(json['CRE_Id']),
      creName: parseString(json['CRE_Name']),
      leadTypeId: parseInt(json['Lead_Type_Id']),
      leadTypeName: parseString(json['Lead_Type_Name']),
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
      'address': address,
      'location': location,
      'Latitude': latitude,
      'Longitude': longitude,
      'Pincode': pinCode,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'Address4': address4,
      'Contact_Number': contactNumber,
      'Phone_Number': phoneNumber,
      'Email': email,
      'FollowUp_Id': followUpId,
      'Next_FollowUp_date': nextFollowUpDate,
      'To_User_Id': toUserId,
      'To_User_Name': toUserName,
      'FollowUp': followUp,
      'Created_By': createdBy,
      'Created_By_Name': createdByName,
      'Entry_Date': entryDate,
      'Status_Id': statusId,
      'Status_Name': statusName,
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
      'Is_Registered': isRegistered,
      'Registered_By': registeredBy,
      'Registered_Date': registeredDate,
      'Registration_No': registrationNo,
      'Enquiry_For_Id': enquiryForId,
      'Enquiry_For_Name': enquiryForName,
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'Remark': remark,
      'Color_Code': colorCode,
      'DeleteStatus': deleteStatus,
      'Lead_Details_Id': leadDetailsId,
      'consumer_number': consumerNumber,
      'electrical_section': electricalSection,
      'inverter_capacity': inverterCapacity,
      'inverter_type_id': inverterTypeId,
      'inverter_type_name': inverterTypeName,
      'panel_capacity': panelCapacity,
      'panel_type_id': panelTypeId,
      'panel_type_name': panelTypeName,
      'phase_id': phaseId,
      'phase_name': phaseName,
      'roof_type_id': roofTypeId,
      'roof_type_name': roofTypeName,
      'project_cost': projectCost,
      'additional_cost': additionalCost,
      'advance_amount': advanceAmount,
      'amount_paid_through_id': amountPaidThroughId,
      'amount_paid_through_name': amountPaidThroughName,
      'upi_transfer_photo': upiTransferPhoto,
      'cost_includes_id': costIncludesId,
      'cost_includes_name': costIncName,
      'electricity_bill_photo': electricityBillPhoto,
      'cancelled_cheque_passbook': cancelledChequePassbook,
      'adhaar_card_back': adhaarCardBack,
      'passport_size_photo': passportSizePhoto,
      'connected_load': connectedLoad,
      'rep': rep,
      'lead_by': leadBy,
      'work_type_id': workTypeId,
      'work_type_name': workTypeName,
      'subsidy_type_id': subsidyTypeId,
      'subsidy_type_name': subsidyTypeName,
      'additional_comments': additionalComments,
      'branch_id': branchId,
      'total_task': totalTask,
      'completed_task': completedTask,
      'active_task_count': activeTaskCount,
      'locations': locations,
      'devices': devices,
      'Source_Category_Id': sourceCategoryId,
      'Source_Category_Name': sourceCategoryName,
      'Branch_Name': branchName,
      'Department_Id': departmentId,
      'Department_Name': departmentName,
      'Reference_Name': referenceName,
      'District_Id': districtId,
      'District': districtName,
      'Invoice_No': invoiceNo,
      'Invoice_Date': invoiceDate,
      'Invoice_Amount': invoiceAmount,
      'Map_Link': mapLink,
      'panel_serial_no': panelSerialNo,
      'Stage_Id': stageId,
      'Stage_Name': stageName,
      'Kseb_Expense': KsebExpense,
      'Actual_RTS_Capacity': actualRTSCapacity,
      'Total_Project_Cost': totalProjectCost,
      'PM_SuryaShakthi_Portal_Id': PMSuryaShakthiPortalid,
      'Jan_Samarth_Id': JanSamarthid,
      'bankbranch': bankbranch,
      'inverterBrandName': inverterBrandName,
      'panelBrandName': panelBrandName,
      'noOfPanels': noOfPanels,
      'Efficiency': Efficiency,
      // New Additional Fields
      'Age': age,
      'PE_Id': peId,
      'PE_Name': peName,
      'CRE_Id': creId,
      'CRE_Name': creName,
      'Lead_Type_Id': leadTypeId,
      'Lead_Type_Name': leadTypeName,
    };
  }

  LeadDetails copyWith({
    int? customerId,
    String? customerName,
    String? address,
    String? location,
    String? latitude,
    String? longitude,
    String? pinCode,
    String? address1,
    String? address2,
    String? address3,
    String? address4,
    String? contactNumber,
    String? phoneNumber,
    String? email,
    int? followUpId,
    String? nextFollowUpDate,
    int? toUserId,
    String? toUserName,
    int? followUp,
    int? createdBy,
    String? createdByName,
    String? entryDate,
    int? statusId,
    String? statusName,
    int? byUserId,
    String? byUserName,
    dynamic isRegistered,
    int? registeredBy,
    String? registeredDate,
    String? registrationNo,
    int? enquiryForId,
    String? enquiryForName,
    int? enquirySourceId,
    String? enquirySourceName,
    String? remark,
    String? colorCode,
    int? deleteStatus,
    int? leadDetailsId,
    String? consumerNumber,
    String? electricalSection,
    double? inverterCapacity,
    int? inverterTypeId,
    String? inverterTypeName,
    double? panelCapacity,
    int? panelTypeId,
    String? panelTypeName,
    int? phaseId,
    String? phaseName,
    int? roofTypeId,
    String? roofTypeName,
    double? projectCost,
    double? additionalCost,
    double? advanceAmount,
    int? amountPaidThroughId,
    String? amountPaidThroughName,
    String? upiTransferPhoto,
    int? costIncludesId,
    String? costIncName,
    String? electricityBillPhoto,
    String? cancelledChequePassbook,
    String? adhaarCardBack,
    String? passportSizePhoto,
    double? connectedLoad,
    String? rep,
    String? leadBy,
    int? workTypeId,
    String? workTypeName,
    int? subsidyTypeId,
    String? subsidyTypeName,
    String? additionalComments,
    int? branchId,
    int? totalTask,
    int? completedTask,
    String? locations,
    String? devices,
    int? sourceCategoryId,
    String? sourceCategoryName,
    String? branchName,
    int? departmentId,
    String? departmentName,
    String? referenceName,
    int? districtId,
    String? districtName,
    String? invoiceNo,
    String? invoiceDate,
    double? invoiceAmount,
    String? mapLink,
    String? panelSerialNo,
    int? stageId,
    String? stageName,
    int? activeTaskCount,
    // New Additional Parameters
    int? age,
    int? peId,
    String? peName,
    int? creId,
    String? creName,
    int? leadTypeId,
    String? leadTypeName,
    List<AudioFileLead>? audioFiles,
  }) {
    return LeadDetails(
      audioFiles: audioFiles ?? this.audioFiles,

      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pinCode: pinCode ?? this.pinCode,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      address4: address4 ?? this.address4,
      contactNumber: contactNumber ?? this.contactNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      followUpId: followUpId ?? this.followUpId,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      followUp: followUp ?? this.followUp,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      entryDate: entryDate ?? this.entryDate,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      byUserId: byUserId ?? this.byUserId,
      byUserName: byUserName ?? this.byUserName,
      isRegistered: isRegistered ?? this.isRegistered,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredDate: registeredDate ?? this.registeredDate,
      registrationNo: registrationNo ?? this.registrationNo,
      enquiryForId: enquiryForId ?? this.enquiryForId,
      enquiryForName: enquiryForName ?? this.enquiryForName,
      enquirySourceId: enquirySourceId ?? this.enquirySourceId,
      enquirySourceName: enquirySourceName ?? this.enquirySourceName,
      remark: remark ?? this.remark,
      colorCode: colorCode ?? this.colorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      leadDetailsId: leadDetailsId ?? this.leadDetailsId,
      consumerNumber: consumerNumber ?? this.consumerNumber,
      electricalSection: electricalSection ?? this.electricalSection,
      inverterCapacity: inverterCapacity ?? this.inverterCapacity,
      inverterTypeId: inverterTypeId ?? this.inverterTypeId,
      inverterTypeName: inverterTypeName ?? this.inverterTypeName,
      panelCapacity: panelCapacity ?? this.panelCapacity,
      panelTypeId: panelTypeId ?? this.panelTypeId,
      panelTypeName: panelTypeName ?? this.panelTypeName,
      phaseId: phaseId ?? this.phaseId,
      phaseName: phaseName ?? this.phaseName,
      roofTypeId: roofTypeId ?? this.roofTypeId,
      roofTypeName: roofTypeName ?? this.roofTypeName,
      projectCost: projectCost ?? this.projectCost,
      additionalCost: additionalCost ?? this.additionalCost,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      amountPaidThroughId: amountPaidThroughId ?? this.amountPaidThroughId,
      amountPaidThroughName:
          amountPaidThroughName ?? this.amountPaidThroughName,
      upiTransferPhoto: upiTransferPhoto ?? this.upiTransferPhoto,
      costIncludesId: costIncludesId ?? this.costIncludesId,
      costIncName: costIncName ?? this.costIncName,
      electricityBillPhoto: electricityBillPhoto ?? this.electricityBillPhoto,
      cancelledChequePassbook:
          cancelledChequePassbook ?? this.cancelledChequePassbook,
      adhaarCardBack: adhaarCardBack ?? this.adhaarCardBack,
      passportSizePhoto: passportSizePhoto ?? this.passportSizePhoto,
      connectedLoad: connectedLoad ?? this.connectedLoad,
      rep: rep ?? this.rep,
      leadBy: leadBy ?? this.leadBy,
      workTypeId: workTypeId ?? this.workTypeId,
      workTypeName: workTypeName ?? this.workTypeName,
      subsidyTypeId: subsidyTypeId ?? this.subsidyTypeId,
      subsidyTypeName: subsidyTypeName ?? this.subsidyTypeName,
      additionalComments: additionalComments ?? this.additionalComments,
      branchId: branchId ?? this.branchId,
      totalTask: totalTask ?? this.totalTask,
      completedTask: completedTask ?? this.completedTask,
      locations: locations ?? this.locations,
      devices: devices ?? this.devices,
      sourceCategoryId: sourceCategoryId ?? this.sourceCategoryId,
      sourceCategoryName: sourceCategoryName ?? this.sourceCategoryName,
      branchName: branchName ?? this.branchName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      referenceName: referenceName ?? this.referenceName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      mapLink: mapLink ?? this.mapLink,
      panelSerialNo: panelSerialNo ?? this.panelSerialNo,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      KsebExpense: KsebExpense ?? this.KsebExpense,
      actualRTSCapacity: actualRTSCapacity ?? this.actualRTSCapacity,
      totalProjectCost: totalProjectCost ?? this.totalProjectCost,
      PMSuryaShakthiPortalid:
          PMSuryaShakthiPortalid ?? this.PMSuryaShakthiPortalid,
      JanSamarthid: JanSamarthid ?? this.JanSamarthid,
      bankbranch: bankbranch ?? this.bankbranch,
      inverterBrandName: inverterBrandName ?? this.inverterBrandName,
      panelBrandName: panelBrandName ?? this.panelBrandName,
      noOfPanels: noOfPanels ?? this.noOfPanels,
      Efficiency: Efficiency ?? this.Efficiency,
      // New Additional Fields
      age: age ?? this.age,
      peId: peId ?? this.peId,
      peName: peName ?? this.peName,
      creId: creId ?? this.creId,
      creName: creName ?? this.creName,
      leadTypeId: leadTypeId ?? this.leadTypeId,
      leadTypeName: leadTypeName ?? this.leadTypeName,
    );
  }

  @override
  String toString() {
    return 'LeadDetails(${toJson().toString()})';
  }
}
