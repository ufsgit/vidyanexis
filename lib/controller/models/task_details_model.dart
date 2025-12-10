import 'package:vidyanexis/controller/models/task_customer_model.dart';

class TaskDetails {
  final List<int> taskId;
  final int taskMasterId;
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
  final String startDate;
  final String startTime;
  final int deleteStatus;
  final String customerName;
  final String toUserName;
  final String createdByName;
  final List<TaskNote> taskNotes;
  final List<TaskDocument> taskDocuments;
  final List<TaskUser> taskUser;
  final List<TaskFile> taskFiles;

  TaskDetails({
    required this.taskId,
    required this.taskMasterId,
    required this.description,
    required this.entryDate,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.toUserId,
    required this.customerId,
    required this.createdBy,
    required this.createdByName,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskDate,
    required this.taskTime,
    required this.completionDate,
    required this.completionTime,
    required this.startDate,
    required this.startTime,
    required this.deleteStatus,
    required this.customerName,
    required this.toUserName,
    required this.taskNotes,
    required this.taskDocuments,
    required this.taskUser,
    required this.taskFiles,
  });

  // Factory constructor with null checks
  factory TaskDetails.fromJson(Map<String, dynamic> json) {
    return TaskDetails(
      taskId: List<int>.from(json["Task_Id_"] ?? []),
      taskMasterId: json['Task_Master_Id'] ?? 0,
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
      createdByName: json['Created_By_Name'] ?? '',
      completionDate: json['Completion_Date'] ?? '',
      completionTime: json['Completion_Time'] ?? '',
      startDate: json['Task_Start_Date'] ?? '',
      startTime: json['Task_Start_Time'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
      toUserName: json['To_User_Name'] ?? '',

      // Null check for task_notes and task_document
      taskNotes: (json['task_notes'] as List<dynamic>?)
              ?.map((item) => TaskNote.fromJson(item))
              .toList() ??
          [],
      taskDocuments: (json['task_document'] as List<dynamic>?)
              ?.map((item) => TaskDocument.fromJson(item))
              .toList() ??
          [],
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
}

class TaskNote {
  final int taskId;
  final String taskNote;
  final int taskNoteId;
  final int userDetailsId;
  final String userDetailsName;

  TaskNote({
    required this.taskId,
    required this.taskNote,
    required this.taskNoteId,
    required this.userDetailsId,
    required this.userDetailsName,
  });

  // Factory constructor with null checks
  factory TaskNote.fromJson(Map<String, dynamic> json) {
    return TaskNote(
      taskId: json['Task_Id'] ?? 0,
      taskNote: json['Task_Note'] ?? '',
      taskNoteId: json['Task_Note_Id'] ?? 0,
      userDetailsId: json['User_Details_Id'] ?? 0,
      userDetailsName: json['User_Details_Name'] ?? '',
    );
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

class TaskDocument {
  final List<Document> documents;
  final int userDetailsId;
  final String userDetailsName;

  TaskDocument({
    required this.documents,
    required this.userDetailsId,
    required this.userDetailsName,
  });

  // Factory constructor to parse JSON data
  factory TaskDocument.fromJson(Map<String, dynamic> json) {
    var docList = json['Documents'] as List;
    List<Document> documents =
        docList.map((doc) => Document.fromJson(doc)).toList();

    return TaskDocument(
      documents: documents,
      userDetailsId: json['User_Details_Id'] ?? 0,
      userDetailsName: json['User_Details_Name'] ?? '',
    );
  }
}

class Document {
  final int taskId;
  final int taskDocumentId;
  final String filePath;
  final String entryDate;
  final String taskNote;
  final String startDateTime;
  final String completionDateTime;

  Document({
    required this.taskId,
    required this.taskDocumentId,
    required this.filePath,
    required this.entryDate,
    required this.taskNote,
    required this.startDateTime,
    required this.completionDateTime,
  });

  // Factory constructor to parse JSON data
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      taskId: json['Task_Id'] ?? 0,
      taskDocumentId: json['Task_Document_Id'] ?? 0,
      filePath: json['File_Path'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      taskNote: json['task_note'] ?? '',
      startDateTime: json['Start_Date_Time'] ?? '',
      completionDateTime: json['Completion_Date_Time'] ?? '',
    );
  }
}
