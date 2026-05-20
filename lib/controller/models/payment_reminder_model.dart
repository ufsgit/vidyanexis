class PaymentReminderModel {
  int customerId = 0;
  String customerName = '';
  String reminderDate = '';
  String balanceAmount = '0';
  String totalProjectCost = '0';
  String receiptAmount = '0';
  String paidPercentage = '0';

  PaymentReminderModel({
    this.customerId = 0,
    this.customerName = '',
    this.reminderDate = '',
    this.balanceAmount = '0',
    this.totalProjectCost = '0',
    this.receiptAmount = '0',
    this.paidPercentage = '0',
  });

  PaymentReminderModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'] ?? 0;
    customerName = json['Customer_Name'] ?? '';
    reminderDate = json['Reminder_Date'] ?? '';
    balanceAmount = json['Balance_Amount'] ?? '0';
    totalProjectCost = json['Total_Project_Cost'] ?? '0';
    receiptAmount = json['Receipt_Amount'] ?? '0';
    paidPercentage = json['Paid_Percentage'] ?? '0';
  }
}
