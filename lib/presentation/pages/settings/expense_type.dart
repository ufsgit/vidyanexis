import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/settings/add_expense.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class ExpenseType extends StatefulWidget {
  const ExpenseType({super.key});

  @override
  State<ExpenseType> createState() => _ExpenseTypeState();
}

class _ExpenseTypeState extends State<ExpenseType> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.getExpenseType('', context);
      settingsProvider.searchExpenseTypeController.clear();
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AddExpenseType(
          editId: '0',
          isEdit: false,
          status: '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              if (settingsProvider.expenseTypeList.isEmpty)
                const CommonEmptyState(message: 'No expense types found.')
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: settingsProvider.expenseTypeList.length,
                    itemBuilder: (context, index) {
                      final item = settingsProvider.expenseTypeList[index];
                      bool isActive = item.deleteStatus == 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Expense Type Name
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.expenseTypeName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // Status Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Actions
                            if (settingsProvider.menuIsEditMap[23] == 1 ||
                                settingsProvider.menuIsViewMap[23] == 1)
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddExpenseType(
                                        editId:
                                            item.expenseTypeId.toString(),
                                        status: item.expenseTypeName,
                                        isEdit: true,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined,
                                    size: 16, color: AppColors.primaryBlue),
                                label: Text(
                                  'Edit',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),

                            if (settingsProvider.menuIsDeleteMap[23] == 1 ||
                                settingsProvider.menuIsViewMap[23] == 1)
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Status Change'),
                                        content: Text(isActive
                                            ? 'Are you sure you want to de-activate this expense type? (It will be hidden from new expenses)'
                                            : 'Are you sure you want to delete this expense type?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              settingsProvider.deleteExpenseType(
                                                  context,
                                                  item.expenseTypeId);
                                            },
                                            child: const Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  isActive
                                      ? Icons.block
                                      : Icons.delete_outline,
                                  size: 16,
                                  color: AppColors.textRed,
                                ),
                                label: Text(
                                  isActive ? 'Deactivate' : 'Delete',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textRed,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );

        if (isWeb) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: content,
          );
        } else {
          return content;
        }
      },
    );
  }
}
