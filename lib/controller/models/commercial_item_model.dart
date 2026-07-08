class CommercialItemModel {
  String? description;
  String? dcCapacity;
  String? acCapacity;
  String? unitPrice;
  String? total;
  String? qty;
  String? gstPerc;
  String? gst;

  CommercialItemModel({
    this.description,
    this.dcCapacity,
    this.acCapacity,
    this.unitPrice,
    this.total,
    this.qty,
    this.gstPerc,
    this.gst,
  });

  factory CommercialItemModel.fromJson(Map<String, dynamic> json) {
    return CommercialItemModel(
      description: json['description']?.toString() ?? '',
      dcCapacity: json['dcCapacity']?.toString() ?? '',
      acCapacity: json['acCapacity']?.toString() ?? '',
      unitPrice: json['unitPrice']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      qty: json['Quantity']?.toString() ?? '',
      gst: json['GST']?.toString() ?? '',
      gstPerc: json['GSTPercent']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description ?? '',
      'dcCapacity': dcCapacity ?? '',
      'acCapacity': acCapacity ?? '',
      'unitPrice': unitPrice ?? '',
      'total': total ?? '',
      'Quantity': qty,
      'GST': gst,
      'GSTPercent': gstPerc,
    };
  }
}
