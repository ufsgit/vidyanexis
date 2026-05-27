import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/expense_card.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_expense.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseTabWidget extends StatefulWidget {
  final String customerId;
  const ExpenseTabWidget({super.key, required this.customerId});

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expenses',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (settingsProvider.menuIsSaveMap[18] == 1)
                  GestureDetector(
                    onTap: () {
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
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
    );
  }
}
