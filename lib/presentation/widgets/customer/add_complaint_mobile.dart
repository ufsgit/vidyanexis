import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/models/follow_up_model.dart';
import 'package:techtify/controller/models/search_user_details_model.dart';
import 'package:techtify/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:techtify/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
import 'package:techtify/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class AddComplaintMobile extends StatefulWidget {
  bool isEdit;
  String customerId;
  String taskId;
  AddComplaintMobile(
      {super.key,
      required this.taskId,
      required this.isEdit,
      required this.customerId});

  @override
  State<AddComplaintMobile> createState() => _AddComplaintMobileState();
}

class _AddComplaintMobileState extends State<AddComplaintMobile> {
  late FocusNode _leadNameFocusNode;
  late FocusNode statusNode;
  late FocusNode complaintNode;

  @override
  void initState() {
    _leadNameFocusNode = FocusNode();
    statusNode = FocusNode();
    complaintNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leadNameFocusNode.requestFocus();
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   _leadNameFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBarWidget(
        title: widget.isEdit ? 'Edit Complaint' : 'Add Complaint',
        isEdit: widget.isEdit,
        onLeadingPressed: () {
          Navigator.pop(context);
        },
        onSavePressed: () async {
          if (customerDetailsProvider.serviceTypeController.text.isNotEmpty &&
              customerDetailsProvider.serviceController.text.isNotEmpty) {
            customerDetailsProvider.saveService(
                widget.taskId,
                widget.customerId,
                customerDetailsProvider.taskDescriptionController.text
                    .toString(),
                customerDetailsProvider.serviceTypeController.text.toString(),
                customerDetailsProvider.serviceController.text.toString(),
                context,
                widget.isEdit);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isEdit)
              CustomAutocomplete<int>(
                focusNode: statusNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: const [1, 2],
                displayStringFunction: (model) =>
                    model == 1 ? 'Pending' : 'Completed',
                defaultText: customerDetailsProvider.selectedServiceStatus == 1
                    ? 'Pending'
                    : 'Completed',
                labelText: 'Choose Status',
                controller: customerDetailsProvider.serviceStatusNameController,
                onSelected: (int selectedStatus) {
                  customerDetailsProvider.updateServiceStatus(selectedStatus);
                  customerDetailsProvider.serviceStatusNameController.text =
                      selectedStatus == 1 ? 'Pending' : 'Completed';
                },
                onChanged: (value) {},
              ),
            if (widget.isEdit) const SizedBox(height: 16.0),
            CustomAutocomplete<int>(
              focusNode: complaintNode,
              showOptionsOnTap: true,
              optionsViewOpenDirection: OptionsViewOpenDirection.down,
              items: const [1, 2],
              displayStringFunction: (model) => model == 1 ? 'Paid' : 'Free',
              defaultText: customerDetailsProvider.selectedServiceTypeId == 1
                  ? 'Paid'
                  : 'Free',
              labelText: 'Complaint Type',
              controller: customerDetailsProvider.serviceTypeController,
              onSelected: (int selectedType) {
                customerDetailsProvider.updateServiceTypeId(selectedType);
                customerDetailsProvider.serviceTypeController.text =
                    selectedType == 1 ? 'Paid' : 'Free';
              },
              onChanged: (value) {},
            ),
            const SizedBox(height: 16.0),
            CustomTextfieldWidgetMobile(
              focusNode: FocusNode(),
              readOnly: false,
              controller: customerDetailsProvider.serviceController,
              labelText: 'Complaint',
            ),
            const SizedBox(height: 16.0),
            CustomTextfieldWidgetMobile(
              focusNode: FocusNode(),
              readOnly: false,
              controller: customerDetailsProvider.serviceAmountController,
              keyBoardType: TextInputType.number,
              labelText: 'Amount',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey)),
              child: CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.taskDescriptionController,
                labelText: 'Description',
                minLines: 3,
                maxLines: 6,
              ),
            ),
            // SizedBox(height: 20),
            // SizedBox(
            //   height: 38,
            //   child: CustomElevatedButton(
            //     textSize: 14,
            //     radius: 12,
            //     isLoading: leadProvider.isSavingFollowup,
            //     buttonText: widget.isEdit ? 'Edit Complaint' : 'Add Complaint',
            //     onPressed: () async {
            //       if (customerDetailsProvider
            //               .serviceTypeController.text.isNotEmpty &&
            //           customerDetailsProvider
            //               .serviceController.text.isNotEmpty) {
            //         customerDetailsProvider.saveService(
            //             widget.taskId,
            //             widget.customerId,
            //             customerDetailsProvider.taskDescriptionController.text
            //                 .toString(),
            //             customerDetailsProvider.serviceTypeController.text
            //                 .toString(),
            //             customerDetailsProvider.serviceController.text
            //                 .toString(),
            //             context,
            //             widget.isEdit);
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
            // ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
