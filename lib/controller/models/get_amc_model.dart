class GetAmcModel {
  int amcId;
  String amcNo;
  DateTime date;
  int amcStatusId;
  String amcStatusName;
  String productName;
  String serviceName;
  String description;
  String amount;
  int createdBy;
  int customerId;
  String customerName;
  DateTime? fromDate;
  DateTime? toDate;
  int deleteStatus;
  String createdByName;

  GetAmcModel({
    required this.amcId,
    required this.amcNo,
    required this.date,
    required this.amcStatusId,
    required this.amcStatusName,
    required this.productName,
    required this.serviceName,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.customerId,
    required this.fromDate,
    required this.toDate,
    required this.deleteStatus,
    required this.createdByName,
    required this.customerName,
  });

  factory GetAmcModel.fromJson(Map<String, dynamic> json) => GetAmcModel(
        amcId: json["AMC_Id"],
        amcNo: json["AMC_No"],
        date: DateTime.parse(json["Date"]),
        amcStatusId: json["AMC_Status_Id"],
        amcStatusName: json["AMC_Status_Name"],
        productName: json["Product_Name"],
        serviceName: json["Service_Name"],
        description: json["Description"],
        customerName: json["Customer_Name"],
        amount: json["Amount"],
        createdBy: json["Created_By"],
        customerId: json["Customer_Id"],
        fromDate: json["From_Date"] != null && json["From_Date"].toString().isNotEmpty
            ? DateTime.parse(json["From_Date"])
            : null,
        toDate: json["To_Date"] != null && json["To_Date"].toString().isNotEmpty
            ? DateTime.parse(json["To_Date"])
            : null,
        deleteStatus: json["DeleteStatus"],
        createdByName: json["Created_By_Name"],
      );

  Map<String, dynamic> toJson() => {
        "AMC_Id": amcId,
        "AMC_No": amcNo,
        "Date": date.toIso8601String(),
        "AMC_Status_Id": amcStatusId,
        "AMC_Status_Name": amcStatusName,
        "Product_Name": productName,
        "Service_Name": serviceName,
        "Description": description,
        "Amount": amount,
        "Created_By": createdBy,
        "Customer_Name": customerName,
        "Customer_Id": customerId,
        "From_Date": fromDate != null
            ? "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}"
            : "",
        "To_Date": toDate != null
            ? "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}"
            : "",
        "DeleteStatus": deleteStatus,
        "Created_By_Name": createdByName,
      };
}