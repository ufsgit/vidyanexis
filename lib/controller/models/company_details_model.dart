class Company {
  final int companyId;
  final String companyName;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String mobileNumber;
  final String phoneNumber;
  final String email;
  final String website;
  final String logo;
  final String gstNo;
  final String panNo;
  final int deleteStatus;
  final int isLocation;

  Company({
    required this.companyId,
    required this.companyName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.mobileNumber,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.logo,
    required this.gstNo,
    required this.panNo,
    required this.deleteStatus,
    required this.isLocation,
  });

  // Factory constructor for creating an instance from JSON with null checks
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['Company_Id'] ?? 0,
      companyName: json['Company_Name'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      address3: json['Address3'] ?? '',
      address4: json['Address4'] ?? '',
      mobileNumber: json['Mobile_Number'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      email: json['Email'] ?? '',
      website: json['Website'] ?? '',
      logo: json['Logo'] ?? '',
      gstNo: json['Gst_No'] ?? '',
      panNo: json['Pan_No'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      isLocation: json['Is_Location'] ?? 0,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Company_Id': companyId,
      'Company_Name': companyName,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'Address4': address4,
      'Mobile_Number': mobileNumber,
      'Phone_Number': phoneNumber,
      'Email': email,
      'Website': website,
      'Logo': logo,
      'Gst_No': gstNo,
      'Pan_No': panNo,
      'DeleteStatus': deleteStatus,
      'Is_Location': isLocation,
    };
  }
}
