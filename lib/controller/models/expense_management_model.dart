// To parse this JSON data, do
//
//     final expenseModel = expenseModelFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

ExpenseModel expenseModelFromJson(String str) =>
    ExpenseModel.fromJson(json.decode(str));

String expenseModelToJson(ExpenseModel data) => json.encode(data.toJson());

class ExpenseModel {
  int? expenseManagementId;
  String? projectTypeName;
  int? projectTypeId;
  String? projectName;
  int? customerId;
  String? customerName;
  int? expenseTypeId;
  String? expenseTypeName;
  int? projectId;
  double? amount;
  String? entryDate;
  String? filePath;
  String? fileType;
  Uint8List? fileBytes;
  bool? isGst;
  double? gstPercentage;
  double? cgstAmount;
  double? sgstAmount;
  double? netAmount;
  int? entryBy, userDetailsId;
  String? expenseHead, comment, userName, entryByName, description;

  ExpenseModel(
      {this.expenseManagementId,
      this.projectTypeName,
      this.projectTypeId,
      this.projectName,
      this.customerId,
      this.customerName,
      this.projectId,
      this.amount,
      this.entryDate,
      this.filePath,
      this.isGst,
      this.gstPercentage,
      this.cgstAmount,
      this.sgstAmount,
      this.netAmount,
      this.entryBy,
      this.userDetailsId,
      this.fileBytes,
      this.fileType,
      this.expenseHead,
      this.comment,
      this.entryByName,
      this.expenseTypeId,
      this.expenseTypeName,
      this.userName,
      this.description});

  ExpenseModel copyWith(
          {int? expenseManagementId,
          String? projectTypeName,
          int? projectTypeId,
          String? projectName,
          int? customerId,
          String? customerName,
          int? expenseTypeId,
          String? expenseTypeName,
          int? projectId,
          double? amount,
          String? entryDate,
          String? filePath,
          bool? isGst,
          double? gstPercentage,
          double? cgstAmount,
          double? sgstAmount,
          double? netAmount,
          int? entryBy,
          userDetailsId,
          String? expenseHead,
          String? comment,
          String? entryByName,
          String? userName,
          String? description}) =>
      ExpenseModel(
        expenseManagementId: expenseManagementId ?? this.expenseManagementId,
        projectTypeName: projectTypeName ?? this.projectTypeName,
        projectTypeId: projectTypeId ?? this.projectTypeId,
        projectName: projectName ?? this.projectName,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        projectId: projectId ?? this.projectId,
        amount: amount ?? this.amount,
        entryDate: entryDate ?? this.entryDate,
        filePath: filePath ?? this.filePath,
        isGst: isGst ?? this.isGst,
        gstPercentage: gstPercentage ?? this.gstPercentage,
        cgstAmount: cgstAmount ?? this.cgstAmount,
        sgstAmount: sgstAmount ?? this.sgstAmount,
        netAmount: netAmount ?? this.netAmount,
        entryBy: entryBy ?? this.entryBy,
        userDetailsId: userDetailsId ?? this.userDetailsId,
        expenseHead: expenseHead ?? this.expenseHead,
        comment: comment ?? this.comment,
        expenseTypeId: expenseTypeId ?? this.expenseTypeId,
        expenseTypeName: expenseTypeName ?? this.expenseTypeName,
        entryByName: entryByName ?? this.entryByName,
        userName: userName ?? this.userName,
        description: description ?? this.description,
      );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseManagementId: json["Expense_Management_Id"] ?? json["Expense_Id"],
      projectTypeName: json["Project_Type_Name"],
      projectTypeId: json["Project_Type_Id"],
      projectName: json["project_Name"],
      projectId: json["project_ID"],
      customerId: json["Customer_Id"],
      customerName: json["Customer_Name"],
      amount: double.tryParse((json["Amount"] ?? 0).toString()),
      entryDate:
          json["Entry_Date"] ?? json["Date"], // Map 'Date' to 'entryDate'
      filePath: json["File_Path"],
      isGst: json["is_gst"] == 1,
      gstPercentage: double.tryParse((json["gst_percentage"] ?? 0).toString()),
      cgstAmount: double.tryParse((json["cgst_amount"] ?? 0).toString()),
      sgstAmount: double.tryParse((json["sgst_amount"] ?? 0).toString()),
      netAmount: double.tryParse((json["net_amount"] ?? 0).toString()),
      entryBy: json["Entry_By"],
      userDetailsId: json["User_Details_Id"],
      expenseHead: json["Expense_Head"],
      comment: json["Comment"],
      expenseTypeId: json["Expense_Type_Id"],
      expenseTypeName: json["Expense_Type_Name"],
      userName: json["User_Name"],
      entryByName: json["Entry_By_Name"],
      description: json["Description"] ?? json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Expense_Management_Id": expenseManagementId,
        "Project_Type_Name": projectTypeName,
        "Project_Type_Id": projectTypeId,
        "Project_Name": projectName,
        "project_ID": projectId,
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Amount": amount,
        "Entry_Date": entryDate,
        "File_Path": filePath,
        "is_gst": (isGst ?? false) ? 1 : 0,
        "gst_percentage": gstPercentage,
        "cgst_amount": cgstAmount,
        "sgst_amount": sgstAmount,
        "net_amount": netAmount,
        "Entry_By": entryBy,
        "User_Details_Id": userDetailsId,
        "Expense_Head": expenseHead,
        "Comment": comment,
        "Expense_Type_Id": expenseTypeId,
        "Expense_Type_Name": expenseTypeName,
        "Entry_By_Name": entryByName,
        "User_Name": userName,
        "Description": description,
      };
}

class ExpenseHeaderModel {
  double? totalBalance;
  double? totalExpenseAmount;
  double? receivedAmount;

  ExpenseHeaderModel({
    this.totalBalance,
    this.totalExpenseAmount,
    this.receivedAmount,
  });
}
