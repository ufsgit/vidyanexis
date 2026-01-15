import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/controller/models/custom_field_enquiry_for_model.dart'
    as enq;
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/dashboard/custom_dropdown.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/enums.dart';

class NewLeadDrawerWidget extends StatefulWidget {
  final bool isEdit;

  const NewLeadDrawerWidget({
    super.key,
    required this.isEdit,
  });

  @override
  State<NewLeadDrawerWidget> createState() => _NewLeadDrawerWidgetState();
}

class _NewLeadDrawerWidgetState extends State<NewLeadDrawerWidget> {
  bool _isFieldValid(String? value) => value != null && value.isNotEmpty;
  late FocusNode _leadNameFocusNode;
  FocusNode _leadAgeFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  bool validatePhone = false;

  void _saveLead() async {
    final fieldValues =
        customFieldLeadStatusKey.currentState?.getFieldValues() ?? [];
    final jsonData =
        customFieldLeadStatusKey.currentState?.getFieldValuesAsJson() ?? [];
    final filledOnly =
        customFieldLeadStatusKey.currentState?.getFilledFieldValues() ?? [];
    final de =
        customFieldEnquirySourceKey.currentState?.getFieldValuesAsJson() ?? [];
    print('gknefroi f $fieldValues');
    print('gknefroi j $jsonData');
    print('gknefroi f $filledOnly');
    print('gknefroi 3 $de');
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // Validation checks
    if (!_validateForm(leadProvider, dropDownProvider)) {
      return;
    }

    final selectedEnquirySource = dropDownProvider.enquiryData.firstWhere(
      (source) =>
          source.enquirySourceId == dropDownProvider.selectedEnquirySourceId,
      orElse: () => Enquirysourcemodel(
          enquirySourceId: 0,
          enquirySourceName: '',
          deleteStatus: 0,
          sourceCategoryId: 0,
          sourceCategoryName: ''),
    );

    final selectedStatus = dropDownProvider.followUpData.firstWhere(
      (status) => status.statusId == dropDownProvider.selectedFollowUpId,
      orElse: () => SearchLeadStatusModel(
        followup: 0,
        statusId: 0,
        statusName: '',
        statusOrder: 0,
      ),
    );

    final selectedUser = dropDownProvider.searchUserDetails.firstWhere(
      (user) => user.userDetailsId == dropDownProvider.selectedUserId,
      orElse: () => SearchUserDetails(userDetailsId: 0, userDetailsName: ''),
    );

    leadProvider.saveLead(
        custId: widget.isEdit ? leadProvider.customerId : 0,
        context: context,
        address1: leadProvider.addressController.text,
        address2: leadProvider.cityController.text,
        address3: leadProvider.districtController.text,
        address4: leadProvider.stateController.text,
        byUserId: 0,
        byUserName: '',
        circle: leadProvider.circleController.text,
        connectedLoad: leadProvider.connectedLoadController.text,
        consumerNo: leadProvider.consumerNoController.text,
        contactNumber: leadProvider.contactNoController.text,
        contactPerson: '',
        createdBy: 0,
        createdByName: '',
        customerName: leadProvider.leadNameController.text,
        division: leadProvider.divisionController.text,
        email: leadProvider.emailIdController.text,
        entryDate: DateTime.now().toString(),
        followUp: leadProvider.followUpDateController.text.isNotEmpty ? 1 : 0,
        mapLink: leadProvider.mapLinkController.text,
        nextFollowUpDate: leadProvider.followUpDateController.text,
        pincode: leadProvider.pincodeController.text,
        proposedKW: leadProvider.proposedKWController.text,
        remark: leadProvider.remarksController.text,
        roofType: leadProvider.roofTypeController.text,
        section: '',
        enquirySourceId: dropDownProvider.selectedEnquirySourceId ?? 0,
        enquirySourceName: selectedEnquirySource.enquirySourceName,
        statusId: dropDownProvider.selectedFollowUpId ?? 0,
        statusName: selectedStatus.statusName!,
        toUserId: dropDownProvider.selectedUserId ?? 0,
        toUserName: selectedUser.userDetailsName ?? '',
        subDistrict: '',
        subDivision: leadProvider.subDivisionController.text,
        village: '',
        enquiryForId: dropDownProvider.selectedEnquiryForId ?? 0,
        enquiryForName: dropDownProvider.selectedEnquiryForName,
        branchId: settingsProvider.selectedBranchId!,
        branchName: leadProvider.branchController.text,
        departmentId: settingsProvider.selectedDepartmentId!,
        departmentName: leadProvider.departmentController.text,
        sourceId: dropDownProvider.selectedSourceId ?? 0,
        sourceName: leadProvider.sourceCategoryController.text,
        districtId: dropDownProvider.selectedDistrictId ?? 0,
        districtName: dropDownProvider.selectedDistrictName,
        age: int.tryParse(leadProvider.leadAgeController.text) ?? 0,
        peId: dropDownProvider.selectedpeUserId ?? 0,
        peName: leadProvider.peController.text,
        creId: dropDownProvider.selectedcreUserId ?? 0,
        creName: leadProvider.creController.text,
        leadtypeId: dropDownProvider.selectedleadtypeUserId ?? 0,
        leadtypeName: leadProvider.leadtypeController.text);
  }

