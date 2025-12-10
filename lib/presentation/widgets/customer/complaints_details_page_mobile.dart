import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/serive_report_model.dart';
import 'package:techtify/controller/models/service_customer_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/presentation/widgets/customer/add_complaint_mobile.dart';
import 'package:techtify/presentation/widgets/customer/expanded_text_widget.dart';
import 'package:techtify/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:techtify/presentation/widgets/customer/task_card_mobile_widget.dart';
import 'package:techtify/presentation/widgets/customer/tile_widget.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';
import 'package:techtify/utils/extensions.dart';

class ComplaintsDetailsPageMobile extends StatefulWidget {
  static String route = '/complaintsDetailsPage/';
  ServiceReportModel service;
  ComplaintsDetailsPageMobile({super.key, required this.service});

  @override
  State<ComplaintsDetailsPageMobile> createState() =>
      _ComplaintsDetailsPageMobileState();
}

class _ComplaintsDetailsPageMobileState
    extends State<ComplaintsDetailsPageMobile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.serviceDetails.clear();
      customerDetailsProvider.getServiceDetails(
          widget.service.serviceId.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: Text(
          'Complaint details',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack),
        ),
        actions: [
          if (settingsprovider.menuIsDeleteMap[14] == 1)
            CustomPopMenuButtonWidget(
              onOptionSelected: (PopupMenuOptions option) async {
                // Add async keyword here
                switch (option) {
                  case PopupMenuOptions.edit:
                    customerDetailsProvider.customerId =
                        widget.service.customerId.toString();
                    customerDetailsProvider.setServiceEditDropDown(
                        widget.service.serviceTypeId,
                        widget.service.serviceTypeName,
                        widget.service.serviceStatusId,
                        widget.service.serviceStatusName);
                    customerDetailsProvider.taskDescriptionController.text =
                        widget.service.description.toString();
                    customerDetailsProvider.serviceController.text =
                        widget.service.serviceName.toString();
                    customerDetailsProvider.serviceAmountController.text =
                        widget.service.amount.toString();
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return AddComplaintMobile(
                            taskId: widget.service.serviceId.toString(),
                            isEdit: true,
                            customerId: widget.service.customerId.toString());
                      },
                    ));
                    // showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true,
                    //   showDragHandle: false,
                    //   isDismissible: false,
                    //   backgroundColor: Colors.transparent,
                    //   builder: (BuildContext context) {
                    //     return Padding(
                    //       padding: EdgeInsets.only(
                    //           bottom: MediaQuery.of(context).viewInsets.bottom),
                    //       child: Wrap(
                    //         children: [
                    //           AddComplaintMobile(
                    //               taskId: widget.service.serviceId.toString(),
                    //               isEdit: true,
                    //               customerId:
                    //                   widget.service.customerId.toString()),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // );
                    break;
                  case PopupMenuOptions.delete:
                    showConfirmationDialog(
                      isLoading: customerDetailsProvider.isDeleteLoading,
                      context: context,
                      title: 'Confirm Deletion',
                      content:
                          'Are you sure you want to delete this complaint?',
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                      onConfirm: () async {
                        await customerDetailsProvider.deleteService(
                            widget.service.serviceId.toString(),
                            widget.service.customerId.toString(),
                            context);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      confirmButtonText: 'Delete',
                      confirmButtonColor: Colors.red,
                    );
                    break;
                }
              },
            ),
        ],
      ),
      body: customerDetailsProvider.serviceDetails.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: StatusUtils.getStatusMobileColor(
                                      customerDetailsProvider
                                          .serviceDetails[0].serviceStatusName)
                                  .withOpacity(.1),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                child: Text(
                                  customerDetailsProvider
                                      .serviceDetails[0].serviceStatusName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: StatusUtils.getStatusMobileColor(
                                        customerDetailsProvider
                                            .serviceDetails[0]
                                            .serviceStatusName),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(color: AppColors.whiteColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                  height: 34,
                                  width: 3,
                                  decoration: BoxDecoration(
                                      color: StatusUtils.getStatusMobileColor(
                                          customerDetailsProvider
                                              .serviceDetails[0]
                                              .serviceStatusName),
                                      borderRadius: BorderRadius.circular(16))),
                              const SizedBox(
                                width: 8,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customerDetailsProvider
                                        .serviceDetails[0].serviceTypeName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textGrey4),
                                  ),
                                  Text(
                                    customerDetailsProvider
                                        .serviceDetails[0].serviceName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          customerDetailsProvider
                                  .serviceDetails[0].description.isNotEmpty
                              ? Align(
                                  alignment: Alignment.topLeft,
                                  child: ExpandableText(
                                    text: customerDetailsProvider
                                        .serviceDetails[0].description,
                                    maxLines: 2,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textGrey3),
                                  ),
                                )
                              : const SizedBox(),
                          customerDetailsProvider
                                  .serviceDetails[0].description.isNotEmpty
                              ? const SizedBox(
                                  height: 12,
                                )
                              : const SizedBox(),
                          CustomText(
                            "Total Amount",
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.textGrey4,
                          ),
                          CustomText(
                            "₹${customerDetailsProvider.serviceDetails[0].amount}",
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                            fontSize: 16,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey3.withOpacity(.7)),
                              children: [
                                const TextSpan(
                                  text: "Created by ",
                                ),
                                TextSpan(
                                  text:
                                      "${customerDetailsProvider.serviceDetails[0].createdBy}",
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3),
                                ),
                                const TextSpan(
                                  text: " on ",
                                ),
                                TextSpan(
                                  text: customerDetailsProvider
                                      .serviceDetails[0].createDate
                                      .toMonthDayYearFormat(),
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
