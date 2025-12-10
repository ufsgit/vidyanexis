class TaskDocumentList {
  final int taskId;
  final String description;
  final String entryDate;
  final int taskStatusId;
  final String taskStatusName;
  final int toUserId;
  final int customerId;
  final int createdBy;
  final int taskTypeId;
  final String taskTypeName;
  final String taskDate;
  final String taskTime;
  final String completionDate;
  final String completionTime;
  final String taskStartDate;
  final String taskStartTime;
  final int deleteStatus;
  final String toUserName;
  final List<DocumentList> documents;

  TaskDocumentList({
    required this.taskId,
    required this.description,
    required this.entryDate,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.toUserId,
    required this.customerId,
    required this.createdBy,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskDate,
    required this.taskTime,
    required this.completionDate,
    required this.completionTime,
    required this.taskStartDate,
    required this.taskStartTime,
    required this.deleteStatus,
    required this.toUserName,
    required this.documents,
  });

  factory TaskDocumentList.fromJson(Map<String, dynamic> json) {
    return TaskDocumentList(
      taskId: json['Task_Id'] ?? 0,
      description: json['Description'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      taskStatusId: json['Task_Status_Id'] ?? 0,
      taskStatusName: json['Task_Status_Name'] ?? '',
      toUserId: json['To_User_Id'] ?? 0,
      customerId: json['Customer_Id'] ?? 0,
      createdBy: json['Created_By'] ?? 0,
      taskTypeId: json['Task_Type_Id'] ?? 0,
      taskTypeName: json['Task_Type_Name'] ?? '',
      taskDate: json['Task_Date'] ?? '',
      taskTime: json['Task_Time'] ?? '',
      completionDate: json['Completion_Date'] ?? '',
      completionTime: json['Completion_Time'] ?? '',
      taskStartDate: json['Task_Start_Date'] ?? '',
      taskStartTime: json['Task_Start_Time'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      toUserName: json['To_User_Name'] ?? '',
      documents: (json['Documents'] as List<dynamic>?)
              ?.where((e) => e != null) // Filter out null values
              .map((e) => DocumentList.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DocumentList {
  final String filePath;
  final String entryDate;
  final int taskDocumentId;

  DocumentList({
    required this.filePath,
    required this.entryDate,
    required this.taskDocumentId,
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      filePath: json['File_Path'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      taskDocumentId: json['Task_Document_Id'] ?? 0,
    );
  }
}
