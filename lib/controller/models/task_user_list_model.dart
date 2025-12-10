class TaskUserListModel {
  final int toUserId;
  final String userDetailsName;

  TaskUserListModel({
    required this.toUserId,
    required this.userDetailsName,
  });

  // Factory method to create a ToUserModel from JSON using ?? operator
  factory TaskUserListModel.fromJson(Map<String, dynamic> json) {
    return TaskUserListModel(
      toUserId:
          json['To_User_Id'] ?? 0, // Default to 0 if value is null or missing
      userDetailsName: json['User_Details_Name'] ?? '', // Default to 'Unknown'
    );
  }

  // Method to convert a ToUserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'To_User_Id': toUserId,
      'User_Details_Name': userDetailsName,
    };
  }
}
