// class StatusPageModel {
//   int projectId;
//   String projectName;
//   int deleteStatus;

//   StatusPageModel({
//     required this.projectId,
//     required this.projectName,
//     required this.deleteStatus,
//   });

//   StatusPageModel copyWith({
//     int? projectId,
//     String? projectName,
//     int? deleteStatus,
//   }) =>
//       StatusPageModel(
//         projectId: projectId ?? this.projectId,
//         projectName: projectName ?? this.projectName,
//         deleteStatus: deleteStatus ?? this.deleteStatus,
//       );

//   factory StatusPageModel.fromJson(Map<String, dynamic> json) =>
//       StatusPageModel(
//         projectId: json["Project_Id"],
//         projectName: json["Project_Name"],
//         deleteStatus: json["DeleteStatus"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Project_Id": projectId,
//         "Project_Name": projectName,
//         "DeleteStatus": deleteStatus,
//       };
// }

// class PurpleStatusPageModel {
//   int fieldCount;
//   int affectedRows;
//   int insertId;
//   String info;
//   int serverStatus;
//   int warningStatus;

//   PurpleStatusPageModel({
//     required this.fieldCount,
//     required this.affectedRows,
//     required this.insertId,
//     required this.info,
//     required this.serverStatus,
//     required this.warningStatus,
//   });

//   PurpleStatusPageModel copyWith({
//     int? fieldCount,
//     int? affectedRows,
//     int? insertId,
//     String? info,
//     int? serverStatus,
//     int? warningStatus,
//   }) =>
//       PurpleStatusPageModel(
//         fieldCount: fieldCount ?? this.fieldCount,
//         affectedRows: affectedRows ?? this.affectedRows,
//         insertId: insertId ?? this.insertId,
//         info: info ?? this.info,
//         serverStatus: serverStatus ?? this.serverStatus,
//         warningStatus: warningStatus ?? this.warningStatus,
//       );

//   factory PurpleStatusPageModel.fromJson(Map<String, dynamic> json) =>
//       PurpleStatusPageModel(
//         fieldCount: json["fieldCount"],
//         affectedRows: json["affectedRows"],
//         insertId: json["insertId"],
//         info: json["info"],
//         serverStatus: json["serverStatus"],
//         warningStatus: json["warningStatus"],
//       );

//   Map<String, dynamic> toJson() => {
//         "fieldCount": fieldCount,
//         "affectedRows": affectedRows,
//         "insertId": insertId,
//         "info": info,
//         "serverStatus": serverStatus,
//         "warningStatus": warningStatus,
//       };
// }
