class AmcReportModeld {
  int amcId;
  String amcNo;
  DateTime? date; // Made nullable
  int amcStatusId;
  String amcStatusName;
  String productName;
  String serviceName;
  String description;
  String amount;
  int createdBy;
  int customerId;
  DateTime? fromDate; // Made nullable
  DateTime? toDate; // Made nullable
  int deleteStatus;
  String createdByName;
  String customerName;
  final String mobile;
  final String address1;

  AmcReportModeld({
    required this.amcId,
    required this.amcNo,
    this.date, // Nullable
    required this.amcStatusId,
    required this.amcStatusName,
    required this.productName,
    required this.serviceName,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.customerId,
    this.fromDate, // Nullable
    this.toDate, // Nullable
    required this.deleteStatus,
    required this.createdByName,
    required this.customerName,
    required this.mobile,
    required this.address1,
  });

  factory AmcReportModeld.fromJson(Map<String, dynamic> json) =>
      AmcReportModeld(
        amcId: json["AMC_Id"] ?? 0,
        amcNo: json["AMC_No"] ?? '',
        date: json["Date"] != null ? DateTime.tryParse(json["Date"]) : null,
        amcStatusId: json["AMC_Status_Id"] ?? 0,
        amcStatusName: json["AMC_Status_Name"] ?? '',
        productName: json["Product_Name"] ?? '',
        serviceName: json["Service_Name"] ?? '',
        description: json["Description"] ?? '',
        amount: json["Amount"] ?? '',
        createdBy: json["Created_By"] ?? 0,
        customerId: json["Customer_Id"] ?? 0,
        fromDate: json["From_Date"] != null
            ? DateTime.tryParse(json["From_Date"])
            : null,
        toDate:
            json["To_Date"] != null ? DateTime.tryParse(json["To_Date"]) : null,
        deleteStatus: json["DeleteStatus"] ?? 0,
        createdByName: json["Created_By_Name"] ?? '',
        customerName: json["Customer_Name"] ?? '',
        mobile: json['Contact_Number'] ?? '',
        address1: json['Address1'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "AMC_Id": amcId,
        "AMC_No": amcNo,
        "Date": date?.toIso8601String(), // Null-aware operator
        "AMC_Status_Id": amcStatusId,
        "AMC_Status_Name": amcStatusName,
        "Product_Name": productName,
        "Service_Name": serviceName,
        "Description": description,
        "Amount": amount,
        "Created_By": createdBy,
        "Customer_Id": customerId,
        "From_Date": fromDate != null
            ? "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}"
            : null,
        "To_Date": toDate != null
            ? "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}"
            : null,
        "DeleteStatus": deleteStatus,
        "Created_By_Name": createdByName,
        "Customer_Name": customerName,
        'Contact_Number': mobile,
        'Address1': address1,
      };
}
