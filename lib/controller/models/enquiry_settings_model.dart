class EnquirySourceModel {
  final int enquirySourceId;
  final String enquirySourceName;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final int deleteStatus;
  final int isMoreDetails;
  final String contactPerson;
  final String phone;
  final String email;
  final String website;
  final String phone2;
  final String contact2;
  final String address;
  final String description;

  // Constructor
  EnquirySourceModel({
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.deleteStatus,
    this.isMoreDetails = 0,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.phone2 = '',
    this.contact2 = '',
    this.address = '',
    this.description = '',
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory EnquirySourceModel.fromJson(Map<String, dynamic> json) {
    return EnquirySourceModel(
      sourceCategoryId: json["Source_Category_Id"] ?? 0,
      sourceCategoryName: json["Source_Category_Name"] ?? '',
      enquirySourceId:
          json['Enquiry_Source_Id'] ?? 0, // Default to 0 if missing
      enquirySourceName: json['Enquiry_Source_Name'] ??
          '', // Default to empty string if missing
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if missing
      isMoreDetails: json['Is_More_Details'] ?? 0,
      contactPerson: json['Contact_Person'] ?? '',
      phone: json['Phone'] ?? '',
      email: json['Email'] ?? '',
      website: json['Website'] ?? '',
      phone2: json['Phone_2'] ?? '',
      contact2: json['Contact_2'] ?? '',
      address: json['Address'] ?? '',
      description: json['Description'] ?? '',
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'DeleteStatus': deleteStatus,
      'Is_More_Details': isMoreDetails,
      'Contact_Person': contactPerson,
      'Phone': phone,
      'Email': email,
      'Website': website,
      'Phone_2': phone2,
      'Contact_2': contact2,
      'Address': address,
      'Description': description,
    };
  }
}
