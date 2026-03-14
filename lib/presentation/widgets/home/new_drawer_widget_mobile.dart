import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/controller/models/save_lead_dropdown_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/source_category_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/home/add_quotation_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/login/login_page_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class NewLeadDrawerMobileWidget extends StatefulWidget {
  final bool isEdit;
  final String customerId;

  const NewLeadDrawerMobileWidget(
      {super.key, required this.isEdit, required this.customerId});

  @override
  State<NewLeadDrawerMobileWidget> createState() =>
      _NewLeadDrawerMobileWidgetState();
}

class _NewLeadDrawerMobileWidgetState extends State<NewLeadDrawerMobileWidget> {
  bool _isFieldValid(String? value) => value != null && value.isNotEmpty;
  late FocusNode _leadNameFocusNode;
  List<ExpansionTileController> _expansionControllers = [];

  ScrollController scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  Map<int, bool> _expandedSections = {0: true, 5: true};
  late FocusNode enquiryNameNode;
  late FocusNode inverterTypeNode;
  late FocusNode panelBrandNode;
  late FocusNode phaseNode;
  late FocusNode roofTypeNode;
  late FocusNode amuntPaidNode;
  late FocusNode costIncludesNode;
  late FocusNode workTypeNode;
  late FocusNode sourceCategoryNode;

  late FocusNode enquiryForNode;
  late FocusNode peNode;
  late FocusNode creNode;
  late FocusNode leadTypeNode;

  late FocusNode followUpStatusNode;
  late FocusNode assignedStaffNode;

  int? expandedIndex = 0; // Default to the first tab being expanded
  bool _isProcessingClick = false;
  bool validatePhone = false;

  // final GlobalKey<_CustomFieldSectionWidgetState> _customFieldKey =
  //     GlobalKey<_CustomFieldSectionWidgetState>();

