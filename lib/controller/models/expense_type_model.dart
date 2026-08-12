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
        expenseTypeId: int.tryParse((json["Expense_Type_Id"] ??
                    json["expense_type_id"] ??
                    json["Expense_Type_ID"] ??
                    0)
                .toString()) ??
            0,
        expenseTypeName: (json["Expense_Type_Name"] ??
                json["expense_type_name"] ??
                json["Expense_Type"] ??
                '')
            .toString(),
        deleteStatus: int.tryParse((json["DeleteStatus"] ??
                    json["delete_status"] ??
                    json["Status"] ??
                    0)
                .toString()) ??
            0,
      );

  Map<String, dynamic> toJson() => {
        "Expense_Type_Id": expenseTypeId,
        "Expense_Type_Name": expenseTypeName,
        "DeleteStatus": deleteStatus,
      };
}
