class QuotationField {
  int? quotationFieldsId;
  String? quotationFieldsName;
  int? captionLoad;
  int? isVisibility;

  QuotationField({
    this.quotationFieldsId,
    this.quotationFieldsName,
    this.captionLoad,
    this.isVisibility,
  });

  factory QuotationField.fromJson(Map<String, dynamic> json) => QuotationField(
        quotationFieldsId: json["quotation_fields_id"],
        quotationFieldsName: json["quotation_fields_name"],
        captionLoad: json["caption_load"],
        isVisibility: json["is_visibility"],
      );

  Map<String, dynamic> toJson() => {
        "quotation_fields_id": quotationFieldsId,
        "quotation_fields_name": quotationFieldsName,
        "caption_load": captionLoad,
        "is_visibility": isVisibility,
      };
}
