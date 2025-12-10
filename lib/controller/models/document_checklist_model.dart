// To parse this JSON data, do
//
//     final documentChecklistModel = documentChecklistModelFromJson(jsonString);

import 'dart:convert';

DocumentChecklistModel documentChecklistModelFromJson(String str) => DocumentChecklistModel.fromJson(json.decode(str));

String documentChecklistModelToJson(DocumentChecklistModel data) => json.encode(data.toJson());

class DocumentChecklistModel {
  int? documentCheckListMasterId;
  String? entryDate;
  int? userId;
  String? usrName;

  DocumentChecklistModel({
    this.documentCheckListMasterId,
    this.entryDate,
    this.userId,
    this.usrName,
  });

  DocumentChecklistModel copyWith({
    int? documentCheckListMasterId,
    String? entryDate,
    int? userId,
    String? usrName,
  }) =>
      DocumentChecklistModel(
        documentCheckListMasterId: documentCheckListMasterId ?? this.documentCheckListMasterId,
        entryDate: entryDate ?? this.entryDate,
        userId: userId ?? this.userId,
        usrName: usrName ?? this.usrName,
      );

  factory DocumentChecklistModel.fromJson(Map<String, dynamic> json) => DocumentChecklistModel(
    documentCheckListMasterId: json["Document_Check_List_Master_Id"],
    entryDate: json["Entry_Date"],
    userId: json["User_Id"],
    usrName: json["Usr_Name"],
  );

  Map<String, dynamic> toJson() => {
    "Document_Check_List_Master_Id": documentCheckListMasterId,
    "Entry_Date": entryDate,
    "User_Id": userId,
    "Usr_Name": usrName,
  };
}
