class MaintenanceDate {
  // final String id; // ID as a String
  final String date; // Date of the maintenance in 'yyyy-MM-dd' format
  final int completed; // 1 if completed, else 0

  MaintenanceDate({
    // required this.id,
    required this.date,
    this.completed = 0,
  });

  // Convert the object to a map (like JSON format)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'Interval_Date': date,
      'Completed_Status': completed,
    };
  }

  // Convert a JSON map to a MaintenanceDate object
  factory MaintenanceDate.fromJson(Map<String, dynamic> json) {
    return MaintenanceDate(
      // id: json['id']?.toString() ?? '0', // Now expect id to be a String
      date: json['Interval_Date']?.toString() ?? '',
      completed: int.tryParse((json['Completed_Status'] ?? 0).toString()) ?? 0,
    );
  }
}
