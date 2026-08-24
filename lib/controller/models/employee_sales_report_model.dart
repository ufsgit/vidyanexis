class EmployeeSalesReportModel {
  final int? userDetailsId;
  final String? username;
  final int? noOfQuotationsGiven;
  final int? noOfConvertedLeads;
  final double? totalKwConverted;

  EmployeeSalesReportModel({
    this.userDetailsId,
    this.username,
    this.noOfQuotationsGiven,
    this.noOfConvertedLeads,
    this.totalKwConverted,
  });

  EmployeeSalesReportModel copyWith({
    int? userDetailsId,
    String? username,
    int? noOfQuotationsGiven,
    int? noOfConvertedLeads,
    double? totalKwConverted,
  }) =>
      EmployeeSalesReportModel(
        userDetailsId: userDetailsId ?? this.userDetailsId,
        username: username ?? this.username,
        noOfQuotationsGiven: noOfQuotationsGiven ?? this.noOfQuotationsGiven,
        noOfConvertedLeads: noOfConvertedLeads ?? this.noOfConvertedLeads,
        totalKwConverted: totalKwConverted ?? this.totalKwConverted,
      );

  factory EmployeeSalesReportModel.fromJson(Map<String, dynamic> json) {
    int? parsedQuotations;
    if (json["No_of_quotation_given"] != null) {
      if (json["No_of_quotation_given"] is num) {
        parsedQuotations = (json["No_of_quotation_given"] as num).toInt();
      } else {
        parsedQuotations = int.tryParse(json["No_of_quotation_given"].toString());
      }
    } else if (json["No_of_Quotations_Given"] != null) {
      if (json["No_of_Quotations_Given"] is num) {
        parsedQuotations = (json["No_of_Quotations_Given"] as num).toInt();
      } else {
        parsedQuotations = int.tryParse(json["No_of_Quotations_Given"].toString());
      }
    } else if (json["no_of_quotations_given"] != null) {
      if (json["no_of_quotations_given"] is num) {
        parsedQuotations = (json["no_of_quotations_given"] as num).toInt();
      } else {
        parsedQuotations = int.tryParse(json["no_of_quotations_given"].toString());
      }
    }

    int? parsedConverted;
    if (json["No_of_converted"] != null) {
      if (json["No_of_converted"] is num) {
        parsedConverted = (json["No_of_converted"] as num).toInt();
      } else {
        parsedConverted = int.tryParse(json["No_of_converted"].toString());
      }
    } else if (json["No_of_Converted"] != null) {
      if (json["No_of_Converted"] is num) {
        parsedConverted = (json["No_of_Converted"] as num).toInt();
      } else {
        parsedConverted = int.tryParse(json["No_of_Converted"].toString());
      }
    } else if (json["no_of_converted"] != null) {
      if (json["no_of_converted"] is num) {
        parsedConverted = (json["no_of_converted"] as num).toInt();
      } else {
        parsedConverted = int.tryParse(json["no_of_converted"].toString());
      }
    }

    double? parsedKw;
    if (json["Total_KW_Converted"] != null) {
      if (json["Total_KW_Converted"] is num) {
        parsedKw = (json["Total_KW_Converted"] as num).toDouble();
      } else {
        parsedKw = double.tryParse(json["Total_KW_Converted"].toString());
      }
    } else if (json["total_kw_converted"] != null) {
      if (json["total_kw_converted"] is num) {
        parsedKw = (json["total_kw_converted"] as num).toDouble();
      } else {
        parsedKw = double.tryParse(json["total_kw_converted"].toString());
      }
    }

    int? parsedUserId;
    if (json["User_Details_Id"] != null) {
      if (json["User_Details_Id"] is num) {
        parsedUserId = (json["User_Details_Id"] as num).toInt();
      } else {
        parsedUserId = int.tryParse(json["User_Details_Id"].toString());
      }
    }

    return EmployeeSalesReportModel(
      userDetailsId: parsedUserId,
      username: json["User_Name"] ?? json["Username"] ?? json["username"] ?? json["Employee_Name"] ?? "-",
      noOfQuotationsGiven: parsedQuotations ?? 0,
      noOfConvertedLeads: parsedConverted ?? 0,
      totalKwConverted: parsedKw ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "User_Details_Id": userDetailsId,
        "User_Name": username,
        "No_of_quotation_given": noOfQuotationsGiven,
        "No_of_converted": noOfConvertedLeads,
        "Total_KW_Converted": totalKwConverted,
      };
}
