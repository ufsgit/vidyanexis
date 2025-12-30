class DurationModel {
  final int durationId;
  final String durationName;
  final int durationNo;

  DurationModel({
    required this.durationId,
    required this.durationName,
    required this.durationNo,
  });

  factory DurationModel.fromJson(Map<String, dynamic> json) {
    return DurationModel(
      durationId: json['Duation_Id'] ?? 0,
      durationName: json['Duration_Name'] ?? '',
      durationNo: json['Duration_No'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Duation_Id': durationId,
      'Duration_Name': durationName,
      'Duration_No': durationNo,
    };
  }
}
