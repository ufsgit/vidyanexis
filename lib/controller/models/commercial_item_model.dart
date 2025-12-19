class CommercialItemModel {
  String? description;
  String? dcCapacity;
  String? acCapacity;
  String? unitPrice;
  String? total;

  CommercialItemModel({
    this.description,
    this.dcCapacity,
    this.acCapacity,
    this.unitPrice,
    this.total,
  });

  factory CommercialItemModel.fromJson(Map<String, dynamic> json) {
    return CommercialItemModel(
      description: json['description']?.toString() ?? '',
      dcCapacity: json['dcCapacity']?.toString() ?? '',
      acCapacity: json['acCapacity']?.toString() ?? '',
      unitPrice: json['unitPrice']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'dcCapacity': dcCapacity,
      'acCapacity': acCapacity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}
