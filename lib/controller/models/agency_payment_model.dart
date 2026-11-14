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
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return AgencyPaymentModel(
      agencyPaymentId: parseInt(json['Agency_Payment_Id'] ?? json['Id']),
      enquirySourceId: parseInt(
          json['Enquiry_Source_Id'] ?? json['Enquiry_Source_id'] ?? json['Enquiry_Source']),
      enquirySourceName:
          (json['Enquiry_Source_Name'] ?? json['Enquiry_Source'] ?? '')
              .toString(),
      amount: double.tryParse(
              (json['Amount'] ?? json['Paying_Amount'] ?? 0).toString()) ??
          0.0,
      paymentDate: (json['Payment_Date'] ?? json['Date'] ?? '').toString(),
      remark: (json['Remark'] ?? json['Description'] ?? '').toString(),
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
