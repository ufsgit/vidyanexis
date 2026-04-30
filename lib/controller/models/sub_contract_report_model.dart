class SubContractReportModel {
  final int customerId;
  final String customerName;
  final String contactNumber;
  final String taskTypeName;
  final String taskStatusName;
  final String toUserName;
  final String commission;
  final String entryDate;

  SubContractReportModel({
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.taskTypeName,
    required this.taskStatusName,
    required this.toUserName,
    required this.commission,
    required this.entryDate,
  });

  factory SubContractReportModel.fromJson(Map<String, dynamic> json) {
    return SubContractReportModel(
      customerId: int.tryParse(json["Customer_Id"]?.toString() ?? "0") ?? 0,
      customerName:
          (json["Lead_Name"] ?? json["Customer_Name"])?.toString() ?? '',
      contactNumber:
          (json["Phone"] ?? json["Phone_Number"] ?? json["contactNumber"])
                  ?.toString() ??
              '',
      taskTypeName:
          (json["Task_Type_Name"] ?? json["TaskTypeName"])?.toString() ?? '',
      taskStatusName:
          (json["Task_Status_Name"] ?? json["Status_Name"])?.toString() ?? '',
      toUserName: json["To_User_Name"]?.toString() ?? '',
      commission: (json["Commission_Number"] ??
                  json["Commission_Amount"] ??
                  json["Commission"])
              ?.toString() ??
          '0.00',
      entryDate: (json["Registered_Date"] ??
                  json["Task_Date"] ??
                  json["Registration_Date"] ??
                  json["Entry_Date"])
              ?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Lead_Name": customerName,
        "Task_Type_Name": taskTypeName,
        "Task_Status_Name": taskStatusName,
        "To_User_Name": toUserName,
        "Commission_Number": commission,
        "Registered_Date": entryDate,
      };
}
