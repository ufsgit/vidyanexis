class InventoryCustomerModel {
  final int customerId;
  final String customerName;
  final String address;
  final String address1;
  final String address2;
  final String address3;
  final String phoneNo;
  final String mobileNo;
  final String email;
  final String gstNo;
  final String openingBalance;
  final int deleteStatus;

  // Constructor to initialize the properties
  InventoryCustomerModel({
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.phoneNo,
    required this.mobileNo,
    required this.email,
    required this.gstNo,
    required this.openingBalance,
    required this.deleteStatus,
  });

  // Factory method to create an instance of InventoryCustomerModel from JSON
  factory InventoryCustomerModel.fromJson(Map<String, dynamic> json) {
    return InventoryCustomerModel(
      customerId: json['Customer_Id'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
      address: json['Address'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      address3: json['Address3'] ?? '',
      phoneNo: json['PhoneNo'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
      email: json['Email'] ?? '',
      gstNo: json['GSTNO'] ?? '',
      openingBalance: json['OpeningBalance'] != null
          ? json['OpeningBalance'].toString()
          : '0',
      deleteStatus: json['DeleteStatus'] ?? 0,
    );
  }

  // Method to convert the model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Address': address,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'PhoneNo': phoneNo,
      'MobileNo': mobileNo,
      'Email': email,
      'GSTNO': gstNo,
      'OpeningBalance': openingBalance,
      'DeleteStatus': deleteStatus,
    };
  }
}

