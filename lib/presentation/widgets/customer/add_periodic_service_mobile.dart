import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/amc_status_model.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';

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
      required this.amcId,
      this.amc});
  final bool isEdit;
  final String customerId;
  final String? amcProductNameController;
  final String? amcServiceController;
  final String? amcDescriptionController;
  final String? amcAmountController;
  final String? fromDateController;
  final String? toDateController;
  final String amcId;
  final AmcReportModeld? amc;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      customerDetailsProvider.maintenanceDates.clear();
      leadDetailsProvider.fetchLeadDetails(widget.customerId, context);
      if (leadDetailsProvider.leadDetails != null &&
          leadDetailsProvider.leadDetails!.isNotEmpty) {
        String installationDate =
            leadDetailsProvider.leadDetails![0].entryDate ?? '';
        customerDetailsProvider.fromDateController.text =
            installationDate.toDDMMYYYY();
      }
      dropDownProvider.setSelectedAmcPeriodicIntervalId(0);
      dropDownProvider.setSelectedAmcTotalDurationId(0);
      dropDownProvider.getDuration(context);
      dropDownProvider.getIntervals(context);
      dropDownProvider.getUserDetails(context);
      customerDetailsProvider.yearInterval = 0;
      customerDetailsProvider.monthInterval = 0;
      if (widget.isEdit) {
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
        customerDetailsProvider.toDateController.text =
            widget.toDateController!;
        dropDownProvider
            .setSelectedAmcPeriodicIntervalId(widget.amc!.periodIntervalId);
        dropDownProvider
            .setSelectedAmcTotalDurationId(widget.amc!.totalDurationId);
        customerDetailsProvider.yearInterval = widget.amc!.totalDurationNo;
        customerDetailsProvider.monthInterval = widget.amc!.periodIntervalNo;
        customerDetailsProvider.amcTotalDurationController.text =
            widget.amc!.totalDurationName;
        customerDetailsProvider.maintenanceDates = widget.amc!.maintenanceDate;
      }
      super.initState();
    });
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
              toDate: customerDetailsProvider.toDateController.text
                  .toUniversalYyyyMmDd(),
              cusId: widget.customerId,
              amount: customerDetailsProvider.amcAmountController.text,
              context: context,
              description:
                  customerDetailsProvider.amcDescriptionController.text,
              fromDate: customerDetailsProvider.fromDateController.text
                  .toUniversalYyyyMmDd(),
              productName:
                  customerDetailsProvider.amcProductNameController.text,
              serviceName: customerDetailsProvider.amcServiceController.text,
            );
            Navigator.pop(context);
            Navigator.pop(context);
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
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                      controller: customerDetailsProvider.fromDateController,
                      readOnly: true,
                      onTap: () async {
                        await _selectDate(
                            context, true, customerDetailsProvider);
                        String installationDate =
                            (customerDetailsProvider.fromDateController.text)
                                .toyyyymmdd();

                        customerDetailsProvider.calculateMaintenanceDates(
                          monthInterval: customerDetailsProvider.monthInterval,
                          context: context,
                          installationDate: installationDate,
                          totalDuration: customerDetailsProvider.yearInterval,
                        );
                      },
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Installation Date *'.replaceAll('*', ''),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CommonDropdown<int>(
                        hintText: 'Periodic Interval',
                        items: dropDownProvider.amcInterval
                            .map((status) => DropdownItem<int>(
                                  id: status.intervalsId,
                                  name: status.intervalsName,
                                  no: status.intervalsNo,
                                ))
                            .toList(),
                        controller:
                            customerDetailsProvider.amcPeriodIntervalController,
                        onItemSelected: (selectedId) {
                          dropDownProvider
                              .setSelectedAmcPeriodicIntervalId(selectedId);

                          final selectedItem =
                              dropDownProvider.amcInterval.firstWhere(
                            (status) => status.intervalsId == selectedId,
                          );

                          customerDetailsProvider.amcPeriodIntervalController
                              .text = selectedItem.intervalsName;

                          String installationDate =
                              (customerDetailsProvider.fromDateController.text)
                                  .toyyyymmdd();

                          customerDetailsProvider.monthInterval =
                              selectedItem.intervalsNo;

                          customerDetailsProvider.calculateMaintenanceDates(
                            monthInterval:
                                customerDetailsProvider.monthInterval,
                            context: context,
                            installationDate: installationDate,
                            totalDuration: customerDetailsProvider.yearInterval,
                          );
                        },
                        selectedValue: dropDownProvider.amcPeriodIntervalId),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'Select Total Duration',
                      items: dropDownProvider.amcDuration
                          .map((status) => DropdownItem<int>(
                                id: status.durationId,
                                name: status.durationName,
                                no: status.durationNo,
                              ))
                          .toList(),
                      controller:
                          customerDetailsProvider.amcTotalDurationController,
                      onItemSelected: (selectedId) {
                        dropDownProvider
                            .setSelectedAmcTotalDurationId(selectedId);

                        final selectedItem =
                            dropDownProvider.amcDuration.firstWhere(
                          (status) => status.durationId == selectedId,
                        );

                        customerDetailsProvider.amcTotalDurationController
                            .text = selectedItem.durationName;

                        String installationDate =
                            (customerDetailsProvider.fromDateController.text)
                                .toyyyymmdd();

                        customerDetailsProvider.yearInterval =
                            selectedItem.durationNo;

                        customerDetailsProvider.calculateMaintenanceDates(
                          monthInterval: customerDetailsProvider.monthInterval,
                          context: context,
                          installationDate: installationDate,
                          totalDuration: customerDetailsProvider.yearInterval,
                        );
                      },
                      selectedValue: dropDownProvider.amcTotalDurationlId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                      controller: customerDetailsProvider.toDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Expiry Date *',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
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
              if (customerDetailsProvider.maintenanceDates.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      'Service Periods:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            customerDetailsProvider.maintenanceDates.length,
                        itemBuilder: (context, index) {
                          final maintenanceDate =
                              customerDetailsProvider.maintenanceDates[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Service Period: ${index + 1}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const Spacer(),
                                    Checkbox(
                                      value: maintenanceDate.completed == 1,
                                      activeColor: AppColors.primaryBlue,
                                      onChanged: (value) {
                                        customerDetailsProvider
                                            .updateMaintenanceDate(index,
                                                completed: value! ? 1 : 0);
                                      },
                                    ),
                                    Text(
                                      'Completed',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textGrey3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: InkWell(
                                        onTap: () async {
                                          final DateTime now = DateTime.now();
                                          final DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.tryParse(
                                                    maintenanceDate.date) ??
                                                now,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            customerDetailsProvider
                                                .updateMaintenanceDate(index,
                                                    date:
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(picked));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.textGrey2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_month,
                                                  size: 18, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                maintenanceDate.date
                                                    .toDayMonthYearFormat(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  color: AppColors.textBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.textGrey2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            hint: Text(
                                              'Select Staff',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                color: AppColors.textGrey3,
                                              ),
                                            ),
                                            value: maintenanceDate.staffId,
                                            items: dropDownProvider
                                                .searchUserDetails
                                                .map((staff) {
                                              return DropdownMenuItem<int>(
                                                value: staff.userDetailsId,
                                                child: Text(
                                                  staff.userDetailsName,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              final staff = dropDownProvider
                                                  .searchUserDetails
                                                  .firstWhere((element) =>
                                                      element.userDetailsId ==
                                                      value);
                                              customerDetailsProvider
                                                  .updateMaintenanceDate(index,
                                                      staffId: value,
                                                      staffName: staff
                                                          .userDetailsName);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
