import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/presentation/pages/dashboard/common_widgets.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AmcCreationWidget extends StatefulWidget {
  final bool isEdit;
  final String customerId;
  final String? amcProductNameController;
  final String? amcServiceController;
  final String? amcDescriptionController;
  final String? amcAmountController;
  final String? fromDateController;
  final String? toDateController;
  final String amcId;
  const AmcCreationWidget(
      {super.key,
      required this.isEdit,
      required this.customerId,
      this.amcAmountController,
      this.amcDescriptionController,
      this.amcProductNameController,
      this.amcServiceController,
      this.fromDateController,
      this.toDateController,
      required this.amcId});

  @override
  State<AmcCreationWidget> createState() => _AmcCreationWidgetState();
}

class _AmcCreationWidgetState extends State<AmcCreationWidget> {
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

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            '${widget.isEdit ? 'Edit' : 'Add'} Periodic Service',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              customerDetailsProvider.clearAmcControllers();
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
        height: MediaQuery.sizeOf(context).height / 2,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1,
                ),
              ),
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.amcProductNameController,
                hintText: 'Product Name *',
                labelText: '',
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.amcServiceController,
                hintText: 'Service *',
                labelText: '',
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, // Custom font size for the input text
                        fontWeight: FontWeight
                            .w600, // Custom font weight for the input text
                        color: AppColors.textBlack, // Color for the input text
                      ),
                      controller: customerDetailsProvider.fromDateController,
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, true, customerDetailsProvider),
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'From *'.replaceAll('*', ''),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *', // The asterisk part
                                style: TextStyle(
                                    color:
                                        Colors.red), // Red color for asterisk
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        hintText: 'From *',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, // Custom font size for the input text
                        fontWeight: FontWeight
                            .w600, // Custom font weight for the input text
                        color: AppColors.textBlack, // Color for the input text
                      ),
                      controller: customerDetailsProvider.toDateController,
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, false, customerDetailsProvider),
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'To *'.replaceAll('*', ''),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *', // The asterisk part
                                style: TextStyle(
                                    color:
                                        Colors.red), // Red color for asterisk
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        hintText: 'To *',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.amcAmountController,
                hintText: 'Amount *',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.amcDescriptionController,
                hintText: 'Description',
                labelText: '',
                keyboardType: TextInputType.multiline,
                minLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearAmcControllers();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider.amcAmountController.text.isNotEmpty &&
                customerDetailsProvider.amcServiceController.text.isNotEmpty &&
                customerDetailsProvider
                    .amcProductNameController.text.isNotEmpty &&
                customerDetailsProvider.fromDateController.text.isNotEmpty &&
                customerDetailsProvider.toDateController.text.isNotEmpty) {
              await customerDetailsProvider.saveAmc(
                amcId: widget.amcId,
                toDate: formatDate(
                    customerDetailsProvider.toDateController.text,
                    "dd-MM-yyyy",
                    "yyyy-MM-dd"),
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
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
