import 'package:intl/intl.dart';

class DeletedLeadReportModel {
  final int? leadId;
  final String? customerName;
  final String? userName;
  final String? deletedDateTime;

  DeletedLeadReportModel({
    this.leadId,
    this.customerName,
    this.userName,
    this.deletedDateTime,
  });

  factory DeletedLeadReportModel.fromJson(Map<String, dynamic> json) {
    return DeletedLeadReportModel(
      leadId: json['Lead_Id'] != null ? int.tryParse(json['Lead_Id'].toString()) : null,
      customerName: json['Customer_Name']?.toString(),
      userName: json['User_Name']?.toString() ?? json['user_name']?.toString(),
      deletedDateTime: json['Deleted_DateTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Lead_Id': leadId,
      'Customer_Name': customerName,
      'User_Name': userName,
      'Deleted_DateTime': deletedDateTime,
    };
  }

  DateTime? get _parsedDateTime {
    if (deletedDateTime == null ||
        deletedDateTime!.isEmpty ||
        deletedDateTime == 'null') {
      return null;
    }
    try {
      return DateFormat('dd-MM-yyyy HH:mm:ss').parse(deletedDateTime!);
    } catch (_) {}
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(deletedDateTime!);
    } catch (_) {}
    try {
      return DateTime.tryParse(deletedDateTime!);
    } catch (_) {}
    return null;
  }

  String get deletedDate {
    if (deletedDateTime == null ||
        deletedDateTime!.isEmpty ||
        deletedDateTime == 'null') {
      return 'N/A';
    }
    final dt = _parsedDateTime;
    if (dt != null) {
      return DateFormat('dd-MM-yyyy').format(dt);
    }
    if (deletedDateTime!.contains(' ')) {
      return deletedDateTime!.split(' ')[0];
    }
    return deletedDateTime!;
  }

  String get deletedTime {
    if (deletedDateTime == null ||
        deletedDateTime!.isEmpty ||
        deletedDateTime == 'null') {
      return 'N/A';
    }
    final dt = _parsedDateTime;
    if (dt != null) {
      return DateFormat('hh:mm:ss a').format(dt);
    }
    final parts = deletedDateTime!.split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return 'N/A';
  }
}
