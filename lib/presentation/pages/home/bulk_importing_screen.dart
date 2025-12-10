import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getFollowUpStatus(context, '1');
      dropDownProvider.getEnquiryFor(context);
      dropDownProvider.getEnquirySource(context);
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
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                if (settingsProvider.menuIsSaveMap[20].toString() == '1')
                  CustomElevatedButton(
                    buttonText: 'Upload Excel',
                    onPressed: () async {
                      var d = await pickAndLoadExcelFile();

                      setState(() {
                        data.clear();
                        data = d;
                      });
                    },
                    backgroundColor: AppColors.whiteColor,
                    borderColor: AppColors.appViolet,
                    textColor: AppColors.appViolet,
                  ),
                //save
                const SizedBox(
                  width: 10,
                ),
                if (data.isNotEmpty)
                  CustomElevatedButton(
                    backgroundColor: AppColors.appViolet,
                    borderColor: AppColors.appViolet,
                    textColor: AppColors.whiteColor,
                    onPressed: () async {
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
                      // Validation check: ensure every item has 'Name' and 'Mobile'
                      // bool isValid = data.every((item) =>
                      //     item.containsKey('Name') &&
                      //     item['Name'] != null &&
                      //     item['Name'].toString().trim().isNotEmpty &&
                      //     item.containsKey('Mobile') &&
                      //     item['Mobile'] != null &&
                      //     item['Mobile'].toString().trim().isNotEmpty);

                      // if (isValid) {
                      //   // Save the data if valid
                      await leadProvider.saveBulkImport(
                        data: data,
                        context: context,
                        statusId: dropDownProvider.selectedStatusId ?? 0,
                        statusName: selectedStatus.statusName!,
                        toUserId: dropDownProvider.selectedUserId ?? 0,
                        toUserName: selectedUser.userDetailsName ?? '',
                        followUpDate:
                            leadProvider.nextFollowUpDateController.text,
                        custId: int.parse(leadProvider.customerId.toString()),
                        followUp: leadProvider
                                .nextFollowUpDateController.text.isNotEmpty
                            ? 1
                            : 0,
                        message: leadProvider.messageController.text,
                        enquiryForId:
                            dropDownProvider.selectedEnquiryForId ?? 0,
                        enquiryForName: dropDownProvider.selectedEnquiryForName,
                        enquirySourceId:
                            dropDownProvider.selectedEnquirySourceId ?? 0,
                        enquirySourceName:
                            selectedEnquirySource.enquirySourceName,
                      );
                      // } else {
                      //   // Show error if validation fails
                      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //     content: Text('Each entry must have a Name and Mobile'),
                      //     backgroundColor: Colors.red,
                      //   ));
                      // }
                    },
                    buttonText: 'Save',
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
                    backgroundColor: AppColors.appViolet,
                    borderColor: AppColors.whiteColor,
                    textColor: AppColors.whiteColor,
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            data.isEmpty
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
                                      (status) => status.statusId == selectedId,
                                    );
                                    leadProvider.statusController.text =
                                        selectedItem.statusName ?? '';
                                    if (!dropDownProvider
                                        .isFollowupRequiredNew()) {
                                      leadProvider.nextFollowUpDateController
                                          .clear();
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
                                      .where(
                                          (staff) => staff.workingStatus == "1")
                                      .map((status) => DropdownItem<int>(
                                            id: status.userDetailsId!,
                                            name: status.userDetailsName ?? '',
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
                                value: dropDownProvider.selectedEnquiryForId !=
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
                                    final selectedEnquiryFor = dropDownProvider
                                        .enquiryForList
                                        .firstWhere((task) =>
                                            task.enquiryForId == newValue);
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
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
                                    borderSide: BorderSide(
                                      color:
                                          AppColors.textGrey2, // Border color
                                      width: 1, // Border width
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
                                    borderSide: BorderSide(
                                      color:
                                          AppColors.textGrey2, // Border color
                                      width: 1, // Border width
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
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
                                          name: source.enquirySourceName ?? '',
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
                            controller: leadProvider.nextFollowUpDateController,
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
                                  leadProvider.nextFollowUpDateController.text =
                                      DateFormat('dd MMM yyyy').format(picked);
                                }
                              },
                            ),
                            labelText: '',
                          ),
                        ),
                      ListView.builder(
                          padding: const EdgeInsets.all(18),
                          itemCount: data.length,
                          shrinkWrap: true,
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
                                            const Expanded(child: Text('Name')),
                                            const Text(':'),
                                            Expanded(
                                                child: Text(
                                                    data[i]['Name'].toString()))
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
                color: AppColors.appViolet,
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
      return false;
    }

    return true;
  }
}