  void _toggleTab(int index) {
    if (_isProcessingClick) return;

    _isProcessingClick = true;

    // Use a local boolean to track the intended expansion state
    bool shouldExpand = expandedIndex != index;

    setState(() {
      if (shouldExpand) {
        // We want to expand this tab
        expandedIndex = index;
        _expansionControllers[index].expand();

        // Collapse all others
        for (int i = 0; i < _expansionControllers.length; i++) {
          if (i != index) {
            _expansionControllers[i].collapse();
          }
        }
      } else {
        // We want to collapse the currently expanded tab
        expandedIndex = null;
        _expansionControllers[index].collapse();
      }
    });

    // Your existing scroll code...
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // Ensure we release the processing lock after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      _isProcessingClick = false;
    });
  }
  // void _validateAndSubmit() {
  //   final dropDownProvider =
  //       Provider.of<DropDownProvider>(context, listen: false);
  //   final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
  //   dropDownProvider.setShowValidation(true);

  //   if (dropDownProvider.isFormValid(
  //     leadProvider.leadNameController.text,
  //     leadProvider.enquirySourceController.text,
  //     leadProvider.contactNoController.text,
  //     leadProvider.addressController.text,
  //     leadProvider.cityController.text,
  //     leadProvider.stateController.text,
  //     leadProvider.followUpStatusController.text,
  //     leadProvider.assignToController.text,
  //   )) {
  //     _saveLead();
  //   }
  // }

  void _saveLead() async {
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

    await leadProvider.saveLead(
        custId: widget.isEdit ? int.tryParse(widget.customerId) ?? 0 : 0,
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
    } else if (dropDownProvider.selectedEnquiryForId == null) {
      errorMessage = 'Please select Enquiry For';
    } else if (leadProvider.followUpStatusController.text.isEmpty &&
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
  }

  late CustomFieldWidgetBuilder widgetBuilder;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    sourceCategoryNode = FocusNode();
    _leadNameFocusNode = FocusNode();
    assignedStaffNode = FocusNode();
    enquiryForNode = FocusNode();
    enquiryNameNode = FocusNode();
    followUpStatusNode = FocusNode();
    expandedIndex = 0;
    inverterTypeNode = FocusNode();
    creNode = FocusNode();
    leadTypeNode = FocusNode();
    panelBrandNode = FocusNode();
    phaseNode = FocusNode();
    amuntPaidNode = FocusNode();
    costIncludesNode = FocusNode();
    roofTypeNode = FocusNode();
    workTypeNode = FocusNode();
    peNode = FocusNode();
    // widgetBuilder = CustomFieldWidgetBuilder(context);

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
      leadProvider.searchUserController.text = leadProvider.loginUserName;
      dropDownProvider.setSelectedUserId(leadProvider.loginUserId);

      // widgetBuilder = CustomFieldWidgetBuilder(context);
    });
  }

  @override
  void dispose() {
    _leadNameFocusNode.dispose();
    _headerScrollController.dispose();

    super.dispose();
  }

  Widget _buildTabsHeader() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final titles = [
      Text(
        'Basic details',
        style: GoogleFonts.plusJakartaSans(
          color: expandedIndex == 0 ? AppColors.textBlack : AppColors.textGrey3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        'Address',
        style: GoogleFonts.plusJakartaSans(
          color: expandedIndex == 1 ? AppColors.textBlack : AppColors.textGrey3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (settingsProvider.menuIsViewMap[33] == 1)
        Text(
          'Inverter and Panel Details',
          style: GoogleFonts.plusJakartaSans(
            color:
                expandedIndex == 2 ? AppColors.textBlack : AppColors.textGrey3,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      // Text(
      //   'Cost details',
      //   style: GoogleFonts.plusJakartaSans(
      //     color: expandedIndex == 2 ? AppColors.textBlack : AppColors.textGrey3,
      //     fontSize: 14,
      //     fontWeight: FontWeight.w500,
      //   ),
      // ),
      // Text(
      //   'Documents',
      //   style: GoogleFonts.plusJakartaSans(
      //     color: expandedIndex == 3 ? AppColors.textBlack : AppColors.textGrey3,
      //     fontSize: 14,
      //     fontWeight: FontWeight.w500,
      //   ),
      // ),
      // Text(
      //   'Additional details',
      //   style: GoogleFonts.plusJakartaSans(
      //     color: expandedIndex == 4 ? AppColors.textBlack : AppColors.textGrey3,
      //     fontSize: 14,
      //     fontWeight: FontWeight.w500,
      //   ),
      // ),
      if (!widget.isEdit)
        Text(
          'Follow-up Details',
          style: GoogleFonts.plusJakartaSans(
            color:
                expandedIndex == 3 ? AppColors.textBlack : AppColors.textGrey3,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
    ];

    return Container(
      height: 60,
      child: Stack(
        children: [
          Scrollbar(
            trackVisibility: false,
            interactive: false,
            controller: _headerScrollController,
            thumbVisibility: false,
            thickness: 3,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  titles.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _toggleTab(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4),
                        decoration: BoxDecoration(
                          color: expandedIndex == index
                              ? AppColors.lightBlueColor
                              : AppColors.scaffoldColor,
                          borderRadius: BorderRadius.circular(6.0),
                          border: expandedIndex == index
                              ? Border.all(
                                  color: AppColors.bluebutton, width: 1)
                              : null,
                        ),
                        child: titles[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Scroll arrows if needed
          if (MediaQuery.of(context).size.width >= 600) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _headerScrollController.hasClients &&
                      _headerScrollController.position.pixels > 10
                  ? Container(
                      width: 40,
                      color: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: () {
                          _headerScrollController.animateTo(
                            _headerScrollController.position.pixels - 100,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _headerScrollController.hasClients &&
                      _headerScrollController.position.hasContentDimensions &&
                      _headerScrollController.position.pixels <
                          _headerScrollController.position.maxScrollExtent - 10
                  ? Container(
                      width: 40,
                      color: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: () {
                          _headerScrollController.animateTo(
                            _headerScrollController.position.pixels + 100,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _onDrawerClosed(context);
                },
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: AppColors.textGrey4,
                ),
              ),
            ),
            leadingWidth: 36,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AppStyles.logo(),
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isEdit ? 'Edit Lead details' : 'Add New Lead',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (!widget.isEdit)
                  Text(
                    '${leadProvider.loginBranchName} | ${leadProvider.loginDepartmentName} | ${leadProvider.loginUserTypeName}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _saveLead,
                child: Text(
                  'Save',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.bluebutton,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTabsHeader(),
                  ),
                ],
              ),
            ),
          ),
          body: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ScrollableMultipleExpansionCard(
                    onTabToggle: _toggleTab,
                    showScrollArrows: false,
                    controllersCallback: (controllers) {
                      _expansionControllers = controllers;
                    },
                    initialExpanded: const {
                      0: true,
                      // 3: true
                    },
                    titles: [
                      Text(
                        'Basic details',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textGrey4,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Address',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textGrey4,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (settingsProvider.menuIsViewMap[33] == 1)
                        Text(
                          'Inverter and Panel Details',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textGrey4,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      // Text(
                      //   'Cost details',
                      //   style: GoogleFonts.plusJakartaSans(
                      //     color: AppColors.textGrey4,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // Text(
                      //   'Documents',
                      //   style: GoogleFonts.plusJakartaSans(
                      //     color: AppColors.textGrey3,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // Text(
                      //   'Additional details',
                      //   style: GoogleFonts.plusJakartaSans(
                      //     color: AppColors.textGrey4,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      if (!widget.isEdit)
                        Text(
                          'Follow-up Details',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textGrey4,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                    childrens: [
                      buildBasicDetails(),
                      buildAddressDetails(),
                      if (settingsProvider.menuIsViewMap[33] == 1)
                        buildInverterAndPanelDetails(),
                      // buildCostDetails(),
                      // buildDocumentsDetails(),
                      // buildAdditionalDetails(),
                      if (!widget.isEdit) buildFollowupDetails()
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFollowupDetails() {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            // CommonDropdown<int>(
            //   hintText: 'Follow-up Status*',
            //   items: dropDownProvider.followUpData
            //       .map((status) => DropdownItem<int>(
            //             id: status.statusId,
            //             name: status.statusName ?? '',
            //           ))
            //       .toList(),
            //   controller: leadProvider.followUpStatusController,
            //   onItemSelected: (selectedId) {
            //     dropDownProvider.setSelectedFollowUPId(selectedId);
            //     // if (!dropDownProvider
            //     //     .isFollowupRequired()) {
            //     //   leadProvider.followUpDateController
            //     //       .clear();
            //     // }
            //   },
            // ),

            const SizedBox(height: 10),
            CommonDropdown<int>(
              hintText: 'Branch*',
              selectedValue: settingsProvider.selectedBranchId,
              items: settingsProvider.branchModel
                  .map((source) => DropdownItem<int>(
                        id: source.branchId ?? 0,
                        name: source.branchName ?? '',
                      ))
                  .toList(),
              controller: leadProvider.branchController,
              onItemSelected: (selectedId) {
                settingsProvider.selectedBranchId = selectedId;

                // Update the controller text with the selected branch name
                final selectedBranch = settingsProvider.branchModel
                    .firstWhere((branch) => branch.branchId == selectedId);
                leadProvider.branchController.text =
                    selectedBranch.branchName ?? '';

                // Clear department and staff selections when branch changes
                settingsProvider.setSelectedDepartmentId(0);
                leadProvider.departmentController.clear();
                dropDownProvider.setSelectedUserId(0);
                leadProvider.searchUserController.clear();

                // Filter staff based on new branch selection
                dropDownProvider.filterStaffByBranchAndDepartment(
                  branchId: selectedId,
                  departmentId: null,
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            CommonDropdown<int>(
              key: ValueKey(settingsProvider.selectedBranchId), // Add this line

              hintText: 'Department*',
              selectedValue: settingsProvider.selectedDepartmentId,
              items: settingsProvider.departmentModel
                  .map((source) => DropdownItem<int>(
                        id: source.departmentId,
                        name: source.departmentName ?? '',
                      ))
                  .toList(),
              controller: leadProvider.departmentController,
              onItemSelected: (selectedId) {
                settingsProvider.selectedDepartmentId = selectedId;
                // Update the controller text with the selected department name
                final selectedDepartment =
                    settingsProvider.departmentModel.firstWhere(
                  (dept) => dept.departmentId == selectedId,
                );
                leadProvider.departmentController.text =
                    selectedDepartment.departmentName ?? '';

                // Clear staff selection when department changes
                dropDownProvider.setSelectedUserId(0);
                leadProvider.searchUserController.clear();

                // Filter staff based on both branch and department
                dropDownProvider.filterStaffByBranchAndDepartment(
                  branchId: settingsProvider.selectedBranchId,
                  departmentId: selectedId,
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            CommonDropdown<int>(
              hintText: 'Follow-up Status*',
              items: dropDownProvider.followUpData
                  .map((status) => DropdownItem<int>(
                        id: status.statusId ?? 0,
                        name: status.statusName ?? '',
                      ))
                  .toList(),
              controller: leadProvider.followUpStatusController,
              onItemSelected: (selectedId) {
                dropDownProvider.setSelectedFollowUPId(selectedId);
                // Update the controller text
                leadProvider.customFieldList.clear();
                leadProvider.getCustomFieldsByStatusId(context,
                    leadId: widget.isEdit ? leadProvider.customerId : 0,
                    statusId: selectedId);
                final selectedStatus = dropDownProvider.followUpData
                    .firstWhere((status) => status.statusId == selectedId);
                leadProvider.followUpStatusController.text =
                    selectedStatus.statusName ?? '';
              },
              selectedValue: dropDownProvider.selectedFollowUpId,
            ),
            SizedBox(
              height: 10,
            ),
            CommonDropdown<int>(
              hintText: 'Assigned Staff*',
              // Use filtered staff data instead of all staff data
              items: dropDownProvider.filteredStaffData
                  .map((staff) => DropdownItem<int>(
                        id: staff.userDetailsId,
                        name: staff.userDetailsName,
                      ))
                  .toList(),
              controller: leadProvider.searchUserController,
              onItemSelected: (selectedId) {
                dropDownProvider.setSelectedUserId(selectedId);

                // Update the controller text with the selected staff name
                final selectedStaff = dropDownProvider.filteredStaffData
                    .firstWhere((staff) => staff.userDetailsId == selectedId);
                leadProvider.searchUserController.text =
                    selectedStaff.userDetailsName;
              },
              selectedValue: dropDownProvider.selectedUserId,
              // Disable if branch or department is not selected
              enabled: settingsProvider.selectedBranchId != null &&
                  settingsProvider.selectedDepartmentId != null,
            ),
            if (dropDownProvider.selectedFollowUpId != null &&
                dropDownProvider.selectedFollowUpId != 0)
              // customFieldSection(),
              if (leadProvider.isLoadingCustomFields)
                const Center(child: CircularProgressIndicator())
              else if (leadProvider.customFieldList.isNotEmpty)
                CustomFieldSectionWidget(
                  controllerKey: CustomFieldControllerkey.leadStatus.value,
                  key: customFieldLeadStatusKey,
                  onFieldValuesChanged: (p0) {
                    print("kikisdhuqe $p0");
                    var f = [];
                    for (var element in p0) {
                      f.add(element.toJson());
                    }
                    print("kikisdhuqe de $f");
                  },
                  customFields: leadProvider.customFieldList,
                  initialValues: {},
                ),

            const SizedBox(height: 10),
            CustomTextField(
              height: 90,
              controller: leadProvider.remarksController,
              hintText: 'Remarks',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
              showError: dropDownProvider.showValidation &&
                  !_isFieldValid(leadProvider.remarksController.text),
            ),
            const SizedBox(height: 8),
            if (dropDownProvider.isFollowupRequired() &&
                leadProvider.followUpStatusController.text.isNotEmpty)
              CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    leadProvider.followUpDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                    // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
                readOnly: true,
                height: 54,
                controller: leadProvider.followUpDateController,
                hintText: 'Next Follow-up Date*',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      leadProvider.followUpDateController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
          ],
        ),
      ],
    );
  }

  Widget buildAdditionalDetails() {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.consumerNoController,
          labelText: 'Consumer no',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.electricalSectionController,
          labelText: 'Electrical Section',
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.connectedLoadController,
          labelText: 'Connection load',
          keyBoardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.repController,
          labelText: 'REP',
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.leadByController,
          labelText: 'Lead By',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomAutocomplete<WorkType>(
                focusNode: workTypeNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: leadProvider.leadDropdownData!.workType,
                displayStringFunction: (model) => model.workTypeName ?? '',
                defaultText: leadProvider.workTypeController.text ?? '',
                labelText: 'Work Type',
                controller: leadProvider.workTypeController,
                onSelected: (WorkType selectedTaskType) {
                  leadProvider.setWorkTypeId(selectedTaskType.workTypeId);

                  final selectedItem =
                      leadProvider.leadDropdownData!.workType.firstWhere(
                    (status) =>
                        status.workTypeId == selectedTaskType.workTypeId,
                  );
                  leadProvider.workTypeController.text =
                      selectedItem.workTypeName;
                },
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: CustomAutocomplete<RoofType>(
                focusNode: roofTypeNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: leadProvider.leadDropdownData!.roofType,
                displayStringFunction: (model) => model.roofTypeName ?? '',
                defaultText: leadProvider.roofTypeController.text ?? '',
                labelText: 'Roof Type',
                controller: leadProvider.roofTypeController,
                onSelected: (RoofType selectedTaskType) {
                  leadProvider.setRoofTypeId(selectedTaskType.roofTypeId);

                  final selectedItem =
                      leadProvider.leadDropdownData!.roofType.firstWhere(
                    (status) =>
                        status.roofTypeId == selectedTaskType.roofTypeId,
                  );
                  leadProvider.roofTypeController.text =
                      selectedItem.roofTypeName;
                },
                onChanged: (value) {},
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.additionalCostControler,
          labelText: 'Any Additional Comments',
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildDocumentsDetails() {
    final imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        //aadhar
        InkWell(
          onTap: () async {
            // Call the addFile method to pick the file
            var fileData = await ImageUploadProvider.addFile();

            if (fileData != null) {
              // Extract file data and name from the result
              Uint8List fileBytes = fileData['data'];

              final fileType = imageUploadProvider.determineFileType(fileBytes);

              // Now, upload the file to AWS
              String? awsFileUrl = await imageUploadProvider.saveToAws(
                  fileBytes,
                  fileType,
                  leadProvider.customerId.toString(),
                  context);

              // If AWS URL is successfully returned, store it in the leadProvider
              if (awsFileUrl != null) {
                leadProvider.aadharImage = awsFileUrl;
                print('File uploaded to AWS: $awsFileUrl');
              }
            }
          },
          child: Container(
            // height: 60,
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icon_camera.svg'),
                const SizedBox(
                  height: 6,
                ),
                CustomText(
                  'Add Aadhar',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (leadProvider.aadharImage.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(
              HttpUrls.imgBaseUrl + leadProvider.aadharImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(
                        HttpUrls.imgBaseUrl + leadProvider.aadharImage);
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    color: Colors.grey[200],
                    width: 100,
                    height: 100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Open PDF',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        //electricity bill
        InkWell(
          onTap: () async {
            var fileData = await ImageUploadProvider.addFile();

            if (fileData != null) {
              Uint8List fileBytes = fileData['data'];

              final fileType = imageUploadProvider.determineFileType(fileBytes);
              String? awsFileUrl = await imageUploadProvider.saveToAws(
                  fileBytes,
                  fileType,
                  leadProvider.customerId.toString(),
                  context);
              if (awsFileUrl != null) {
                leadProvider.electricityBillImage = awsFileUrl;
                print('File uploaded to AWS: $awsFileUrl');
              }
            }
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icon_camera.svg'),
                const SizedBox(
                  height: 6,
                ),
                CustomText(
                  'Add Electricity Bill',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (leadProvider.electricityBillImage.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(
              HttpUrls.imgBaseUrl + leadProvider.electricityBillImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(HttpUrls.imgBaseUrl +
                        leadProvider.electricityBillImage);
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    color: Colors.grey[200],
                    width: 100,
                    height: 100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Open PDF',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(
          height: 8,
        ),
        //cancelled passbook image
        InkWell(
          onTap: () async {
            // Call the addFile method to pick the file
            var fileData = await ImageUploadProvider.addFile();

            if (fileData != null) {
              // Extract file data and name from the result
              Uint8List fileBytes = fileData['data'];

              final fileType = imageUploadProvider.determineFileType(fileBytes);

              // Now, upload the file to AWS
              String? awsFileUrl = await imageUploadProvider.saveToAws(
                  fileBytes,
                  fileType,
                  leadProvider.customerId.toString(),
                  context);

              // If AWS URL is successfully returned, store it in the leadProvider
              if (awsFileUrl != null) {
                leadProvider.cancelledPassBookImage = awsFileUrl;
                print('File uploaded to AWS: $awsFileUrl');
              }
            }
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icon_camera.svg'),
                const SizedBox(
                  height: 6,
                ),
                CustomText(
                  'Add Cancelled Cheque/Passbook',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (leadProvider.cancelledPassBookImage.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(
              HttpUrls.imgBaseUrl + leadProvider.cancelledPassBookImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(HttpUrls.imgBaseUrl +
                        leadProvider.cancelledPassBookImage);
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    color: Colors.grey[200],
                    width: 100,
                    height: 100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Open PDF',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(
          height: 8,
        ),
        //passport size image
        InkWell(
          onTap: () async {
            // Call the addFile method to pick the file
            var fileData = await ImageUploadProvider.addFile();

            if (fileData != null) {
              // Extract file data and name from the result
              Uint8List fileBytes = fileData['data'];

              final fileType = imageUploadProvider.determineFileType(fileBytes);

              // Now, upload the file to AWS
              String? awsFileUrl = await imageUploadProvider.saveToAws(
                  fileBytes,
                  fileType,
                  leadProvider.customerId.toString(),
                  context);

              // If AWS URL is successfully returned, store it in the leadProvider
              if (awsFileUrl != null) {
                leadProvider.passportImage = awsFileUrl;
                print('File uploaded to AWS: $awsFileUrl');
              }
            }
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icon_camera.svg'),
                const SizedBox(
                  height: 6,
                ),
                CustomText(
                  'Add Passport size photo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (leadProvider.passportImage.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(
              HttpUrls.imgBaseUrl + leadProvider.passportImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(
                        HttpUrls.imgBaseUrl + leadProvider.passportImage);
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    color: Colors.grey[200],
                    width: 100,
                    height: 100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Open PDF',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildAddressDetails() {
    final imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        CustomTextfieldWidgetMobile(
          controller: leadProvider.addressController,
          labelText: 'Address',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.addressController.text),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            CustomTextfieldWidgetMobile(
              controller: leadProvider.mapLinkController,
              labelText: 'Map link',
              onChanged: (value) {
                leadProvider.extractCoordinates();
              },
              showError: dropDownProvider.showValidation &&
                  !_isFieldValid(leadProvider.mapLinkController.text),
            ),
            Positioned(
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textBlack),
                    onSelected: (String value) {
                      if (value == 'current') {
                        leadProvider.useCurrentLocation();
                      } else if (value == 'custom') {
                        leadProvider.mapLinkController.text = '';
                        leadProvider.latitudeController.text = '';
                        leadProvider.longitudeController.text = '';
                        leadProvider.extractCoordinates();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'current',
                        child: Text('Use current location'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'custom',
                        child: Text('Custom entry'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextfieldWidgetMobile(
          controller: leadProvider.latitudeController,
          labelText: 'Latitude',
        ),
        const SizedBox(height: 8),
        CustomTextfieldWidgetMobile(
          controller: leadProvider.longitudeController,
          labelText: 'Longitude',
        ),
        const SizedBox(height: 8),
        CustomTextfieldWidgetMobile(
          controller: leadProvider.cityController,
          labelText: 'City',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.cityController.text),
        ),
        const SizedBox(height: 8),
        CommonDropdown<int>(
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
              final selectedEnquiryFor = dropDownProvider.districtList
                  .firstWhere((task) => task.districtId == newValue);
              dropDownProvider.updateDistrict(
                  newValue, selectedEnquiryFor.districtName ?? '');
            }
          },
          selectedValue: dropDownProvider.selectedDistrictId != null &&
                  dropDownProvider.districtList.any((item) =>
                      item.districtId == dropDownProvider.selectedDistrictId)
              ? dropDownProvider.selectedDistrictId
              : null,
        ),
        const SizedBox(height: 8),
        CustomTextfieldWidgetMobile(
          controller: leadProvider.pincodeController,
          labelText: 'Pincode',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.pincodeController.text),
        ),
        const SizedBox(height: 8),
        CustomTextfieldWidgetMobile(
          controller: leadProvider.stateController,
          labelText: 'State',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.stateController.text),
        ),
      ],
    );
  }

  Widget buildCostDetails() {
    final imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextfieldWidgetMobile(
                readOnly: false,
                controller: leadProvider.projectCostController,
                labelText: 'Project Cost',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextfieldWidgetMobile(
                readOnly: false,
                controller: leadProvider.additionalCostControler,
                labelText: 'Additional Cost',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextfieldWidgetMobile(
                readOnly: false,
                controller: leadProvider.advanceAmountController,
                labelText: 'Advance Paid By Customer',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomAutocomplete<AmountPaidThrough>(
                focusNode: amuntPaidNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: leadProvider.leadDropdownData!.amountPaidThrough,
                displayStringFunction: (model) =>
                    model.amountPaidThroughName ?? '',
                defaultText: leadProvider.amountPaidController.text ?? '',
                labelText: 'Amount Paid through',
                controller: leadProvider.amountPaidController,
                onSelected: (AmountPaidThrough selectedTaskType) {
                  leadProvider
                      .setAmountPaidId(selectedTaskType.amountPaidThroughId);

                  final selectedItem = leadProvider
                      .leadDropdownData!.amountPaidThrough
                      .firstWhere(
                    (status) =>
                        status.amountPaidThroughId ==
                        selectedTaskType.amountPaidThroughId,
                  );
                  leadProvider.amountPaidController.text =
                      selectedItem.amountPaidThroughName;
                },
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        CustomAutocomplete<CostInclude>(
          focusNode: costIncludesNode,
          showOptionsOnTap: true,
          optionsViewOpenDirection: OptionsViewOpenDirection.down,
          items: leadProvider.leadDropdownData!.costIncludes,
          displayStringFunction: (model) => model.costIncludesName ?? '',
          defaultText: leadProvider.costIncludesController.text ?? '',
          labelText: 'Cost Includes',
          controller: leadProvider.costIncludesController,
          onSelected: (CostInclude selectedTaskType) {
            leadProvider.setCostIncId(selectedTaskType.costIncludesId);

            final selectedItem =
                leadProvider.leadDropdownData!.costIncludes.firstWhere(
              (status) =>
                  status.costIncludesId == selectedTaskType.costIncludesId,
            );
            leadProvider.costIncludesController.text =
                selectedItem.costIncludesName;
          },
          onChanged: (value) {},
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () async {
            // Call the addFile method to pick the file
            var fileData = await ImageUploadProvider.addFile();

            if (fileData != null) {
              // Extract file data and name from the result
              Uint8List fileBytes = fileData['data'];

              final fileType = imageUploadProvider.determineFileType(fileBytes);

              // Now, upload the file to AWS
              String? awsFileUrl = await imageUploadProvider.saveToAws(
                  fileBytes,
                  fileType,
                  leadProvider.customerId.toString(),
                  context);

              // If AWS URL is successfully returned, store it in the leadProvider
              if (awsFileUrl != null) {
                leadProvider.upiImage = awsFileUrl;
                print('File uploaded to AWS: $awsFileUrl');
              }
            }
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icon_camera.svg'),
                const SizedBox(
                  height: 6,
                ),
                CustomText(
                  'Photo if UPI Transfer',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (leadProvider.upiImage.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(
              HttpUrls.imgBaseUrl + leadProvider.upiImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return GestureDetector(
                  onTap: () async {
                    final Uri url =
                        Uri.parse(HttpUrls.imgBaseUrl + leadProvider.upiImage);
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      print('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    color: Colors.grey[200],
                    width: 100,
                    height: 100,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Open PDF',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildInverterAndPanelDetails() {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        // Row(
        //   children: [
        //     const SizedBox(
        //       height: 10,
        //     ),
        //     Text(
        //       'Invertor Details',
        //       style: GoogleFonts.plusJakartaSans(
        //         color: AppColors.textBlack,
        //         fontSize: 12,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(
        //   height: 10,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomAutocomplete<InverterType>(
                focusNode: inverterTypeNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: leadProvider.leadDropdownData!.inverterType,
                displayStringFunction: (model) => model.inverterTypeName ?? '',
                defaultText: leadProvider.inverterTypeController.text ?? '',
                labelText: 'Inverter Type',
                controller: leadProvider.inverterTypeController,
                onSelected: (InverterType selectedTaskType) {
                  leadProvider.setInverterId(selectedTaskType.inverterTypeId);

                  leadProvider.inverterTypeController.text =
                      selectedTaskType.inverterTypeName ?? '';
                },
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                controller: leadProvider.invertorCapacityController,
                labelText: 'Inverter Capacity',
                keyBoardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        // const SizedBox(height: 8),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(
        //       child: CustomTextfieldWidgetMobile(
        //         focusNode: FocusNode(),
        //         controller: leadProvider.invertorModelController,
        //         labelText: 'Invertor Model',
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //     Expanded(
        //       child: CustomTextfieldWidgetMobile(
        //         focusNode: FocusNode(),
        //         controller: leadProvider.invertorSnController,
        //         labelText: 'Invertor SN',
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 15),
        // Row(
        //   children: [
        //     Text(
        //       'Panel Details',
        //       style: GoogleFonts.plusJakartaSans(
        //         color: AppColors.textBlack,
        //         fontSize: 12,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomAutocomplete<PanelType>(
                focusNode: panelBrandNode,
                showOptionsOnTap: true,
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                items: leadProvider.leadDropdownData!.panelType,
                displayStringFunction: (model) => model.panelTypeName ?? '',
                defaultText: leadProvider.panelBrandController.text ?? '',
                labelText: 'Panel Brand',
                controller: leadProvider.panelBrandController,
                onSelected: (PanelType selectedTaskType) {
                  leadProvider.setPanelId(selectedTaskType.panelTypeId);

                  final selectedItem =
                      leadProvider.leadDropdownData!.panelType.firstWhere(
                    (status) =>
                        status.panelTypeId == selectedTaskType.panelTypeId,
                  );
                  leadProvider.panelBrandController.text =
                      selectedItem.panelTypeName ?? '';
                },
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextfieldWidgetMobile(
                focusNode: FocusNode(),
                controller: leadProvider.panelCapacityController,
                labelText: 'Panel Capacity (in kW)',
                keyBoardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // CustomTextfieldWidgetMobile(
        //   focusNode: FocusNode(),
        //   onTap: () async {
        //     final DateTime? picked = await showDatePicker(
        //       context: context,
        //       initialDate: DateTime.now(),
        //       firstDate: DateTime(2000),
        //       lastDate: DateTime(2101),
        //     );
        //     if (picked != null) {
        //       leadProvider.installationDateController.text =
        //           DateFormat('dd MMM yyyy').format(picked);
        //       // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        //     }
        //   },
        //   readOnly: true,
        //   controller: leadProvider.installationDateController,
        //   labelText: 'Installation Date',
        //   suffixIcon: IconButton(
        //     icon: const Icon(Icons.calendar_today),
        //     onPressed: () async {
        //       final DateTime? picked = await showDatePicker(
        //         context: context,
        //         initialDate: DateTime.now(),
        //         firstDate: DateTime(2000),
        //         lastDate: DateTime(2101),
        //       );
        //       if (picked != null) {
        //         leadProvider.installationDateController.text =
        //             DateFormat('dd MMM yyyy').format(picked);
        //         // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        //       }
        //     },
        //   ),
        // ),
        // const SizedBox(height: 8),
        // Row(
        //   children: [
        //     Text(
        //       "Warrenty",
        //       style: GoogleFonts.plusJakartaSans(
        //         fontSize: 12,
        //         fontWeight: FontWeight.w500,
        //         color: AppColors.textGrey4,
        //       ),
        //     ),
        //     Checkbox(
        //       value: leadProvider.isWarrentyChecked == 1,
        //       onChanged: (bool? value) {
        //         leadProvider
        //             .toggleWarrentyCheckbox(value ?? false);
        //       },
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        // if (leadProvider.isWarrentyChecked == 1)
        //   CustomTextfieldWidgetMobile(
        //     focusNode: FocusNode(),
        //     onTap: () async {
        //       final DateTime? picked = await showDatePicker(
        //         context: context,
        //         initialDate: DateTime.now(),
        //         firstDate: DateTime.now(),
        //         lastDate: DateTime(2101),
        //       );
        //       if (picked != null) {
        //         leadProvider.expiryDateController.text =
        //             DateFormat('dd MMM yyyy').format(picked);
        //         // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        //       }
        //     },
        //     readOnly: true,
        //     controller: leadProvider.expiryDateController,
        //     labelText: 'Expiry Date',
        //     suffixIcon: IconButton(
        //       icon: const Icon(Icons.calendar_today),
        //       onPressed: () async {
        //         final DateTime? picked = await showDatePicker(
        //           context: context,
        //           initialDate: DateTime.now(),
        //           firstDate: DateTime.now(),
        //           lastDate: DateTime(2101),
        //         );
        //         if (picked != null) {
        //           leadProvider.expiryDateController.text =
        //               DateFormat('dd MMM yyyy').format(picked);
        //           // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        //         }
        //       },
        //     ),
        //   ),
        // const SizedBox(height: 8),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(
        //       child: CustomTextfieldWidgetMobile(
        //         focusNode: FocusNode(),
        //         controller: leadProvider.panelSnController,
        //         labelText: 'Panel SN',
        //         keyBoardType: TextInputType.multiline,
        //         minLines: 3,
        //         maxLines: 5,
        //       ),
        //     ),
        //   ],
        // ),
        CustomAutocomplete<Phase>(
          focusNode: phaseNode,
          showOptionsOnTap: true,
          optionsViewOpenDirection: OptionsViewOpenDirection.down,
          items: leadProvider.leadDropdownData!.phase,
          displayStringFunction: (model) => model.phaseName ?? '',
          defaultText: leadProvider.panelPhaseController.text ?? '',
          labelText: 'Panel Phase',
          controller: leadProvider.panelPhaseController,
          onSelected: (Phase selectedTaskType) {
            leadProvider.setPhaseId(selectedTaskType.phaseId);

            final selectedItem =
                leadProvider.leadDropdownData!.phase.firstWhere(
              (status) => status.phaseId == selectedTaskType.phaseId,
            );
            leadProvider.panelPhaseController.text =
                selectedItem.phaseName ?? '';
          },
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget buildBasicDetails() {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final leadDetailsProvider =
        Provider.of<LeadDetailsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    return Column(
      children: [
        CustomTextfieldWidgetMobile(
          // height: 54,
          controller: leadProvider.leadNameController,
          labelText: 'Lead Name *',
          // labelText: '',
          focusNode: _leadNameFocusNode,
          // showError: dropDownProvider.showValidation &&
          //     !_isFieldValid(leadProvider.leadNameController.text),
        ),
        const SizedBox(
          height: 10,
        ),

        CommonDropdown<int>(
          hintText: 'Source*',
          items: settingsProvider.searchSourceCategory
              .map((source) => DropdownItem<int>(
                    id: source.sourceId,
                    name: source.sourceName ?? '',
                  ))
              .toList(),
          controller: leadProvider.sourceCategoryController,
          onItemSelected: (selectedId) {
            dropDownProvider.setSourceCategoryId(selectedId);
            final selectedItem = settingsProvider.searchSourceCategory
                .firstWhere((source) => source.sourceId == selectedId);
            leadProvider.sourceCategoryController.text =
                selectedItem.sourceName ?? '';
            // dropDownProvider
            //     .setSelectedEnquirySourceId(-1);
            // leadProvider.enquirySourceController
            //     .clear();
            // dropDownProvider
            //     .filterEnquirySourcesByCategory(
            //         selectedId);
            dropDownProvider.updateEnquiryForName(0, '');
            leadProvider.enquiryForController.clear();

            dropDownProvider.filterEnquiryForByCategory(selectedId);
          },
          selectedValue: dropDownProvider.selectedSourceId,
        ),
        const SizedBox(
          height: 10,
        ),

        if (dropDownProvider.selectedSourceId != null &&
            dropDownProvider.selectedSourceId! > 0)
          CommonDropdown<int>(
            hintText: 'Enquiry Source*',
            items: dropDownProvider.enquiryData
                .map((source) => DropdownItem<int>(
                      id: source.enquirySourceId,
                      name: source.enquirySourceName ?? '',
                    ))
                .toList(),
            controller: leadProvider.enquirySourceController,
            onItemSelected: (selectedId) {
              dropDownProvider.setSelectedEnquirySourceId(selectedId);
              final selectedItem = dropDownProvider.enquiryData
                  .firstWhere((source) => source.enquirySourceId == selectedId);

              leadProvider.enquirySourceController.text =
                  selectedItem.enquirySourceName ?? '';
            },
            selectedValue: dropDownProvider.selectedEnquirySourceId,
          ),

        const SizedBox(
          height: 10,
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📱 Phone TextField
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: leadProvider.contactNoController,
                builder: (context, value, child) {
                  final isValid = value.text.length == 10;

                  return CustomTextField(
                    controller: leadProvider.contactNoController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      if (validatePhone) LengthLimitingTextInputFormatter(10),
                    ],
                    hintText: 'Mobile No*',
                    labelText: '',
                    height: 54,
                    suffixIcon: validatePhone
                        ? Icon(
                            isValid ? Icons.check_circle : Icons.cancel,
                            color: isValid ? Colors.green : Colors.red,
                          )
                        : null,
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            // ☑️ Validation Checkbox
            Tooltip(
              message: "Enable to validate phone number",
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

        const SizedBox(height: 10),

        CommonDropdown<int>(
          hintText: 'Enquiry For*',
          enabled: dropDownProvider.selectedSourceId != null,
          items: dropDownProvider.filteredEnquiryForData
              .map((status) => DropdownItem<int>(
                    id: status.enquiryForId,
                    name: status.enquiryForName,
                  ))
              .toList(),
          controller: leadProvider.enquiryForController,
          onItemSelected: (int? newValue) {
            if (newValue != null) {
              final selectedEnquiryFor = dropDownProvider.filteredEnquiryForData
                  .firstWhere((task) => task.enquiryForId == newValue);
              dropDownProvider.updateEnquiryForName(
                  newValue, selectedEnquiryFor.enquiryForName);
              leadProvider.customFieldEnquiryFor.clear();
              leadProvider.getCustomFieldsByEnquiryForId(
                context,
                leadId: widget.isEdit ? leadProvider.customerId : 0,
                enquiryForId: newValue,
              );
            }
          },
          selectedValue: dropDownProvider.selectedEnquiryForId,
        ),
        const SizedBox(
          height: 10,
        ),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          controller: leadProvider.referenceNameController,
          labelText: 'Sub Source',
        ),
        const SizedBox(
          height: 10,
        ),
        // if (dropDownProvider.selectedEnquiryForId != null &&
        //     dropDownProvider.selectedEnquiryForId != 0)
        //   // customFieldSection(),
        //   if (leadProvider.isLoadingEnquiryCustomFields)
        //     const Center(child: CircularProgressIndicator())
        //   else if (leadProvider.customFieldEnquiryFor.isNotEmpty)
        //     CustomFieldSectionWidget(
        //       controllerKey: CustomFieldControllerkey.enquirySource.value,
        //       key: customFieldEnquirySourceKey,

        //       initialFieldValues: widget.isEdit
        //           ? leadProvider.customFieldEnquiryFor
        //               .map((e) => FieldValueModel(
        //                   customFieldId: e.customFieldId, value: e.datavalue))
        //               .toList()
        //           : [],
        //       onFieldValuesChanged: (p0) {},
        //       customFields: leadProvider.customFieldEnquiryFor,
        //       initialValues: const {}, // Pre-fill if editing
        //     ),
        if (dropDownProvider.selectedEnquiryForId != null &&
            dropDownProvider.selectedEnquiryForId != 0)
          if (leadProvider.isLoadingEnquiryCustomFields)
            const Center(child: CircularProgressIndicator())
          else if (leadProvider.customFieldEnquiryFor.isNotEmpty)
            // Use Consumer to rebuild only when custom field values change
            Consumer<LeadsProvider>(
              builder: (context, provider, child) {
                return CustomFieldSectionWidget(
                  controllerKey: CustomFieldControllerkey.enquirySource.value,
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
                                  .getCustomFieldValue(e.customFieldId ?? 0)))
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
                  customFields: leadProvider.customFieldEnquiryFor,
                  initialValues: const {},
                );
              },
            ),
        // CustomAutocomplete<UserStatusType>(
        //   focusNode: leadTypeNode,
        //   showOptionsOnTap: true,
        //   optionsViewOpenDirection: OptionsViewOpenDirection.down,
        //   items: UserStatusType.values,
        //   displayStringFunction: (model) => model.name,
        //   defaultText: dropDownProvider.selectedEnquiryForName,
        //   labelText: 'Lead type',
        //   controller: leadProvider.leadtypeController,
        //   onSelected: (UserStatusType selectedItem) {
        //     dropDownProvider.setSelectedleadtypeUserId(selectedItem.value);
        //     leadProvider.leadtypeController.text = selectedItem.name;
        //     dropDownProvider.notifyListeners();
        //   },
        // ),
      ],
    );
  }
}
