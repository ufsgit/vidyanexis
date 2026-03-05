import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/inventory_customer_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddCustomer extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final InventoryCustomerModel? data;

  const AddCustomer({
    super.key,
    required this.isEdit,
    required this.editId,
    this.data,
  });

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.inventoryCustomerNameController.text.trim().isEmpty) {
      return 'Please enter Customer Name';
    }
    if (settingsProvider.inventoryCustomerAddressController.text.trim().isEmpty) {
      return 'Please enter Customer Address';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    
    // Debug: Print widget parameters
    print('=== AddCustomer initState ===');
    print('isEdit: ${widget.isEdit}');
    print('editId: ${widget.editId}');
    print('data is null: ${widget.data == null}');
    
    if (widget.data != null) {
      print('--- Customer Data ---');
      print('customerName: ${widget.data!.customerName}');
      print('address: ${widget.data!.address}');
      print('address1: ${widget.data!.address1}');
      print('address2: ${widget.data!.address2}');
      print('address3: ${widget.data!.address3}');
      print('phoneNo: ${widget.data!.phoneNo}');
      print('mobileNo: ${widget.data!.mobileNo}');
      print('email: ${widget.data!.email}');
      print('gstNo: ${widget.data!.gstNo}');
      print('openingBalance: ${widget.data!.openingBalance}');
      print('--- End Customer Data ---');
    }
    
    // Initialize immediately in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      
      if (widget.isEdit && widget.data != null) {
        print('>>> Setting controller values <<<');
        // For edit mode, populate all fields
        settingsProvider.inventoryCustomerNameController.text =
            widget.data!.customerName ?? '';
        print('Name controller set to: ${settingsProvider.inventoryCustomerNameController.text}');
        
        settingsProvider.inventoryCustomerAddressController.text =
            widget.data!.address ?? '';
        print('Address controller set to: ${settingsProvider.inventoryCustomerAddressController.text}');
        
        settingsProvider.inventoryCustomerAddress1Controller.text =
            widget.data!.address1 ?? '';
        print('Address1 controller set to: ${settingsProvider.inventoryCustomerAddress1Controller.text}');
        
        settingsProvider.inventoryCustomerAddress2Controller.text =
            widget.data!.address2 ?? '';
        print('Address2 controller set to: ${settingsProvider.inventoryCustomerAddress2Controller.text}');
        
        settingsProvider.inventoryCustomerAddress3Controller.text =
            widget.data!.address3 ?? '';
        print('Address3 controller set to: ${settingsProvider.inventoryCustomerAddress3Controller.text}');
        
        settingsProvider.inventoryCustomerPhoneController.text =
            widget.data!.phoneNo ?? '';
        print('Phone controller set to: ${settingsProvider.inventoryCustomerPhoneController.text}');
        
        settingsProvider.inventoryCustomerMobileController.text =
            widget.data!.mobileNo ?? '';
        print('Mobile controller set to: ${settingsProvider.inventoryCustomerMobileController.text}');
        
        settingsProvider.inventoryCustomerEmailController.text =
            widget.data!.email ?? '';
        print('Email controller set to: ${settingsProvider.inventoryCustomerEmailController.text}');
        
        settingsProvider.inventoryCustomerGstNoController.text =
            widget.data!.gstNo ?? '';
        print('GstNo controller set to: ${settingsProvider.inventoryCustomerGstNoController.text}');
        
        settingsProvider.inventoryCustomerOpeningBalanceController.text =
            widget.data!.openingBalance?.toString() ?? '';
        print('OpeningBalance controller set to: ${settingsProvider.inventoryCustomerOpeningBalanceController.text}');
        
        print('>>> All controllers set <<<');
      } else {
        print('>>> Clearing controllers (Add mode) <<<');
        // For add mode, ensure controllers are empty
        settingsProvider.inventoryCustomerClear();
      }
    });
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use listen: false to prevent rebuilds from clearing the data
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Customer' : 'Add Customer',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.inventoryCustomerClear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
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
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerNameController,
                      hintText: 'Customer Name*',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerAddressController,
                      hintText: 'Address*',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerAddress1Controller,
                      hintText: 'Address 1',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerAddress2Controller,
                      hintText: 'Address 2',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerAddress3Controller,
                      hintText: 'Address 3',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerPhoneController,
                      hintText: 'Phone',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerMobileController,
                      hintText: 'Mobile',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerEmailController,
                      hintText: 'Email',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.inventoryCustomerGstNoController,
                      hintText: 'GST No',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: settingsProvider.inventoryCustomerOpeningBalanceController,
                hintText: 'Opening Balance',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.inventoryCustomerClear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }

            settingsProvider.addInventoryCustomer(
              context: context,
              statusId: widget.editId,
            );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:futore_nxt/constants/app_colors.dart';
