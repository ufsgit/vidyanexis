import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/amc_status_model.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/customer_details_provider.dart';
import '../../pages/dashboard/common_widgets.dart';

class AddPeriodicServiceMobile extends StatefulWidget {
  const AddPeriodicServiceMobile(
      {super.key,
      required this.isEdit,
      required this.customerId,
      this.amcProductNameController,
      this.amcServiceController,
      this.amcDescriptionController,
      this.amcAmountController,
      this.fromDateController,
      this.toDateController,
      required this.amcId});
  final bool isEdit;
  final String customerId;
  final String? amcProductNameController;
  final String? amcServiceController;
  final String? amcDescriptionController;
  final String? amcAmountController;
  final String? fromDateController;
  final String? toDateController;
  final String amcId;

  @override
  State<AddPeriodicServiceMobile> createState() =>
      _AddPeriodicServiceMobileState();
}

class _AddPeriodicServiceMobileState extends State<AddPeriodicServiceMobile> {
  FocusNode statusNode = FocusNode();

  Future<void> _selectDate(BuildContext context, bool isFromDate,
      CustomerDetailsProvider provider) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.appViolet,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      if (isFromDate) {
        provider.fromDateController.text = formattedDate;
        // Removed automatic to-date selection
      } else {
        // Ensure To date is not before From date
        final fromDate =
            DateFormat('dd-MM-yyyy').parse(provider.fromDateController.text);
        if (picked.isAfter(fromDate)) {
          provider.toDateController.text = formattedDate;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Invalid Date Selection',
                  style: TextStyle(
                    color: AppColors.appViolet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'To date cannot be before From date',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
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
      }
    }
  }

