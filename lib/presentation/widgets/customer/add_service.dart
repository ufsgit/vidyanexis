import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class ServiceCreationWidget extends StatelessWidget {
  bool isEdit;
  String customerId;
  String taskId;
  ServiceCreationWidget(
      {super.key,
      required this.taskId,
      required this.isEdit,
      required this.customerId});

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            isEdit ? 'Edit Complaint' : 'Add Complaint',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                customerDetailsProvider.clearServiceDetails();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        // height: MediaQuery.sizeOf(context).height / 1.5,
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
            if (isEdit)
              DropdownButtonFormField<int>(
                value: customerDetailsProvider.selectedServiceStatus ?? 1,
                items: const [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('Completed'),
                  ),
                  // DropdownMenuItem<int>(
                  //   value: 3,
                  //   child: Text('Completed'),
                  // ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    customerDetailsProvider.updateServiceStatus(newValue);
                  }
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, // Custom font size
                  fontWeight: FontWeight.w600, // Custom font weight
                  color: AppColors.textBlack, // Custom color for selected item
                ),
                decoration: InputDecoration(
                  label: Text(
                    'Choose Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
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
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                ),
                // items: provider.followUpData
                //     .map((status) => DropdownMenuItem<int>(
                //           value: status.statusId,
                //           child: Text(
                //             status.statusName ?? '',
                //             style: TextStyle(fontSize: 14),
                //           ),
                //         ))
                //     .toList(),
                // onChanged: (int? newValue) {
                //   if (newValue != null) {
                //     leadProvider
                //         .setStatus(newValue); // Update the status in the provider
                //   }
                // },
                isDense: true,
                iconSize: 18,
              ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              value: customerDetailsProvider.selectedServiceTypeId,
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('Paid'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('Free'),
                ),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  customerDetailsProvider.updateServiceTypeId(newValue);
                }
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, // Custom font size
                fontWeight: FontWeight.w600, // Custom font weight
                color: AppColors.textBlack, // Custom color for selected item
              ),
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: 'Complaint Type',
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
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  borderSide: BorderSide(
                    color: AppColors.textGrey2, // Border color
                    width: 1, // Border width
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
              // items: provider.followUpData
              //     .map((status) => DropdownMenuItem<int>(
              //           value: status.statusId,
              //           child: Text(
              //             status.statusName ?? '',
              //             style: TextStyle(fontSize: 14),
              //           ),
              //         ))
              //     .toList(),
              // onChanged: (int? newValue) {
              //   if (newValue != null) {
              //     leadProvider
              //         .setStatus(newValue); // Update the status in the provider
              //   }
              // },
              isDense: true,
              iconSize: 18,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.serviceController,
              hintText: 'Complaint*',
              labelText: '',
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.serviceAmountController,
                hintText: 'Amount',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.taskDescriptionController,
              hintText: 'Complaint Description',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),

            // Row(
            //   children: [
            //     Expanded(
            //       child: CustomTextField(
            //         onTap: () async {
            //           final DateTime? picked = await showDatePicker(
            //             context: context,
            //             initialDate: DateTime.now(),
            //             firstDate: DateTime.now(),
            //             lastDate: DateTime.now().add(const Duration(days: 365)),
            //           );
            //           if (picked != null) {
            //             customerDetailsProvider.taskChoosedateController.text =
            //                 DateFormat('dd MMM yyyy').format(picked);
            //             // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            //           }
            //         },
            //         readOnly: true,
            //         height: 54,
            //         controller:
            //             customerDetailsProvider.taskChoosedateController,
            //         hintText: 'Choose Date',
            //         suffixIcon: IconButton(
            //           icon: const Icon(Icons.calendar_today),
            //           onPressed: () async {
            //             final DateTime? picked = await showDatePicker(
            //               context: context,
            //               initialDate: DateTime.now(),
            //               firstDate: DateTime.now(),
            //               lastDate:
            //                   DateTime.now().add(const Duration(days: 365)),
            //             );
            //             if (picked != null) {
            //               customerDetailsProvider.taskChoosedateController
            //                   .text = DateFormat('dd MMM yyyy').format(picked);
            //             }
            //           },
            //         ),
            //         labelText: '',
            //       ),
            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Expanded(
            //       child: CustomTextField(
            //         onTap: () async {
            //           final TimeOfDay? pickedTime = await showTimePicker(
            //             context: context,
            //             initialTime: TimeOfDay.now(),
            //           );

            //           if (pickedTime != null) {
            //             final DateTime parsedTime = DateTime(
            //               0,
            //               0,
            //               0,
            //               pickedTime.hour,
            //               pickedTime.minute,
            //             );

            //             final String formattedTime =
            //                 DateFormat('hh:mm a').format(parsedTime);
            //             customerDetailsProvider.taskChoosetimeController.text =
            //                 formattedTime;
            //           }
            //         },
            //         readOnly: true,
            //         height: 54,
            //         controller:
            //             customerDetailsProvider.taskChoosetimeController,
            //         hintText: 'Choose Time',
            //         suffixIcon: IconButton(
            //           icon: const Icon(Icons.access_time_rounded),
            //           onPressed: () async {
            //             final TimeOfDay? pickedTime = await showTimePicker(
            //               context: context,
            //               initialTime: TimeOfDay.now(),
            //             );

            //             if (pickedTime != null) {
            //               final DateTime parsedTime = DateTime(
            //                 0,
            //                 0,
            //                 0,
            //                 pickedTime.hour,
            //                 pickedTime.minute,
            //               );

            //               final String formattedTime =
            //                   DateFormat('hh:mm a').format(parsedTime);
            //               customerDetailsProvider
            //                   .taskChoosetimeController.text = formattedTime;
            //             }
            //           },
            //         ),
            //         labelText: '',
            //       ),
            //     ),
            //   ],
            // ),
            //       SizedBox(height: 16.0),
            //       Text(
            //         'Assign Workers',
            //         style: GoogleFonts.plusJakartaSans(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.textGrey1,
            //         ),
            //       ),
            //       SizedBox(height: 10.0),
            //       Container(
            //         width: MediaQuery.sizeOf(context).width,
            //         decoration: BoxDecoration(
            //           color: Color(0xFFF6F7F9),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         padding: EdgeInsets.all(10),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             if (customerDetailsProvider
            //                 .selectedAssignWorkerName.isNotEmpty)
            //               Container(
            //                 padding: EdgeInsets.all(4),
            //                 margin: EdgeInsets.only(bottom: 10),
            //                 decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(8),
            //                     color: AppColors.grey),
            //                 child: Text(
            //                   customerDetailsProvider.selectedAssignWorkerName,
            //                   style: TextStyle(
            //                     fontSize: 16,
            //                     color: AppColors.textBlack,
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //               ),
            //             CustomElevatedButton(
            //               buttonText: '+ Assign a Worker',
            //               onPressed: () {
            //                 if (dropDownProvider.searchUserDetails.isEmpty) {
            //                   ScaffoldMessenger.of(context).showSnackBar(
            //                     const SnackBar(
            //                         content: Text('No workers available to assign!')),
            //                   );
            //                   return;
            //                 }

            //                 showMenu(
            //                   context: context,
            //                   position: RelativeRect.fromLTRB(
            //                       500, 500, 500, 500), // Adjust position
            //                   items: dropDownProvider.searchUserDetails
            //                       .map(
            //                         (status) => PopupMenuItem<int>(
            //                           value: status.userDetailsId!,
            //                           child: Text(status.userDetailsName ??
            //                               ''), // Display worker's name
            //                         ),
            //                       )
            //                       .toList(),
            //                 ).then((value) {
            //                   if (value != null) {
            //                     customerDetailsProvider.updateAssignWorker(
            //                         value, dropDownProvider);
            //                   }
            //                 });
            //               },
            //               backgroundColor: AppColors.whiteColor,
            //               borderColor: AppColors.appViolet,
            //               textColor: AppColors.appViolet,
            //             ),
            //           ],
            //         ),
            //       ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearServiceDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider.serviceTypeController.text.isNotEmpty &&
                customerDetailsProvider.serviceController.text.isNotEmpty) {
              customerDetailsProvider.saveService(
                  taskId,
                  customerId,
                  customerDetailsProvider.taskDescriptionController.text
                      .toString(),
                  customerDetailsProvider.serviceTypeController.text.toString(),
                  customerDetailsProvider.serviceController.text.toString(),
                  context,
                  isEdit);
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
