class AttendanceRecord {
  final int id;
  final int userDetailsId;
  final String userDetailsName;
  final String photo;
  final String location;
  final String latitude;
  final String longitude;
  final String updatedAt;
  final String createdAt;
  final String attendanceDate;
  final String attendanceTime;

  // Constructor
  AttendanceRecord({
    required this.id,
    required this.userDetailsId,
    required this.userDetailsName,
    required this.photo,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    required this.createdAt,
    required this.attendanceDate,
    required this.attendanceTime,
  });

  // Factory method to create an instance from a JSON map
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      userDetailsId: json['User_Details_Id'] ??
          0, // Default to 0 if 'User_Details_Id' is null
      userDetailsName: json['User_Details_Name'] ??
          '', // Default to empty string if 'User_Details_Name' is null
      photo: json['photo'] ?? '', // Default to empty string if 'photo' is null
      location: json['location'] ??
          '', // Default to empty string if 'location' is null
      latitude: json['latitude'] ??
          "0.0", // Convert to double and default to 0.0 if null
      longitude: json['longitude'] ??
          "0.0", // Convert to double and default to 0.0 if null
      updatedAt: json['updated_at'] ??
          '', // Default to empty string if 'updated_at' is null
      createdAt: json['created_at'] ??
          '', // Default to empty string if 'created_at' is null
      attendanceDate: json['attendance_date'] ??
          '', // Default to empty string if 'attendance_date' is null
      attendanceTime: json['attendance_time'] ??
          '', // Default to empty string if 'attendance_time' is null
    );
  }

  // Method to convert model to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'User_Details_Id': userDetailsId,
      'User_Details_Name': userDetailsName,
      'photo': photo,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'attendance_date': attendanceDate,
      'attendance_time': attendanceTime,
    };
  }
}
