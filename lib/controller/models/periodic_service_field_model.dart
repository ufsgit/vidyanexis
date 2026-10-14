class PeriodicServiceField {
  int? periodicServiceFieldsId;
  String? periodicServiceFieldsName;
  int? captionLoad;
  int? isVisibility;

  PeriodicServiceField({
    this.periodicServiceFieldsId,
    this.periodicServiceFieldsName,
    this.captionLoad,
    this.isVisibility,
  });

  factory PeriodicServiceField.fromJson(Map<String, dynamic> json) =>
      PeriodicServiceField(
        periodicServiceFieldsId: json["periodic_service_fields_id"],
        periodicServiceFieldsName: json["periodic_service_fields_name"],
        captionLoad: json["caption_load"],
        isVisibility: json["is_visibility"],
      );

  Map<String, dynamic> toJson() => {
        "periodic_service_fields_id": periodicServiceFieldsId,
        "periodic_service_fields_name": periodicServiceFieldsName,
        "caption_load": captionLoad,
        "is_visibility": isVisibility,
      };
}
