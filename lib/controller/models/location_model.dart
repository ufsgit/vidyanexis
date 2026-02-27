class LocationModel {
  int locationId;
  String locationName;

  LocationModel({
    required this.locationId,
    required this.locationName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        locationId: int.tryParse(json["Location_Id"].toString()) ?? 0,
        locationName: json["Location_Name"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Location_Id": locationId,
        "Location_Name": locationName,
      };
}
