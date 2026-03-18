import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/payment_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddPaymentWidget extends StatefulWidget {
  final String customerId;
  const AddPaymentWidget({super.key, required this.customerId});

  @override
  State<AddPaymentWidget> createState() => _AddPaymentWidgetState();
}

class _AddPaymentWidgetState extends State<AddPaymentWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMode;
  final List<String> _paymentModes = [
    'Cash',
    'UPI',
    'Cheque',
    'Bank Transfer',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize date with current date if empty
    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    if (provider.paymentDateController.text.isEmpty) {
      provider.paymentDateController.text =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Preserve time part of current now, or set to 00:00:00?
      // Existing logic uses HH:mm:ss in provider fallback, so let's keep it consistent but maybe just set time to current time or 00:00:00.
      // For simplicity, let's just use the date part for display and maybe append current time for the full string if needed by backend,
      // but the provider expects 'yyyy-MM-dd HH:mm:ss'.

      final now = DateTime.now();
      final DateTime fullDateTime = DateTime(picked.year, picked.month,
          picked.day, now.hour, now.minute, now.second);

      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .paymentDateController
          .text = DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Payment',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              customerDetailsProvider.clearPaymentDetails();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          // Constrain width for dialog
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: IgnorePointer(
                    child: CustomTextField(
                      controller: customerDetailsProvider.paymentDateController,
                      hintText: 'Payment Date',
                      labelText: 'Select Date',
                      height: 50,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      suffixIcon: const Icon(Icons.calendar_today),
                      readOnly:
                          true, // Make it readonly so user has to pick via dialog
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Amount
                CustomTextField(
                  controller: customerDetailsProvider.paymentAmountController,
                  hintText: 'Paying Amount*',
                  labelText: 'Enter Amount',
                  height: 50,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Payment Mode Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Payment Mode*',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  initialValue: _selectedPaymentMode,
                  items: _paymentModes.map((String mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMode = newValue;
                      customerDetailsProvider.paymentModeController.text =
                          newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select payment mode';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Description
                CustomTextField(
                  controller:
                      customerDetailsProvider.paymentDescriptionController,
                  hintText: 'Description',
                  labelText: 'Enter Description',
                  height: 50,
                  minLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appViolet,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final payment = PaymentModel(
                paymentId: 0,
                date: customerDetailsProvider.paymentDateController.text,
                paymentModeId: _getPaymentModeId(_selectedPaymentMode),
                paymentModeName: _selectedPaymentMode,
                payingAmount: double.tryParse(
                    customerDetailsProvider.paymentAmountController.text),
                description:
                    customerDetailsProvider.paymentDescriptionController.text,
                customerId: int.tryParse(widget.customerId),
              );
              customerDetailsProvider.savePaymentApi(payment, context);
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  int _getPaymentModeId(String? mode) {
    switch (mode) {
      case 'Cash':
        return 1;
      case 'UPI':
        return 2;
      case 'Cheque':
        return 3;
      case 'Bank Transfer':
        return 4;
      case 'Other':
        return 5;
      default:
        return 1;
    }
  }
}
