import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _showAttachmentViewer(BuildContext context, String url) {
    bool isPdf = url.toLowerCase().endsWith('.pdf');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expense Attachment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Center(
                    child: isPdf
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Open PDF Document'),
                              ),
                            ],
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image,
                                      size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text('Unable to load receipt image'),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    child: const Text('Open Link'),
                                  )
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    String type = expense.expenseTypeName ?? "Unknown";
    String description = expense.description ?? "";
    String userName = expense.userName ?? expense.entryByName ?? "";
    String dateStr = expense.entryDate ?? DateTime.now().toString();

    DateTime? parsedDate = DateTime.tryParse(dateStr);
    String formattedDate = parsedDate != null
        ? DateFormat('dd MMM yyyy').format(parsedDate)
        : dateStr;

    bool hasAttachment = expense.filePath != null && expense.filePath!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '₹ ${expense.amount ?? 0}',
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                if (userName.isNotEmpty) ...[
                  const Spacer(),
                  const Icon(Icons.person_outline,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            if (description.isNotEmpty) ...[
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
                ],
              ),
            ],
            const SizedBox(height: 8.0),
            Row(
              children: [
                if (hasAttachment)
                  InkWell(
                    onTap: () =>
                        _showAttachmentViewer(context, expense.filePath!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file,
                              size: 14, color: AppColors.secondaryBlue),
                          SizedBox(width: 4),
                          Text(
                            'View Receipt',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                if (settingsProvider.menuIsEditMap[48] == 1)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      customerDetailsProvider.expenseAmountController.text =
                          (expense.amount ?? 0).toString();
                      customerDetailsProvider
                              .expenseDescriptionController.text =
                          expense.description ?? "";
                      customerDetailsProvider.selectedExpenseType =
                          expense.expenseTypeId;
                      if (expense.entryDate != null) {
                        DateTime? d = DateTime.tryParse(expense.entryDate!);
                        if (d != null) {
                          customerDetailsProvider.setExpenseDate(d);
                        }
                      }
                      customerDetailsProvider
                          .setExpenseFilePath(expense.filePath);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AddExpenseWidget(
                            expenseId:
                                (expense.expenseManagementId ?? 0).toString(),
                            isEdit: true,
                            customerId: customerId,
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                const SizedBox(width: 8),
                if (settingsProvider.menuIsDeleteMap[48] == 1)
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
                              (expense.expenseManagementId ?? 0).toString(),
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
      ),
    );
  }
}
