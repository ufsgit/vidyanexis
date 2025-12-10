class UnitModel {
  final int unitId;
  final String unitName;
  final int deleteStatus;

  // Constructor
  UnitModel({
    required this.unitId,
    required this.unitName,
    required this.deleteStatus,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      unitId: json['Unit_Id'] ?? 0, // Default to 0 if missing
      unitName: json['Unit_Name'] ?? '', // Default to empty string if missing
      deleteStatus: json['Delete_Status'] ?? 0, // Default to 0 if missing
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Unit_Id': unitId,
      'Unit_Name': unitName,
      'Delete_Status': deleteStatus,
    };
  }
}
