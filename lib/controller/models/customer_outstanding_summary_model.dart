class CustomerOutstandingSummaryModel {
  final int totalCustomers;
  final String totalProjectCost;
  final String totalReceived;
  final String totalBalance;

  CustomerOutstandingSummaryModel({
    required this.totalCustomers,
    required this.totalProjectCost,
    required this.totalReceived,
    required this.totalBalance,
  });

  factory CustomerOutstandingSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerOutstandingSummaryModel(
      totalCustomers:
          int.tryParse(json['Total_Customers']?.toString() ?? '0') ?? 0,
      totalProjectCost: json['Total_Project_Cost']?.toString() ?? '0.00',
      totalReceived: json['Total_Received']?.toString() ?? '0.00',
      totalBalance: json['Total_Balance']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        'Total_Customers': totalCustomers,
        'Total_Project_Cost': totalProjectCost,
        'Total_Received': totalReceived,
        'Total_Balance': totalBalance,
      };
}