  bool _validateForm(
      LeadsProvider leadProvider, DropDownProvider dropDownProvider) {
    String? errorMessage;
    final validation = customFieldLeadStatusKey.currentState?.validateForm();
    final validation2 =
        customFieldEnquirySourceKey.currentState?.validateForm();

    if (leadProvider.leadNameController.text.isEmpty) {
      errorMessage = 'Lead name is required';
    } else if (dropDownProvider.selectedEnquirySourceId == null) {
      errorMessage = 'Please select an Enquiry source';
    } else if (leadProvider.enquirySourceController.text.isEmpty) {
      errorMessage = 'Please select an Enquiry source';
    } else if (leadProvider.contactNoController.text.isEmpty) {
      errorMessage = 'Mobile number is required';
    } else if (validatePhone &&
        leadProvider.contactNoController.text.length != 10) {
      errorMessage = 'Mobile number must be 10 digits';
    }
    // else if (leadProvider.emailIdController.text.isEmpty) {
    //   errorMessage = 'Email address is required';
    // }
    else if (leadProvider.emailIdController.text.isNotEmpty &&
        !(leadProvider.emailIdController.text.contains('@') &&
            leadProvider.emailIdController.text.contains('.'))) {
      errorMessage = 'Enter Valid Email';
    } else if (dropDownProvider.selectedEnquiryForId == null) {
      errorMessage = 'Please select Enquiry For';
    }
    // else if (leadProvider.mapLinkController.text.isEmpty) {
    //   errorMessage = 'Location is required';
    // }
    // else if (leadProvider.addressController.text.isEmpty) {
    //   errorMessage = 'Address is required';
    // }
    else if (leadProvider.followUpStatusController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Follow-up Status';
    } else if (leadProvider.branchController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Branch';
    } else if (leadProvider.departmentController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Department';
    } else if (leadProvider.searchUserController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please Assign Staff';
    } else if (dropDownProvider.isFollowupRequired() &&
        leadProvider.followUpDateController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Follow-up Date';
    } else if (validation?.isValid == false) {
      errorMessage = 'Please Enter mandatory fields';
    } else if (validation2?.isValid == false) {
      errorMessage = 'Please Enter mandatory fields';
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

  void _onDrawerClosed(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    leadProvider.clearAllLeadControllers(context);
    dropDownProvider.resetFields();
    dropDownProvider.setSourceCategoryId(null);
    dropDownProvider.setSelectedEnquirySourceId(null);
    dropDownProvider.setSelectedFollowUPId(0);
    dropDownProvider.setSelectedUserId(0);
    dropDownProvider.updateEnquiryForName(null, '');
    leadProvider.customFieldList.clear();
    leadProvider.customFieldEnquiryFor.clear();
  }

  // late CustomFieldWidgetBuilder widgetBuilder;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _leadNameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _leadNameFocusNode.requestFocus();
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);

      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      await leadProvider.loadLoginDetails();

      if (widget.isEdit) {
        leadProvider.getCustomFieldsByEnquiryForId(
          context,
          enquiryForId: dropDownProvider.selectedEnquiryForId ?? 0,
          leadId: leadProvider.customerId,
        );
      } else {
        leadProvider.clearAllLeadControllers(context);

        // Populate defaults from login
        leadProvider.branchController.text = leadProvider.loginBranchName;
        leadProvider.departmentController.text =
            leadProvider.loginDepartmentName;
        leadProvider.searchUserController.text = leadProvider.loginUserName;
        leadProvider.followUpDateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());

        dropDownProvider.setSelectedUserId(leadProvider.loginUserId);
        settingsProvider.selectedBranchId = leadProvider.loginBranchId;
        settingsProvider
            .setSelectedDepartmentId(leadProvider.loginDepartmentId);

        // Filter staff initially
        dropDownProvider.filterStaffByBranchAndDepartment(
          branchId: leadProvider.loginBranchId,
          departmentId: leadProvider.loginDepartmentId,
        );

        //default source category
        int? selectedSourceId;
        if (settingsProvider.searchSourceCategory.isNotEmpty) {
          selectedSourceId =
              settingsProvider.searchSourceCategory.first.sourceId;
        }

        if (selectedSourceId != null) {
          dropDownProvider.setSourceCategoryId(selectedSourceId);
          final selectedItem = settingsProvider.searchSourceCategory
              .firstWhere((source) => source.sourceId == selectedSourceId);
          leadProvider.sourceCategoryController.text = selectedItem.sourceName;

          dropDownProvider.updateEnquiryForName(0, '');
          leadProvider.enquiryForController.clear();

          dropDownProvider.filterEnquiryForByCategory(selectedSourceId);
        }

        //default enquiry for
        int? defaultEnquiryForId;
        if (dropDownProvider.filteredEnquiryForData.isNotEmpty) {
          defaultEnquiryForId =
              dropDownProvider.filteredEnquiryForData.first.enquiryForId;
        }

        if (defaultEnquiryForId != null) {
          final selectedEnquiryFor = dropDownProvider.filteredEnquiryForData
              .firstWhere((task) => task.enquiryForId == defaultEnquiryForId);
          dropDownProvider.updateEnquiryForName(
              defaultEnquiryForId, selectedEnquiryFor.enquiryForName);
          leadProvider.customFieldEnquiryFor.clear();
          leadProvider.getCustomFieldsByEnquiryForId(
            context,
            leadId: widget.isEdit ? leadProvider.customerId : 0,
            enquiryForId: defaultEnquiryForId,
          );
        }
      }
      dropDownProvider.getUserDetails(context);
      print(leadProvider.loginUserName);
      leadProvider.searchUserController.text = leadProvider.loginUserName;
      dropDownProvider.setSelectedUserId(leadProvider.loginUserId);

