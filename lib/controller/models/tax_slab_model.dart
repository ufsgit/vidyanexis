import 'dart:convert';

List<TaxSlabModel> taxSlabModelFromJson(String str) => List<TaxSlabModel>.from(
    json.decode(str).map((x) => TaxSlabModel.fromJson(x)));

String taxSlabModelToJson(List<TaxSlabModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaxSlabModel {
  int? taxId;
  String? taxName;
  double? taxPercentage;
  int? deleteStatus;
  int? isInclusive;

  TaxSlabModel({
    this.taxId,
    this.taxName,
    this.taxPercentage,
    this.deleteStatus,
    this.isInclusive,
  });

  factory TaxSlabModel.fromJson(Map<String, dynamic> json) => TaxSlabModel(
        taxId: json["tax_id"] ?? json["Tax_Id"],
        taxName: json["tax_name"] ?? json["Tax_Name"],
        taxPercentage:
            _parseDouble(json["tax_percentage"] ?? json["Tax_Percentage"]),
        deleteStatus: json["delete_status"] ?? json["DeleteStatus"],
        isInclusive: json["is_inclusive"] ?? json["Is_Inclusive"],
      );

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        "tax_id": taxId,
        "tax_name": taxName,
        "tax_percentage": taxPercentage,
        "delete_status": deleteStatus,
        "is_inclusive": isInclusive,
      };

  TaxSlabModel copyWith({
    int? taxId,
    String? taxName,
    double? taxPercentage,
    int? deleteStatus,
    int? isInclusive,
  }) {
    return TaxSlabModel(
      taxId: taxId ?? this.taxId,
      taxName: taxName ?? this.taxName,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      isInclusive: isInclusive ?? this.isInclusive,
    );
  }
}
