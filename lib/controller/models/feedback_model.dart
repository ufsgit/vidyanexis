class FeedbackModel {
  final String feedbackId;
  final String feedbackDate;
  final String customerName;
  final String customerId;
  final String feedbackText;
  final String taskTypeName;
  final String taskDescription;
  final String userName;

  FeedbackModel({
    required this.feedbackId,
    required this.feedbackDate,
    required this.customerName,
    required this.customerId,
    required this.feedbackText,
    required this.taskTypeName,
    required this.taskDescription,
    required this.userName,
  });

  // Factory constructor to create an instance from a Map
  factory FeedbackModel.fromJson(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['Feedback_Id']?.toString() ?? '',
      feedbackDate: map['Feedback_Date']?.toString() ?? '',
      customerName: map['Customer_Name']?.toString() ?? '',
      customerId: map['Customer_Id']?.toString() ?? '',
      feedbackText: map['Feedback_Text']?.toString() ?? '',
      taskTypeName: map['Task_Type_Name']?.toString() ?? '',
      taskDescription: map['Task_Description']?.toString() ?? '',
      userName: map['User_Details_Name']?.toString() ?? '',
    );
  }

  // Convert an instance to a Map
  Map<String, dynamic> tojson() {
    return {
      'Feedback_Id': feedbackId,
      'Feedback_Date': feedbackDate,
      'Customer_Name': customerName,
      'Customer_Id': customerId,
      'Feedback_Text': feedbackText,
      'Task_Type_Name': taskTypeName,
      'Task_Description': taskDescription,
    };
  }
}