      // widgetBuilder = CustomFieldWidgetBuilder(context);
    });
  }

  @override
  void dispose() {
    _leadNameFocusNode.dispose();
    _onDrawerClosed(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);

    final settingsProvider = Provider.of<SettingsProvider>(context);
    print(leadProvider.enquirySourceController.text);

    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Copy all your existing ExpansionTile widgets here
                      // (Basic details, Address, Invertor and Panel Details, etc.)

                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.textGrey2.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isEdit
                                      ? 'Edit Lead details'
                                      : 'Add New Lead',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textBlack,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!widget.isEdit)
                                  Text(
                                    '${leadProvider.loginBranchName} | ${leadProvider.loginDepartmentName} | ${leadProvider.loginUserTypeName}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                // if (widget.isEdit)
                                //   ElevatedButton(
                                //     onPressed: () async {
                                //       Navigator.of(context).pop();
                                //       //
                                //       // final leadDetailsProvider =
                                //       //     Provider.of<LeadDetailsProvider>(context,
                                //       //         listen: false);
                                //       //
                                //       // await leadDetailsProvider.fetchLeadDetails(
                                //       //     widget.customerId.toString(), context);
                                //       //
                                //       // context.push(
                                //       //     '${CustomerDetailsScreen.route}${widget.customerId.toString()}/${'true'}');
                                //     },
                                //     style: ElevatedButton.styleFrom(
                                //       foregroundColor: AppColors.primaryBlue,
                                //       backgroundColor:
                                //           Colors.white, // Text color
                                //       side: BorderSide(
                                //           color: AppColors
                                //               .primaryBlue), // Border color
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(
                                //             5), // Border radius
                                //       ),
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 8.0,
                                //           vertical:
                                //               0.0), // Reduced horizontal padding
                                //     ),
                                //     child: Row(
                                //       children: [
                                //         Icon(
                                //           Icons.person,
                                //           color: AppColors.primaryBlue,
                                //         ),
                                //         if (AppStyles.isWebScreen(context))
                                //           const Text(
                                //             'View Details',
                                //             style: TextStyle(fontSize: 16),
                                //           ),
                                //       ],
                                //     ),
                                //   ),
                                if (widget.isEdit) const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: AppColors.textBlack),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _onDrawerClosed(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      //basic
                      ExpansionTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        title: Text(
                          'Basic details',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textGrey3,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded: true,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const SizedBox(height: 10),
                          // Row 1: Lead Name, Channel Source, Mobile No
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CustomTextField(
                                    height: 54,
                                    controller: leadProvider.leadNameController,
                                    hintText: 'Lead Name*',
                                    labelText: '',
                                    focusNode: _leadNameFocusNode,
                                    showError:
                                        dropDownProvider.showValidation &&
                                            !_isFieldValid(leadProvider
                                                .leadNameController.text),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: CommonDropdown<int>(
                                    hintText: 'Source*',
                                    items: settingsProvider.searchSourceCategory
                                        .map((source) => DropdownItem<int>(
                                              id: source.sourceId,
                                              name: source.sourceName ?? '',
                                            ))
                                        .toList(),
                                    controller:
                                        leadProvider.sourceCategoryController,
                                    onItemSelected: (selectedId) {
                                      dropDownProvider
                                          .setSourceCategoryId(selectedId);
                                      final selectedItem = settingsProvider
                                          .searchSourceCategory
                                          .firstWhere((source) =>
                                              source.sourceId == selectedId);
                                      leadProvider.sourceCategoryController
                                          .text = selectedItem.sourceName ?? '';
                                      // dropDownProvider
                                      //     .setSelectedEnquirySourceId(-1);
                                      // leadProvider.enquirySourceController
                                      //     .clear();
                                      // dropDownProvider
                                      //     .filterEnquirySourcesByCategory(
                                      //         selectedId);
                                      dropDownProvider.updateEnquiryForName(
                                          0, '');
                                      leadProvider.enquiryForController.clear();

                                      dropDownProvider
                                          .filterEnquiryForByCategory(
                                              selectedId);
                                    },
                                    selectedValue:
                                        dropDownProvider.selectedSourceId,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 📱 Phone TextField
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: ValueListenableBuilder<
                                            TextEditingValue>(
                                          valueListenable:
                                              leadProvider.contactNoController,
                                          builder: (context, value, child) {
                                            final isValid =
                                                value.text.length == 10;

                                            return CustomTextField(
                                              controller: leadProvider
                                                  .contactNoController,
                                              keyboardType: TextInputType.phone,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                if (validatePhone)
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                              ],
                                              hintText: 'Mobile No*',
                                              labelText: '',
                                              height: 54,
                                              suffixIcon: validatePhone
                                                  ? Icon(
                                                      isValid
                                                          ? Icons.check_circle
                                                          : Icons.cancel,
                                                      color: isValid
                                                          ? Colors.green
                                                          : Colors.red,
                                                    )
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // ☑️ Validation Checkbox
                                    Tooltip(
                                      message:
                                          "Enable to validate phone number",
                                      child: Checkbox(
                                        value: validatePhone,
                                        onChanged: (checked) {
                                          setState(() {
                                            validatePhone = checked ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 2: Enquiry Source, Enquiry For, Sub Source
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CommonDropdown<int>(
                                    hintText: 'Enquiry Source*',
                                    items: dropDownProvider.enquiryData
                                        .map((source) => DropdownItem<int>(
                                              id: source.enquirySourceId,
                                              name: source.enquirySourceName ??
                                                  '',
                                            ))
                                        .toList(),
                                    controller:
                                        leadProvider.enquirySourceController,
                                    onItemSelected: (selectedId) {
                                      dropDownProvider
                                          .setSelectedEnquirySourceId(
                                              selectedId);
                                      final selectedItem = dropDownProvider
                                          .enquiryData
                                          .firstWhere((source) =>
                                              source.enquirySourceId ==
                                              selectedId);

                                      leadProvider
                                              .enquirySourceController.text =
                                          selectedItem.enquirySourceName ?? '';
                                    },
                                    selectedValue: dropDownProvider
                                        .selectedEnquirySourceId,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: CommonDropdown<int>(
                                    hintText: 'Enquiry For*',
                                    enabled:
                                        dropDownProvider.selectedSourceId !=
                                            null,
                                    items:
                                        dropDownProvider.filteredEnquiryForData
                                            .map((status) => DropdownItem<int>(
                                                  id: status.enquiryForId,
                                                  name: status.enquiryForName,
                                                ))
                                            .toList(),
                                    controller:
                                        leadProvider.enquiryForController,
                                    onItemSelected: (int? newValue) {
                                      if (newValue != null) {
                                        final selectedEnquiryFor =
                                            dropDownProvider
                                                .filteredEnquiryForData
                                                .firstWhere((task) =>
                                                    task.enquiryForId ==
                                                    newValue);
                                        dropDownProvider.updateEnquiryForName(
                                            newValue,
                                            selectedEnquiryFor.enquiryForName);
                                        leadProvider.customFieldEnquiryFor
                                            .clear();
                                        leadProvider
                                            .getCustomFieldsByEnquiryForId(
                                          context,
                                          leadId: widget.isEdit
                                              ? leadProvider.customerId
                                              : 0,
                                          enquiryForId: newValue,
                                        );
                                      }
                                    },
                                    selectedValue:
                                        dropDownProvider.selectedEnquiryForId,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: CustomTextField(
                                    height: 54,
                                    controller:
                                        leadProvider.referenceNameController,
                                    hintText: 'Sub Source',
                                    labelText: '',
                                    showError:
                                        dropDownProvider.showValidation &&
                                            !_isFieldValid(leadProvider
                                                .referenceNameController.text),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // // Row 3: PE, CRE, Lead Type
                          // Row(
                          //   children: [
                          //     // Expanded(
                          //     //   child: Padding(
                          //     //     padding: const EdgeInsets.only(right: 8.0),
                          //     //     child: CommonDropdown<int>(
                          //     //       hintText: 'PE',
                          //     //       items: dropDownProvider.searchUserDetails
                          //     //           .map((staff) => DropdownItem<int>(
                          //     //                 id: staff.userDetailsId,
                          //     //                 name: staff.userDetailsName,
                          //     //               ))
                          //     //           .toList(),
                          //     //       controller: leadProvider.peController,
                          //     //       onItemSelected: (selectedId) {
                          //     //         dropDownProvider
                          //     //             .setSelectedpeUserId(selectedId);
                          //     //         final selectedStaff = dropDownProvider
                          //     //             .searchUserDetails
                          //     //             .firstWhere((staff) =>
                          //     //                 staff.userDetailsId ==
                          //     //                 selectedId);
                          //     //         leadProvider.peController.text =
                          //     //             selectedStaff.userDetailsName;
                          //     //       },
                          //     //       selectedValue:
                          //     //           dropDownProvider.selectedpeUserId,
                          //     //     ),
                          //     //   ),
                          //     // ),
                          //     // Expanded(
                          //     //   child: Padding(
                          //     //     padding: const EdgeInsets.symmetric(
                          //     //         horizontal: 4.0),
                          //     //     child: CommonDropdown<int>(
                          //     //       hintText: 'CRE',
                          //     //       items: dropDownProvider.searchUserDetails
                          //     //           .map((staff) => DropdownItem<int>(
                          //     //                 id: staff.userDetailsId,
                          //     //                 name: staff.userDetailsName,
                          //     //               ))
                          //     //           .toList(),
                          //     //       controller: leadProvider.creController,
                          //     //       onItemSelected: (selectedId) {
                          //     //         dropDownProvider
                          //     //             .setSelectedcreUserId(selectedId);
                          //     //         final selectedStaff = dropDownProvider
                          //     //             .searchUserDetails
                          //     //             .firstWhere((staff) =>
                          //     //                 staff.userDetailsId ==
                          //     //                 selectedId);
                          //     //         leadProvider.creController.text =
                          //     //             selectedStaff.userDetailsName;
                          //     //       },
                          //     //       selectedValue:
                          //     //           dropDownProvider.selectedcreUserId,
                          //     //     ),
                          //     //   ),
                          //     // ),
                          //     // Expanded(
                          //     //   child: Padding(
                          //     //     padding: const EdgeInsets.only(left: 0.0),
                          //     //     child: CommonDropdown<int>(
                          //     //       hintText: 'Lead type',
                          //     //       items: UserStatusType.values
                          //     //           .map((staff) => DropdownItem<int>(
                          //     //                 id: staff.value,
                          //     //                 name: '${staff.name}',
                          //     //               ))
                          //     //           .toList(),
                          //     //       controller: leadProvider.leadtypeController,
                          //     //       onItemSelected: (selectedId) {
                          //     //         dropDownProvider
                          //     //             .setSelectedleadtypeUserId(
                          //     //                 selectedId);
                          //     //         final selectedStatus = UserStatusType
                          //     //             .values
                          //     //             .firstWhere((status) =>
                          //     //                 status.value == selectedId);
                          //     //         leadProvider.leadtypeController.text =
                          //     //             selectedStatus.name;
                          //     //       },
                          //     //       selectedValue:
                          //     //           dropDownProvider.selectedleadtypeUserId,
                          //     //     ),
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                          const SizedBox(height: 8),

                          // if (dropDownProvider.selectedEnquiryForId != null &&
                          //     dropDownProvider.selectedEnquiryForId != 0)
                          //   if (leadProvider.isLoadingEnquiryCustomFields)
                          //     const Center(child: CircularProgressIndicator())
                          //   else if (leadProvider
                          //       .customFieldEnquiryFor.isNotEmpty)
                          //     CustomFieldSectionWidget(
                          //       controllerKey: CustomFieldControllerkey
                          //           .enquirySource.value,
                          //       key: customFieldEnquirySourceKey,
                          //       initialFieldValues: widget.isEdit
                          //           ? leadProvider.customFieldEnquiryFor
                          //               .map((e) => FieldValueModel(
                          //                   customFieldId: e.customFieldId,
                          //                   value: e.datavalue))
                          //               .toList()
                          //           : [],
                          //       onFieldValuesChanged: (p0) {},
                          //       customFields:
                          //           leadProvider.customFieldEnquiryFor,
                          //       initialValues: const {},
                          //     ),
                          if (dropDownProvider.selectedEnquiryForId != null &&
                              dropDownProvider.selectedEnquiryForId != 0)
                            if (leadProvider.isLoadingEnquiryCustomFields)
                              const Center(child: CircularProgressIndicator())
                            else if (leadProvider
                                .customFieldEnquiryFor.isNotEmpty)
                              // Use Consumer to rebuild only when custom field values change
                              Consumer<LeadsProvider>(
                                builder: (context, provider, child) {
                                  return CustomFieldSectionWidget(
                                    controllerKey: CustomFieldControllerkey
                                        .enquirySource.value,
                                    key: customFieldEnquirySourceKey,
                                    initialFieldValues: widget.isEdit
                                        ? leadProvider.customFieldEnquiryFor
                                            .map((e) => FieldValueModel(
                                                customFieldId: e.customFieldId,
                                                value: e.datavalue))
                                            .toList()
                                        : leadProvider.customFieldEnquiryFor
                                            .map((e) => FieldValueModel(
                                                customFieldId: e.customFieldId,
                                                value: provider
                                                    .getCustomFieldValue(
                                                        e.customFieldId ?? 0)))
                                            .toList(),
                                    onFieldValuesChanged: (fieldValues) {
                                      if (!widget.isEdit) {
                                        for (var fieldValue in fieldValues) {
                                          provider.updateCustomFieldValue(
                                              fieldValue.customFieldId ?? 0,
                                              fieldValue.value ?? '');
                                        }
                                      }
                                    },
                                    customFields:
                                        leadProvider.customFieldEnquiryFor,
                                    initialValues: const {},
                                  );
                                },
                              ),
                        ],
                      ),
                      //address
                      ExpansionTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        title: Text(
                          'Address',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textGrey3,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        tilePadding: EdgeInsets.zero,
                        initiallyExpanded: false,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  height: 90,
                                  controller: leadProvider.addressController,
                                  hintText: 'Address',
                                  labelText: '',
                                  showError: dropDownProvider.showValidation &&
                                      !_isFieldValid(
                                          leadProvider.addressController.text),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    CustomTextField(
                                      height: 90,
                                      controller:
                                          leadProvider.mapLinkController,
                                      hintText: 'Map link',
                                      labelText: '',
                                      onChanged: (value) {
                                        leadProvider.extractCoordinates();
                                      },
                                      showError:
                                          dropDownProvider.showValidation &&
                                              !_isFieldValid(leadProvider
                                                  .mapLinkController.text),
                                    ),
                                    Positioned(
                                      right: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PopupMenuButton<String>(
                                            icon: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: AppColors.textBlack),
                                            onSelected: (String value) {
                                              if (value == 'current') {
                                                leadProvider
                                                    .useCurrentLocation();
                                              } else if (value == 'custom') {
                                                leadProvider.mapLinkController
                                                    .text = '';
                                                leadProvider.latitudeController
                                                    .text = '';
                                                leadProvider.longitudeController
                                                    .text = '';
                                                leadProvider
                                                    .extractCoordinates();
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'current',
                                                child: Text(
                                                    'Use current location'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'custom',
                                                child: Text('Custom entry'),
                                              ),
                                            ],
                                          ),
                                          // // Button to get current location directly
                                          // IconButton(
                                          //   icon: Icon(
                                          //     Icons.my_location,
                                          //     color: AppColors.textGrey4,
                                          //     size: 16,
                                          //   ),
                                          //   onPressed: () {
                                          //     leadProvider.useCurrentLocation();
                                          //   },
                                          //   tooltip: 'Get current location',
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  height: 90,
                                  controller: leadProvider.latitudeController,
                                  hintText: 'Latitude',
                                  labelText: '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  height: 90,
                                  controller: leadProvider.longitudeController,
                                  hintText: 'Longitude',
                                  labelText: '',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  height: 54,
                                  controller: leadProvider.cityController,
                                  hintText: 'City',
                                  labelText: '',
                                  showError: dropDownProvider.showValidation &&
                                      !_isFieldValid(
                                          leadProvider.cityController.text),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CommonDropdown<int>(
                                  hintText: 'District',
                                  items: dropDownProvider.districtList
                                      .map((status) => DropdownItem<int>(
                                            id: status.districtId ?? 0,
                                            name: status.districtName ?? '',
                                          ))
                                      .toList(),
                                  controller: leadProvider.districtController,
                                  onItemSelected: (int? newValue) {
                                    if (newValue != null) {
                                      final selectedEnquiryFor =
                                          dropDownProvider.districtList
                                              .firstWhere((task) =>
                                                  task.districtId == newValue);
                                      dropDownProvider.updateDistrict(
                                          newValue,
                                          selectedEnquiryFor.districtName ??
                                              '');
                                    }
                                  },
                                  selectedValue:
                                      dropDownProvider.selectedDistrictId !=
                                                  null &&
                                              dropDownProvider.districtList.any(
                                                  (item) =>
                                                      item.districtId ==
                                                      dropDownProvider
                                                          .selectedDistrictId)
                                          ? dropDownProvider.selectedDistrictId
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  height: 54,
                                  controller: leadProvider.pincodeController,
                                  hintText: 'Pincode',
                                  labelText: '',
                                  showError: dropDownProvider.showValidation &&
                                      !_isFieldValid(
                                          leadProvider.pincodeController.text),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  height: 54,
                                  controller: leadProvider.stateController,
                                  hintText: 'State',
                                  labelText: '',
                                  showError: dropDownProvider.showValidation &&
                                      !_isFieldValid(
                                          leadProvider.stateController.text),
                                ),
                              ),
                              const Spacer()
                            ],
                          ),
                        ],
                      ),

                      //invertor and panel
                      if (settingsProvider.menuIsViewMap[33] == 1)
                        ExpansionTile(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          title: Text(
                            'Inverter and Panel Details',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textGrey3,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          tilePadding: EdgeInsets.zero,
                          initiallyExpanded: false,
                          children: [
                            // const Text('Invertor Details'),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CommonDropdown<int>(
                                    hintText: 'Inverter Type',
                                    items: leadProvider
                                        .leadDropdownData!.inverterType
                                        .map((status) => DropdownItem<int>(
                                              id: status.inverterTypeId,
                                              name: status.inverterTypeName,
                                            ))
                                        .toList(),
                                    controller:
                                        leadProvider.inverterTypeController,
                                    onItemSelected: (selectedId) {
                                      leadProvider.setInverterId(selectedId);
                                      final selectedItem = leadProvider
                                          .leadDropdownData!.inverterType
                                          .firstWhere(
                                        (status) =>
                                            status.inverterTypeId == selectedId,
                                      );
                                      leadProvider.inverterTypeController.text =
                                          selectedItem.inverterTypeName ?? '';
                                    },
                                    selectedValue:
                                        leadProvider.selectedInverterId,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    height: 90,
                                    controller:
                                        leadProvider.invertorCapacityController,
                                    hintText: 'Inverter Capacity',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CommonDropdown<int>(
                                    hintText: 'Panel Brand',
                                    items:
                                        leadProvider.leadDropdownData!.panelType
                                            .map((status) => DropdownItem<int>(
                                                  id: status.panelTypeId,
                                                  name: status.panelTypeName,
                                                ))
                                            .toList(),
                                    controller:
                                        leadProvider.panelBrandController,
                                    onItemSelected: (selectedId) {
                                      leadProvider.setPanelId(selectedId);
                                      final selectedItem = leadProvider
                                          .leadDropdownData!.panelType
                                          .firstWhere(
                                        (status) =>
                                            status.panelTypeId == selectedId,
                                      );
                                      leadProvider.panelBrandController.text =
                                          selectedItem.panelTypeName ?? '';
                                    },
                                    selectedValue: leadProvider.selectedPanelId,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    height: 90,
                                    controller:
                                        leadProvider.panelCapacityController,
                                    hintText: 'Panel Capacity (in kW)',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CommonDropdown<int>(
                                    hintText: 'Panel Phase',
                                    items: leadProvider.leadDropdownData!.phase
                                        .map((status) => DropdownItem<int>(
                                              id: status.phaseId,
                                              name: status.phaseName,
                                            ))
                                        .toList(),
                                    controller:
                                        leadProvider.panelPhaseController,
                                    onItemSelected: (selectedId) {
                                      leadProvider.setPhaseId(selectedId);
                                      final selectedItem = leadProvider
                                          .leadDropdownData!.phase
                                          .firstWhere(
                                        (status) =>
                                            status.phaseId == selectedId,
                                      );
                                      leadProvider.panelPhaseController.text =
                                          selectedItem.phaseName ?? '';
                                    },
                                    selectedValue: leadProvider.selectedPhaseId,
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ],
                        ),

                      //consumer details
                      // if (settingsProvider.menuIsViewMap[34] == 1)
                      //   ExpansionTile(
                      //     shape: const RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.zero,
                      //     ),
                      //     title: Text(
                      //       'Additional details',
                      //       style: GoogleFonts.plusJakartaSans(
                      //         color: AppColors.textGrey3,
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //     tilePadding: EdgeInsets.zero,
                      //     initiallyExpanded: false,
                      //     // leadProvider.consumerNoController.text.isEmpty
                      //     //     ? false
                      //     //     : true,
                      //     children: [
                      //       const SizedBox(
                      //         height: 5,
                      //       ),
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(right: 8.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller:
                      //                     leadProvider.consumerNoController,
                      //                 hintText: 'Consumer no',
                      //                 labelText: '',
                      //                 inputFormatters: [
                      //                   FilteringTextInputFormatter.digitsOnly
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 4.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller: leadProvider
                      //                     .electricalSectionController,
                      //                 hintText: 'Electrical Section',
                      //                 labelText: '',
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(left: 8.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller:
                      //                     leadProvider.connectedLoadController,
                      //                 hintText: 'Connected load',
                      //                 labelText: '',
                      //                 inputFormatters: [
                      //                   FilteringTextInputFormatter.digitsOnly
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const SizedBox(height: 8),
                      //       // Row 2: REP, Lead By, Work Type
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(right: 8.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller: leadProvider.repController,
                      //                 hintText: 'REP',
                      //                 labelText: '',
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 4.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller: leadProvider.leadByController,
                      //                 hintText: 'Lead By',
                      //                 labelText: '',
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(left: 8.0),
                      //               child: CommonDropdown<int>(
                      //                 hintText: 'Work Type',
                      //                 items: leadProvider
                      //                     .leadDropdownData!.workType
                      //                     .map((status) => DropdownItem<int>(
                      //                           id: status.workTypeId,
                      //                           name: status.workTypeName,
                      //                         ))
                      //                     .toList(),
                      //                 controller:
                      //                     leadProvider.workTypeController,
                      //                 onItemSelected: (selectedId) {
                      //                   leadProvider.setWorkTypeId(selectedId);
                      //                   final selectedItem = leadProvider
                      //                       .leadDropdownData!.workType
                      //                       .firstWhere((status) =>
                      //                           status.workTypeId ==
                      //                           selectedId);
                      //                   leadProvider.workTypeController.text =
                      //                       selectedItem.workTypeName ?? '';
                      //                 },
                      //                 selectedValue:
                      //                     leadProvider.selectedWorkTypeId,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const SizedBox(height: 8),
                      //       // Row 3: Additional Comments, Roof Type, Empty space
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(right: 8.0),
                      //               child: CustomTextField(
                      //                 readOnly: false,
                      //                 height: 54,
                      //                 controller: leadProvider
                      //                     .additionalCommentscONTROLLER,
                      //                 hintText: 'Any Additional Comments',
                      //                 labelText: '',
                      //               ),
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 4.0),
                      //               child: CommonDropdown<int>(
                      //                 hintText: 'Roof Type',
                      //                 items: leadProvider
                      //                     .leadDropdownData!.roofType
                      //                     .map((status) => DropdownItem<int>(
                      //                           id: status.roofTypeId,
                      //                           name: status.roofTypeName,
                      //                         ))
                      //                     .toList(),
                      //                 controller:
                      //                     leadProvider.roofTypeController,
                      //                 onItemSelected: (selectedId) {
                      //                   leadProvider.setRoofTypeId(selectedId);
                      //                   final selectedItem = leadProvider
                      //                       .leadDropdownData!.roofType
                      //                       .firstWhere((status) =>
                      //                           status.roofTypeId ==
                      //                           selectedId);
                      //                   leadProvider.roofTypeController.text =
                      //                       selectedItem.roofTypeName ?? '';
                      //                 },
                      //                 selectedValue:
                      //                     leadProvider.selectedRoofId,
                      //               ),
                      //             ),
                      //           ),
                      //           const Spacer()
                      //         ],
                      //       ),
                      //     ],
                      //   ),

                      //follow up
                      if (widget.isEdit == false)
                        ExpansionTile(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          title: Text(
                            'Follow-up Details',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textGrey3,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          tilePadding: EdgeInsets.zero,
                          initiallyExpanded: true,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                // Row 1: Branch, Department, Follow-up Status
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: CommonDropdown<int>(
                                          hintText: 'Branch*',
                                          selectedValue:
                                              settingsProvider.selectedBranchId,
                                          items: settingsProvider.branchModel
                                              .map((source) =>
                                                  DropdownItem<int>(
                                                    id: source.branchId ?? 0,
                                                    name:
                                                        source.branchName ?? '',
                                                  ))
                                              .toList(),
                                          controller:
                                              leadProvider.branchController,
                                          onItemSelected: (selectedId) {
                                            settingsProvider.selectedBranchId =
                                                selectedId;
                                            final selectedBranch =
                                                settingsProvider.branchModel
                                                    .firstWhere((branch) =>
                                                        branch.branchId ==
                                                        selectedId);
                                            leadProvider.branchController.text =
                                                selectedBranch.branchName ?? '';
                                            settingsProvider
                                                .setSelectedDepartmentId(0);
                                            leadProvider.departmentController
                                                .clear();
                                            dropDownProvider
                                                .setSelectedUserId(0);
                                            leadProvider.searchUserController
                                                .clear();
                                            dropDownProvider
                                                .filterStaffByBranchAndDepartment(
                                              branchId: selectedId,
                                              departmentId: null,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: CommonDropdown<int>(
                                          key: ValueKey(settingsProvider
                                              .selectedBranchId),
                                          hintText: 'Department*',
                                          selectedValue: settingsProvider
                                              .selectedDepartmentId,
                                          items: settingsProvider
                                              .departmentModel
                                              .map(
                                                  (source) => DropdownItem<int>(
                                                        id: source.departmentId,
                                                        name: source
                                                                .departmentName ??
                                                            '',
                                                      ))
                                              .toList(),
                                          controller:
                                              leadProvider.departmentController,
                                          onItemSelected: (selectedId) {
                                            settingsProvider
                                                    .selectedDepartmentId =
                                                selectedId;
                                            final selectedDepartment =
                                                settingsProvider.departmentModel
                                                    .firstWhere((dept) =>
                                                        dept.departmentId ==
                                                        selectedId);
                                            leadProvider.departmentController
                                                .text = selectedDepartment
                                                    .departmentName ??
                                                '';
                                            dropDownProvider
                                                .setSelectedUserId(0);
                                            leadProvider.searchUserController
                                                .clear();
                                            dropDownProvider
                                                .filterStaffByBranchAndDepartment(
                                              branchId: settingsProvider
                                                  .selectedBranchId,
                                              departmentId: selectedId,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: CommonDropdown<int>(
                                          hintText: 'Follow-up Status*',
                                          items: dropDownProvider.followUpData
                                              .map((status) =>
                                                  DropdownItem<int>(
                                                    id: status.statusId ?? 0,
                                                    name:
                                                        status.statusName ?? '',
                                                  ))
                                              .toList(),
                                          controller: leadProvider
                                              .followUpStatusController,
                                          onItemSelected: (selectedId) {
                                            dropDownProvider
                                                .setSelectedFollowUPId(
                                                    selectedId);
                                            leadProvider.customFieldList
                                                .clear();
                                            leadProvider
                                                .getCustomFieldsByStatusId(
                                              context,
                                              leadId: widget.isEdit
                                                  ? leadProvider.customerId
                                                  : 0,
                                              statusId: selectedId,
                                            );
                                            final selectedStatus =
                                                dropDownProvider.followUpData
                                                    .firstWhere((status) =>
                                                        status.statusId ==
                                                        selectedId);
                                            leadProvider
                                                    .followUpStatusController
                                                    .text =
                                                selectedStatus.statusName ?? '';
                                          },
                                          selectedValue: dropDownProvider
                                              .selectedFollowUpId,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                if (dropDownProvider.selectedFollowUpId !=
                                        null &&
                                    dropDownProvider.selectedFollowUpId != 0)
                                  if (leadProvider.isLoadingCustomFields)
                                    const Center(
                                        child: CircularProgressIndicator())
                                  else if (leadProvider
                                      .customFieldList.isNotEmpty)
                                    CustomFieldSectionWidget(
                                      controllerKey: CustomFieldControllerkey
                                          .leadStatus.value,
                                      key: customFieldLeadStatusKey,
                                      onFieldValuesChanged: (p0) {},
                                      customFields:
                                          leadProvider.customFieldList,
                                      initialValues: const {},
                                    ),
                                const SizedBox(height: 8),
                                // Row 2: Assigned Staff, Remarks, Next Follow-up Date
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: CommonDropdown<int>(
                                          hintText: 'Assigned Staff*',
                                          items: dropDownProvider
                                              .filteredStaffData
                                              .map((staff) => DropdownItem<int>(
                                                    id: staff.userDetailsId,
                                                    name: staff.userDetailsName,
                                                  ))
                                              .toList(),
                                          controller:
                                              leadProvider.searchUserController,
                                          onItemSelected: (selectedId) {
                                            dropDownProvider
                                                .setSelectedUserId(selectedId);
                                            final selectedStaff =
                                                dropDownProvider
                                                    .filteredStaffData
                                                    .firstWhere((staff) =>
                                                        staff.userDetailsId ==
                                                        selectedId);
                                            leadProvider
                                                    .searchUserController.text =
                                                selectedStaff.userDetailsName;
                                          },
                                          selectedValue:
                                              dropDownProvider.selectedUserId,
                                          enabled: settingsProvider
                                                      .selectedBranchId !=
                                                  null &&
                                              settingsProvider
                                                      .selectedDepartmentId !=
                                                  null,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: CustomTextField(
                                          height: 54, // Set height to 54
                                          controller:
                                              leadProvider.remarksController,
                                          hintText: 'Remarks',
                                          labelText: '',
                                          keyboardType: TextInputType
                                              .text, // Changed from multiline to text
                                          showError:
                                              dropDownProvider.showValidation &&
                                                  !_isFieldValid(leadProvider
                                                      .remarksController.text),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: dropDownProvider
                                                    .isFollowupRequired() &&
                                                leadProvider
                                                    .followUpStatusController
                                                    .text
                                                    .isNotEmpty
                                            ? CustomTextField(
                                                onTap: () async {
                                                  final DateTime? picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 365)),
                                                  );
                                                  if (picked != null) {
                                                    leadProvider
                                                        .followUpDateController
                                                        .text = DateFormat(
                                                            'dd MMM yyyy')
                                                        .format(picked);
                                                  }
                                                },
                                                readOnly: true,
                                                height: 54,
                                                controller: leadProvider
                                                    .followUpDateController,
                                                hintText:
                                                    'Next Follow-up Date*',
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                      Icons.calendar_today),
                                                  onPressed: () async {
                                                    final DateTime? picked =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime.now()
                                                          .add(const Duration(
                                                              days: 365)),
                                                    );
                                                    if (picked != null) {
                                                      leadProvider
                                                          .followUpDateController
                                                          .text = DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(picked);
                                                    }
                                                  },
                                                ),
                                                labelText: '',
                                              )
                                            : const SizedBox(), // Empty space when follow-up date is not required
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Fixed bottom buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomElevatedButton(
                          buttonText: 'Cancel',
                          onPressed: () {
                            _onDrawerClosed(context);
                            Navigator.of(context).pop();
                          },
                          backgroundColor: AppColors.whiteColor,
                          borderColor: AppColors.appViolet,
                          textColor: AppColors.appViolet,
                        ),
                        const SizedBox(width: 16),
                        CustomElevatedButton(
                          buttonText: 'Save',
                          onPressed: _saveLead,
                          backgroundColor: AppColors.appViolet,
                          borderColor: AppColors.appViolet,
                          textColor: AppColors.whiteColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
