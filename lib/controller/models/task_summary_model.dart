class TaskSummaryModel {
  final String userName;
  final int totalTask;
  final String pending;
  final String completed;

  TaskSummaryModel({
    required this.userName,
    required this.totalTask,
    required this.pending,
    required this.completed,
  });

  factory TaskSummaryModel.fromJson(Map<String, dynamic> json) {
    return TaskSummaryModel(
      userName: json['User_Name'] ?? '',
      totalTask: json['Total_Task'] ?? 0,
      pending: json['Pending']?.toString() ?? '0',
      completed: json['Completed']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'User_Name': userName,
      'Total_Task': totalTask,
      'Pending': pending,
      'Completed': completed,
    };
  }
}