// import 'package:futore_nxt/controller/models/inventory_customer_model.dart';
// import 'package:futore_nxt/controller/settings_provider.dart';
// import 'package:futore_nxt/presentation/widgets/home/custom_button_widget.dart';
// import 'package:futore_nxt/presentation/widgets/home/custom_text_field.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// class AddCustomer extends StatefulWidget {
//   final bool isEdit;
//   final String editId;
//   final InventoryCustomerModel? data;

//   const AddCustomer({
//     super.key,
//     required this.isEdit,
//     required this.editId,
//     this.data,
//   });

//   @override
//   State<AddCustomer> createState() => _AddCustomerState();
// }

// class _AddCustomerState extends State<AddCustomer> {
//   String? validateInputs(
//       BuildContext context, SettingsProvider settingsProvider) {
//     if (settingsProvider.inventoryCustomerNameController.text.trim().isEmpty) {
//       return 'Please enter Customer Name';
//     }
//     if (settingsProvider.inventoryCustomerAddressController.text.trim().isEmpty) {
//       return 'Please enter Customer Address';
//     }
//     return null;
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (widget.isEdit) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final settingsProvider =
//             Provider.of<SettingsProvider>(context, listen: false);
//         settingsProvider.inventoryCustomerNameController.text =
//             widget.data?.customerName ?? '';
//         settingsProvider.inventoryCustomerAddressController.text =
//             widget.data?.address ?? '';
//         settingsProvider.inventoryCustomerAddress1Controller.text =
//             widget.data?.address1 ?? '';
//         settingsProvider.inventoryCustomerAddress2Controller.text =
//             widget.data?.address2 ?? '';
//         settingsProvider.inventoryCustomerAddress3Controller.text =
//             widget.data?.address3 ?? '';
//         settingsProvider.inventoryCustomerPhoneController.text =
//             widget.data?.phoneNo ?? '';
//         settingsProvider.inventoryCustomerMobileController.text =
//             widget.data?.mobileNo ?? '';
//         settingsProvider.inventoryCustomerEmailController.text =
//             widget.data?.email ?? '';
//         settingsProvider.inventoryCustomerGstNoController.text =
//             widget.data?.gstNo ?? '';
//         settingsProvider.inventoryCustomerOpeningBalanceController.text =
//             widget.data?.openingBalance.toString() ?? '';
//       });
//     }
//   }

//   void showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Cannot save',
//           style: TextStyle(
//             color: AppColors.appViolet,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 16,
//           ),
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text(
//               'OK',
//               style: TextStyle(
//                 color: AppColors.appViolet,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settingsProvider = Provider.of<SettingsProvider>(context);

//     return AlertDialog(
//       scrollable: true,
//       backgroundColor: Colors.white,
//       title: Row(
//         children: [
//           Text(
//             widget.isEdit ? 'Edit Customer' : 'Add Customer',
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textBlack,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () {
//               settingsProvider.inventoryCustomerClear();
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close),
//           ),
//         ],
//       ),
//       content: Container(
//         color: Colors.white,
//         width: MediaQuery.sizeOf(context).width / 2,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerNameController,
//                       hintText: 'Customer Name*',
//                       labelText: '',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerAddressController,
//                       hintText: 'Address*',
//                       labelText: '',
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerAddress1Controller,
//                       hintText: 'Address 1',
//                       labelText: '',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerAddress2Controller,
//                       hintText: 'Address 2',
//                       labelText: '',
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerAddress3Controller,
//                       hintText: 'Address 3',
//                       labelText: '',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerPhoneController,
//                       hintText: 'Phone',
//                       labelText: '',
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerMobileController,
//                       hintText: 'Mobile',
//                       labelText: '',
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerEmailController,
//                       hintText: 'Email',
//                       labelText: '',
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: CustomTextField(
//                       readOnly: false,
//                       height: 54,
//                       controller: settingsProvider.inventoryCustomerGstNoController,
//                       hintText: 'GST No',
//                       labelText: '',
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               CustomTextField(
//                 readOnly: false,
//                 height: 54,
//                 controller: settingsProvider.inventoryCustomerOpeningBalanceController,
//                 hintText: 'Opening Balance',
//                 labelText: '',
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         CustomElevatedButton(
//           buttonText: 'Cancel',
//           onPressed: () {
//             settingsProvider.inventoryCustomerClear();
//             Navigator.pop(context);
//           },
//           backgroundColor: AppColors.whiteColor,
//           borderColor: AppColors.appViolet,
//           textColor: AppColors.appViolet,
//         ),
//         CustomElevatedButton(
//           buttonText: 'Save',
//           onPressed: () async {
//             final validationError = validateInputs(context, settingsProvider);
//             if (validationError != null) {
//               showErrorDialog(context, validationError);
//               return;
//             }

//             settingsProvider.addInventoryCustomer(
//               context: context,
//               statusId: widget.editId,
//             );
//           },
//           backgroundColor: AppColors.appViolet,
//           borderColor: AppColors.appViolet,
//           textColor: AppColors.whiteColor,
//         ),
//       ],
//     );
//   }
// }


