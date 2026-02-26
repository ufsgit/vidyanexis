import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_expense.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final String customerId;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    String type = expense.expenseTypeName ?? "Unknown";
    String description = expense.description ?? "";
    String dateStr = expense.entryDate ?? DateTime.now().toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Rs ${expense.amount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Type: $type",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (settingsProvider.menuIsEditMap[18] == 1)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          await customerDetailsProvider.getExpenseByIdApi(
                              expense.expenseManagementId.toString(), context);
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AddExpenseWidget(
                                  expenseId:
                                      expense.expenseManagementId.toString(),
                                  isEdit: true,
                                  customerId: customerId,
                                );
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    if (settingsProvider.menuIsDeleteMap[18] == 1)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showConfirmationDialog(
                            isLoading: customerDetailsProvider.isDeleteLoading,
                            context: context,
                            title: 'Confirm Deletion',
                            content:
                                'Are you sure you want to delete this Expense?',
                            onCancel: () {
                              Navigator.of(context).pop();
                            },
                            onConfirm: () {
                              customerDetailsProvider.deleteExpenseApi(
                                  expense.expenseManagementId.toString(),
                                  customerId,
                                  context);
                              Navigator.of(context).pop();
                            },
                            confirmButtonText: 'Delete',
                            confirmButtonColor: Colors.red,
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.textRed,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
