class AMCStatusModel {
  final int amcStatusId;
  final String amcStatusName;

  AMCStatusModel({
    required this.amcStatusId,
    required this.amcStatusName,
  });

  /// Factory method to create a AMCStatus object from JSON
  factory AMCStatusModel.fromJson(Map<String, dynamic> json) {
    return AMCStatusModel(
      amcStatusId: json['AMC_Status_Id'] ?? 0,
      amcStatusName: json['AMC_Status_Name'] ?? '',
    );
  }

  /// Method to convert AMCStatus object to JSON
  Map<String, dynamic> toJson() {
    return {
      'AMC_Status_Id': amcStatusId,
      'AMC_Status_Name': amcStatusName,
    };
  }

  String get displayStatus {
    if (amcStatusName == '1') {
      return 'Completed';
    } else if (amcStatusName == '0') {
      return 'Pending';
    }
    return amcStatusName;
  }
}
