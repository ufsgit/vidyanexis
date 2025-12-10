class TaskInfoDashboardModel {
  int? customerId;
  String? customerName;
  List<TaskList>? taskList;

  TaskInfoDashboardModel({
    this.customerId,
    this.customerName,
    this.taskList,
  });

  factory TaskInfoDashboardModel.fromJson(Map<String, dynamic> json) =>
      TaskInfoDashboardModel(
        customerId: json["Customer_Id"],
        customerName: json["Customer_Name"],
        taskList: json["taskList"] == null
            ? []
            : List<TaskList>.from(
                json["taskList"]!.map((x) => TaskList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "taskList": taskList == null
            ? []
            : List<dynamic>.from(taskList!.map((x) => x.toJson())),
      };
}

class TaskList {
  int? duration;
  dynamic followup;
  dynamic statusName;
  int? taskTypeId;
  String? taskTypeName;
  int? taskTypeOrder;

  TaskList({
    this.duration,
    this.followup,
    this.statusName,
    this.taskTypeId,
    this.taskTypeName,
    this.taskTypeOrder,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) => TaskList(
        duration: json["Duration"],
        followup: json["Followup"],
        statusName: json["Status_Name"],
        taskTypeId: json["Task_Type_Id"],
        taskTypeName: json["Task_Type_Name"],
        taskTypeOrder: json["Task_Type_Order"],
      );

  Map<String, dynamic> toJson() => {
        "Duration": duration,
        "Followup": followup,
        "Status_Name": statusName,
        "Task_Type_Id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "Task_Type_Order": taskTypeOrder,
      };
}
