import 'dart:convert';

DashBoardTaskModel dashBoardTaskModelFromJson(String str) =>
    DashBoardTaskModel.fromJson(json.decode(str));

String dashBoardTaskModelToJson(DashBoardTaskModel data) =>
    json.encode(data.toJson());

class DashBoardTaskModel {
  bool? success;
  String? message;
  dynamic data; // Using dynamic to handle the complex structure

  DashBoardTaskModel({
    this.success,
    this.message,
    this.data,
  });

  factory DashBoardTaskModel.fromJson(Map<String, dynamic> json) =>
      DashBoardTaskModel(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };

  // Improved helper method to extract department data safely
  List<Department> getDepartments() {
    if (data == null) {
      return [];
    }

    try {
      // Based on the JSON structure you shared, data is a List where the first element
      // is another List containing department objects
      if (data is List && data.isNotEmpty && data[0] is List) {
        List<dynamic> departmentsList = data[0];
        return departmentsList
            .map((dept) => Department.fromJson(dept))
            .toList();
      }
      // Handle case where data structure might be different
      else if (data is List &&
          data.isNotEmpty &&
          data[0] is Map<String, dynamic>) {
        // Handle case where first item is directly a department object, not a list
        List<dynamic> allItems = data;
        return allItems
            .where((item) =>
                item is Map<String, dynamic> &&
                item.containsKey("Department_Id"))
            .map((dept) => Department.fromJson(dept))
            .toList();
      }
    } catch (e) {
      print('Error parsing departments: $e');
    }

    return [];
  }
}

class Department {
  int? departmentId;
  String? departmentName;
  int? taskCount;
  List<Task>? tasks;

  Department({
    this.departmentId,
    this.departmentName,
    this.taskCount,
    this.tasks,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        departmentId: json["Department_Id"],
        departmentName: json["Department_Name"],
        taskCount: json["Task_Count"],
        tasks: json["Tasks"] == null
            ? []
            : List<Task>.from(json["Tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Department_Id": departmentId,
        "Department_Name": departmentName,
        "Task_Count": taskCount,
        "Tasks": tasks == null
            ? []
            : List<dynamic>.from(tasks!.map((x) => x.toJson())),
      };
}

class Task {
  int? taskTypeId;
  int? subTaskCount;
  String? taskTypeName;

  Task({
    this.taskTypeId,
    this.subTaskCount,
    this.taskTypeName,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        taskTypeId: json["Task_Type_Id"],
        subTaskCount: json["SubTask_Count"],
        taskTypeName: json["Task_Type_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Task_Type_Id": taskTypeId,
        "SubTask_Count": subTaskCount,
        "Task_Type_Name": taskTypeName,
      };
}
