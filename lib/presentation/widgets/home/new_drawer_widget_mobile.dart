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
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/save_lead_dropdown_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/home/add_quotation_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/searchable_bottom_sheet_dropdown.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_enquiry_for_widget.dart';
import 'package:vidyanexis/presentation/pages/settings/add_enquiry_for_mobile_page.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_new_enquiry_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_new_status_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_custom_field.dart';

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

  ScrollController scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final GlobalKey _basicDetailsKey = GlobalKey();
  final GlobalKey _addressDetailsKey = GlobalKey();
  final GlobalKey _additionalDetailsKey = GlobalKey();
  final GlobalKey _followupDetailsKey = GlobalKey();
  bool _isScrollingProgrammatically = false;
  final Map<int, bool> _expandedSections = {0: true, 5: true};
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

  int expandedIndex = 0; // Default to the first tab being active
  bool _isProcessingClick = false;
  bool validatePhone = false;
  DateTime? originalFollowUpDate;
  bool showAmountForMain = false;
  bool showAmountForSecondary = false;
  bool get showAmount => showAmountForMain || showAmountForSecondary;
  bool showTransferStatus = false;
  bool showTime = false;
  bool showDate = false;
  bool showTransfer = false;
  List<SearchLeadStatusModel> _filteredTransferStatuses = [];
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
        landmark: leadProvider.landmarkController.text,
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
        departmentId: settingsProvider.selectedDepartmentId,
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
        leadtypeName: leadProvider.leadtypeController.text,
        locationId: dropDownProvider.selectedLocationId,
        workCompletionDate: leadProvider.workCompletionDateController.text);
  }

  bool _validateForm(
      LeadsProvider leadProvider, DropDownProvider dropDownProvider) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    String? errorMessage;
    int? errorTab;
    final validation = customFieldLeadStatusKey.currentState?.validateForm();
    final validation2 =
        customFieldEnquirySourceKey.currentState?.validateForm();

    if (leadProvider.contactNoController.text.isEmpty) {
      errorMessage = 'Mobile number is required';
      errorTab = 0;
    } else if (validatePhone &&
        leadProvider.contactNoController.text.length != 10) {
      errorMessage = 'Mobile number must be 10 digits';
      errorTab = 0;
    } else if (leadProvider.followUpStatusController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Follow-up Status';
      errorTab = 3;
    } else if (leadProvider.branchController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Branch';
      errorTab = 3;
    } else if (leadProvider.departmentController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Department';
      errorTab = 3;
    } else if (leadProvider.searchUserController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please Assign Staff';
      errorTab = 3;
    } else if (settingsProvider.companyDetails.isNotEmpty &&
        settingsProvider.companyDetails[0].districtCityMandatory == 1 &&
        (dropDownProvider.selectedDistrictId == null ||
            dropDownProvider.selectedDistrictId == 0)) {
      errorMessage = 'Please select District';
      errorTab = 0;
    } else if (settingsProvider.companyDetails.isNotEmpty &&
        settingsProvider.companyDetails[0].districtCityMandatory == 1 &&
        (settingsProvider.menuIsViewMap[146] ?? 0) == 1 &&
        leadProvider.cityController.text.isEmpty) {
      errorMessage = 'Place is required';
      errorTab = 0;
    } else if (settingsProvider.enquiryForMandatory == 1 &&
        (dropDownProvider.selectedEnquiryForId == null ||
            dropDownProvider.selectedEnquiryForId == 0) &&
        widget.isEdit == false) {
      errorMessage = 'Please select Enquiry For';
      errorTab = 0;
    } else if (settingsProvider.enquirySourceMandatory == 1 &&
        (dropDownProvider.selectedEnquirySourceId == null ||
            dropDownProvider.selectedEnquirySourceId == 0) &&
        widget.isEdit == false) {
      errorMessage = 'Please select Enquiry Source';
      errorTab = 0;
    } else if (dropDownProvider.isFollowupRequired() &&
        leadProvider.followUpDateController.text.isEmpty &&
        widget.isEdit == false) {
      errorMessage = 'Please select Follow-up Date';
      errorTab = 3;
    } else if (validation?.isValid == false) {
      errorMessage = 'Please Enter mandatory fields';
      errorTab = 3;
    } else if (validation2?.isValid == false) {
      errorMessage = 'Please Enter mandatory fields';
      errorTab = 0;
    }

    if (errorMessage != null) {
      final tabsCount = widget.isEdit ? 3 : 4;
      if (errorTab != null && errorTab < tabsCount) {
        GlobalKey? targetKey;
        if (errorTab == 0) targetKey = _basicDetailsKey;
        else if (errorTab == 1) targetKey = _addressDetailsKey;
        else if (errorTab == 2) targetKey = _additionalDetailsKey;
        else if (errorTab == 3) targetKey = _followupDetailsKey;

        if (targetKey != null) {
          _scrollToSection(targetKey, errorTab);
        }
      }

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
    leadProvider.clearCustomFieldEnquiryFor();

    // Restore unfiltered master lists so that list page lookup remains fully populated
    dropDownProvider.getEnquirySource(context, fetchUserSpecific: false);
    dropDownProvider.getEnquiryFor(context, fetchUserSpecific: false);
  }

  late CustomFieldWidgetBuilder widgetBuilder;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
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
      if (widget.isEdit) {
        if (leadProvider.followUpDateController.text.isNotEmpty) {
          try {
            originalFollowUpDate = DateFormat('dd MMM yyyy')
                .parse(leadProvider.followUpDateController.text);
          } catch (_) {
            try {
              originalFollowUpDate =
                  DateTime.parse(leadProvider.followUpDateController.text);
            } catch (_) {}
          }
        }
      } else {
        originalFollowUpDate = DateTime.now();
      }

      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.getCompanyDetails();
      await leadProvider.loadLoginDetails();

      // Load branch and department data if not already cached
      await settingsProvider.searchBranch(context);
      await settingsProvider.searchDepartment('', context);

      await dropDownProvider.getEnquirySource(context, fetchUserSpecific: true);
      await dropDownProvider.getEnquiryFor(context, fetchUserSpecific: true);
      await settingsProvider.getPriorities(context);
      await dropDownProvider.getFollowUpStatus(context, "1", forceRefresh: true);

      // CRITICAL: Await getUserDetails so filteredStaffData is never empty
      await dropDownProvider.getUserDetails(context);

      if (widget.isEdit) {
        leadProvider.getCustomFieldsByEnquiryForId(
          context,
          enquiryForId: dropDownProvider.selectedEnquiryForId ?? 0,
          leadId: leadProvider.customerId,
        );
      } else {
        leadProvider.clearAllLeadControllers(context);

        // After priorities are loaded
        if (settingsProvider.priorities.isNotEmpty) {
          final first = settingsProvider.priorities.first;
          leadProvider.priorityId = first.priorityId;
          leadProvider.priorityNameController.text = first.priorityName;
        }

        // Set default follow-up status to first available status with isCreateNew == 1 in dropdown
        final createNewStatuses = dropDownProvider.followUpData
            .where((s) => s.isCreateNew == 1)
            .toList();
        final availableStatuses = widget.isEdit
            ? dropDownProvider.followUpData
            : (createNewStatuses.isNotEmpty
                ? createNewStatuses
                : dropDownProvider.followUpData);

        int defaultDeptId = leadProvider.loginDepartmentId;
        String defaultDeptName = leadProvider.loginDepartmentName;

        if (availableStatuses.isNotEmpty) {
          final firstStatus = availableStatuses.first;
          if (firstStatus.statusId != null) {
            dropDownProvider.setSelectedFollowUPId(firstStatus.statusId);
            leadProvider.followUpStatusController.text =
                firstStatus.statusName ?? '';

            // Also trigger custom fields for this status if needed
            leadProvider.getCustomFieldsByStatusId(
              context,
              leadId: 0,
              statusId: firstStatus.statusId!,
            );

            final transferStatusesData = await settingsProvider
                .getTransferStatusById(context, firstStatus.statusId.toString());
            final statusData = await settingsProvider
                .getStatusById(context, firstStatus.statusId.toString());

            bool mainHasAmount = (statusData.isNotEmpty &&
                    statusData.first.isAmount == 1) ||
                (transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.isAmount == 1);

            if (mounted) {
              setState(() {
                showAmountForMain = mainHasAmount;
                showAmountForSecondary = false;
                showTransferStatus = transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.isTransferStatus == 1;
                showTime = transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.isTime == 1;
                showDate = transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.isShowFollowupDate == 1;
                showTransfer = transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.isTransfer == 1;
                _filteredTransferStatuses = transferStatusesData.isNotEmpty
                    ? transferStatusesData.first.transferStatuses
                            ?.map((s) => SearchLeadStatusModel(
                                  statusId: s.subStatusId,
                                  statusName: s.subStatusName,
                                ))
                            .toList() ??
                        []
                    : [];
              });
            }

            if (transferStatusesData.isNotEmpty &&
                transferStatusesData.first.departmentId != null &&
                transferStatusesData.first.departmentId != 0) {
              defaultDeptId = transferStatusesData.first.departmentId!;
              defaultDeptName =
                  transferStatusesData.first.departmentName ?? '';
            } else if (firstStatus.departmentId != null &&
                firstStatus.departmentId != 0) {
              defaultDeptId = firstStatus.departmentId!;
              defaultDeptName = firstStatus.departmentName ?? '';
            }
          }
        } else {
          dropDownProvider.setSelectedFollowUPId(0);
          leadProvider.followUpStatusController.clear();
        }

        // Populate defaults
        leadProvider.branchController.text = leadProvider.loginBranchName;
        leadProvider.departmentController.text = defaultDeptName;
        leadProvider.followUpDateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());

        settingsProvider.selectedBranchId = leadProvider.loginBranchId;
        settingsProvider.setSelectedDepartmentId(defaultDeptId);

        // Filter staff by department and branch
        await dropDownProvider.fetchStaffByDepartment(
          context: context,
          branchId: leadProvider.loginBranchId,
          departmentId: defaultDeptId,
        );

        // Set inside value in assigned staff dropdown
        if (dropDownProvider.filteredStaffData
            .any((s) => s.userDetailsId == leadProvider.loginUserId)) {
          dropDownProvider.setSelectedUserId(leadProvider.loginUserId);
          leadProvider.searchUserController.text = leadProvider.loginUserName;
        } else if (dropDownProvider.filteredStaffData.isNotEmpty) {
          final firstStaff = dropDownProvider.filteredStaffData.first;
          dropDownProvider.setSelectedUserId(firstStaff.userDetailsId);
          leadProvider.searchUserController.text = firstStaff.userDetailsName;
        } else {
          dropDownProvider.setSelectedUserId(0);
          leadProvider.searchUserController.clear();
        }

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
          leadProvider.clearCustomFieldEnquiryFor();
          leadProvider.getCustomFieldsByEnquiryForId(
            context,
            leadId: widget.isEdit ? (leadProvider.customerId ?? 0) : 0,
            enquiryForId: defaultEnquiryForId,
          );
        }
      }
      dropDownProvider.getLocations(context);

      if (widget.isEdit &&
          settingsProvider.selectedDepartmentId != null &&
          settingsProvider.selectedDepartmentId != 0 &&
          widget.customerId != null &&
          widget.customerId.isNotEmpty &&
          widget.customerId != '0') {
        dropDownProvider.fetchAndSetAssignedUser(
          context: context,
          leadId: widget.customerId,
          branchId: settingsProvider.selectedBranchId,
          departmentId: settingsProvider.selectedDepartmentId,
          leadProvider: leadProvider,
        );
      }
      // widgetBuilder = CustomFieldWidgetBuilder(context);
    });
  }

  void _showAllEnquirySourcesBottomSheet(
      BuildContext context,
      DropDownProvider dropDownProvider,
      LeadsProvider leadProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredList = dropDownProvider.enquiryData.where((source) {
              final name = source.enquirySourceName?.toLowerCase() ?? '';
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Enquiry Source',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search TextField
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search enquiry source...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final source = filteredList[index];
                        final isSelected =
                            dropDownProvider.selectedEnquirySourceId ==
                                source.enquirySourceId;
                        return ListTile(
                          title: Text(
                            source.enquirySourceName ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.bluebutton
                                  : AppColors.textBlack,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: AppColors.bluebutton)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            dropDownProvider.setSelectedEnquirySourceId(
                                source.enquirySourceId);
                            leadProvider.enquirySourceController.text =
                                source.enquirySourceName ?? '';
                            Navigator.pop(context);
                            // Also trigger rebuild on parent widget
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onScroll() {
    if (_isScrollingProgrammatically) return;

    final List<Map<String, dynamic>> sections = [
      {'key': _basicDetailsKey},
      {'key': _addressDetailsKey},
      {'key': _additionalDetailsKey},
      if (!widget.isEdit) {'key': _followupDetailsKey},
    ];

    int activeIndex = 0;
    final threshold = MediaQuery.of(context).padding.top + kToolbarHeight + 60;

    for (int i = sections.length - 1; i >= 0; i--) {
      final key = sections[i]['key'] as GlobalKey;
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          if (position.dy <= threshold) {
            activeIndex = i;
            break;
          }
        }
      }
    }

    if (activeIndex != expandedIndex) {
      setState(() {
        expandedIndex = activeIndex;
      });
      _scrollToHeader(activeIndex);
    }
  }

  void _scrollToHeader(int index) {
    if (_headerScrollController.hasClients) {
      _headerScrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSection(GlobalKey key, int index) {
    setState(() {
      expandedIndex = index;
      _isScrollingProgrammatically = true;
    });

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _isScrollingProgrammatically = false;
        });
      });
    } else {
      _isScrollingProgrammatically = false;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required GlobalKey key,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bluebutton.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.bluebutton,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _leadNameFocusNode.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  Widget _buildTabsHeader(List<Map<String, dynamic>> tabs) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        controller: _headerScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = expandedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 6, top: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                _scrollToSection(tabs[index]['key'] as GlobalKey, index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bluebutton : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.bluebutton.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tabs[index]['title'],
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? Colors.white : AppColors.textGrey3,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveLead,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluebutton,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.isEdit ? 'Save Changes' : 'Save Lead',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {
        'title': 'Basic details',
        'key': _basicDetailsKey,
        'widget': buildBasicDetails(),
      },
      {
        'title': 'Address',
        'key': _addressDetailsKey,
        'widget': buildAddressDetails(),
      },
      {
        'title': 'Additional details',
        'key': _additionalDetailsKey,
        'widget': buildAdditionalDetails(),
      },
      if (!widget.isEdit)
        {
          'title': 'Follow-up Details',
          'key': _followupDetailsKey,
          'widget': buildFollowupDetails(),
        },
    ];

    // Safety check for tab range
    if (expandedIndex >= tabs.length) {
      expandedIndex = 0;
    }

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final displayLogo = settingsProvider.displayLogo;

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
              ],
            ),
            actions: const [],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabsHeader(tabs),
              ),
            ),
          ),
          body: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          _buildSection(
                            title: 'Basic details',
                            icon: Icons.assignment_outlined,
                            key: _basicDetailsKey,
                            child: buildBasicDetails(),
                          ),
                          _buildSection(
                            title: 'Address',
                            icon: Icons.location_on_outlined,
                            key: _addressDetailsKey,
                            child: buildAddressDetails(),
                          ),
                          _buildSection(
                            title: 'Additional details',
                            icon: Icons.add_circle_outline,
                            key: _additionalDetailsKey,
                            child: buildAdditionalDetails(),
                          ),
                          if (!widget.isEdit)
                            _buildSection(
                              title: 'Follow-up Details',
                              icon: Icons.event_note_outlined,
                              key: _followupDetailsKey,
                              child: buildFollowupDetails(),
                            ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomNavigation(),
              ],
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
            SearchableBottomSheetDropdown<int>(
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

                if (selectedId != null) {
                  // Update the controller text with the selected branch name
                  final selectedBranch = settingsProvider.branchModel
                      .firstWhere((branch) => branch.branchId == selectedId);
                  leadProvider.branchController.text =
                      selectedBranch.branchName ?? '';
                } else {
                  leadProvider.branchController.clear();
                }

                // Clear department and staff selections when branch changes
                settingsProvider.setSelectedDepartmentId(0);
                leadProvider.departmentController.clear();
                dropDownProvider.setSelectedUserId(0);
                leadProvider.searchUserController.clear();

                // Filter staff based on new branch selection
                dropDownProvider.fetchStaffByDepartment(
                  context: context,
                  branchId: selectedId,
                  departmentId: null,
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            SearchableBottomSheetDropdown<int>(
              hintText: 'Department*',
              selectedValue: settingsProvider.selectedDepartmentId,
              items: settingsProvider.departmentModel
                  .map((source) => DropdownItem<int>(
                        id: source.departmentId,
                        name: source.departmentName ?? '',
                      ))
                  .toList(),
              controller: leadProvider.departmentController,
              onItemSelected: (selectedId) async {
                settingsProvider.selectedDepartmentId = selectedId;
                if (selectedId != null) {
                  // Update the controller text with the selected department name
                  final selectedDepartment =
                      settingsProvider.departmentModel.firstWhere(
                    (dept) => dept.departmentId == selectedId,
                    orElse: () => DepartmentModel(
                        departmentId: selectedId, departmentName: ''),
                  );
                  leadProvider.departmentController.text =
                      selectedDepartment.departmentName ?? '';
                } else {
                  leadProvider.departmentController.clear();
                }

                // Filter staff based on both branch and department
                await dropDownProvider.fetchStaffByDepartment(
                  context: context,
                  branchId: settingsProvider.selectedBranchId,
                  departmentId: selectedId,
                );

                if (dropDownProvider.filteredStaffData.any((s) => s.userDetailsId == leadProvider.loginUserId)) {
                  dropDownProvider.setSelectedUserId(leadProvider.loginUserId);
                  leadProvider.searchUserController.text = leadProvider.loginUserName;
                } else if (dropDownProvider.filteredStaffData.isNotEmpty) {
                  final firstStaff = dropDownProvider.filteredStaffData.first;
                  dropDownProvider.setSelectedUserId(firstStaff.userDetailsId);
                  leadProvider.searchUserController.text = firstStaff.userDetailsName;
                } else {
                  dropDownProvider.setSelectedUserId(0);
                  leadProvider.searchUserController.clear();
                }

                if (widget.customerId != null &&
                    widget.customerId.isNotEmpty &&
                    widget.customerId != '0') {
                  dropDownProvider.fetchAndSetAssignedUser(
                    context: context,
                    leadId: widget.customerId,
                    branchId: settingsProvider.selectedBranchId,
                    departmentId: selectedId,
                    leadProvider: leadProvider,
                  );
                }
                if (mounted) setState(() {});
              },
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: SearchableBottomSheetDropdown<int>(
                    hintText: 'Follow-up Status*',
                    items: dropDownProvider.followUpData
                        .where(
                            (status) => widget.isEdit ? true : status.isCreateNew == 1)
                        .map((status) => DropdownItem<int>(
                              id: status.statusId ?? 0,
                              name: status.statusName ?? '',
                            ))
                        .toList(),
                    controller: leadProvider.followUpStatusController,
                    onItemSelected: (selectedId) async {
                      dropDownProvider.setSelectedFollowUPId(selectedId);
                      // Update the controller text
                      leadProvider.customFieldList.clear();
                      if (selectedId != null) {
                        leadProvider.getCustomFieldsByStatusId(context,
                            leadId: widget.isEdit ? leadProvider.customerId : 0,
                            statusId: selectedId);
                        final selectedStatus = dropDownProvider.followUpData
                            .firstWhere((status) => status.statusId == selectedId,
                                orElse: () => SearchLeadStatusModel(
                                    statusId: selectedId, statusName: ''));
                        leadProvider.followUpStatusController.text =
                            selectedStatus.statusName ?? '';
                        if (selectedStatus.isShowFollowupDate == 1) {
                          int durationVal =
                              int.tryParse(selectedStatus.statusDuration ?? '') ??
                                  0;
                          DateTime baseDate =
                              originalFollowUpDate ?? DateTime.now();
                          DateTime targetDate =
                              baseDate.add(Duration(days: durationVal));
                          leadProvider.followUpDateController.text =
                              DateFormat('dd MMM yyyy').format(targetDate);
                        } else {
                          leadProvider.followUpDateController.clear();
                        }

                        final statusData = await settingsProvider.getStatusById(
                            context, selectedId.toString());
                        final transferStatusesData = await settingsProvider
                            .getTransferStatusById(context, selectedId.toString());

                        bool mainHasAmount =
                            (statusData.isNotEmpty && statusData.first.isAmount == 1) ||
                                (transferStatusesData.isNotEmpty &&
                                    transferStatusesData.first.isAmount == 1);

                        int? statusDeptId;
                        String? statusDeptName;
                        if (transferStatusesData.isNotEmpty &&
                            transferStatusesData.first.departmentId != null &&
                            transferStatusesData.first.departmentId != 0) {
                          statusDeptId = transferStatusesData.first.departmentId;
                          statusDeptName = transferStatusesData.first.departmentName;
                        } else if (selectedStatus.departmentId != null &&
                            selectedStatus.departmentId != 0) {
                          statusDeptId = selectedStatus.departmentId;
                          statusDeptName = selectedStatus.departmentName;
                        }

                        if (statusDeptId != null && statusDeptId != 0) {
                          settingsProvider.selectedDepartmentId = statusDeptId;
                          leadProvider.departmentController.text = statusDeptName ?? '';

                          await dropDownProvider.fetchStaffByDepartment(
                            context: context,
                            branchId: settingsProvider.selectedBranchId,
                            departmentId: statusDeptId,
                          );

                          if (dropDownProvider.filteredStaffData.any((s) => s.userDetailsId == leadProvider.loginUserId)) {
                            dropDownProvider.setSelectedUserId(leadProvider.loginUserId);
                            leadProvider.searchUserController.text = leadProvider.loginUserName;
                          } else if (dropDownProvider.filteredStaffData.isNotEmpty) {
                            final firstStaff = dropDownProvider.filteredStaffData.first;
                            dropDownProvider.setSelectedUserId(firstStaff.userDetailsId);
                            leadProvider.searchUserController.text = firstStaff.userDetailsName;
                          } else {
                            dropDownProvider.setSelectedUserId(0);
                            leadProvider.searchUserController.clear();
                          }
                        }

                        if (mounted) {
                          setState(() {
                            showAmountForMain = mainHasAmount;
                            showAmountForSecondary = false;
                            showTransferStatus = transferStatusesData.isNotEmpty &&
                                transferStatusesData.first.isTransferStatus == 1;
                            showTime = transferStatusesData.isNotEmpty &&
                                transferStatusesData.first.isTime == 1;
                            showDate = transferStatusesData.isNotEmpty &&
                                transferStatusesData.first.isShowFollowupDate == 1;
                            showTransfer = transferStatusesData.isNotEmpty &&
                                transferStatusesData.first.isTransfer == 1;
                            _filteredTransferStatuses = transferStatusesData.isNotEmpty
                                ? transferStatusesData.first.transferStatuses
                                        ?.map((s) => SearchLeadStatusModel(
                                              statusId: s.subStatusId,
                                              statusName: s.subStatusName,
                                            ))
                                        .toList() ??
                                    []
                                : [];
                          });
                        }
                      } else {
                        leadProvider.followUpStatusController.clear();
                        leadProvider.followUpDateController.clear();
                        if (mounted) {
                          setState(() {
                            showAmountForMain = false;
                            showAmountForSecondary = false;
                            showTransferStatus = false;
                            showTime = false;
                            showDate = false;
                            showTransfer = false;
                            _filteredTransferStatuses = [];
                          });
                        }
                      }
                    },
                    selectedValue: dropDownProvider.selectedFollowUpId,
                  ),
                ),
                IconButton(
                  tooltip: "Add Followup Status",
                  icon: Icon(Icons.add_circle, color: AppColors.primaryViolet),
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AddNewStatusWidget(
                          editId: '0',
                          followUp: '',
                          isEdit: false,
                          status: '',
                          isRegister: '',
                          colorCode: '',
                        );
                      },
                    ).then((value) {
                      if (context.mounted) {
                        dropDownProvider.getFollowUpStatus(context, "1");
                      }
                    });
                  },
                ),
              ],
            ),
            if (showTransferStatus && _filteredTransferStatuses.isNotEmpty) ...[
              const SizedBox(height: 10),
              SearchableBottomSheetDropdown<int>(
                hintText: 'Secondary Status',
                items: _filteredTransferStatuses
                    .where((status) => status.statusId != null)
                    .map((status) => DropdownItem<int>(
                          id: status.statusId!,
                          name: status.statusName ?? '',
                        ))
                    .toList(),
                controller: leadProvider.transferStatusController,
                onItemSelected: (selectedId) async {
                  dropDownProvider.setSelectedTransferStatusId(selectedId);
                  if (selectedId != null) {
                    final selectedItem = _filteredTransferStatuses.firstWhere(
                      (status) => status.statusId == selectedId,
                      orElse: () => SearchLeadStatusModel(
                          statusId: selectedId, statusName: ''),
                    );
                    leadProvider.transferStatusController.text =
                        selectedItem.statusName ?? '';
                    final statusData = await settingsProvider.getStatusById(
                        context, selectedId.toString());
                    final transferStatusesData = await settingsProvider
                        .getTransferStatusById(context, selectedId.toString());

                    bool secondaryHasAmount = (statusData.isNotEmpty &&
                            statusData.first.isAmount == 1) ||
                        (transferStatusesData.isNotEmpty &&
                            transferStatusesData.first.isAmount == 1);

                    if (mounted) {
                      setState(() {
                        showAmountForSecondary = secondaryHasAmount;
                      });
                    }
                  } else {
                    leadProvider.transferStatusController.clear();
                    if (mounted) {
                      setState(() {
                        showAmountForSecondary = false;
                      });
                    }
                  }
                },
                selectedValue: dropDownProvider.selectedTransferStatusId ?? 0,
              ),
            ],
            if (showAmount) ...[
              const SizedBox(height: 10),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: leadProvider.followupAmountController,
                hintText: 'Amount',
                labelText: '',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
              ),
            ],

            SizedBox(
              height: 10,
            ),
            SearchableBottomSheetDropdown<int>(
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

                if (selectedId != null) {
                  // Update the controller text with the selected staff name
                  final selectedStaff = dropDownProvider.filteredStaffData
                      .firstWhere((staff) => staff.userDetailsId == selectedId);
                  leadProvider.searchUserController.text =
                      selectedStaff.userDetailsName;
                } else {
                  leadProvider.searchUserController.clear();
                }
              },
              selectedValue: dropDownProvider.selectedUserId,
              // Disable if branch or department is not selected
              enabled: settingsProvider.selectedBranchId != null,
            ),
            if (dropDownProvider.selectedFollowUpId != null &&
                dropDownProvider.selectedFollowUpId != 0)
              // customFieldSection(),
              Consumer<LeadsProvider>(
                builder: (context, leadProvider, child) {
                  if (leadProvider.isLoadingCustomFields) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (leadProvider.customFieldList.isNotEmpty) {
                    return CustomFieldSectionWidget(
                      showEditButton: true,
                      controllerKey: CustomFieldControllerkey.leadStatus.value,
                      key: customFieldLeadStatusKey,
                      showMore: false,
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
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
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
        SearchableBottomSheetDropdown<int>(
          hintText: 'Work Type',
          items: leadProvider.leadDropdownData!.workType
              .map((item) => DropdownItem<int>(
                    id: item.workTypeId,
                    name: item.workTypeName ?? '',
                  ))
              .toList(),
          controller: leadProvider.workTypeController,
          selectedValue: leadProvider.selectedWorkTypeId,
          onItemSelected: (selectedId) {
            if (selectedId != null) {
              leadProvider.setWorkTypeId(selectedId);
              final selectedItem = leadProvider.leadDropdownData!.workType
                  .firstWhere((item) => item.workTypeId == selectedId);
              leadProvider.workTypeController.text =
                  selectedItem.workTypeName ?? '';
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        SearchableBottomSheetDropdown<int>(
          hintText: 'Roof Type',
          items: leadProvider.leadDropdownData!.roofType
              .map((item) => DropdownItem<int>(
                    id: item.roofTypeId,
                    name: item.roofTypeName ?? '',
                  ))
              .toList(),
          controller: leadProvider.roofTypeController,
          selectedValue: leadProvider.selectedRoofId,
          onItemSelected: (selectedId) {
            if (selectedId != null) {
              leadProvider.setRoofTypeId(selectedId);
              final selectedItem = leadProvider.leadDropdownData!.roofType
                  .firstWhere((item) => item.roofTypeId == selectedId);
              leadProvider.roofTypeController.text =
                  selectedItem.roofTypeName ?? '';
            }
          },
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: false,
          controller: leadProvider.additionalCostControler,
          labelText: 'Any Additional Comments',
        ),
        const SizedBox(height: 10),
        CustomTextfieldWidgetMobile(
          focusNode: FocusNode(),
          readOnly: true,
          controller: leadProvider.workCompletionDateController,
          labelText: 'Work Completion Date',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                leadProvider.workCompletionDateController.text =
                    DateFormat('dd MMM yyyy').format(picked);
                leadProvider.installationDateController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              leadProvider.workCompletionDateController.text =
                  DateFormat('dd MMM yyyy').format(picked);
              leadProvider.installationDateController.text =
                  DateFormat('dd MMM yyyy').format(picked);
            }
          },
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
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
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
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Column(
      children: [
        CustomTextfieldWidgetMobile(
          controller: leadProvider.addressController,
          labelText: 'Address',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.addressController.text),
        ),
        if (settingsProvider.menuIsViewMap[160] == 1) ...[
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
        ],
        if (settingsProvider.menuIsViewMap[158] == 1) ...[
          const SizedBox(height: 8),
          CustomTextfieldWidgetMobile(
            controller: leadProvider.latitudeController,
            labelText: 'Latitude',
          ),
        ],
        if (settingsProvider.menuIsViewMap[159] == 1) ...[
          const SizedBox(height: 8),
          CustomTextfieldWidgetMobile(
            controller: leadProvider.longitudeController,
            labelText: 'Longitude',
          ),
        ],
        const SizedBox(height: 8),
        if (settingsProvider.companyDetails.isEmpty ||
            settingsProvider.companyDetails[0].districtCityMandatory == 0) ...[
          SearchableBottomSheetDropdown<int>(
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
            controller: leadProvider.cityController,
            labelText: 'Place',
          ),
          const SizedBox(height: 8),
        ],
        CustomTextfieldWidgetMobile(
          controller: leadProvider.pincodeController,
          labelText: 'Pincode',
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.pincodeController.text),
        ),
        const SizedBox(height: 8),
        SearchableBottomSheetDropdown<int>(
          hintText: 'State',
          items: dropDownProvider.stateList
              .map((status) => DropdownItem<int>(
                    id: status.stateId ?? 0,
                    name: status.stateName ?? '',
                  ))
              .toList(),
          controller: leadProvider.stateController,
          onItemSelected: (int? newValue) {
            if (newValue != null) {
              final selectedState = dropDownProvider.stateList
                  .firstWhere((task) => task.stateId == newValue);
              dropDownProvider.updateState(
                  newValue, selectedState.stateName ?? '');
              leadProvider.stateController.text =
                  selectedState.stateName ?? '';
            }
          },
          selectedValue: dropDownProvider.selectedStateId != null &&
                  dropDownProvider.stateList.any(
                      (item) => item.stateId == dropDownProvider.selectedStateId)
              ? dropDownProvider.selectedStateId
              : null,
          showError: dropDownProvider.showValidation &&
              !_isFieldValid(leadProvider.stateController.text),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          height: 54,
          controller: leadProvider.landmarkController,
          hintText: 'Landmark',
          labelText: '',
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
              child: SearchableBottomSheetDropdown<int>(
                hintText: 'Amount Paid through',
                items: leadProvider.leadDropdownData!.amountPaidThrough
                    .map((item) => DropdownItem<int>(
                          id: item.amountPaidThroughId,
                          name: item.amountPaidThroughName ?? '',
                        ))
                    .toList(),
                controller: leadProvider.amountPaidController,
                selectedValue: leadProvider.selectedAmountPaidId,
                onItemSelected: (selectedId) {
                  if (selectedId != null) {
                    leadProvider.setAmountPaidId(selectedId);
                    final selectedItem = leadProvider
                        .leadDropdownData!.amountPaidThrough
                        .firstWhere(
                      (status) => status.amountPaidThroughId == selectedId,
                    );
                    leadProvider.amountPaidController.text =
                        selectedItem.amountPaidThroughName ?? '';
                  }
                },
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
              child: SearchableBottomSheetDropdown<int>(
                hintText: 'Cost Includes',
                items: leadProvider.leadDropdownData!.costIncludes
                    .map((item) => DropdownItem<int>(
                          id: item.costIncludesId,
                          name: item.costIncludesName ?? '',
                        ))
                    .toList(),
                controller: leadProvider.costIncludesController,
                selectedValue: leadProvider.selectedCostIncId,
                onItemSelected: (selectedId) {
                  if (selectedId != null) {
                    leadProvider.setCostIncId(selectedId);
                    final selectedItem = leadProvider
                        .leadDropdownData!.costIncludes
                        .firstWhere(
                      (status) => status.costIncludesId == selectedId,
                    );
                    leadProvider.costIncludesController.text =
                        selectedItem.costIncludesName ?? '';
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextfieldWidgetMobile(
                readOnly: false,
                controller: leadProvider.commissionController,
                labelText: 'Commission',
                keyBoardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
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
              borderRadius: BorderRadius.circular(4),
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
              child: SearchableBottomSheetDropdown<int>(
                hintText: 'Inverter Type',
                items: leadProvider.leadDropdownData!.inverterType
                    .map((item) => DropdownItem<int>(
                          id: item.inverterTypeId,
                          name: item.inverterTypeName ?? '',
                        ))
                    .toList(),
                controller: leadProvider.inverterTypeController,
                selectedValue: leadProvider.selectedInverterId,
                onItemSelected: (selectedId) {
                  if (selectedId != null) {
                    leadProvider.setInverterId(selectedId);
                    final selectedItem = leadProvider
                        .leadDropdownData!.inverterType
                        .firstWhere((item) => item.inverterTypeId == selectedId);
                    leadProvider.inverterTypeController.text =
                        selectedItem.inverterTypeName ?? '';
                  }
                },
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
              child: SearchableBottomSheetDropdown<int>(
                hintText: 'Panel Brand',
                items: leadProvider.leadDropdownData!.panelType
                    .map((item) => DropdownItem<int>(
                          id: item.panelTypeId,
                          name: item.panelTypeName ?? '',
                        ))
                    .toList(),
                controller: leadProvider.panelBrandController,
                selectedValue: leadProvider.selectedPanelId,
                onItemSelected: (selectedId) {
                  if (selectedId != null) {
                    leadProvider.setPanelId(selectedId);
                    final selectedItem = leadProvider
                        .leadDropdownData!.panelType
                        .firstWhere((item) => item.panelTypeId == selectedId);
                    leadProvider.panelBrandController.text =
                        selectedItem.panelTypeName ?? '';
                  }
                },
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
        SearchableBottomSheetDropdown<int>(
          hintText: 'Panel Phase',
          items: leadProvider.leadDropdownData!.phase
              .map((item) => DropdownItem<int>(
                    id: item.phaseId,
                    name: item.phaseName ?? '',
                  ))
              .toList(),
          controller: leadProvider.panelPhaseController,
          selectedValue: leadProvider.selectedPhaseId,
          onItemSelected: (selectedId) {
            if (selectedId != null) {
              leadProvider.setPhaseId(selectedId);
              final selectedItem = leadProvider.leadDropdownData!.phase
                  .firstWhere((item) => item.phaseId == selectedId);
              leadProvider.panelPhaseController.text =
                  selectedItem.phaseName ?? '';
            }
          },
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
          labelText: settingsProvider.leadNameLabel,
          // labelText: '',
          focusNode: _leadNameFocusNode,
          // showError: dropDownProvider.showValidation &&
          //     !_isFieldValid(leadProvider.leadNameController.text),
        ),
        const SizedBox(
          height: 10,
        ),
        if (settingsProvider.menuIsViewMap[145] == 1) ...[
          CustomTextfieldWidgetMobile(
            focusNode: FocusNode(),
            controller: leadProvider.referenceNameController,
            labelText: 'Reference Name',
          ),
          const SizedBox(height: 10),
        ],
        if (settingsProvider.menuIsViewMap[146] == 1) ...[
          SearchableBottomSheetDropdown<int>(
            hintText: 'Location',
            items: dropDownProvider.locationList
                .map((loc) => DropdownItem<int>(
                      id: loc.locationId,
                      name: loc.locationName,
                    ))
                .toList(),
            onItemSelected: (selectedId) {
              dropDownProvider.selectedLocationId = selectedId;
            },
            selectedValue: dropDownProvider.selectedLocationId,
          ),
          const SizedBox(height: 10),
        ],

        if (settingsProvider.menuIsViewMap[149] == 1) ...[
          SearchableBottomSheetDropdown<int>(
            hintText: 'Source',
            items: settingsProvider.searchSourceCategory
                .map((source) => DropdownItem<int>(
                      id: source.sourceId,
                      name: source.sourceName ?? '',
                    ))
                .toList(),
            controller: leadProvider.sourceCategoryController,
            onItemSelected: (selectedId) {
              dropDownProvider.setSourceCategoryId(selectedId);
              if (selectedId != null) {
                final selectedItem = settingsProvider.searchSourceCategory
                    .firstWhere((source) => source.sourceId == selectedId);
                leadProvider.sourceCategoryController.text =
                    selectedItem.sourceName ?? '';
              } else {
                leadProvider.sourceCategoryController.clear();
              }
              dropDownProvider.updateEnquiryForName(0, '');
              leadProvider.enquiryForController.clear();

              dropDownProvider.filterEnquiryForByCategory(selectedId ?? 0);
            },
            selectedValue: dropDownProvider.selectedSourceId,
          ),
          const SizedBox(height: 10),
        ],

        if (dropDownProvider.selectedSourceId != null &&
            dropDownProvider.selectedSourceId! > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enquiry Source${settingsProvider.enquirySourceMandatory == 1 ? '*' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textGrey4,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    tooltip: "Add Enquiry Source",
                    icon: Icon(Icons.add_circle, color: AppColors.primaryViolet),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return const AddEnquirySource(
                            editId: '0',
                            isEdit: false,
                            status: '',
                          );
                        },
                      ).then((value) {
                        if (context.mounted) {
                          dropDownProvider.getEnquirySource(context);
                        }
                      });
                    },
                  ),
                ],
              ),
              () {
                final selectedSourceId = dropDownProvider.selectedEnquirySourceId;
                final List<Enquirysourcemodel> displaySources = dropDownProvider.enquiryData.take(5).toList();
                if (selectedSourceId != null && selectedSourceId > 0) {
                  final hasSelected = displaySources.any((s) => s.enquirySourceId == selectedSourceId);
                  if (!hasSelected) {
                    final selectedSourceObj = dropDownProvider.enquiryData.firstWhere(
                      (s) => s.enquirySourceId == selectedSourceId,
                      orElse: () => Enquirysourcemodel(
                        enquirySourceId: selectedSourceId,
                        enquirySourceName: leadProvider.enquirySourceController.text,
                        sourceCategoryId: dropDownProvider.selectedSourceId ?? 0,
                        sourceCategoryName: leadProvider.sourceCategoryController.text,
                        deleteStatus: 0,
                      ),
                    );
                    if (selectedSourceObj.enquirySourceName != null &&
                        selectedSourceObj.enquirySourceName!.isNotEmpty) {
                      displaySources.insert(0, selectedSourceObj);
                    }
                  }
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...displaySources.map((source) {
                        final isSelected = selectedSourceId == source.enquirySourceId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Text(source.enquirySourceName ?? ''),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                dropDownProvider.setSelectedEnquirySourceId(source.enquirySourceId);
                                leadProvider.enquirySourceController.text = source.enquirySourceName ?? '';
                              }
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            selectedColor: AppColors.lightBlueColor,
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: isSelected ? AppColors.textBlue800 : AppColors.textGrey3,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: isSelected ? AppColors.textBlue800 : AppColors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (dropDownProvider.enquiryData.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('More'),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textGrey3),
                              ],
                            ),
                            selected: false,
                            onSelected: (bool selected) {
                              _showAllEnquirySourcesBottomSheet(context, dropDownProvider, leadProvider);
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            backgroundColor: Colors.grey[100],
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.textGrey3,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }(),
              if (dropDownProvider.showValidation &&
                  (dropDownProvider.selectedEnquirySourceId == null ||
                      dropDownProvider.selectedEnquirySourceId == 0) &&
                  settingsProvider.enquirySourceMandatory == 1) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Please select Enquiry Source',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
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

        if (settingsProvider.menuIsViewMap[148] == 1) ...[
          if (settingsProvider.consumerNameMandatory == 1) ...[
            CustomTextfieldWidgetMobile(
              controller: leadProvider.consumerNameController,
              labelText: leadProvider.getConsumerNameCaption(),
            ),
            const SizedBox(height: 10),
          ],
          if (settingsProvider.consumerContactNoMandatory == 1) ...[
            CustomTextfieldWidgetMobile(
              controller: leadProvider.consumerContactNoController,
              labelText: leadProvider.getConsumerNoCaption(),
              keyBoardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],

        if (settingsProvider.companyDetails.isNotEmpty &&
            settingsProvider.companyDetails[0].districtCityMandatory == 1) ...[
          SearchableBottomSheetDropdown<int>(
            hintText: 'District*',
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
            showError: dropDownProvider.showValidation &&
                dropDownProvider.selectedDistrictId == null,
          ),
          const SizedBox(height: 10),
          CustomTextfieldWidgetMobile(
            controller: leadProvider.cityController,
            labelText: 'Place*',
            showError: dropDownProvider.showValidation &&
                !_isFieldValid(leadProvider.cityController.text),
          ),
          const SizedBox(height: 10),
        ],

        Row(
          children: [
            Expanded(
              child: SearchableBottomSheetDropdown<int>(
                hintText:
                    'Enquiry For${settingsProvider.enquiryForMandatory == 1 ? '*' : ''}',
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
                    final selectedEnquiryFor = dropDownProvider
                        .filteredEnquiryForData
                        .firstWhere((task) => task.enquiryForId == newValue);
                    dropDownProvider.updateEnquiryForName(
                        newValue, selectedEnquiryFor.enquiryForName);
                    leadProvider.clearCustomFieldEnquiryFor();
                    leadProvider.getCustomFieldsByEnquiryForId(
                      context,
                      leadId: widget.isEdit ? (leadProvider.customerId ?? 0) : 0,
                      enquiryForId: newValue,
                    );
                  }
                },
                selectedValue: dropDownProvider.selectedEnquiryForId,
              ),
            ),
            IconButton(
              tooltip: "Add Enquiry For",
              icon: Icon(Icons.add_circle, color: AppColors.primaryViolet),
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return const AddEnquiryFor(
                      editId: '0',
                      isEdit: false,
                      sourceId: '0',
                      sourceName: '',
                      status: '',
                      data: null,
                    );
                  },
                ).then((value) async {
                  if (context.mounted) {
                    await dropDownProvider.getEnquiryFor(context);
                    dropDownProvider.filterEnquiryForByCategory(
                        dropDownProvider.selectedSourceId ?? 0);
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SearchableBottomSheetDropdown<int>(
          hintText: 'Priority',
          items: settingsProvider.priorities
              .map((source) => DropdownItem<int>(
                    id: source.priorityId,
                    name: source.priorityName,
                  ))
              .toList(),
          controller: leadProvider.priorityNameController,
          onItemSelected: (selectedId) {
            leadProvider.priorityId = selectedId ?? 0;
            if (selectedId != null) {
              final selectedItem = settingsProvider.priorities
                  .firstWhere((source) => source.priorityId == selectedId);
              leadProvider.priorityNameController.text =
                  selectedItem.priorityName;
            } else {
              leadProvider.priorityNameController.clear();
            }
          },
          selectedValue: leadProvider.priorityId,
        ),
        const SizedBox(
          height: 10,
        ),
       if (settingsProvider.menuIsViewMap[171] == 1) ...[
          CustomTextField(
            height: 54,
            controller: leadProvider.leadSubsidyController,
            hintText: 'Subsidy Amount',
            labelText: '',
            showError: dropDownProvider.showValidation &&
                !_isFieldValid(leadProvider.leadSubsidyController.text),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
        if (settingsProvider.menuIsViewMap[104] == 1) ...[
          CustomTextfieldWidgetMobile(
            focusNode: FocusNode(),
            controller: leadProvider.projectCostController,
            labelText: 'Total Project Cost',
            keyBoardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
        if (settingsProvider.menuIsViewMap[147] == 1) ...[
          CustomTextfieldWidgetMobile(
            focusNode: FocusNode(),
            controller: leadProvider.commissionController,
            labelText: 'Commission',
            keyBoardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
        ],

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
          Consumer<LeadsProvider>(
            builder: (context, leadProvider, child) {
              if (leadProvider.isLoadingEnquiryCustomFields) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadProvider.customFieldEnquiryFor.isNotEmpty)
                      CustomFieldSectionWidget(
                        showEditButton: true,
                        controllerKey: CustomFieldControllerkey.enquirySource.value,
                        key: customFieldEnquirySourceKey,
                        showMore: false,
                        initialFieldValues: widget.isEdit
                            ? leadProvider.customFieldEnquiryFor
                                .map((e) => FieldValueModel(
                                    customFieldId: e.customFieldId,
                                    value: e.datavalue))
                                .toList()
                            : leadProvider.customFieldEnquiryFor
                                .map((e) => FieldValueModel(
                                    customFieldId: e.customFieldId,
                                    value: leadProvider
                                        .getCustomFieldValue(e.customFieldId ?? 0)))
                                .toList(),
                        onFieldValuesChanged: (fieldValues) {
                          if (!widget.isEdit) {
                            for (var fieldValue in fieldValues) {
                              leadProvider.updateCustomFieldValue(
                                  fieldValue.customFieldId ?? 0,
                                  fieldValue.value ?? '');
                            }
                          }
                        },
                        customFields: leadProvider.customFieldEnquiryFor,
                        initialValues: const {},
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const AddCustomField(
                                editId: '0',
                                isEdit: false,
                                status: '',
                              );
                            },
                          ).then((value) async {
                            if (context.mounted) {
                              if (null != value && value) {
                                settingsProvider.getCustomField(context);
                              }
                            }
                          });
                        },
                        icon: Icon(Icons.add_circle, color: AppColors.primaryViolet),
                        label: Text('Choose Custom Field', style: GoogleFonts.plusJakartaSans(color: AppColors.primaryViolet, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                );
              }
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
