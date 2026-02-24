class HSNResponse {
  final List<HSNModel> hsnDetails;
  final TotalsModel totals;

  HSNResponse({
    required this.hsnDetails,
    required this.totals,
  });

  factory HSNResponse.fromJson(Map<String, dynamic> json) {
    return HSNResponse(
      hsnDetails: (json['hsnDetails'] as List)
          .map((item) => HSNModel.fromJson(item))
          .toList(),
      totals: TotalsModel.fromJson(json['totals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hsnDetails': hsnDetails.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}

class HSNModel {
  final String hsnCode;
  final String gst;
  final String cgst;
  final String sgst;
  final String totalTaxableAmount;
  final String totalCgstAmount;
  final String totalSgstAmount;

  HSNModel({
    required this.hsnCode,
    required this.gst,
    required this.cgst,
    required this.sgst,
    required this.totalTaxableAmount,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
  });

  factory HSNModel.fromJson(Map<String, dynamic> json) {
    return HSNModel(
      hsnCode: json['hsn_code']?.toString() ?? "0",
      gst: json['gst']?.toString() ?? "0",
      cgst: json['cgst']?.toString() ?? "0",
      sgst: json['sgst']?.toString() ?? "0",
      totalTaxableAmount: json['total_gst_amount']?.toString() ?? "0",
      totalCgstAmount: json['total_cgst_amount']?.toString() ?? "0",
      totalSgstAmount: json['total_sgst_amount']?.toString() ?? "0",
    );
  }

  Map<String, String> toJson() {
    return {
      'hsn_code': hsnCode,
      'gst': gst,
      'cgst': cgst,
      'sgst': sgst,
      'total_gst_amount': totalTaxableAmount,
      'total_cgst_amount': totalCgstAmount,
      'total_sgst_amount': totalSgstAmount,
    };
  }
}

class TotalsModel {
  final String totalTaxableAmount;
  final String totalCgstAmount;
  final String totalSgstAmount;

  TotalsModel({
    required this.totalTaxableAmount,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
  });

  factory TotalsModel.fromJson(Map<String, dynamic> json) {
    return TotalsModel(
      totalTaxableAmount: json['total_gst_amount']?.toString() ?? "0",
      totalCgstAmount: json['total_cgst_amount']?.toString() ?? "0",
      totalSgstAmount: json['total_sgst_amount']?.toString() ?? "0",
    );
  }

  Map<String, String> toJson() {
    return {
      'total_gst_amount': totalTaxableAmount,
      'total_cgst_amount': totalCgstAmount,
      'total_sgst_amount': totalSgstAmount,
    };
  }
}
