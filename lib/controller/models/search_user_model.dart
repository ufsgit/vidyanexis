class SearchUserTypeModel {
  int userTypeId;
  String userTypeName;

  SearchUserTypeModel({
    required this.userTypeId,
    required this.userTypeName,
  });

  factory SearchUserTypeModel.fromJson(Map<String, dynamic> json) =>
      SearchUserTypeModel(
        userTypeId: json["User_Type_Id"],
        userTypeName: json["User_Type_Name"],
      );

  Map<String, dynamic> toJson() => {
        "User_Type_Id": userTypeId,
        "User_Type_Name": userTypeName,
      };
}
