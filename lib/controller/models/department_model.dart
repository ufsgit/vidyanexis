class DepartmentMainModel {
  bool success;
  String message;
  List<dynamic> data;

  DepartmentMainModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DepartmentMainModel.fromJson(Map<String, dynamic> json) =>
      DepartmentMainModel(
        success: json["success"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}

class DepartmentModel {
  int departmentId;
  String departmentName;

  DepartmentModel({
    required this.departmentId,
    required this.departmentName,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        departmentId: json["Department_Id"],
        departmentName: json["Department_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Department_Id": departmentId,
        "Department_Name": departmentName,
      };
}
