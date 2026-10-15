class SourceCategorySummaryModel {
  final String parentEnquirySource;
  final String enquirySource;
  final String leadName;
  final double projectCost;
  final double commissionPercentage;
  final double commissionAmount;
  final String conversionDate;

  SourceCategorySummaryModel({
    required this.parentEnquirySource,
    required this.enquirySource,
    required this.leadName,
    required this.projectCost,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.conversionDate,
  });

  factory SourceCategorySummaryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return SourceCategorySummaryModel(
      parentEnquirySource: (json['Parent_Enquiry_Source'] ??
              json['parent_enquiry_source'] ??
              json['ParentEnquirySource'])
          ?.toString() ??
          '',
      enquirySource: (json['Enquiry_Source'] ??
              json['enquiry_source'] ??
              json['EnquirySource'])
          ?.toString() ??
          '',
      leadName:
          (json['Lead_Name'] ?? json['lead_name'] ?? json['LeadName'])
              ?.toString() ??
              '',
      projectCost: parseDouble(json['Project_Cost'] ??
          json['project_cost'] ??
          json['ProjectCost']),
      commissionPercentage: parseDouble(json['Commission_Percentage'] ??
          json['commission_percentage'] ??
          json['CommissionPercentage']),
      commissionAmount: parseDouble(json['Commission_Amount'] ??
          json['commission_amount'] ??
          json['CommissionAmount']),
      conversionDate: (json['Conversion_Date'] ??
              json['conversion_date'] ??
              json['ConversionDate'])
          ?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Parent_Enquiry_Source': parentEnquirySource,
      'Enquiry_Source': enquirySource,
      'Lead_Name': leadName,
      'Project_Cost': projectCost.toStringAsFixed(2),
      'Commission_Percentage': commissionPercentage.toStringAsFixed(2),
      'Commission_Amount': commissionAmount.toStringAsFixed(2),
      'Conversion_Date': conversionDate,
    };
  }
}
