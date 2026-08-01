class TargetReportModel {
  final String userDetailsId;
  final String userDetailsName;
  final String dailyTarget;
  final String monthlyTarget;
  final String completedTasks;
  final String remainingToday;
  final String dailyPercentage;
  final String remainingThisMonth;
  final String monthlyPercentage;
  final String taskTypeName;
  final String taskTypeId;

  TargetReportModel({
    required this.userDetailsId,
    required this.userDetailsName,
    required this.dailyTarget,
    required this.monthlyTarget,
    required this.completedTasks,
    required this.remainingToday,
    required this.dailyPercentage,
    required this.remainingThisMonth,
    required this.monthlyPercentage,
    required this.taskTypeId,
    required this.taskTypeName,
  });

  factory TargetReportModel.fromJson(Map<String, dynamic> json) {
    return TargetReportModel(
      userDetailsId: json['User_Details_Id']?.toString() ?? '0',
      userDetailsName: json['User_Details_Name']?.toString() ?? '',
      dailyTarget: json['Daily_Target']?.toString() ?? '0',
      monthlyTarget: json['Monthly_Target']?.toString() ?? '0',
      completedTasks: json['Completed_Tasks']?.toString() ?? '0',
      remainingToday: json['Remaining_Today']?.toString() ?? '0',
      dailyPercentage: json['Daily_Percentage']?.toString() ?? '',
      remainingThisMonth: json['Remaining_This_Month']?.toString() ?? '0',
      monthlyPercentage: json['Monthly_Percentage']?.toString() ?? '',
      taskTypeId: json['Task_Type_Id']?.toString() ?? '0',
      taskTypeName: json['Task_Type_Name']?.toString() ?? '',
    );
  }
}
