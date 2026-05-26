class TimeTrackModel {
  final int count;
  final String entryDate;

  TimeTrackModel({
    required this.count,
    required this.entryDate,
  });

  factory TimeTrackModel.fromJson(Map<String, dynamic> json) {
    int parsedCount = 0;
    if (json['Count'] != null) {
      parsedCount = int.tryParse(json['Count'].toString()) ?? 0;
    } else if (json['count'] != null) {
      parsedCount = int.tryParse(json['count'].toString()) ?? 0;
    } else if (json['Total'] != null) {
      parsedCount = int.tryParse(json['Total'].toString()) ?? 0;
    } else if (json['total'] != null) {
      parsedCount = int.tryParse(json['total'].toString()) ?? 0;
    } else if (json['hours'] != null) {
      parsedCount = int.tryParse(json['hours'].toString()) ?? 0;
    } else if (json['Hours'] != null) {
      parsedCount = int.tryParse(json['Hours'].toString()) ?? 0;
    } else if (json['time'] != null) {
      parsedCount = int.tryParse(json['time'].toString()) ?? 0;
    } else if (json['Time'] != null) {
      parsedCount = int.tryParse(json['Time'].toString()) ?? 0;
    }

    String parsedDate = '';
    if (json['Entry_Date'] != null) {
      parsedDate = json['Entry_Date'].toString();
    } else if (json['entry_date'] != null) {
      parsedDate = json['entry_date'].toString();
    } else if (json['entryDate'] != null) {
      parsedDate = json['entryDate'].toString();
    } else if (json['Date'] != null) {
      parsedDate = json['Date'].toString();
    } else if (json['date'] != null) {
      parsedDate = json['date'].toString();
    } else if (json['Followup_Date'] != null) {
      parsedDate = json['Followup_Date'].toString();
    }

    return TimeTrackModel(
      count: parsedCount,
      entryDate: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Count': count,
      'Entry_Date': entryDate,
    };
  }
}
