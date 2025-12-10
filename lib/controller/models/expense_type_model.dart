class ExpenseTypeModel {
  int expenseTypeId;
  String expenseTypeName;
  int deleteStatus;

  ExpenseTypeModel({
    required this.expenseTypeId,
    required this.expenseTypeName,
    required this.deleteStatus,
  });

  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) =>
      ExpenseTypeModel(
        expenseTypeId: json["Expense_Type_Id"],
        expenseTypeName: json["Expense_Type_Name"],
        deleteStatus: json["DeleteStatus"],
      );

  Map<String, dynamic> toJson() => {
        "Expense_Type_Id": expenseTypeId,
        "Expense_Type_Name": expenseTypeName,
        "DeleteStatus": deleteStatus,
      };
}
