import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class BulkImportScreen extends StatefulWidget {
  static String route = '/bulkImport';
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  List data = [];
  bool _isPickingFile = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      dropDownProvider.searchUserDetails.clear();
      dropDownProvider.followUpData.clear();
      dropDownProvider.enquiryForList.clear();
      dropDownProvider.enquiryData.clear();

      // Only fetch if data is empty to prevent infinite loops if the widget is recreated
      if (dropDownProvider.searchUserDetails.isEmpty) {
        dropDownProvider.getUserDetails(context);
      }
      if (dropDownProvider.followUpData.isEmpty) {
        dropDownProvider.getFollowUpStatus(context, '1');
      }
      if (dropDownProvider.enquiryForList.isEmpty) {
        dropDownProvider.getEnquiryFor(context);
      }
      if (dropDownProvider.enquiryData.isEmpty) {
        dropDownProvider.getEnquirySource(context);
      }

      dropDownProvider.setSelectedStatusId(0);
      dropDownProvider.setSelectedUserId(0);
      dropDownProvider.setSelectedEnquirySourceId(0);
      dropDownProvider.updateEnquiryForName(0, '');
      dropDownProvider.updateDistrict(0, '');

      leadProvider.nextFollowUpDateController.text = '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final leadProvider = Provider.of<LeadsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(builder: (contextx, constraints) {
      return SizedBox(
        width: constraints.maxWidth < minContentWidth
            ? minContentWidth
            : constraints.maxWidth,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  if (settingsProvider.menuIsSaveMap[20].toString() == '1')
                    CustomElevatedButton(
                      buttonText:
                          _isPickingFile ? 'Picking...' : 'Upload Excel',
                      onPressed: _isPickingFile
                          ? null
                          : () async {
                              setState(() => _isPickingFile = true);
                              try {
                                var d = await pickAndLoadExcelFile();
                                if (mounted) {
                                  setState(() {
                                    data.clear();
                                    data = d;
                                  });
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isPickingFile = false);
                                }
                              }
                            },
                      radius: 4,
                      backgroundColor: AppColors.whiteColor,
                      borderColor: const Color(0xFFE2E8F0),
                      textColor: const Color(0xFF64748B),
                    ),
                  //save
                  const SizedBox(
                    width: 10,
                  ),
                  if (data.isNotEmpty)
                    CustomElevatedButton(
                      radius: 4,
                      backgroundColor: AppColors.secondaryBlue,
                      borderColor: AppColors.secondaryBlue,
                      textColor: AppColors.whiteColor,
                      onPressed: leadProvider.isImporting
                          ? null
                          : () async {
                              final selectedStatus =
                                  dropDownProvider.followUpData.firstWhere(
                                (status) =>
                                    status.statusId ==
                                    dropDownProvider.selectedStatusId,
                                orElse: () => SearchLeadStatusModel(
                                  followup: 0,
                                  statusId: 0,
                                  statusName: '',
                                  statusOrder: 0,
                                ),
                              );

                              final selectedUser =
                                  dropDownProvider.searchUserDetails.firstWhere(
                                (user) =>
                                    user.userDetailsId ==
                                    dropDownProvider.selectedUserId,
                                orElse: () => SearchUserDetails(
                                  userDetailsId: 0,
                                  userDetailsName: '',
                                ),
                              );
                              final selectedEnquirySource =
                                  dropDownProvider.enquiryData.firstWhere(
                                (source) =>
                                    source.enquirySourceId ==
                                    dropDownProvider.selectedEnquirySourceId,
                                orElse: () => Enquirysourcemodel(
                                  sourceCategoryId: 0,
                                  sourceCategoryName: '',
                                  enquirySourceId: 0,
                                  enquirySourceName: '',
                                  deleteStatus: 0,
                                ),
                              );

                              if (!_validateFollowUpForm(
                                  leadProvider,
                                  dropDownProvider,
                                  selectedStatus.statusName,
                                  selectedUser.userDetailsName)) {
                                return;
                              }

                              await leadProvider.saveBulkImport(
                                data: data,
                                context: context,
                                statusId:
                                    dropDownProvider.selectedStatusId ?? 0,
                                statusName: selectedStatus.statusName!,
                                toUserId: dropDownProvider.selectedUserId ?? 0,
                                toUserName: selectedUser.userDetailsName ?? '',
                                followUpDate: leadProvider
                                    .nextFollowUpDateController.text,
                                custId: int.parse(
                                    leadProvider.customerId.toString()),
                                followUp: leadProvider
                                        .nextFollowUpDateController
                                        .text
                                        .isNotEmpty
                                    ? 1
                                    : 0,
                                message: leadProvider.messageController.text,
                                enquiryForId:
                                    dropDownProvider.selectedEnquiryForId ?? 0,
                                enquiryForName:
                                    dropDownProvider.selectedEnquiryForName,
                                enquirySourceId:
                                    dropDownProvider.selectedEnquirySourceId ??
                                        0,
                                enquirySourceName:
                                    selectedEnquirySource.enquirySourceName,
                              );

                              if (leadProvider.importProgress == 1.0) {
                                setState(() {
                                  data.clear();
                                });
                              }
                            },
                      buttonText:
                          leadProvider.isImporting ? 'Saving...' : 'Save',
                    )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              //download
              if (data.isEmpty)
                Column(
                  children: [
                    Image.asset('assets/images/excel_image.png'),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomElevatedButton(
                      buttonText: 'Download Excel Format',
                      onPressed: () async {
                        // Request permission to access storage
                        leadProvider.downloadExcelFile();
                      },
                      radius: 4,
                      backgroundColor: AppColors.secondaryBlue,
                      borderColor: AppColors.secondaryBlue,
                      textColor: AppColors.whiteColor,
                    ),
                  ],
                ),
              if (leadProvider.isImporting)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        leadProvider.importStatusText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: leadProvider.importProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondaryBlue),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${(leadProvider.importProgress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              data.isEmpty && !leadProvider.isImporting
                  ? Center(
                      child: Text(
                        'Please Choose File',
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade400),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonDropdown<int>(
                                    hintText: 'Follow-up Status*',
                                    items: dropDownProvider.followUpData
                                        .map((status) => DropdownItem<int>(
                                              id: status.statusId ?? 0,
                                              name: status.statusName ?? '',
                                            ))
                                        .toList(),
                                    controller: leadProvider.statusController,
                                    onItemSelected: (selectedId) {
                                      dropDownProvider
                                          .setSelectedStatusId(selectedId);

                                      final selectedItem = dropDownProvider
                                          .followUpData
                                          .firstWhere(
                                        (status) =>
                                            status.statusId == selectedId,
                                        orElse: () => SearchLeadStatusModel(
                                            statusId: selectedId, statusName: ''),
                                      );
                                      leadProvider.statusController.text =
                                          selectedItem.statusName ?? '';
                                      if (selectedItem.isShowFollowupDate == 1) {
                                        int durationVal = int.tryParse(selectedItem.statusDuration ?? '') ?? 0;
                                        DateTime targetDate = DateTime.now().add(Duration(days: durationVal));
                                        leadProvider.nextFollowUpDateController.text =
                                            DateFormat('dd MMM yyyy').format(targetDate);
                                      } else {
                                        leadProvider.nextFollowUpDateController.clear();
                                      }
                                    },
                                    selectedValue:
                                        dropDownProvider.selectedStatusId),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: CommonDropdown<int>(
                                    hintText: 'Assigned Staff*',
                                    items: dropDownProvider.searchUserDetails
                                        .where((staff) =>
                                            staff.workingStatus == "1")
                                        .map((status) => DropdownItem<int>(
                                              id: status.userDetailsId,
                                              name:
                                                  status.userDetailsName ?? '',
                                            ))
                                        .toList(),
                                    controller:
                                        leadProvider.assignToFollowUpController,
                                    onItemSelected: (selectedId) {
                                      dropDownProvider
                                          .setSelectedUserId(selectedId);

                                      final selectedItem = dropDownProvider
                                          .searchUserDetails
                                          .firstWhere(
                                        (user) =>
                                            user.userDetailsId == selectedId,
                                      );
                                      leadProvider
                                              .assignToFollowUpController.text =
                                          selectedItem.userDetailsName ?? '';
                                    },
                                    selectedValue:
                                        dropDownProvider.selectedUserId),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: dropDownProvider
                                                  .selectedEnquiryForId !=
                                              null &&
                                          dropDownProvider.enquiryForList.any(
                                              (item) =>
                                                  item.enquiryForId ==
                                                  dropDownProvider
                                                      .selectedEnquiryForId)
                                      ? dropDownProvider.selectedEnquiryForId
                                      : null,
                                  items: dropDownProvider.enquiryForList
                                      .map((status) => DropdownMenuItem<int>(
                                            value: status.enquiryForId,
                                            child: Text(
                                              status.enquiryForName,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      final selectedEnquiryFor =
                                          dropDownProvider.enquiryForList
                                              .firstWhere(
                                                  (task) =>
                                                      task.enquiryForId ==
                                                      newValue);
                                      dropDownProvider.updateEnquiryForName(
                                          newValue,
                                          selectedEnquiryFor.enquiryForName);
                                    }
                                  },
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, // Custom font size
                                    fontWeight:
                                        FontWeight.w600, // Custom font weight
                                    color: AppColors
                                        .textBlack, // Custom color for selected item
                                  ),
                                  decoration: InputDecoration(
                                    label: RichText(
                                      text: TextSpan(
                                        text: 'Enquiry For',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey3,
                                        ),
                                        children: const <TextSpan>[
                                          TextSpan(
                                            text: ' *', // The asterisk part
                                            style: TextStyle(
                                                color: Colors
                                                    .red), // Red color for asterisk
                                          ),
                                        ],
                                      ),
                                    ),
                                    floatingLabelBehavior: FloatingLabelBehavior
                                        .auto, // Always show the label
                                    floatingLabelStyle:
                                        GoogleFonts.plusJakartaSans(
                                      fontSize:
                                          16, // Slightly smaller size for floating label
                                      fontWeight: FontWeight.w500,
                                      color: AppColors
                                          .textGrey1, // Color for floating label
                                    ),
                                    labelStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4), // Rounded corners
                                      borderSide: BorderSide(
                                        color:
                                            AppColors.textGrey2, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4), // Rounded corners
                                      borderSide: BorderSide(
                                        color:
                                            AppColors.textGrey2, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4), // Rounded corners
                                      borderSide: BorderSide(
                                        color:
                                            AppColors.textGrey2, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 12),
                                  ),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CommonDropdown<int>(
                                  hintText: 'Enquiry Source*',
                                  items: dropDownProvider.enquiryData
                                      .map((source) => DropdownItem<int>(
                                            id: source.enquirySourceId,
                                            name:
                                                source.enquirySourceName ?? '',
                                          ))
                                      .toList(),
                                  controller:
                                      leadProvider.enquirySourceController,
                                  onItemSelected: (selectedId) {
                                    // Set the selected enquiry source ID in the provider
                                    dropDownProvider
                                        .setSelectedEnquirySourceId(selectedId);

                                    // Update the controller text with the selected item's name
                                    final selectedItem =
                                        dropDownProvider.enquiryData.firstWhere(
                                      (source) =>
                                          source.enquirySourceId == selectedId,
                                    );
                                    leadProvider.enquirySourceController.text =
                                        selectedItem.enquirySourceName ?? '';
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (dropDownProvider.isFollowupRequiredNew())
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 8),
                            child: CustomTextField(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  leadProvider.nextFollowUpDateController.text =
                                      DateFormat('dd MMM yyyy').format(picked);
                                }
                              },
                              readOnly: true,
                              height: 54,
                              controller:
                                  leadProvider.nextFollowUpDateController,
                              hintText: 'Next Follow-up Date*',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    leadProvider
                                            .nextFollowUpDateController.text =
                                        DateFormat('dd MMM yyyy')
                                            .format(picked);
                                  }
                                },
                              ),
                              labelText: '',
                            ),
                          ),
                        if (data.length > 50)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 8.0),
                            child: Text(
                              'Showing first 50 of ${data.length} records. Total ${data.length} records will be imported.',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.secondaryBlue,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ListView.builder(
                            padding: const EdgeInsets.all(18),
                            itemCount: data.length > 50 ? 50 : data.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (c, i) {
                              return Card(
                                  color: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Expanded(
                                                  child: Text('Name')),
                                              const Text(':'),
                                              Expanded(
                                                  child: Text(data[i]['Name']
                                                      .toString()))
                                            ]),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Expanded(
                                                  child: Text('Mobile')),
                                              const Text(':'),
                                              Expanded(
                                                  child: Text(data[i]['Mobile']
                                                      .toString()))
                                            ]),
                                      ],
                                    ),
                                  ));
                            }),
                      ],
                    ),
            ],
          ),
        ),
      );
    });
  }

  bool _validateFollowUpForm(
      LeadsProvider leadProvider,
      DropDownProvider dropDownProvider,
      String? statusName,
      String? userDetailsName) {
    String? errorMessage;

    if (leadProvider.statusController.text.isEmpty ||
        statusName == null ||
        statusName.isEmpty) {
      errorMessage = 'Follow Up Status Required';
    }
    // else if (leadProvider.emailIdController.text.isNotEmpty &&
    //     !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
    //         .hasMatch(leadProvider.emailIdController.text)) {
    //   errorMessage = 'Please enter a valid email address';
    // }

    // else if (leadProvider.pincodeController.text.isNotEmpty &&
    //     leadProvider.pincodeController.text.length != 6) {
    //   errorMessage = 'Pincode must be 6 digits';
    // }
    else if (leadProvider.assignToFollowUpController.text.isEmpty ||
        userDetailsName == null ||
        userDetailsName.isEmpty) {
      errorMessage = 'Please Assign Staff';
    } else if (dropDownProvider.isFollowupRequiredNew() &&
        leadProvider.nextFollowUpDateController.text.isEmpty) {
      errorMessage = 'Please select followup Date';
    } else if (dropDownProvider.selectedEnquiryForId == null ||
        dropDownProvider.selectedEnquiryForName.isEmpty) {
      errorMessage = 'Please select Enquiry For';
    } else if (leadProvider.enquirySourceController.text.isEmpty) {
      errorMessage = 'Please select Enquiry Source';
    }
    if (errorMessage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.secondaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              errorMessage!,
              style: const TextStyle(
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
                    color: AppColors.secondaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return false;
    }

    return true;
  }
}
