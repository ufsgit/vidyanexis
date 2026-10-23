class CustomerField {
  int? customerFieldsId;
  String? customerFieldsName;
  int? isVisibility;
  int? sort;

  CustomerField({
    this.customerFieldsId,
    this.customerFieldsName,
    this.isVisibility,
    this.sort,
  });

  factory CustomerField.fromJson(Map<String, dynamic> json) => CustomerField(
        customerFieldsId: json["customer_fields_id"],
        customerFieldsName: json["customer_fields_name"],
        isVisibility: json["is_visibility"],
        sort: json["sort"],
      );

  Map<String, dynamic> toJson() => {
        "customer_fields_id": customerFieldsId,
        "customer_fields_name": customerFieldsName,
        "is_visibility": isVisibility,
        "sort": sort,
      };
}
