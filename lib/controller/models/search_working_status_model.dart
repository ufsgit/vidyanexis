class SearchWorkingStatusModel {
  int workingStatusId;
  String workingStatusName;

  SearchWorkingStatusModel({
    required this.workingStatusId,
    required this.workingStatusName,
  });

  factory SearchWorkingStatusModel.fromJson(Map<String, dynamic> json) =>
      SearchWorkingStatusModel(
        workingStatusId: json["Working_Status_Id"],
        workingStatusName: json["Working_Status_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Working_Status_Id": workingStatusId,
        "Working_Status_Name": workingStatusName,
      };
}
