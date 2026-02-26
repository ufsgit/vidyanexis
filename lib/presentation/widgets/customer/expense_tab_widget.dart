import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/expense_card.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_expense.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

class ExpenseTabWidget extends StatefulWidget {
  final String customerId;
  const ExpenseTabWidget({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<ExpenseTabWidget> createState() => _ExpenseTabWidgetState();
}

class _ExpenseTabWidgetState extends State<ExpenseTabWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getExpenseListApi(widget.customerId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: customerDetailsProvider.expenseList.isEmpty
                ? const Center(
                    child: Text(
                      "No expenses found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: customerDetailsProvider.expenseList.length,
                    itemBuilder: (context, index) {
                      final expense =
                          customerDetailsProvider.expenseList[index];
                      return ExpenseCard(
                        expense: expense,
                        customerId: widget.customerId,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: settingsProvider.menuIsSaveMap[18] == 1
          ? CustomElevatedButton(
              prefixIcon: Icons.add,
              radius: 32,
              buttonText: 'Add Expense',
              onPressed: () {
                customerDetailsProvider.clearExpenseDetails();
                showDialog(
                  context: context,
                  builder: (context) => AddExpenseWidget(
                    customerId: widget.customerId,
                    expenseId: '0',
                    isEdit: false,
                  ),
                );
              },
              backgroundColor: AppColors.bluebutton,
              borderColor: AppColors.bluebutton,
              textColor: AppColors.whiteColor,
            )
          : null,
    );
  }
}
