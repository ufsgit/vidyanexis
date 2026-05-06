class Item {
  String ItemName;
  String Hsn;
  double UnitPrice;
  int Quantity;
  double Amount;
  String MRP;
  double GST;
  double GSTPercent;
  double AdCESS;
  String Unit;

  Item({
    required this.ItemName,
    required this.Hsn,
    required this.UnitPrice,
    required this.Quantity,
    required this.MRP,
    required this.GST,
    required this.GSTPercent,
    required this.AdCESS,
    required this.Unit,
    required this.Amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'ItemName': ItemName,
      'HSN': Hsn,
      'UnitPrice': UnitPrice,
      'Quantity': Quantity,
      'MRP': MRP,
      'Amount': Amount,
      'GST': GST,
      'GSTPercent': GSTPercent,
      'AdCESS': AdCESS,
      'Unit': Unit,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      ItemName: json['ItemName'],
      Hsn: json['HSN']?.toString() ?? '',
      MRP: json['MRP']?.toString() ?? '',
      UnitPrice: json['UnitPrice'].toDouble(),
      Quantity: json['Quantity'],
      GST: json['GST'],
      GSTPercent: json['GSTPercent'],
      AdCESS: json['AdCESS'],
      Unit: json['Unit'],
      Amount: json['Amount'],
    );
  }

}

