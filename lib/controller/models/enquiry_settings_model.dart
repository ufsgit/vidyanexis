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
  final int underSourceId;
  final String underSourceName;
  final double commissionPercent;

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
    this.underSourceId = 0,
    this.underSourceName = '',
    this.commissionPercent = 0.0,
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
      underSourceId: json["Under_Source_Id"] != null
          ? int.tryParse(json["Under_Source_Id"].toString()) ?? 0
          : (json["under_source_id"] != null
              ? int.tryParse(json["under_source_id"].toString()) ?? 0
              : (json["Under_Source"] != null
                  ? int.tryParse(json["Under_Source"].toString()) ?? 0
                  : 0)),
      underSourceName: json["Under_Source_Name"] ??
          json["under_source_name"] ??
          '',
      commissionPercent: json["Commission_Percentage"] != null
          ? double.tryParse(json["Commission_Percentage"].toString()) ?? 0.0
          : (json["Commission_Percent"] != null
              ? double.tryParse(json["Commission_Percent"].toString()) ?? 0.0
              : (json["commission_percent"] != null
                  ? double.tryParse(json["commission_percent"].toString()) ?? 0.0
                  : (json["Commission"] != null
                      ? double.tryParse(json["Commission"].toString()) ?? 0.0
                      : (json["commission"] != null
                          ? double.tryParse(json["commission"].toString()) ?? 0.0
                          : 0.0)))),
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
      'Under_Source_Id': underSourceId,
      'Under_Source_Name': underSourceName,
      'Commission_Percentage': commissionPercent,
      'Commission_Percent': commissionPercent,
      'Commission': commissionPercent,
      'commission_percent': commissionPercent,
    };
  }
}
