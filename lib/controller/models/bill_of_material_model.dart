class BillOfMaterialItem {
  String itemsAndDescription;
  String make;
  int quantity;
  String distributor;
  String invoiceNo;

  BillOfMaterialItem({
    required this.itemsAndDescription,
    required this.make,
    required this.quantity,
    required this.distributor,
    required this.invoiceNo,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Items_And_Description': itemsAndDescription,
      'make': make,
      'Quantity': quantity,
      'Distributor': distributor,
      'Invoice_No': invoiceNo,
    };
  }

  // Create from JSON
  factory BillOfMaterialItem.fromJson(Map<String, dynamic> json) {
    return BillOfMaterialItem(
      itemsAndDescription: json['Items_And_Description'],
      make: json['make'],
      quantity: json['Quantity'],
      distributor: json['Distributor'],
      invoiceNo: json['Invoice_No'],
    );
  }
}
