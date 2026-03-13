// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

// NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  String? notificationId;
  String? title;
  String? body;
  String? menuId;
  String? userDetailsId;
  String? isRead;
  String? createdAt;
  String? deleteStatus;
  String? masterId;
  String? followupId;
  String? redirectId;
  var additionalData;
  String? titleNew;
  String? bodyNew;
  String? customerId;

  NotificationModel({
    this.notificationId,
    this.title,
    this.body,
    this.menuId,
    this.userDetailsId,
    this.isRead,
    this.createdAt,
    this.deleteStatus,
    this.masterId,
    this.followupId,
    this.redirectId,
    this.additionalData,
    this.titleNew,
    this.bodyNew,
    this.customerId,
  });

  NotificationModel copyWith({
    String? notificationId,
    String? title,
    String? body,
    String? menuId,
    String? userDetailsId,
    String? isRead,
    String? createdAt,
    String? deleteStatus,
    String? masterId,
    String? followupId,
    String? redirectId,
    var additionalData,
    String? titleNew,
    String? bodyNew,
    String? customerId,
  }) =>
      NotificationModel(
        notificationId: notificationId ?? this.notificationId,
        title: title ?? this.title,
        body: body ?? this.body,
        menuId: menuId ?? this.menuId,
        userDetailsId: userDetailsId ?? this.userDetailsId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        masterId: masterId ?? this.masterId,
        followupId: followupId ?? this.followupId,
        redirectId: redirectId ?? this.redirectId,
        additionalData: additionalData ?? this.additionalData,
        titleNew: titleNew ?? this.titleNew,
        bodyNew: bodyNew ?? this.bodyNew,
        customerId: customerId ?? this.customerId,
      );

  factory NotificationModel.fromJson(
    dynamic json,
    dynamic additionalData,
  ) {
    Map<String, dynamic> toMap(dynamic value) {
      if (value == null) return <String, dynamic>{};
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty &&
            (trimmed.startsWith('{') || trimmed.startsWith('['))) {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is Map) return Map<String, dynamic>.from(decoded);
          } catch (_) {}
        }
      }
      return <String, dynamic>{};
    }

    String asIntString(dynamic value) {
      if (value == null) return '0';
      if (value is int) return value.toString();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        return (parsed ?? 0).toString();
      }
      return '0';
    }

    String asString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    final map = toMap(json);
    final addl = additionalData is String
        ? (() {
            final trimmed = additionalData.trim();
            if (trimmed.isNotEmpty &&
                (trimmed.startsWith('{') || trimmed.startsWith('['))) {
              try {
                final decoded = jsonDecode(trimmed);
                return decoded is Map
                    ? Map<String, dynamic>.from(decoded)
                    : additionalData;
              } catch (_) {}
            }
            return additionalData;
          })()
        : (additionalData is Map
            ? Map<String, dynamic>.from(additionalData)
            : additionalData);

    return NotificationModel(
      notificationId: asIntString(
        map["Notification_Id"] ?? map['notification_id'] ?? map['id'],
      ),
      title: asString(map["Title"] ?? map['title']),
      body: asString(map["Body"] ?? map['body']),
      menuId: asIntString(map["Menu_Id"] ?? map['menu_id']),
      userDetailsId: asIntString(
          map["User_Details_Id"] ?? map['user_id'] ?? map['userDetailsId']),
      isRead:
          asIntString(map["Is_Read"] ?? map['readStatus'] ?? map['is_read']),
      createdAt:
          asString(map["Created_At"] ?? map['created_at'] ?? map['createdAt']),
      deleteStatus: asString(map["DeleteStatus"] ?? map['delete_status']),
      masterId: asIntString(map["Master_Id"] ?? map['master_id']),
      followupId: asIntString(map["Followup_Id"] ?? map['followup_id']),
      redirectId: asIntString(
          map["Notification_Type_Id"] ?? map['notification_type_id']),
      titleNew: asString(map["TITLE_NEW"] ?? map['title_new']),
      bodyNew: asString(map["BODY_NEW"] ?? map['body_new']),
      customerId: asIntString(map["Customer_Id"] ?? map['customer_id']),
      additionalData: addl,
    );
  }

  Map<String, dynamic> toJson() => {
        "Notification_Id": notificationId,
        "Title": title,
        "Body": body,
        "menu_id": menuId,
        "User_Details_Id": userDetailsId,
        "Is_Read": isRead,
        "Created_At": createdAt,
        "DeleteStatus": deleteStatus,
        "Master_Id": masterId,
        "Followup_Id": followupId,
        "Notification_Type_Id": redirectId,
        "TITLE_NEW": titleNew,
        "BODY_NEW": bodyNew,
        "Customer_Id": customerId,
      };
}
