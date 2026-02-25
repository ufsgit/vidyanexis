import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/utils/extensions.dart';

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
  final AmcReportModeld? amc;
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
      required this.amcId,
      this.amc});

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
      firstDate: DateTime(2000),
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

        // Set text controllers with fallback if names are empty
        customerDetailsProvider.amcTotalDurationController.text =
            widget.amc!.totalDurationName.isNotEmpty
                ? widget.amc!.totalDurationName
                : _getDurationName(widget.amc!.totalDurationId);

        customerDetailsProvider.amcPeriodIntervalController.text =
            widget.amc!.periodIntervalName.isNotEmpty
                ? widget.amc!.periodIntervalName
                : _getIntervalName(widget.amc!.periodIntervalId);

        customerDetailsProvider.maintenanceDates = widget.amc!.maintenanceDate;
      }
      super.initState();
    });
  }

  String _getIntervalName(int id) {
    switch (id) {
      case 1:
        return 'Monthly';
      case 2:
        return 'Quarterly';
      case 3:
        return 'Half Yearly';
      case 4:
        return 'Yearly';
      default:
        return '';
    }
  }

  String _getDurationName(int id) {
    return '$id Year${id > 1 ? 's' : ''}';
  }

  // final List<DropdownItem<int>> durationItems = [
  //   for (int i = 1; i <= 12; i++) DropdownItem<int>(id: i, name: '$i Months')
  // ];

  // final List<DropdownItem<int>> yearDurationItems = [
  //   DropdownItem(id: 1, name: '1 Year'),
  //   DropdownItem(id: 2, name: '2 Years'),
  //   DropdownItem(id: 3, name: '3 Years'),
  //   DropdownItem(id: 4, name: '4 Years'),
  //   DropdownItem(id: 5, name: '5 Years'),
  // ];

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
            '${widget.isEdit ? 'Edit' : 'Add'} Periodic Service ',
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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller:
                          customerDetailsProvider.amcProductNameController,
                      hintText: 'Product Name *',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider.amcServiceController,
                      hintText: 'Service *',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider.amcAmountController,
                      hintText: 'Amount *',
                      labelText: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                    ),
                  ),
                ],
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
                  //periodic interval
                  Expanded(
                    child: Builder(builder: (context) {
                      var items = dropDownProvider.amcInterval
                          .map((status) => DropdownItem<int>(
                                id: status.intervalsId,
                                name: status.intervalsName,
                                no: status.intervalsNo,
                              ))
                          .toList();

                      // Ensure selected item exists in list
                      if (widget.isEdit &&
                          widget.amc != null &&
                          !items.any(
                              (e) => e.id == widget.amc!.periodIntervalId)) {
                        items.add(DropdownItem(
                          id: widget.amc!.periodIntervalId,
                          name: _getIntervalName(widget.amc!.periodIntervalId),
                          no: widget.amc!.periodIntervalNo,
                        ));
                      }

                      return CommonDropdown<int>(
                          hintText: 'Periodic Interval',
                          items: items,
                          controller: customerDetailsProvider
                              .amcPeriodIntervalController,
                          onItemSelected: (selectedId) {
                            dropDownProvider
                                .setSelectedAmcPeriodicIntervalId(selectedId);

                            final selectedItem = items.firstWhere(
                              (status) => status.id == selectedId,
                            );

                            customerDetailsProvider.amcPeriodIntervalController
                                .text = selectedItem.name;

                            String installationDate = (customerDetailsProvider
                                    .fromDateController.text)
                                .toyyyymmdd();

                            customerDetailsProvider.monthInterval =
                                selectedItem.no!;

                            customerDetailsProvider.calculateMaintenanceDates(
                              monthInterval:
                                  customerDetailsProvider.monthInterval,
                              context: context,
                              installationDate: installationDate,
                              totalDuration:
                                  customerDetailsProvider.yearInterval,
                            );
                          },
                          selectedValue: dropDownProvider.amcPeriodIntervalId);
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Builder(builder: (context) {
                      var items = dropDownProvider.amcDuration
                          .map((status) => DropdownItem<int>(
                                id: status.durationId,
                                name: status.durationName,
                                no: status.durationNo,
                              ))
                          .toList();

                      // Ensure selected item exists in list
                      if (widget.isEdit &&
                          widget.amc != null &&
                          !items.any(
                              (e) => e.id == widget.amc!.totalDurationId)) {
                        items.add(DropdownItem(
                          id: widget.amc!.totalDurationId,
                          name: _getDurationName(widget.amc!.totalDurationId),
                          no: widget.amc!.totalDurationNo,
                        ));
                      }

                      return CommonDropdown<int>(
                        hintText: 'Select Total Duration',
                        items: items,
                        controller:
                            customerDetailsProvider.amcTotalDurationController,
                        onItemSelected: (selectedId) {
                          dropDownProvider
                              .setSelectedAmcTotalDurationId(selectedId);

                          final selectedItem = items.firstWhere(
                            (status) => status.id == selectedId,
                          );

                          customerDetailsProvider.amcTotalDurationController
                              .text = selectedItem.name;

                          String installationDate =
                              (customerDetailsProvider.fromDateController.text)
                                  .toyyyymmdd();

                          customerDetailsProvider.yearInterval =
                              selectedItem.no!;

                          customerDetailsProvider.calculateMaintenanceDates(
                            monthInterval:
                                customerDetailsProvider.monthInterval,
                            context: context,
                            installationDate: installationDate,
                            totalDuration: customerDetailsProvider.yearInterval,
                          );
                        },
                        selectedValue: dropDownProvider.amcTotalDurationlId,
                      );
                    }),
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
                      // onTap: () =>
                      //     _selectDate(context, false, customerDetailsProvider),
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
                    if (customerDetailsProvider.maintenanceDates.length > 2)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // Light background
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              customerDetailsProvider.maintenanceDates.length -
                                  2,
                          itemBuilder: (context, index) {
                            final maintenanceDate = customerDetailsProvider
                                .maintenanceDates[index + 1];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 12.0),
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
                              child: Row(
                                children: [
                                  const Icon(Icons.event,
                                      color: Colors.orange, size: 18),
                                  const SizedBox(width: 8.0),
                                  InkWell(
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
                                            .updateMaintenanceDate(index + 1,
                                                date: DateFormat('yyyy-MM-dd')
                                                    .format(picked));
                                      }
                                    },
                                    child: Text(
                                      maintenanceDate.date
                                          .toDayMonthYearFormat(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Staff selection
                                  Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.textGrey2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Select Staff',
                                          style: GoogleFonts.plusJakartaSans(
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
                                              style:
                                                  GoogleFonts.plusJakartaSans(
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
                                              .updateMaintenanceDate(index + 1,
                                                  staffId: value,
                                                  staffName:
                                                      staff.userDetailsName);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    'Completed',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey1,
                                    ),
                                  ),
                                  Checkbox(
                                    value: (maintenanceDate.completed == 1),
                                    onChanged: (bool? value) {
                                      customerDetailsProvider
                                          .updateMaintenanceDate(index + 1,
                                              completed:
                                                  (value ?? false) ? 1 : 0);
                                    },
                                    activeColor: Colors.orange,
                                  ),
                                  const SizedBox(width: 4.0),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Text(
                        'No Service Period available.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
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
              customerDetailsProvider.saveAmc(
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:vidyanexis/constants/app_colors.dart';
// import 'package:vidyanexis/constants/app_styles.dart';
// import 'package:vidyanexis/controller/customer_details_provider.dart';
// import 'package:vidyanexis/controller/drop_down_provider.dart';
// import 'package:vidyanexis/presentation/pages/dashboard/common_widgets.dart';
// import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
// import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

// class AmcCreationWidget extends StatefulWidget {
//   final bool isEdit;
//   final String customerId;
//   final String? amcProductNameController;
//   final String? amcServiceController;
//   final String? amcDescriptionController;
//   final String? amcAmountController;
//   final String? fromDateController;
//   final String? toDateController;
//   final String amcId;
//   const AmcCreationWidget(
//       {super.key,
//       required this.isEdit,
//       required this.customerId,
//       this.amcAmountController,
//       this.amcDescriptionController,
//       this.amcProductNameController,
//       this.amcServiceController,
//       this.fromDateController,
//       this.toDateController,
//       required this.amcId});

//   @override
//   State<AmcCreationWidget> createState() => _AmcCreationWidgetState();
// }

// class _AmcCreationWidgetState extends State<AmcCreationWidget> {
//   Future<void> _selectDate(BuildContext context, bool isFromDate,
//       CustomerDetailsProvider provider) async {
//     final DateTime now = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: now,
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.appViolet,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textBlack,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
//       if (isFromDate) {
//         provider.fromDateController.text = formattedDate;
//         // Removed automatic to-date selection
//       } else {
//         // Ensure To date is not before From date
//         final fromDate =
//             DateFormat('dd-MM-yyyy').parse(provider.fromDateController.text);
//         if (picked.isAfter(fromDate)) {
//           provider.toDateController.text = formattedDate;
//         } else {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text(
//                   'Invalid Date Selection',
//                   style: TextStyle(
//                     color: AppColors.appViolet,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 content: const Text(
//                   'To date cannot be before From date',
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 16,
//                   ),
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       'OK',
//                       style: TextStyle(
//                         color: AppColors.appViolet,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       }
//     }
//   }

//   @override
//   void initState() {
//     if (widget.isEdit) {
//       final customerDetailsProvider =
//           Provider.of<CustomerDetailsProvider>(context, listen: false);
//       customerDetailsProvider.amcProductNameController.text =
//           widget.amcProductNameController!;
//       customerDetailsProvider.amcServiceController.text =
//           widget.amcServiceController!;
//       customerDetailsProvider.amcDescriptionController.text =
//           widget.amcDescriptionController!;
//       customerDetailsProvider.amcAmountController.text =
//           widget.amcAmountController!;
//       customerDetailsProvider.fromDateController.text =
//           widget.fromDateController!;
//       customerDetailsProvider.toDateController.text = widget.toDateController!;
//       super.initState();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dropDownProvider = Provider.of<DropDownProvider>(context);
//     final customerDetailsProvider =
//         Provider.of<CustomerDetailsProvider>(context);

//     return AlertDialog(
//       backgroundColor: Colors.white,
//       title: Row(
//         children: [
//           Text(
//             '${widget.isEdit ? 'Edit' : 'Add'} Periodic Service',
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textBlack,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () {
//               customerDetailsProvider.clearAmcControllers();
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.close),
//           )
//         ],
//       ),
//       content: Container(
//         color: Colors.white,
//         width: AppStyles.isWebScreen(context)
//             ? MediaQuery.of(context).size.width / 2
//             : MediaQuery.of(context).size.width,
//         height: MediaQuery.sizeOf(context).height / 2,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Basic details',
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textGrey1,
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               if (widget.isEdit)
//                 DropdownButtonFormField<int>(
//                   value: customerDetailsProvider.selectedAMCStatus ?? 1,
//                   items: dropDownProvider.amcStatus
//                       .map((status) => DropdownMenuItem<int>(
//                             value: status.amcStatusId,
//                             child: Text(
//                               status.amcStatusName,
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (int? newValue) {
//                     if (newValue != null) {
//                       final selectedAmcStatus = dropDownProvider.amcStatus
//                           .firstWhere((task) => task.amcStatusId == newValue);
//                       customerDetailsProvider.updateAMCStatus(
//                           newValue, selectedAmcStatus.amcStatusName);
//                     }
//                   },
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 14, // Custom font size
//                     fontWeight: FontWeight.w600, // Custom font weight
//                     color:
//                         AppColors.textBlack, // Custom color for selected item
//                   ),
//                   decoration: InputDecoration(
//                     label: RichText(
//                       text: TextSpan(
//                         text: 'Choose Status',
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textGrey3,
//                         ),
//                         children: const <TextSpan>[
//                           TextSpan(
//                             text: ' *', // The asterisk part
//                             style: TextStyle(
//                                 color: Colors.red), // Red color for asterisk
//                           ),
//                         ],
//                       ),
//                     ),
//                     floatingLabelBehavior:
//                         FloatingLabelBehavior.auto, // Always show the label
//                     floatingLabelStyle: GoogleFonts.plusJakartaSans(
//                       fontSize: 16, // Slightly smaller size for floating label
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.textGrey1, // Color for floating label
//                     ),
//                     labelStyle: GoogleFonts.plusJakartaSans(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.textGrey3,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(10), // Rounded corners
//                       borderSide: BorderSide(
//                         color: AppColors.textGrey2, // Border color
//                         width: 1, // Border width
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(10), // Rounded corners
//                       borderSide: BorderSide(
//                         color: AppColors.textGrey2, // Border color
//                         width: 1, // Border width
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(10), // Rounded corners
//                       borderSide: BorderSide(
//                         color: AppColors.textGrey2, // Border color
//                         width: 1, // Border width
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 18, horizontal: 12),
//                   ),
//                   isDense: true,
//                   iconSize: 18,
//                 ),
//               const SizedBox(height: 16.0),
//               CustomTextField(
//                 readOnly: false,
//                 height: 54,
//                 controller: customerDetailsProvider.amcProductNameController,
//                 hintText: 'Product Name *',
//                 labelText: '',
//               ),
//               const SizedBox(height: 16.0),
//               CustomTextField(
//                 readOnly: false,
//                 height: 54,
//                 controller: customerDetailsProvider.amcServiceController,
//                 hintText: 'Service *',
//                 labelText: '',
//               ),
//               const SizedBox(height: 16.0),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       style: GoogleFonts.plusJakartaSans(
//                         fontSize: 16, // Custom font size for the input text
//                         fontWeight: FontWeight
//                             .w600, // Custom font weight for the input text
//                         color: AppColors.textBlack, // Color for the input text
//                       ),
//                       controller: customerDetailsProvider.fromDateController,
//                       readOnly: true,
//                       onTap: () =>
//                           _selectDate(context, true, customerDetailsProvider),
//                       decoration: InputDecoration(
//                         label: RichText(
//                           text: TextSpan(
//                             text: 'From *'.replaceAll('*', ''),
//                             style: GoogleFonts.plusJakartaSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textGrey3,
//                             ),
//                             children: const <TextSpan>[
//                               TextSpan(
//                                 text: ' *', // The asterisk part
//                                 style: TextStyle(
//                                     color:
//                                         Colors.red), // Red color for asterisk
//                               ),
//                             ],
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         hintText: 'From *',
//                         hintStyle: GoogleFonts.plusJakartaSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textGrey3,
//                         ),
//                         suffixIcon: const Icon(Icons.calendar_month),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextField(
//                       style: GoogleFonts.plusJakartaSans(
//                         fontSize: 16, // Custom font size for the input text
//                         fontWeight: FontWeight
//                             .w600, // Custom font weight for the input text
//                         color: AppColors.textBlack, // Color for the input text
//                       ),
//                       controller: customerDetailsProvider.toDateController,
//                       readOnly: true,
//                       onTap: () =>
//                           _selectDate(context, false, customerDetailsProvider),
//                       decoration: InputDecoration(
//                         label: RichText(
//                           text: TextSpan(
//                             text: 'To *'.replaceAll('*', ''),
//                             style: GoogleFonts.plusJakartaSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textGrey3,
//                             ),
//                             children: const <TextSpan>[
//                               TextSpan(
//                                 text: ' *', // The asterisk part
//                                 style: TextStyle(
//                                     color:
//                                         Colors.red), // Red color for asterisk
//                               ),
//                             ],
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(
//                             color: AppColors.textGrey2,
//                             width: 1,
//                           ),
//                         ),
//                         hintText: 'To *',
//                         hintStyle: GoogleFonts.plusJakartaSans(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textGrey3,
//                         ),
//                         suffixIcon: const Icon(Icons.calendar_month),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16.0),
//               CustomTextField(
//                 readOnly: false,
//                 height: 54,
//                 controller: customerDetailsProvider.amcAmountController,
//                 hintText: 'Amount *',
//                 labelText: '',
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//               const SizedBox(height: 16.0),
//               CustomTextField(
//                 readOnly: false,
//                 height: 54,
//                 controller: customerDetailsProvider.amcDescriptionController,
//                 hintText: 'Description',
//                 labelText: '',
//                 keyboardType: TextInputType.multiline,
//                 minLines: 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         CustomElevatedButton(
//           buttonText: 'Cancel',
//           onPressed: () {
//             customerDetailsProvider.clearAmcControllers();
//             Navigator.pop(context);
//           },
//           backgroundColor: AppColors.whiteColor,
//           borderColor: AppColors.appViolet,
//           textColor: AppColors.appViolet,
//         ),
//         CustomElevatedButton(
//           buttonText: 'Save',
//           onPressed: () async {
//             if (customerDetailsProvider.amcAmountController.text.isNotEmpty &&
//                 customerDetailsProvider.amcServiceController.text.isNotEmpty &&
//                 customerDetailsProvider
//                     .amcProductNameController.text.isNotEmpty &&
//                 customerDetailsProvider.fromDateController.text.isNotEmpty &&
//                 customerDetailsProvider.toDateController.text.isNotEmpty) {
//               await customerDetailsProvider.saveAmc(
//                 amcId: widget.amcId,
//                 toDate: formatDate(
//                     customerDetailsProvider.toDateController.text,
//                     "dd-MM-yyyy",
//                     "yyyy-MM-dd"),
//                 cusId: widget.customerId,
//                 amount: customerDetailsProvider.amcAmountController.text,
//                 context: context,
//                 description:
//                     customerDetailsProvider.amcDescriptionController.text,
//                 fromDate: formatDate(
//                     customerDetailsProvider.fromDateController.text,
//                     "dd-MM-yyyy",
//                     "yyyy-MM-dd"),
//                 productName:
//                     customerDetailsProvider.amcProductNameController.text,
//                 serviceName: customerDetailsProvider.amcServiceController.text,
//               );
//             } else {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text(
//                       'Cannot save',
//                       style: TextStyle(
//                         color: AppColors.appViolet,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     content: const Text(
//                       'Missing Details',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 16,
//                       ),
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text(
//                           'OK',
//                           style: TextStyle(
//                             color: AppColors.appViolet,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             }
//           },
//           backgroundColor: AppColors.appViolet,
//           borderColor: AppColors.appViolet,
//           textColor: AppColors.whiteColor,
//         ),
//       ],
//     );
//   }
// }
