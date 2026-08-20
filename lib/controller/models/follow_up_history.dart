class FollowUpHistory {
  final String followUpId;
  final String statusName;
  final int statusId;
  final String nextFollowUpDate;
  final String entryDate;
  final String toUserName;
  final String byUserName;
  final String remark;
  final int sortColumn;
  final String actualFollowUpDate;
  final String colorCode;
  final int followUp;
  final List<FollowUpAudio> audios;

  FollowUpHistory({
    this.followUpId = '',
    required this.statusName,
    required this.statusId,
    required this.nextFollowUpDate,
    required this.entryDate,
    required this.toUserName,
    required this.byUserName,
    required this.remark,
    required this.sortColumn,
    required this.actualFollowUpDate,
    required this.followUp,
    required this.colorCode,
    required this.audios,
  });

  factory FollowUpHistory.fromJson(Map<String, dynamic> json) {
    return FollowUpHistory(
      followUpId: json['FollowUp_Id']?.toString() ??
          json['Followup_Id']?.toString() ??
          json['id']?.toString() ??
          '',
      statusName: json['Status_Name'] ?? '',
      statusId: json['Status'] ?? 0,
      nextFollowUpDate: json['Next_FollowUp_Date'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      toUserName: json['To_User_Name'] ?? '',
      byUserName: json['By_User_Name'] ?? '',
      remark: json['Remark']?.toString() ?? json['Remarks']?.toString() ?? '',
      followUp: json['Followup'] is int
          ? json['Followup']
          : int.tryParse(json['Followup']?.toString() ?? '0') ?? 0,
      sortColumn: json['Sort_Coloumn'] ?? 0,
      actualFollowUpDate: json['Actual_FollowUp_Date'] ?? '',
      colorCode: json["Color_Code"] ?? "Color(0xff34c759)",
      audios: (json['Audio_Files'] != null && json['Audio_Files'] is List)
          ? List<FollowUpAudio>.from((json['Audio_Files'] as List)
              .map((audio) => FollowUpAudio.fromJson(audio)))
          : <FollowUpAudio>[],
    );
  }
}

class FollowUpAudio {
  final String? fileName;
  final String? filePath;
  final String? fileType;

  FollowUpAudio({this.fileName, this.filePath, this.fileType});

  factory FollowUpAudio.fromJson(Map<String, dynamic> json) {
    return FollowUpAudio(
      fileName: json['File_Name']?.toString() ?? '',
      filePath: json['File_Path']?.toString() ?? '',
      fileType: json['File_Type']?.toString() ?? '',
    );
  }
}
