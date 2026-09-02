class ProjectDurationModel {
  int? customerId;
  String? customerName;
  int? expectedDuration;
  String? projectStartDate;
  int? actualDuration;
  int? difference;

  ProjectDurationModel({
    this.customerId,
    this.customerName,
    this.expectedDuration,
    this.projectStartDate,
    this.actualDuration,
    this.difference,
  });

  factory ProjectDurationModel.fromJson(Map<String, dynamic> json) {
    return ProjectDurationModel(
      customerId: json['Customer_Id'],
      customerName: json['Customer_Name'],
      expectedDuration: json['Expected_Duration'],
      projectStartDate: json['Project_Start_Date'],
      actualDuration: json['Actual_Duration'],
      difference: json['Difference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Expected_Duration': expectedDuration,
      'Project_Start_Date': projectStartDate,
      'Actual_Duration': actualDuration,
      'Difference': difference,
    };
  }
}
