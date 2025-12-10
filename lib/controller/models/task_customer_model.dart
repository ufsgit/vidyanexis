class TaskCustomerModel {
  final int taskId;
  final int taskMasterId;
  final String description;
  final DateTime? entryDate;
  final int taskStatusId;
  final String taskStatusName;
  final String toUsername;
  final String createdByName;

  final int toUserId;
  final int customerId;
  final int createdBy;
  final int taskTypeId;
  final String taskTypeName;
  final DateTime taskDate;
  final String taskTime;
  final int deleteStatus;
  final List<TaskUser> taskUser;
  final List<TaskFile> taskFiles;

  TaskCustomerModel({
    required this.taskId,
    required this.taskMasterId,
    required this.description,
    required this.entryDate,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.toUsername,
    required this.toUserId,
    required this.customerId,
    required this.createdBy,
    required this.createdByName,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskTime,
    required this.taskDate,
    required this.deleteStatus,
    required this.taskUser,
    required this.taskFiles,
  });

  // Factory constructor to create an instance of TaskCustomerModel from JSON
  factory TaskCustomerModel.fromJson(Map<String, dynamic> json) {
    return TaskCustomerModel(
      taskId: json['Task_Id'] ?? 0, // default value 0 if null
      taskMasterId: json['Task_Master_Id'] ?? 0, // default value 0 if null
      description: json['Description'] ?? '', // default value '' if null
      entryDate: json['Entry_Date'] != null
          ? DateTime.tryParse(json['Entry_Date']) // null check for date
          : null,
      taskStatusId: json['Task_Status_Id'] ?? 0,
      taskStatusName: json['Task_Status_Name'] ?? '',
      toUsername: json['To_User_Name'] ?? '',
      toUserId: json['To_User_Id'] ?? 0,
      customerId: json['Customer_Id'] ?? 0,
      createdBy: json['Created_By'] ?? 0,
      createdByName: json['Created_By_Name'] ?? '',
      taskTypeId: json['Task_Type_Id'] ?? 0,
      taskTypeName: json['Task_Type_Name'] ?? '',
      taskTime: json['Task_Time'] ?? '',
      taskDate: DateTime.tryParse(json['Task_Date']) ?? DateTime.now(),
      deleteStatus: json['DeleteStatus'] ?? 0,
      taskUser: (json['Task_user'] as List<dynamic>?)
              ?.map((item) => TaskUser.fromJson(item))
              .toList() ??
          [],
      taskFiles: (json['Task_Files'] as List<dynamic>?)
              ?.map((item) => TaskFile.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Method to convert TaskCustomerModel to JSON format
  Map<String, dynamic> toJson() {
    return {
      'Task_Id': taskId,
      'Task_Master_Id': taskMasterId,
      'Description': description,
      'Entry_Date': entryDate?.toIso8601String(),
      'Task_Status_Id': taskStatusId,
      'Task_Status_Name': taskStatusName,
      'To_User_Name': toUsername,
      "Created_By_Name": createdByName,
      'To_User_Id': toUserId,
      'Customer_Id': customerId,
      'Created_By': createdBy,
      'Task_Type_Id': taskTypeId,
      'Task_Type_Name': taskTypeName,
      'Task_Time': taskTime,
      'Task_Date': taskDate.toIso8601String(),
      'DeleteStatus': deleteStatus,
    };
  }
}

class TaskUser {
  final int toUserId;
  final String toUsername;

  TaskUser({
    required this.toUserId,
    required this.toUsername,
  });

  // Factory constructor with null checks
  factory TaskUser.fromJson(Map<String, dynamic> json) {
    return TaskUser(
      toUserId: json['To_User_Id'] ?? 0,
      toUsername: json['To_User_Name'] ?? '',
    );
  }
}

class TaskFile {
  String? filePath;
  String? fileName;
  String? fileType;

  TaskFile({
    this.filePath,
    this.fileName,
    this.fileType,
  });

  // Factory constructor with null checks
  factory TaskFile.fromJson(Map<String, dynamic> json) {
    return TaskFile(
      filePath: json['File_Path'] ?? 0,
      fileName: json['File_Name'] ?? '',
      fileType: json['File_Type'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        "File_Path": filePath,
        "File_Name": fileName,
        "File_Type": fileType,
      };
}
