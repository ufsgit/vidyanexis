import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddExpenseWidget extends StatefulWidget {
  final bool isEdit;
  final String customerId;
  final String expenseId;

  const AddExpenseWidget({
    super.key,
    required this.expenseId,
    required this.isEdit,
    required this.customerId,
  });

  @override
  State<AddExpenseWidget> createState() => _AddExpenseWidgetState();
}

class _AddExpenseWidgetState extends State<AddExpenseWidget> {
  bool _isUploadingFile = false;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getExpenseTypeApi(context);
    });
  }

  Future<void> _pickAndUploadFile(CustomerDetailsProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? fileData;

        if (file.bytes != null) {
          fileData = file.bytes;
        } else if (file.path != null) {
          fileData = await File(file.path!).readAsBytes();
        }

        if (fileData != null) {
          setState(() {
            _isUploadingFile = true;
            _selectedFileName = file.name;
          });

          String ext = file.extension?.toLowerCase() ?? '';
          String mimeType = ext == 'pdf' ? 'application/pdf' : 'image/$ext';
          if (ext == 'jpg') mimeType = 'image/jpeg';

          String? uploadedPath = await CloudflareUpload.uploadToCloudflare(
              fileData, mimeType, widget.customerId, context);

          setState(() {
            _isUploadingFile = false;
          });

          if (uploadedPath != null && uploadedPath.isNotEmpty) {
            provider.setExpenseFilePath(uploadedPath);
          } else {
            setState(() {
              _selectedFileName = null;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('File upload failed. Please try again.')),
              );
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingFile = false;
        _selectedFileName = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    // Active expense types only
    final activeExpenseTypes = customerDetailsProvider.expenseTypeList
        .where((element) => element.deleteStatus == 0)
        .toList();

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Expense' : 'Add Expense',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              customerDetailsProvider.clearExpenseDetails();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),

            // Expense Type Dropdown
            DropdownButtonFormField<int>(
              initialValue: activeExpenseTypes.any((e) =>
                      e.expenseTypeId ==
                      customerDetailsProvider.selectedExpenseType)
                  ? customerDetailsProvider.selectedExpenseType
                  : null,
              items: activeExpenseTypes
                  .map((type) => DropdownMenuItem<int>(
                        value: type.expenseTypeId,
                        child: Text(
                          type.expenseTypeName,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        ),
                      ))
                  .toList(),
              onChanged: (int? newValue) {
                customerDetailsProvider.selectedExpenseType = newValue;
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: 'Expense Type',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
              ),
              isDense: true,
              iconSize: 18,
            ),
            const SizedBox(height: 16.0),

            // Expense Date Picker Field
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: customerDetailsProvider.selectedExpenseDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  customerDetailsProvider.setExpenseDate(picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Expense Date *',
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textGrey3,
                  ),
                  suffixIcon:
                      const Icon(Icons.calendar_today_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.textGrey2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.textGrey2),
                  ),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy')
                      .format(customerDetailsProvider.selectedExpenseDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Amount Field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.expenseAmountController,
              hintText: 'Amount*',
              labelText: '',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),

            // Description Field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.expenseDescriptionController,
              hintText: 'Description',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16.0),

            // Attachment Control
            Text(
              'Attachment (Receipt / Document)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 8.0),
            if (_isUploadingFile)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Uploading document...'),
                  ],
                ),
              )
            else if (customerDetailsProvider.expenseFilePath != null &&
                customerDetailsProvider.expenseFilePath!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: AppColors.secondaryBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 18, color: AppColors.secondaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFileName ??
                            customerDetailsProvider.expenseFilePath!
                                .split('/')
                                .last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFileName = null;
                        });
                        customerDetailsProvider.setExpenseFilePath(null);
                      },
                    )
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _pickAndUploadFile(customerDetailsProvider),
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(
                  'Upload Receipt / File',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  side: BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: customerDetailsProvider.isSavingExpense
              ? null
              : () {
                  customerDetailsProvider.clearExpenseDetails();
                  Navigator.of(context).pop();
                },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: customerDetailsProvider.isSavingExpense
              ? 'Saving...'
              : 'Save Expense',
          onPressed: (customerDetailsProvider.isSavingExpense ||
                  _isUploadingFile)
              ? null
              : () async {
                  final amountText = customerDetailsProvider
                      .expenseAmountController.text
                      .trim();
                  final amountVal = double.tryParse(amountText);

                  if (customerDetailsProvider.selectedExpenseType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select an Expense Type')),
                    );
                    return;
                  }

                  if (amountText.isEmpty ||
                      amountVal == null ||
                      amountVal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid amount > 0')),
                    );
                    return;
                  }

                  customerDetailsProvider.saveExpenseApi(
                      widget.expenseId, widget.customerId, context);
                },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
