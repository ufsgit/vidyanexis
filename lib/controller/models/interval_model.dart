class IntervalModel {
  final int intervalsId;
  final String intervalsName;
  final int intervalsNo;

  IntervalModel({
    required this.intervalsId,
    required this.intervalsName,
    required this.intervalsNo,
  });

  factory IntervalModel.fromJson(Map<String, dynamic> json) {
    return IntervalModel(
      intervalsId: json['Intervals_Id'] ?? 0,
      intervalsName: json['Intervals_Name'] ?? '',
      intervalsNo: json['Intervals_No'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Intervals_Id': intervalsId,
      'Intervals_Name': intervalsName,
      'Intervals_No': intervalsNo,
    };
  }
}
