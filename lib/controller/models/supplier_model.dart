class SupplierModel {
  final int supplierId;
  final String supplierName;
  final String address;
  final String address1;
  final String address2;
  final String address3;
  final String phoneNo;
  final String mobileNo;
  final String email;
  final String gstNo;
  final String website;
  final String openingBalance;
  final int deleteStatus;

  // Constructor to initialize the properties
  SupplierModel({
    required this.supplierId,
    required this.supplierName,
    required this.address,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.phoneNo,
    required this.mobileNo,
    required this.email,
    required this.gstNo,
    required this.website,
    required this.openingBalance,
    required this.deleteStatus,
  });

  // Factory method to create an instance of SupplierModel from JSON
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierId: json['Supplier_Id'] ?? 0, // Default 0 if null
      supplierName: json['Supplier_Name'] ?? '', // Default empty string if null
      address: json['Address'] ?? '', // Default empty string if null
      address1: json['Address1'] ?? '', // Default empty string if null
      address2: json['Address2'] ?? '', // Default empty string if null
      address3: json['Address3'] ?? '', // Default empty string if null
      phoneNo: json['PhoneNo'] ?? '', // Default empty string if null
      mobileNo: json['MobileNo'] ?? '', // Default empty string if null
      email: json['Email'] ?? '', // Default empty string if null
      gstNo: json['GSTNO'] ?? '', // Default empty string if null
      website: json['Website'] ?? '', // Default empty string if null
      openingBalance: json['OpeningBalance'] != null
          ? json['OpeningBalance'].toString()
          : '0', // Default 0.0 if null
      deleteStatus: json['DeleteStatus'] ?? 0, // Default 0 if null
    );
  }

  // Method to convert the model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'Supplier_Id': supplierId,
      'Supplier_Name': supplierName,
      'Address': address,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'PhoneNo': phoneNo,
      'MobileNo': mobileNo,
      'Email': email,
      'GSTNO': gstNo,
      'Website': website,
      'OpeningBalance': openingBalance,
      'DeleteStatus': deleteStatus,
    };
  }
}
