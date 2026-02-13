class PaymentModel {
  int? paymentId;
  String? date;
  int? paymentModeId;
  String? paymentModeName;
  double? payingAmount;
  String? description;
  int? byUserId;
  int? customerId;

  PaymentModel({
    this.paymentId,
    this.date,
    this.paymentModeId,
    this.paymentModeName,
    this.payingAmount,
    this.description,
    this.byUserId,
    this.customerId,
  });

  PaymentModel.fromJson(Map<String, dynamic> json) {
    paymentId = json['Payment_Id'];
    date = json['Date'];
    paymentModeId = json['Payment_Mode_Id'];
    paymentModeName = json['Payment_Mode_Name'];
    payingAmount = double.tryParse(json['Paying_Amount'].toString());
    description = json['Description'];
    byUserId = json['By_User_Id'];
    customerId = json['Customer_Id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Payment_Id'] = paymentId;
    data['Date'] = date;
    data['Payment_Mode_Id'] = paymentModeId;
    data['Payment_Mode_Name'] = paymentModeName;
    data['Paying_Amount'] = payingAmount;
    data['Description'] = description;
    data['By_User_Id'] = byUserId;
    data['Customer_Id'] = customerId;
    return data;
  }
}
