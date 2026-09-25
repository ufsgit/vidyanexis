class DayWiseCountModel {
  DateTime? date;
  int? leadCount;

  DayWiseCountModel({this.date, this.leadCount});

  factory DayWiseCountModel.fromJson(Map<String, dynamic> json) {
    return DayWiseCountModel(
      date: json['Date'] != null ? DateTime.tryParse(json['Date'].toString()) : null,
      leadCount: json['Lead_Count'] != null ? int.tryParse(json['Lead_Count'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Date'] = date?.toIso8601String();
    data['Lead_Count'] = leadCount;
    return data;
  }
}
