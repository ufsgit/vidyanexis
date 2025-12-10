class WorkSummaryModel {
  final String toStaff;
  final int noOfFollowUp;
  final int userDetailsId;

  WorkSummaryModel({
    required this.toStaff,
    required this.noOfFollowUp,
    required this.userDetailsId,
  });

  // Factory method for creating an instance from JSON with default values
  factory WorkSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkSummaryModel(
      toStaff: json['To_Staff'] ?? '',
      noOfFollowUp: json['No_of_Follow_Up'] ?? 0,
      userDetailsId: json['User_Details_Id'] ?? 0,
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'To_Staff': toStaff,
      'No_of_Follow_Up': noOfFollowUp,
      'User_Details_Id': userDetailsId,
    };
  }
}
