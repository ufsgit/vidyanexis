class CalendarItemModel {
  final String id;
  final String date;
  final String description;
  final String departmentId;
  final String departmentName;
  final String userId;
  final String userName;

  CalendarItemModel({
    required this.id,
    required this.date,
    required this.description,
    this.departmentId = '',
    this.departmentName = '',
    this.userId = '',
    this.userName = '',
  });

  factory CalendarItemModel.fromJson(Map<String, dynamic> json) {
    return CalendarItemModel(
      id: json['id']?.toString() ??
          json['Calendar_Detail_Id']?.toString() ??
          '',
      date: json['Calendar_Date']?.toString() ?? json['date']?.toString() ?? '',
      description: json['Description']?.toString() ??
          json['description']?.toString() ??
          '',
      departmentId: json['Department_Id']?.toString() ??
          json['department_id']?.toString() ??
          '',
      departmentName: json['Department_Name']?.toString() ??
          json['department_name']?.toString() ??
          '',
      userId: json['User_Id']?.toString() ?? json['user_id']?.toString() ?? '',
      userName:
          json['User_Name']?.toString() ?? json['user_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Calendar_Date': date,
      'Description': description,
      'Department_Id': departmentId,
      'Department_Name': departmentName,
      'User_Id': userId,
      'User_Name': userName,
    };
  }

  CalendarItemModel copyWith({
    String? id,
    String? date,
    String? description,
    String? departmentId,
    String? departmentName,
    String? userId,
    String? userName,
  }) {
    return CalendarItemModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }
}

class CalendarTabModel {
  final String calendarId;
  final String customerId;
  final String name;
  final List<CalendarItemModel> items;
  final String createdAt;
  final String updatedAt;

  CalendarTabModel({
    required this.calendarId,
    required this.customerId,
    required this.name,
    required this.items,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory CalendarTabModel.fromJson(Map<String, dynamic> json) {
    final details = json['Calendar_Details'] ??
        json['calendar_details'] ??
        json['items'] ??
        [];
    final itemsList = (details as List<dynamic>?)
            ?.map((e) => CalendarItemModel.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return CalendarTabModel(
      calendarId: json['Calendar_Id']?.toString() ??
          json['calendar_id']?.toString() ??
          json['id']?.toString() ??
          '',
      customerId: json['Customer_id']?.toString() ??
          json['Customer_Id']?.toString() ??
          json['customer_id']?.toString() ??
          '',
      name: json['Calendar_Name']?.toString() ??
          json['calendar_name']?.toString() ??
          json['name']?.toString() ??
          '',
      items: itemsList,
      createdAt: json['created_at']?.toString() ??
          json['Created_At']?.toString() ??
          '',
      updatedAt: json['updated_at']?.toString() ??
          json['Updated_At']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson({String? customerIdOverride}) {
    return {
      'Calendar_Id': int.tryParse(calendarId) ?? 0,
      'Customer_id': int.tryParse(customerIdOverride ?? customerId) ?? 0,
      'Calendar_Name': name,
      'Calendar_Details': items.map((e) => e.toJson()).toList(),
    };
  }

  CalendarTabModel copyWith({
    String? calendarId,
    String? customerId,
    String? name,
    List<CalendarItemModel>? items,
    String? createdAt,
    String? updatedAt,
  }) {
    return CalendarTabModel(
      calendarId: calendarId ?? this.calendarId,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
