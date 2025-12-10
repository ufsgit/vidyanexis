enum UserStatusType {
  hotLead(1, "Hot", "🔥"),
  warmLead(2, "Warm", "🌤️"),
  coldLead(3, "Cold", "❄️");

  final int value;
  final String name;
  final String symbol;

  const UserStatusType(this.value, this.name, this.symbol);
}

enum CustomFieldType {
  numberOnly(1),
  textOnly(2),
  dropdown(3),
  datePicker(4),
  checkbox(5), // Added checkbox type
  fileUpload(6);

  const CustomFieldType(this.value);
  final int value;

  static CustomFieldType fromValue(int? value) {
    if (value == null) return CustomFieldType.textOnly; // Default fallback

    for (CustomFieldType type in CustomFieldType.values) {
      if (type.value == value) return type;
    }
    return CustomFieldType.textOnly; // Default fallback
  }
}

enum CustomFieldControllerkey {
  enquirySource('ENQ'),
  leadStatus('STS');

  final String value;
  const CustomFieldControllerkey(this.value);
}