  @override
  void initState() {
    if (widget.isEdit) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.amcProductNameController.text =
          widget.amcProductNameController!;
      customerDetailsProvider.amcServiceController.text =
          widget.amcServiceController!;
      customerDetailsProvider.amcDescriptionController.text =
          widget.amcDescriptionController!;
      customerDetailsProvider.amcAmountController.text =
          widget.amcAmountController!;
      customerDetailsProvider.fromDateController.text =
          widget.fromDateController!;
      customerDetailsProvider.toDateController.text = widget.toDateController!;
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        title: '${widget.isEdit ? 'Edit' : 'Add'} Periodic Service',
        onLeadingPressed: () {
          customerDetailsProvider.clearAmcControllers();
          Navigator.pop(context);
        },
        onSavePressed: () async {
          if (customerDetailsProvider.amcAmountController.text.isNotEmpty &&
              customerDetailsProvider.amcServiceController.text.isNotEmpty &&
              customerDetailsProvider
                  .amcProductNameController.text.isNotEmpty &&
              customerDetailsProvider.fromDateController.text.isNotEmpty &&
              customerDetailsProvider.toDateController.text.isNotEmpty) {
            await customerDetailsProvider.saveAmc(
              amcId: widget.amcId,
              toDate: formatDate(customerDetailsProvider.toDateController.text,
                  "dd-MM-yyyy", "yyyy-MM-dd"),
              cusId: widget.customerId,
              amount: customerDetailsProvider.amcAmountController.text,
              context: context,
              description:
                  customerDetailsProvider.amcDescriptionController.text,
              fromDate: formatDate(
                  customerDetailsProvider.fromDateController.text,
                  "dd-MM-yyyy",
                  "yyyy-MM-dd"),
              productName:
                  customerDetailsProvider.amcProductNameController.text,
              serviceName: customerDetailsProvider.amcServiceController.text,
            );
          } else {
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
                  content: const Text(
                    'Missing Details',
                    style: TextStyle(
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
        },
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isEdit)
                DropdownButtonFormField<int>(
                  value: customerDetailsProvider.selectedAMCStatus ?? 1,
                  items: dropDownProvider.amcStatus
                      .map((status) => DropdownMenuItem<int>(
                            value: status.amcStatusId,
                            child: Text(
                              status.amcStatusName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      final selectedAmcStatus = dropDownProvider.amcStatus
                          .firstWhere((task) => task.amcStatusId == newValue);
                      customerDetailsProvider.updateAMCStatus(
                          newValue, selectedAmcStatus.amcStatusName);
                    }
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, // Custom font size
                    fontWeight: FontWeight.w600, // Custom font weight
                    color:
                        AppColors.textBlack, // Custom color for selected item
                  ),
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: 'Choose Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: ' *', // The asterisk part
                            style: TextStyle(
                                color: Colors.red), // Red color for asterisk
                          ),
                        ],
                      ),
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Always show the label
                    floatingLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16, // Slightly smaller size for floating label
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey1, // Color for floating label
                    ),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      borderSide: BorderSide(
                        color: AppColors.textGrey2, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      borderSide: BorderSide(
                        color: AppColors.textGrey2, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      borderSide: BorderSide(
                        color: AppColors.textGrey2, // Border color
                        width: 1, // Border width
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 12),
                  ),
                  isDense: true,
                  iconSize: 18,
                ),
              // CustomAutocomplete<AMCStatusModel>(
              //   focusNode: statusNode,
              //   showOptionsOnTap: true,
              //   maxHeight: 300,
              //   optionsViewOpenDirection: OptionsViewOpenDirection.down,
              //   items: dropDownProvider.amcStatus,
              //   displayStringFunction: (model) => model.amcStatusName ?? '',
              //   defaultText: customerDetailsProvider.statusController.text,
              //   labelText: 'Status',
              //   controller: customerDetailsProvider.statusController,
              //   onSelected: (AMCStatusModel selectedStatus) {
              //     setState(() {
              //       final selectedAmcStatus = dropDownProvider.amcStatus
              //           .firstWhere((task) =>
              //               task.amcStatusId == selectedStatus.amcStatusId);
              //       customerDetailsProvider.updateAMCStatus(
              //           selectedStatus.amcStatusId,
              //           selectedAmcStatus.amcStatusName);
              //       customerDetailsProvider.statusController.text =
              //           selectedStatus.amcStatusName ?? '';
              //     });
              //   },
              //   onChanged: (value) {},
              // ),
              const SizedBox(height: 16.0),
              CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.amcProductNameController,
                labelText: 'Product Name *',
              ),
              const SizedBox(height: 16.0),
              CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.amcServiceController,
                labelText: 'Service *',
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      controller: customerDetailsProvider.fromDateController,
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, true, customerDetailsProvider),
                      labelText: 'From *',
                      // decoration: InputDecoration(
                      //   label: RichText(
                      //     text: TextSpan(
                      //       text: 'From *'.replaceAll('*', ''),
                      //       style: GoogleFonts.plusJakartaSans(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w500,
                      //         color: AppColors.textGrey3,
                      //       ),
                      //       children: const <TextSpan>[
                      //         TextSpan(
                      //           text: ' *', // The asterisk part
                      //           style: TextStyle(
                      //               color:
                      //                   Colors.red), // Red color for asterisk
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   hintText: 'From *',
                      //   hintStyle: GoogleFonts.plusJakartaSans(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //     color: AppColors.textGrey3,
                      //   ),
                      //   suffixIcon: const Icon(Icons.calendar_month),
                      // ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      controller: customerDetailsProvider.toDateController,
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, false, customerDetailsProvider),
                      // decoration: InputDecoration(
                      //   label: RichText(
                      //     text: TextSpan(
                      //       text: 'To *'.replaceAll('*', ''),
                      //       style: GoogleFonts.plusJakartaSans(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w500,
                      //         color: AppColors.textGrey3,
                      //       ),
                      //       children: const <TextSpan>[
                      //         TextSpan(
                      //           text: ' *', // The asterisk part
                      //           style: TextStyle(
                      //               color:
                      //                   Colors.red), // Red color for asterisk
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(10),
                      //     borderSide: BorderSide(
                      //       color: AppColors.textGrey2,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   hintText: 'To *',
                      //   hintStyle: GoogleFonts.plusJakartaSans(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //     color: AppColors.textGrey3,
                      //   ),
                      //   suffixIcon: const Icon(Icons.calendar_month),
                      // ),
                      labelText: 'To *',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.amcAmountController,
                labelText: 'Amount *',
                keyBoardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16.0),
              CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.amcDescriptionController,
                labelText: 'Description',
                keyBoardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      // actions: [
      //   CustomElevatedButton(
      //     buttonText: 'Cancel',
      //     onPressed: () {
      //       customerDetailsProvider.clearAmcControllers();
      //       Navigator.pop(context);
      //     },
      //     backgroundColor: AppColors.whiteColor,
      //     borderColor: AppColors.appViolet,
      //     textColor: AppColors.appViolet,
      //   ),
      //   CustomElevatedButton(
      //     buttonText: 'Save',
      //     onPressed: () async {
      //       if (customerDetailsProvider.amcAmountController.text.isNotEmpty &&
      //           customerDetailsProvider.amcServiceController.text.isNotEmpty &&
      //           customerDetailsProvider.amcProductNameController.text.isNotEmpty &&
      //           customerDetailsProvider.fromDateController.text.isNotEmpty) {
      //         customerDetailsProvider.saveAmc(
      //           amcId: widget.amcId,
      //           toDate: formatDate(customerDetailsProvider.toDateController.text, "dd-MM-yyyy", "yyyy-MM-dd"),
      //           cusId: widget.customerId,
      //           amount: customerDetailsProvider.amcAmountController.text,
      //           context: context,
      //           description: customerDetailsProvider.amcDescriptionController.text,
      //           fromDate: formatDate(customerDetailsProvider.fromDateController.text, "dd-MM-yyyy", "yyyy-MM-dd"),
      //           productName: customerDetailsProvider.amcProductNameController.text,
      //           serviceName: customerDetailsProvider.amcServiceController.text,
      //         );
      //       } else {
      //         showDialog(
      //           context: context,
      //           builder: (BuildContext context) {
      //             return AlertDialog(
      //               title: Text(
      //                 'Cannot save',
      //                 style: TextStyle(
      //                   color: AppColors.appViolet,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               content: const Text(
      //                 'Missing Details',
      //                 style: TextStyle(
      //                   color: Colors.black87,
      //                   fontSize: 16,
      //                 ),
      //               ),
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(15),
      //               ),
      //               actions: [
      //                 TextButton(
      //                   onPressed: () {
      //                     Navigator.pop(context);
      //                   },
      //                   child: Text(
      //                     'OK',
      //                     style: TextStyle(
      //                       color: AppColors.appViolet,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 16,
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             );
      //           },
      //         );
      //       }
      //     },
      //     backgroundColor: AppColors.appViolet,
      //     borderColor: AppColors.appViolet,
      //     textColor: AppColors.whiteColor,
      //   ),
      // ],
    );
  }
}
