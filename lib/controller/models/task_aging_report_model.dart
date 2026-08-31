class TaskAgingReportModel {
  String? employee;
  String? zeroToTwoDays;
  String? threeToSevenDays;
  String? eightToFifteenDays;
  String? fifteenPlusDays;

  TaskAgingReportModel({
    this.employee,
    this.zeroToTwoDays,
    this.threeToSevenDays,
    this.eightToFifteenDays,
    this.fifteenPlusDays,
  });

  factory TaskAgingReportModel.fromJson(Map<String, dynamic> json) {
    return TaskAgingReportModel(
      employee: json['Employee']?.toString(),
      zeroToTwoDays: json['0_2_Days']?.toString(),
      threeToSevenDays: json['3_7_Days']?.toString(),
      eightToFifteenDays: json['8_15_Days']?.toString(),
      fifteenPlusDays: json['15_Plus_Days']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Employee': employee,
      '0_2_Days': zeroToTwoDays,
      '3_7_Days': threeToSevenDays,
      '8_15_Days': eightToFifteenDays,
      '15_Plus_Days': fifteenPlusDays,
    };
  }
}
