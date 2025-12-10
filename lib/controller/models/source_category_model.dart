class SourceCategoryModel {
  final int sourceId;
  final String sourceName;

  final int deleteStatus;

  // Constructor
  SourceCategoryModel({
    required this.sourceId,
    required this.sourceName,
    required this.deleteStatus,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory SourceCategoryModel.fromJson(Map<String, dynamic> json) {
    return SourceCategoryModel(
      sourceId: json['Source_Category_Id'] ?? 0, // Default to 0 if missing
      sourceName: json['Source_Category_Name'] ??
          '', // Default to empty string if missing
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if missing
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Source_Category_Id': sourceId,
      'Source_Category_Name': sourceName,
      'DeleteStatus': deleteStatus,
    };
  }
}
