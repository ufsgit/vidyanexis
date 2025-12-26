class TimeTrackModel {
  final int count;
  final String entryDate;

  TimeTrackModel({
    required this.count,
    required this.entryDate,
  });

  // Factory method to create a TimeTrackModel from JSON using ?? operator
  factory TimeTrackModel.fromJson(Map<String, dynamic> json) {
    return TimeTrackModel(
      count: json['Count'] ?? 0, // Default to 0 if value is null or missing
      entryDate: json['Entry_Date'] ?? '', // Default to empty string
    );
  }

  // Method to convert a TimeTrackModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'Count': count,
      'Entry_Date': entryDate,
    };
  }
}
