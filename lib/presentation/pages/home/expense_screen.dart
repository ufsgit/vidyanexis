import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_expense.dart';
import 'package:vidyanexis/presentation/widgets/customer/expense_card.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class ExpenseScreen extends StatefulWidget {
  final String customerId;
  const ExpenseScreen(this.customerId, {super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cdProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      cdProvider.getExpenseListApi(widget.customerId.toString(), context);
    });
  }

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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                            mode:
                                                LaunchMode.externalApplication);
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
    CustomerDetailsProvider customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    const borderColor = Color(0xFFE9EDF1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expenses',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Refresh Expenses',
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          customerDetailsProvider.getExpenseListApi(
                              widget.customerId.toString(), context,
                              forceRefresh: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      if (settingsProvider.menuIsSaveMap[48] == 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            customerDetailsProvider.clearExpenseDetails();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AddExpenseWidget(
                                customerId: widget.customerId,
                                expenseId: '0',
                                isEdit: false,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Expense'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content area
              Expanded(
                child: customerDetailsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customerDetailsProvider.expenseList.isEmpty
                        ? const CommonEmptyState(
                            message: 'No expenses found for this Lead.',
                          )
                        : (!isWeb
                            ? ListView.builder(
                                itemCount:
                                    customerDetailsProvider.expenseList.length,
                                itemBuilder: (context, index) {
                                  final expense = customerDetailsProvider
                                      .expenseList[index];
                                  return ExpenseCard(
                                    expense: expense,
                                    customerId: widget.customerId,
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      color: const Color(0xFFF8FAFC),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _buildHeaderCell('#', width: 50),
                                            _buildHeaderCell('Expense Type',
                                                flex: 2),
                                            _buildHeaderCell('Date', flex: 2),
                                            _buildHeaderCell('Amount', flex: 2),
                                            _buildHeaderCell('Description',
                                                flex: 3),
                                            _buildHeaderCell('Created By',
                                                flex: 2),
                                            _buildHeaderCell('Attachment',
                                                flex: 2),
                                            _buildHeaderCell('Actions',
                                                flex: 1),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    // Table Rows
                                    Expanded(
                                      child: ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            const Divider(
                                                height: 1, color: borderColor),
                                        itemCount: customerDetailsProvider
                                            .expenseList.length,
                                        itemBuilder: (context, index) {
                                          var expense = customerDetailsProvider
                                              .expenseList[index];
                                          String dateStr = expense.entryDate ??
                                              expense.entryDate ??
                                              '';
                                          DateTime? d =
                                              DateTime.tryParse(dateStr);
                                          String formattedDate = d != null
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(d)
                                              : (dateStr.isNotEmpty
                                                  ? dateStr
                                                  : '-');

                                          bool hasAttachment =
                                              expense.filePath != null &&
                                                  expense.filePath!.isNotEmpty;

                                          return IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                _buildDataCell(
                                                    (index + 1).toString(),
                                                    width: 50),
                                                _buildDataCell(
                                                    expense.expenseTypeName ??
                                                        '-',
                                                    flex: 2,
                                                    isBold: true),
                                                _buildDataCell(formattedDate,
                                                    flex: 2),
                                                _buildDataCell(
                                                    '₹ ${expense.amount ?? 0}',
                                                    flex: 2),
                                                _buildDataCell(
                                                    expense.description ?? '-',
                                                    flex: 3),
                                                _buildDataCell(
                                                    expense.userName ??
                                                        expense.entryByName ??
                                                        '-',
                                                    flex: 2),
                                                _buildWidgetCell(
                                                  flex: 2,
                                                  child: hasAttachment
                                                      ? TextButton.icon(
                                                          style:
                                                              TextButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () =>
                                                              _showAttachmentViewer(
                                                                  context,
                                                                  expense
                                                                      .filePath!),
                                                          icon: const Icon(
                                                              Icons.attach_file,
                                                              size: 16),
                                                          label: const Text(
                                                            'Receipt',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        )
                                                      : const Text(
                                                          'No attachment',
                                                          style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                ),
                                                _buildWidgetCell(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (settingsProvider
                                                              .menuIsEditMap[
                                                          48] ==
                                                          1)
                                                        IconButton(
                                                          tooltip: 'Edit',
                                                          onPressed: () {
                                                            customerDetailsProvider
                                                                    .expenseAmountController
                                                                    .text =
                                                                (expense.amount ??
                                                                        0)
                                                                    .toString();
                                                            customerDetailsProvider
                                                                    .expenseDescriptionController
                                                                    .text =
                                                                expense.description ??
                                                                    "";
                                                            customerDetailsProvider
                                                                    .selectedExpenseType =
                                                                expense
                                                                    .expenseTypeId;
                                                            if (expense
                                                                    .entryDate !=
                                                                null) {
                                                              DateTime? dDate =
                                                                  DateTime.tryParse(
                                                                      expense
                                                                          .entryDate!);
                                                              if (dDate !=
                                                                  null) {
                                                                customerDetailsProvider
                                                                    .setExpenseDate(
                                                                        dDate);
                                                              }
                                                            }
                                                            customerDetailsProvider
                                                                .setExpenseFilePath(
                                                                    expense
                                                                        .filePath);

                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AddExpenseWidget(
                                                                  expenseId: (expense
                                                                              .expenseManagementId ??
                                                                          0)
                                                                      .toString(),
                                                                  isEdit: true,
                                                                  customerId: widget
                                                                      .customerId,
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: const Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 18,
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      if (settingsProvider
                                                              .menuIsDeleteMap[
                                                          48] ==
                                                          1)
                                                        IconButton(
                                                          tooltip: 'Delete',
                                                          onPressed: () {
                                                            showConfirmationDialog(
                                                              isLoading:
                                                                  customerDetailsProvider
                                                                      .isDeleteLoading,
                                                              context: context,
                                                              title:
                                                                  'Confirm Deletion',
                                                              content:
                                                                  'Are you sure you want to delete this Expense?',
                                                              onCancel: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              onConfirm: () {
                                                                customerDetailsProvider.deleteExpenseApi(
                                                                    (expense.expenseManagementId ??
                                                                            0)
                                                                        .toString(),
                                                                    widget
                                                                        .customerId,
                                                                    context);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              confirmButtonText:
                                                                  'Delete',
                                                              confirmButtonColor:
                                                                  Colors.red,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 18,
                                                            color: AppColors
                                                                .textRed,
                                                          ),
                                                        ),
                                                    ],
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
                              )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF475569),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildDataCell(String text,
      {int flex = 1, bool isBold = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            color: AppColors.textBlack,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1}) {
    const borderColor = Color(0xFFE9EDF1);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: borderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}
