class UserActivityReportModel {
  final SummaryModel? summary;
  final List<UserReportModel>? userReport;

  UserActivityReportModel({
    this.summary,
    this.userReport,
  });

  factory UserActivityReportModel.fromJson(Map<String, dynamic> json) {
    return UserActivityReportModel(
      summary: json['Summary'] != null
          ? SummaryModel.fromJson(json['Summary'])
          : null,
      userReport: (json['User_Report'] as List?)
              ?.map((e) => UserReportModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SummaryModel {
  final int? totalAssigned;
  final String? totalCompleted;
  final String? totalPending;
  final String? totalOverdue;
  final String? performancePercentage;

  SummaryModel({
    this.totalAssigned,
    this.totalCompleted,
    this.totalPending,
    this.totalOverdue,
    this.performancePercentage,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalAssigned: _parseInt(json['Total_Assigned']),
      totalCompleted: json['Total_Completed']?.toString(),
      totalPending: json['Total_Pending']?.toString(),
      totalOverdue: json['Total_Overdue']?.toString(),
      performancePercentage: json['Performance_Percentage']?.toString(),
    );
  }
}

class UserReportModel {
  final int? userDetailsId;
  final String? userDetailsName;
  final int? assigned;
  final String? completed;
  final String? pending;
  final String? overdue;
  final String? averageCompletionMinutes;
  final String? productivity;

  UserReportModel({
    this.userDetailsId,
    this.userDetailsName,
    this.assigned,
    this.completed,
    this.pending,
    this.overdue,
    this.averageCompletionMinutes,
    this.productivity,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    int? parsedId = _parseInt(json['User_Details_Id'] ?? json['User_Id'] ?? json['user_details_id'] ?? json['user_id'] ?? json['UserId']);
    
    if (parsedId == null) {
      for (var key in json.keys) {
        if (key.toLowerCase().contains('id') && (key.toLowerCase().contains('user') || key.toLowerCase().contains('detail'))) {
          parsedId = _parseInt(json[key]);
          if (parsedId != null) break;
        }
      }
    }

    return UserReportModel(
      userDetailsId: parsedId,
      userDetailsName: json['User_Details_Name']?.toString() ?? json['User_Name']?.toString() ?? '',
      assigned: _parseInt(json['Assigned']),
      completed: json['Completed']?.toString(),
      pending: json['Pending']?.toString(),
      overdue: json['Overdue']?.toString(),
      averageCompletionMinutes: json['Average_Completion_Minutes']?.toString(),
      productivity: json['Productivity']?.toString(),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}
