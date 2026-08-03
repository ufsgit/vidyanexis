class AccountsSummaryReportModel {
  final String? materialDeliveryDate;
  final int customerId;
  final String customerName;
  final String? projectType;
  final String? advancePayment;
  final String? secondPayment;
  final String? thirdPayment;
  final String balancePayment;
  final String? subsidyAmount;

  AccountsSummaryReportModel({
    this.materialDeliveryDate,
    required this.customerId,
    required this.customerName,
    this.projectType,
    this.advancePayment,
    this.secondPayment,
    this.thirdPayment,
    required this.balancePayment,
    this.subsidyAmount,
  });

  factory AccountsSummaryReportModel.fromJson(Map<String, dynamic> json) {
    return AccountsSummaryReportModel(
      materialDeliveryDate: json['Material_Delivery_Date']?.toString(),
      customerId: int.tryParse(json['Customer_Id']?.toString() ?? '0') ?? 0,
      customerName: json['Customer_Name']?.toString() ?? '',
      projectType: json['Project_Type']?.toString(),
      advancePayment: json['Advance_Payment']?.toString(),
      secondPayment: json['Second_Payment']?.toString(),
      thirdPayment: json['Third_Payment']?.toString(),
      balancePayment: json['Balance_Payment']?.toString() ?? '0.00',
      subsidyAmount: json['Subsidy_Amount']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Material_Delivery_Date': materialDeliveryDate,
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Project_Type': projectType,
      'Advance_Payment': advancePayment,
      'Second_Payment': secondPayment,
      'Third_Payment': thirdPayment,
      'Balance_Payment': balancePayment,
      'Subsidy_Amount': subsidyAmount,
    };
  }
}
