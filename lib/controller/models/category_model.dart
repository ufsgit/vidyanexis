class CategoryModel {
  final int categoryId;
  final String categoryName;
  final int deleteStatus;

  // Constructor
  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.deleteStatus,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['Category_Id'] ?? 0, // Default to 0 if missing
      categoryName:
          json['Category_Name'] ?? '', // Default to empty string if missing
      deleteStatus: json['Delete_Status'] ?? 0, // Default to 0 if missing
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Category_Id': categoryId,
      'Category_Name': categoryName,
      'Delete_Status': deleteStatus,
    };
  }
}
