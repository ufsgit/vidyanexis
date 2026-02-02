import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/get_amc_model.dart';
import 'package:vidyanexis/controller/models/service_customer_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/common_widgets.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_complaint_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_periodic_service_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/expanded_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class PeriodicServiceDetailsPageMobile extends StatefulWidget {
  AmcReportModeld item;
  PeriodicServiceDetailsPageMobile({super.key, required this.item});

  @override
  State<PeriodicServiceDetailsPageMobile> createState() =>
      _PeriodicServiceDetailsPageMobileState();
}

class _PeriodicServiceDetailsPageMobileState
    extends State<PeriodicServiceDetailsPageMobile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
          'Periodic service details',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => AddPeriodicServiceMobile(
                            amcId: widget.item.amcId.toString(),
                            customerId: widget.item.customerId.toString(),
                            amcAmountController: widget.item.amount,
                            amcDescriptionController: widget.item.description,
                            amcProductNameController: widget.item.productName,
                            amcServiceController: widget.item.serviceName,
                            fromDateController: formatDate(
                              widget.item.fromDate.toString(),
                              "yyyy-MM-dd",
                              "dd-MM-yyyy",
                            ),
                            toDateController: formatDate(
                              widget.item.toDate.toString(),
                              "yyyy-MM-dd",
                              "dd-MM-yyyy",
                            ),
                            amc: widget.item,
                            isEdit: true),
                      ),
                    );
                    break;
                  case PopupMenuOptions.delete:
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirm Deletion',
                      content:
                          'Are you sure you want to delete this Periodic service?',
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                      onConfirm: () async {
                        await customerDetailsProvider.deleteAMC(
                            widget.item.amcId.toString(),
                            widget.item.customerId.toString(),
                            context);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      confirmButtonText: 'Delete',
                      confirmButtonColor: Colors.red,
                      isLoading: customerDetailsProvider.isDeleteLoading,
                    );
                    break;
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                widget.item.amcStatusName)
                            .withOpacity(.1),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: Text(
                            widget.item.amcStatusName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: StatusUtils.getStatusMobileColor(
                                  widget.item.amcStatusName),
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
                                    widget.item.amcStatusName),
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
                              widget.item.productName,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey4),
                            ),
                            Text(
                              widget.item.serviceName,
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: ExpandableText(
                        text: widget.item.description,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.textGrey2,
                          size: 12,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        CustomText(
                          widget.item.fromDate
                              .toString()
                              .toMonthDayYearFormat(),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.textGrey4,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomText(
                      "Total Amount",
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.textGrey4,
                    ),
                    CustomText(
                      "₹${widget.item.amount}",
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
                            text: "${widget.item.createdByName}",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey3),
                          ),
                          const TextSpan(
                            text: " on ",
                          ),
                          TextSpan(
                            text: widget.item.date
                                .toString()
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
