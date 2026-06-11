class SubStatus {
  int? subStatusId;
  String? subStatusName;

  SubStatus({
    this.subStatusId,
    this.subStatusName,
  });

  factory SubStatus.fromJson(Map<String, dynamic> json) => SubStatus(
        subStatusId: json["sub_status_id"] ?? json["Status_Id"] ?? 0,
        subStatusName: json["sub_status_name"] ?? json["Status_Name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "sub_status_id": subStatusId,
        "sub_status_name": subStatusName,
      };
}
