import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/agency_payment_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddAgencyPaymentWidget extends StatefulWidget {
  const AddAgencyPaymentWidget({super.key});

  @override
  State<AddAgencyPaymentWidget> createState() => _AddAgencyPaymentWidgetState();
}

class _AddAgencyPaymentWidgetState extends State<AddAgencyPaymentWidget> {
  @override
  void initState() {
    super.initState();
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final agencyPaymentProvider =
        Provider.of<AgencyPaymentProvider>(context, listen: false);

    dropDownProvider.getEnquirySource(context);
    agencyPaymentProvider.clearForm();
  }

  Future<void> _selectPaymentDate(
      BuildContext context, AgencyPaymentProvider agencyPaymentProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      agencyPaymentProvider
          .setPaymentDate(DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final agencyPaymentProvider =
        Provider.of<AgencyPaymentProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);

    Widget buildFormContent(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            Text(
              'Add New Agency Payment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 24),
          ],
          Consumer<DropDownProvider>(
            builder: (context, dropDownProvider, child) {
              return CommonDropdown<int>(
                hintText: 'Enquiry Source',
                items: dropDownProvider.enquiryData
                    .map((source) => DropdownItem<int>(
                          id: source.enquirySourceId,
                          name: source.enquirySourceName,
                        ))
                    .toList(),
                onItemSelected: (selectedId) {
                  agencyPaymentProvider.setSelectedEnquirySource(selectedId);
                },
                selectedValue: agencyPaymentProvider.selectedEnquirySourceId,
              );
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: agencyPaymentProvider.amountController,
            hintText: 'Amount',
            labelText: 'Amount',
            keyboardType: TextInputType.number,
            readOnly: false,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectPaymentDate(context, agencyPaymentProvider),
            child: IgnorePointer(
              child: CustomTextField(
                controller: agencyPaymentProvider.paymentDateController,
                hintText: 'Payment Date',
                labelText: 'Select Payment Date',
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: agencyPaymentProvider.remarkController,
            hintText: 'Remark',
            labelText: 'Remark',
            minLines: 1,
            maxLines: 3,
            readOnly: false,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                buttonText: 'Cancel',
                onPressed: () {
                  agencyPaymentProvider.clearForm();
                  Navigator.pop(context);
                },
                radius: 4,
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF64748B),
              ),
              const SizedBox(width: 16),
              CustomElevatedButton(
                radius: 4,
                backgroundColor: AppColors.secondaryBlue,
                borderColor: AppColors.secondaryBlue,
                textColor: Colors.white,
                isLoading: agencyPaymentProvider.isLoading,
                onPressed: () {
                  final dropDownProvider =
                      Provider.of<DropDownProvider>(context, listen: false);
                  final matchingSources = dropDownProvider.enquiryData.where(
                      (e) =>
                          e.enquirySourceId ==
                          agencyPaymentProvider.selectedEnquirySourceId);
                  final String sourceName = matchingSources.isNotEmpty
                      ? matchingSources.first.enquirySourceName
                      : '';

                  agencyPaymentProvider.saveAgencyPayment(
                    context: context,
                    enquirySourceName: sourceName,
                  );
                },
                buttonText: 'Save',
              ),
            ],
          ),
        ],
      );
    }

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () {
              agencyPaymentProvider.clearForm();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Add New Agency Payment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: buildFormContent(context),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        child: SingleChildScrollView(
          child: buildFormContent(context),
        ),
      ),
    );
  }
}
