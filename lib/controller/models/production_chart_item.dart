class ProductionChartItem {
  String unitProduction;
  String dailyTotal;
  String monthlyTotal;
  String remark;

  ProductionChartItem({
    required this.unitProduction,
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.remark,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unit_production': unitProduction,
      'daily_total': dailyTotal,
      'monthly_total': monthlyTotal,
      'Remark': remark,
    };
  }

  // Create from JSON
  factory ProductionChartItem.fromJson(Map<String, dynamic> json) {
    return ProductionChartItem(
      unitProduction: json['unit_production'],
      dailyTotal: json['daily_total'],
      monthlyTotal: json['monthly_total'],
      remark: json['Remark'],
    );
  }
}
