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
    }

    String parsedDate = '';
    if (json['Entry_Date'] != null) {
      parsedDate = json['Entry_Date'].toString();
    } else if (json['entry_date'] != null) {
      parsedDate = json['entry_date'].toString();
    } else if (json['entryDate'] != null) {
      parsedDate = json['entryDate'].toString();
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
