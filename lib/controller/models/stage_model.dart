class StageModel {
  final int stageId;
  final String stageName;

  final int deleteStatus;

  // Constructor
  StageModel({
    required this.stageId,
    required this.stageName,
    required this.deleteStatus,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      stageId: json['Stage_Id'] ?? 0, // Default to 0 if missing
      stageName: json['Stage_Name'] ?? '', // Default to empty string if missing
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if missing
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Stage_Id': stageId,
      'Stage_Name': stageName,
      'DeleteStatus': deleteStatus,
    };
  }
}
