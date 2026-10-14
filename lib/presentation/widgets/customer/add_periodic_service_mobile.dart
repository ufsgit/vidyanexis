import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/maintenance_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/customer_details_provider.dart';

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
      } else {
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
                  borderRadius: BorderRadius.circular(4),
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

  @override
  void initState() {
    super.initState();
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
      dropDownProvider.getCategoryPeriodicService(context);
      dropDownProvider.getAMCStatus(context);
      customerDetailsProvider.getPeriodicServiceFieldsApi();
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
            widget.amc!.totalDurationName.isNotEmpty
                ? widget.amc!.totalDurationName
                : _getDurationName(widget.amc!.totalDurationId);

        customerDetailsProvider.amcPeriodIntervalController.text =
            widget.amc!.periodIntervalName.isNotEmpty
                ? widget.amc!.periodIntervalName
                : _getIntervalName(widget.amc!.periodIntervalId);

        customerDetailsProvider.maintenanceDates = widget.amc!.maintenanceDate;
      }
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
          if (customerDetailsProvider.amcServiceController.text.isNotEmpty &&
              customerDetailsProvider
                  .amcProductNameController.text.isNotEmpty &&
              customerDetailsProvider.fromDateController.text.isNotEmpty &&
              customerDetailsProvider.toDateController.text.isNotEmpty) {
            await customerDetailsProvider.saveAmc(
              amcId: widget.amcId,
              toDate: customerDetailsProvider.toDateController.text
                  .toUniversalYyyyMmDd(),
              cusId: widget.customerId,
              amount: (double.tryParse(
                          customerDetailsProvider.amcAmountController.text) ??
                      0)
                  .toString(),
              context: context,
              description:
                  customerDetailsProvider.amcDescriptionController.text,
              fromDate: customerDetailsProvider.fromDateController.text
                  .toUniversalYyyyMmDd(),
              productName:
                  customerDetailsProvider.amcProductNameController.text,
              serviceName: customerDetailsProvider.amcServiceController.text,
            );
            // Navigator.pop(context);
            // Navigator.pop(context);
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
                    borderRadius: BorderRadius.circular(4),
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
              // Field 1: Status (edit only)
              if (widget.isEdit &&
                  customerDetailsProvider.isPeriodicServiceFieldVisible(1))
                DropdownButtonFormField<int>(
                  initialValue: customerDetailsProvider.selectedAMCStatus ?? 1,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: customerDetailsProvider
                            .getPeriodicServiceFieldName(1, 'Choose Status'),
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
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    floatingLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey1,
                    ),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 12),
                  ),
                  isDense: true,
                  iconSize: 18,
                ),
              if (widget.isEdit &&
                  customerDetailsProvider.isPeriodicServiceFieldVisible(1))
                const SizedBox(height: 16.0),

              // Field 2: Product / Technician Name
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(2)) ...[
                CustomTextfieldWidgetMobile(
                  focusNode: FocusNode(),
                  readOnly: false,
                  controller: customerDetailsProvider.amcProductNameController,
                  labelText: customerDetailsProvider
                      .getPeriodicServiceFieldName(2, 'Technician Name *'),
                ),
                const SizedBox(height: 16.0),
              ],

              // Field 3: Service
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(3)) ...[
                CustomTextfieldWidgetMobile(
                  focusNode: FocusNode(),
                  readOnly: false,
                  controller: customerDetailsProvider.amcServiceController,
                  labelText: customerDetailsProvider
                      .getPeriodicServiceFieldName(3, 'Service *'),
                ),
                const SizedBox(height: 16.0),
              ],

              // Field 10: Amount
              if (customerDetailsProvider
                  .isPeriodicServiceFieldVisible(10)) ...[
                CustomTextfieldWidgetMobile(
                  focusNode: FocusNode(),
                  readOnly: false,
                  controller: customerDetailsProvider.amcAmountController,
                  labelText: customerDetailsProvider
                      .getPeriodicServiceFieldName(10, 'Amount *'),
                  keyBoardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],

              // Field 4: Category
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(4)) ...[
                Builder(builder: (context) {
                  return CommonDropdown<int>(
                    hintText: customerDetailsProvider
                        .getPeriodicServiceFieldName(4, 'Category'),
                    items: dropDownProvider.categoryPeriodicService
                        .map((status) => DropdownItem<int>(
                              id: status.categoryId,
                              name: status.categoryName,
                              no: status.deleteStatus,
                            ))
                        .toList(),
                    controller: customerDetailsProvider.amcCategoryController,
                    onItemSelected: (selectedId) {
                      final selectedItem = dropDownProvider
                          .categoryPeriodicService
                          .firstWhere(
                        (item) => item.categoryId == selectedId,
                      );
                      customerDetailsProvider.updateAMCCategory(
                          selectedId, selectedItem.categoryName);
                    },
                    selectedValue: customerDetailsProvider.selectedAMCCategory,
                  );
                }),
                const SizedBox(height: 16.0),
              ],

              // Field 5: Service Date
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(5)) ...[
                TextField(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                  controller: customerDetailsProvider.fromDateController,
                  readOnly: true,
                  onTap: () async {
                    await _selectDate(context, true, customerDetailsProvider);
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
                        text: customerDetailsProvider
                            .getPeriodicServiceFieldName(5, 'Service Date')
                            .replaceAll('*', ''),
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
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
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
                const SizedBox(height: 10),
              ],

              // Field 6 + 7: Periodic Interval + Total Duration
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(6) ||
                  customerDetailsProvider
                      .isPeriodicServiceFieldVisible(7)) ...[
                Row(
                  children: [
                    if (customerDetailsProvider
                        .isPeriodicServiceFieldVisible(6))
                      Expanded(
                        child: Builder(builder: (context) {
                          var items = dropDownProvider.amcInterval
                              .map((status) => DropdownItem<int>(
                                    id: status.intervalsId,
                                    name: status.intervalsName,
                                    no: status.intervalsNo,
                                  ))
                              .toList();

                          if (widget.isEdit &&
                              widget.amc != null &&
                              !items.any((e) =>
                                  e.id == widget.amc!.periodIntervalId)) {
                            items.add(DropdownItem(
                              id: widget.amc!.periodIntervalId,
                              name: _getIntervalName(
                                  widget.amc!.periodIntervalId),
                              no: widget.amc!.periodIntervalNo,
                            ));
                          }

                          return CommonDropdown<int>(
                              hintText: customerDetailsProvider
                                  .getPeriodicServiceFieldName(
                                      6, 'Periodic Interval'),
                              items: items,
                              controller: customerDetailsProvider
                                  .amcPeriodIntervalController,
                              onItemSelected: (selectedId) {
                                dropDownProvider
                                    .setSelectedAmcPeriodicIntervalId(
                                        selectedId);

                                final selectedItem = items.firstWhere(
                                  (status) => status.id == selectedId,
                                );

                                customerDetailsProvider
                                    .amcPeriodIntervalController
                                    .text = selectedItem.name;

                                String installationDate =
                                    (customerDetailsProvider
                                            .fromDateController.text)
                                        .toyyyymmdd();

                                customerDetailsProvider.monthInterval =
                                    selectedItem.no!;

                                customerDetailsProvider
                                    .calculateMaintenanceDates(
                                  monthInterval:
                                      customerDetailsProvider.monthInterval,
                                  context: context,
                                  installationDate: installationDate,
                                  totalDuration:
                                      customerDetailsProvider.yearInterval,
                                );
                              },
                              selectedValue:
                                  dropDownProvider.amcPeriodIntervalId);
                        }),
                      ),
                    if (customerDetailsProvider
                            .isPeriodicServiceFieldVisible(6) &&
                        customerDetailsProvider
                            .isPeriodicServiceFieldVisible(7))
                      const SizedBox(width: 10),
                    if (customerDetailsProvider
                        .isPeriodicServiceFieldVisible(7))
                      Expanded(
                        child: Builder(builder: (context) {
                          var items = dropDownProvider.amcDuration
                              .map((status) => DropdownItem<int>(
                                    id: status.durationId,
                                    name: status.durationName,
                                    no: status.durationNo,
                                  ))
                              .toList();

                          if (widget.isEdit &&
                              widget.amc != null &&
                              !items.any(
                                  (e) => e.id == widget.amc!.totalDurationId)) {
                            items.add(DropdownItem(
                              id: widget.amc!.totalDurationId,
                              name: _getDurationName(
                                  widget.amc!.totalDurationId),
                              no: widget.amc!.totalDurationNo,
                            ));
                          }

                          return CommonDropdown<int>(
                            hintText: customerDetailsProvider
                                .getPeriodicServiceFieldName(
                                    7, 'Select Total Duration'),
                            items: items,
                            controller: customerDetailsProvider
                                .amcTotalDurationController,
                            onItemSelected: (selectedId) {
                              dropDownProvider
                                  .setSelectedAmcTotalDurationId(selectedId);

                              final selectedItem = items.firstWhere(
                                (status) => status.id == selectedId,
                              );

                              customerDetailsProvider
                                  .amcTotalDurationController
                                  .text = selectedItem.name;

                              String installationDate =
                                  (customerDetailsProvider
                                          .fromDateController.text)
                                      .toyyyymmdd();

                              customerDetailsProvider.yearInterval =
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
                            selectedValue:
                                dropDownProvider.amcTotalDurationlId,
                          );
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // Field 8: Expiry Date
              if (customerDetailsProvider.isPeriodicServiceFieldVisible(8)) ...[
                TextField(
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
                        text: customerDetailsProvider
                            .getPeriodicServiceFieldName(8, 'Expiry Date *'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
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
                const SizedBox(height: 16.0),
              ],

              // Description (always shown)
              CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                readOnly: false,
                controller: customerDetailsProvider.amcDescriptionController,
                labelText: 'Description',
                keyBoardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
              ),

              // Field 9: Service Periods
              if (customerDetailsProvider.maintenanceDates.isNotEmpty &&
                  customerDetailsProvider.isPeriodicServiceFieldVisible(9))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      customerDetailsProvider.getPeriodicServiceFieldName(
                          9, 'Service Periods:'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (customerDetailsProvider.maintenanceDates.length > 1)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: customerDetailsProvider
                                  .maintenanceDates.length -
                              1,
                          itemBuilder: (context, index) {
                            final dateString = customerDetailsProvider
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
                                  Icon(Icons.event,
                                      color: AppColors.primaryBlue, size: 18),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      dateString.date
                                          .toString()
                                          .toDayMonthYearFormat(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryBlue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Completed',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Checkbox(
                                    value: (dateString.completed == 1),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        customerDetailsProvider
                                                .maintenanceDates[index + 1] =
                                            MaintenanceDate(
                                          date: dateString.date,
                                          completed: (value ?? false) ? 1 : 0,
                                        );
                                      });
                                    },
                                    activeColor: AppColors.primaryBlue,
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
            ],
          ),
        ),
      ),
    );
  }
}