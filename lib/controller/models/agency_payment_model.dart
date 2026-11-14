class AgencyPaymentModel {
  final int agencyPaymentId;
  final int enquirySourceId;
  final String enquirySourceName;
  final double amount;
  final String paymentDate;
  final String remark;

  AgencyPaymentModel({
    this.agencyPaymentId = 0,
    this.enquirySourceId = 0,
    this.enquirySourceName = '',
    this.amount = 0.0,
    this.paymentDate = '',
    this.remark = '',
  });

  factory AgencyPaymentModel.fromJson(Map<String, dynamic> json) {
    return AgencyPaymentModel(
      agencyPaymentId: json['Agency_Payment_Id'] ?? json['Id'] ?? 0,
      enquirySourceId:
          json['Enquiry_Source_Id'] ?? json['Enquiry_Source'] ?? 0,
      enquirySourceName: json['Enquiry_Source_Name'] ?? '',
      amount: double.tryParse(
              (json['Amount'] ?? json['Paying_Amount'] ?? 0).toString()) ??
          0.0,
      paymentDate: json['Payment_Date'] ?? json['Date'] ?? '',
      remark: json['Remark'] ?? json['Description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Agency_Payment_Id': agencyPaymentId,
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'Amount': amount,
      'Payment_Date': paymentDate,
      'Remark': remark,
    };
  }
}
