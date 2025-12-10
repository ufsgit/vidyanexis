import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddExpenseManagement extends StatefulWidget {
  final bool isEdit;
  final String editId;

  const AddExpenseManagement({
    super.key,
    required this.isEdit,
    required this.editId,
  });

  @override
  State<AddExpenseManagement> createState() => _AddExpenseManagementState();
}

class _AddExpenseManagementState extends State<AddExpenseManagement> {
  String? validateInputs(
      BuildContext context, ExpenseProvider expenseProvider) {
    // if (expenseProvider.enquiryForController.text.trim().isEmpty) {
    //   return 'Please enter Enquiry For';
    // }

    // if (expenseProvider.selectedColor == null) {
    //   return 'Please select a category color';
    // }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.getExpenseType(context);

    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit
                ? 'Edit Expense Management'
                : 'Add Expense Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width / 2,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'Expense Type*',
                      selectedValue: widget.isEdit
                          ? expenseProvider.selectedItemCategory
                          : null,
                      items: expenseProvider.expenseTypeList
                          .map((status) => DropdownItem<int>(
                                id: status.expenseTypeId,
                                name: status.expenseTypeName,
                              ))
                          .toList(),
                      controller: expenseProvider.expenseTypeController,
                      onItemSelected: (selectedId) {
                        expenseProvider.setSelectedExpenseTypeId(selectedId);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.taskController,
                      hintText: 'Task',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.amountController,
                      hintText: 'Amount',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: true,
                      height: 54,
                      controller: expenseProvider.dateController,
                      hintText: 'Date',
                      labelText: '',
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          expenseProvider.dateController.text =
                              DateFormat('dd MMM yyyy').format(picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CustomElevatedButton(
                buttonText: 'Upload Document',
                onPressed: () async {
                  await expenseProvider.addFile();
                },
                backgroundColor: AppColors.whiteColor,
                borderColor: AppColors.appViolet,
                textColor: AppColors.appViolet,
              ),
              const SizedBox(
                height: 10,
              ),
              expenseProvider.images.isEmpty && expenseProvider.pdfs.isEmpty
                  ? const Text(
                      'No documents uploaded yet.') // Common message for both
                  : Column(
                      children: [
                        // Display images if uploaded
                        expenseProvider.images.isNotEmpty
                            ? MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: SizedBox(
                                  height: 100,
                                  child: Scrollbar(
                                    controller:
                                        expenseProvider.scrollController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller:
                                          expenseProvider.scrollController,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: expenseProvider.images.length,
                                      itemBuilder: (context, index) {
                                        final image =
                                            expenseProvider.images[index];
                                        return Stack(
                                          children: [
                                            Center(
                                              child: InkWell(
                                                onTap: () {
                                                  // Implement full-screen image view here
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    image,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: GestureDetector(
                                                onTap: () => expenseProvider
                                                    .removeImage(image),
                                                child: const CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.grey,
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : Container(),

                        // Display PDFs if uploaded
                        expenseProvider.pdfs.isNotEmpty
                            ? MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: SizedBox(
                                  height: 100,
                                  child: Scrollbar(
                                    controller:
                                        expenseProvider.scrollController,
                                    thumbVisibility: true,
                                    child: ListView.separated(
                                      controller:
                                          expenseProvider.scrollController,
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: expenseProvider.pdfs.length,
                                      itemBuilder: (context, index) {
                                        final pdf = expenseProvider.pdfs[index];
                                        return Stack(
                                          children: [
                                            Center(
                                              child: InkWell(
                                                onTap: () {
                                                  // Implement PDF view here (if needed)
                                                },
                                                child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  child: const Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 50,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: GestureDetector(
                                                onTap: () => expenseProvider
                                                    .removePdf(pdf),
                                                child: const CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.grey,
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, expenseProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            String userId = preferences.getString('userId') ?? "0";
            if (expenseProvider.images.isNotEmpty ||
                expenseProvider.pdfs.isNotEmpty) {
              if (expenseProvider.images.isNotEmpty) {
                await expenseProvider.uploadImagesToAws(userId, context);
              }
              if (expenseProvider.pdfs.isNotEmpty) {
                await expenseProvider.uploadPdfsToAws(userId, context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pick Documents')),
              );
            }

            // expenseProvider.saveCompanyDetails(
            //   context: context,
            //   companyId: widget.editId,
            // );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
