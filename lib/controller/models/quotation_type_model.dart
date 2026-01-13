class QuotationTypeModel {
  final int quotationTypeId;
  final String quotationTypeName;

  QuotationTypeModel({
    required this.quotationTypeId,
    required this.quotationTypeName,
  });

  /// Factory method to create a TaskType object from JSON
  factory QuotationTypeModel.fromJson(Map<String, dynamic> json) {
    return QuotationTypeModel(
      quotationTypeId: json['id'] ?? 0,
      quotationTypeName: json['name'] ?? '',
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': quotationTypeId,
      'name': quotationTypeName,
    };
  }
}
