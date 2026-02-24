class PaymentReminderModel {
  late int customerId;
  late String customerName;
  late String reminderDate;
  late String balanceAmount;

  PaymentReminderModel({
    required this.customerId,
    required this.customerName,
    required this.reminderDate,
    required this.balanceAmount,
  });

  PaymentReminderModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'] ?? 0;
    customerName = json['Customer_Name'] ?? '';
    reminderDate = json['Reminder_Date'] ?? '';
    balanceAmount = json['Balance_Amount'] ?? '';
  }
}
