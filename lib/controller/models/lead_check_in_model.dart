class LeadCheckIn {
  final String? userDetailsName;
  final String? checkinLocation;
  final String? checkoutLocation;
  final String? checkinDate;
  final String? checkoutDate;
  final String? leadName;
  final int? customerId;
  final String? checkinStatus;
  final String? location;
  final int? leadId;
  final int? userDetailId;
  final dynamic checkoutData;
  final double? latitude;
  final double? longitude;
  final String? timeDifference;

  LeadCheckIn({
    this.userDetailsName,
    this.checkinLocation,
    this.checkoutLocation,
    this.checkinDate,
    this.checkoutDate,
    this.leadName,
    this.customerId,
    this.checkinStatus,
    this.location,
    this.leadId,
    this.userDetailId,
    this.checkoutData,
    this.latitude,
    this.longitude,
    this.timeDifference,
  });

  factory LeadCheckIn.fromJson(Map<String, dynamic> json) {
    return LeadCheckIn(
      userDetailsName: json['User_Details_Name'] ??
          json['user_details_name'] ??
          json['user_name'] ??
          json['User_Name'] ??
          json['staff_name'] ??
          json['Staff_Name'],
      checkinLocation: json['checkin_location'],
      checkoutLocation: json['checkout_location'],
      checkinDate: json['checkindate'],
      checkoutDate: json['checkoutdate'],
      leadName: json['lead_name'] ?? json['leadname'],
      customerId: json['Customer_Id'],
      checkinStatus: json['checkin_status'],
      location: json['Location'],
      leadId: json['Lead_Id'],
      userDetailId: json['UserDetail_Id'],
      checkoutData: json['CheckoutData'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : (json['Latitude'] != null ? double.tryParse(json['Latitude'].toString()) : null),
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : (json['Longitude'] != null ? double.tryParse(json['Longitude'].toString()) : null),
      timeDifference: json['time_difference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'User_Details_Name': userDetailsName,
      'checkin_location': checkinLocation,
      'checkout_location': checkoutLocation,
      'checkindate': checkinDate,
      'checkoutdate': checkoutDate,
      'lead_name': leadName,
      'Customer_Id': customerId,
      'checkin_status': checkinStatus,
      'Location': location,
      'Lead_Id': leadId,
      'UserDetail_Id': userDetailId,
      'CheckoutData': checkoutData,
      'latitude': latitude,
      'longitude': longitude,
      'time_difference': timeDifference,
    };
  }

  @override
  String toString() {
    return 'LeadCheckIn(userDetailsName: $userDetailsName, checkinLocation: $checkinLocation, checkoutLocation: $checkoutLocation, checkinDate: $checkinDate, checkoutDate: $checkoutDate, leadName: $leadName, customerId: $customerId, checkinStatus: $checkinStatus, location: $location, leadId: $leadId, userDetailId: $userDetailId, checkoutData: $checkoutData, latitude: $latitude, longitude: $longitude)';
  }
}

class LeadCheckInResponse {
  final bool? success;
  final String? message;
  final List<LeadCheckIn>? data;

  LeadCheckInResponse({this.success, this.message, this.data});

  factory LeadCheckInResponse.fromJson(Map<String, dynamic> json) {
    return LeadCheckInResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => LeadCheckIn.fromJson(i)).toList()
          : null,
    );
  }
}
