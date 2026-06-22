import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield_search.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';

class AddFollowupDialog extends StatefulWidget {
  final String customerName;
  final String statusId;
  final String? amount;
  const AddFollowupDialog({
    super.key,
    required this.customerName,
    this.statusId = '0',
    this.amount,
  });

  @override
  State<AddFollowupDialog> createState() => _AddFollowupDialogState();
}

class _AddFollowupDialogState extends State<AddFollowupDialog> {
  late FocusNode _leadNameFocusNode;
  late FocusNode statusNode;
  late FocusNode staffNode;
  List<SearchLeadStatusModel> _filteredFollowUpStatuses = [];
  List<SearchLeadStatusModel> _filteredTransferStatuses = [];
  bool showTransferStatus = false;
  bool showTime = false;
  bool showTransfer = false;
  bool showAmountForMain = false;
  bool showAmountForSecondary = false;
  bool get showAmount => showAmountForMain || showAmountForSecondary;
  late TextEditingController amountController;
  DateTime? originalFollowUpDate;

  @override
  void dispose() {
    _leadNameFocusNode.dispose();
    statusNode.dispose();
    staffNode.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _leadNameFocusNode = FocusNode();
    statusNode = FocusNode();
    staffNode = FocusNode();
    
    double? parsedAmount = double.tryParse(widget.amount ?? '');
    if (parsedAmount != null && parsedAmount > 0) {
      if (parsedAmount == parsedAmount.toInt()) {
        amountController = TextEditingController(text: parsedAmount.toInt().toString());
      } else {
        amountController = TextEditingController(text: parsedAmount.toString());
      }
    } else {
      amountController = TextEditingController();
    }
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (leadProvider.nextFollowUpDateController.text.isNotEmpty) {
      try {
        originalFollowUpDate = DateFormat('dd MMM yyyy').parse(leadProvider.nextFollowUpDateController.text);
      } catch (_) {
        try {
          originalFollowUpDate = DateTime.parse(leadProvider.nextFollowUpDateController.text);
        } catch (_) {}
      }
    }

    leadProvider.transferStatusController.clear();
    dropDownProvider.setSelectedTransferStatusId(0);
    leadProvider.followUpTimeController.clear();

    leadProvider.messageController
        .clear(); // Clear remarks textfield by default

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _leadNameFocusNode.requestFocus();
      leadProvider.getCustomFieldsByStatusId(
        context,
        statusId: dropDownProvider.selectedStatusId ?? 0,
        leadId: leadProvider.customerId,
      );

      // Ensure that branches, departments, and staff details are loaded
      if (settingsProvider.branchModel.isEmpty) {
        settingsProvider.searchBranch(context);
      }
      if (settingsProvider.departmentModel.isEmpty) {
        settingsProvider.searchDepartment('', context);
      }
      if (dropDownProvider.searchUserDetails.isEmpty) {
        dropDownProvider.getUserDetails(context);
      }

      // Fetch specific sub-statuses for the current status
      // Prioritize widget.statusId, then provider's selectedStatusId
      String targetStatusId = widget.statusId?.toString() ??
          dropDownProvider.selectedStatusId?.toString() ??
          '0';

      if (targetStatusId != '0' && targetStatusId != 'null') {
        final parentStatuses =
            await settingsProvider.getStatusById(context, targetStatusId);
        bool parentHasAmount = parentStatuses.isNotEmpty && parentStatuses.first.isAmount == 1;
        if (mounted) {
          setState(() {
            showAmountForMain = parentHasAmount;
            _filteredFollowUpStatuses = parentStatuses.isNotEmpty
                ? parentStatuses.first.subStatuses
                        ?.map((s) => SearchLeadStatusModel(
                              statusId: s.subStatusId,
                              statusName: s.subStatusName,
                            ))
                        .toList() ??
                    []
                : [];
          });
        }

        //transfer status
        if (targetStatusId != '0' && targetStatusId != 'null') {
          final transferStatusesData = await settingsProvider
              .getTransferStatusById(context, targetStatusId);
          bool transferHasAmount = transferStatusesData.isNotEmpty && transferStatusesData.first.isAmount == 1;

          int? prefillDeptId;
          String prefillDeptName = '';

          if (transferStatusesData.isNotEmpty &&
              transferStatusesData.first.departmentId != null &&
              transferStatusesData.first.departmentId! > 0) {
            prefillDeptId = transferStatusesData.first.departmentId;
            prefillDeptName = transferStatusesData.first.departmentName ?? '';
          }

          if (mounted) {
            setState(() {
              showTransferStatus =
                  transferStatusesData.first.isTransferStatus == 1;
              showTime = transferStatusesData.first.isTime == 1;
              showTransfer = transferStatusesData.first.isTransfer == 1;
              showAmountForSecondary = transferHasAmount;
              _filteredTransferStatuses = transferStatusesData.isNotEmpty
                  ? transferStatusesData.first.transferStatuses
                          ?.map((s) => SearchLeadStatusModel(
                                statusId: s.subStatusId,
                                statusName: s.subStatusName,
                              ))
                          .toList() ??
                      []
                  : [];

              // Pre-fill department from transfer status API response
              if (prefillDeptId != null) {
                settingsProvider.selectedDepartmentId = prefillDeptId;
                leadProvider.departmentController.text = prefillDeptName;
              }
            });

            // Fetch and pre-fill assigned user based on department from API
            final effectiveDeptId = prefillDeptId ?? settingsProvider.selectedDepartmentId;
            if (effectiveDeptId != null && effectiveDeptId > 0) {
              dropDownProvider.fetchAndSetAssignedUser(
                context: context,
                leadId: leadProvider.customerId.toString(),
                branchId: settingsProvider.selectedBranchId,
                departmentId: effectiveDeptId,
                leadProvider: leadProvider,
              );
            }
          }
        }
      }
    });
    super.initState();
  }

  void _clearDateControllerIfNotRequired() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    if (!dropDownProvider.isFollowupRequiredNew()) {
      leadProvider.nextFollowUpDateController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final audioProvider = Provider.of<AudioFileProvider>(context);

    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return !AppStyles.isWebScreen(context)
            ? Scaffold(
                backgroundColor: AppColors.whiteColor,
                appBar: CustomAppBarWidget(
                  title: 'Add follow up\n',
                  richText: widget.customerName,
                  isRichTextClickable: true,
                  onRichTextPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailPageMobile(
                          customerId:
                              int.parse(leadProvider.customerId.toString()),
                          fromLead: true,
                        ),
                      ),
                    );
                  },
                  onLeadingPressed: () {
                    Navigator.of(context).pop();
                  },
                  onSavePressed: () async {
                    await _saveFollowUp(
                      leadProvider,
                      dropDownProvider,
                      settingsProvider,
                      audioProvider,
                    );
                  },
                ),
                body: _addFollowUpSection(
                    dropDownProvider: dropDownProvider,
                    leadProvider: leadProvider,
                    settingsProvider: settingsProvider,
                    audioProvider: audioProvider),
              )
            : AlertDialog(
                backgroundColor: AppColors.whiteColor,
                surfaceTintColor: Colors.transparent,
                scrollable: AppStyles.isWebScreen(context) ? false : false,
                content: SizedBox(
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 3
                      : MediaQuery.of(context).size.width,
                  child: _addFollowUpSection(
                      dropDownProvider: dropDownProvider,
                      leadProvider: leadProvider,
                      settingsProvider: settingsProvider,
                      audioProvider: audioProvider),
                ),
                actions: [
                  CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    backgroundColor: AppColors.whiteColor,
                    borderColor: AppColors.appViolet,
                    textColor: AppColors.appViolet,
                  ),
                  CustomElevatedButton(
                    buttonText: 'Add',
                    onPressed: () async {
                      await _saveFollowUp(
                        leadProvider,
                        dropDownProvider,
                        settingsProvider,
                        audioProvider,
                      );
                    },
                    backgroundColor: AppColors.appViolet,
                    borderColor: AppColors.appViolet,
                    textColor: AppColors.whiteColor,
                  ),
                ],
              );
      },
    );
  }

  Future<void> _saveFollowUp(
    LeadsProvider leadProvider,
    DropDownProvider dropDownProvider,
    SettingsProvider settingsProvider,
    AudioFileProvider audioProvider,
  ) async {
    if (!dropDownProvider.isFollowupRequiredNew()) {
      leadProvider.nextFollowUpDateController.clear();
    }

    final selectedStatus = dropDownProvider.followUpData.firstWhere(
      (status) => status.statusId == dropDownProvider.selectedStatusId,
      orElse: () => SearchLeadStatusModel(
        followup: 0,
        statusId: 0,
        statusName: '',
        statusOrder: 0,
      ),
    );

    final selectedUser = dropDownProvider.searchUserDetails.firstWhere(
      (user) => user.userDetailsId == dropDownProvider.selectedUserId,
      orElse: () => SearchUserDetails(
        userDetailsId: 0,
        userDetailsName: '',
      ),
    );

    // Check for missing mandatory documents
    List<String> missingDocs = [];
    for (var field in leadProvider.customFieldList) {
      if (field.missingMandatoryDocumentNames != null &&
          field.missingMandatoryDocumentNames!.isNotEmpty) {
        missingDocs.addAll(field.missingMandatoryDocumentNames!);
      }
    }

    if (missingDocs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Documents'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please upload the following mandatory documents:'),
                const SizedBox(height: 10),
                ...missingDocs.map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $doc',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!_validateFollowUpForm(
        leadProvider,
        dropDownProvider,
        selectedStatus.statusName,
        selectedUser.userDetailsName,
        settingsProvider)) {
      return;
    }

    // Upload audio files if any
    List<Map<String, String>> uploadedAudioFiles = [];
    if (audioProvider.audios.isNotEmpty) {
      uploadedAudioFiles = await audioProvider.uploadAllAudios(
        leadProvider.customerId.toString(),
        context,
      );
    }

    final success = await leadProvider.saveFollowUp(
      statusId: dropDownProvider.selectedStatusId ?? 0,
      statusName: selectedStatus.statusName ?? '',
      branchId: settingsProvider.selectedBranchId!,
      branchName: leadProvider.branchController.text,
      departmentId: settingsProvider.selectedDepartmentId,
      departmentName: leadProvider.departmentController.text,
      context: context,
      toUserId: dropDownProvider.selectedUserId ?? 0,
      toUserName: selectedUser.userDetailsName ?? '',
      followUpDate: leadProvider.nextFollowUpDateController.text,
      custId: int.parse(leadProvider.customerId.toString()),
      followUp: leadProvider.nextFollowUpDateController.text.isNotEmpty ? 1 : 0,
      message: leadProvider.messageController.text,
      amount: amountController.text,
      audioFiles: uploadedAudioFiles,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }

    // Clear audio files after successful save
    audioProvider.clearAudios();
  }

  bool _validateFollowUpForm(
    LeadsProvider leadProvider,
    DropDownProvider dropDownProvider,
    String? statusName,
    String? userDetailsName,
    SettingsProvider settingsProvider,
  ) {
    String? errorMessage;
    final validation = customFieldLeadStatusKey.currentState?.validateForm();

    if (leadProvider.statusController.text.isEmpty ||
        statusName == null ||
        statusName.isEmpty) {
      errorMessage = 'Follow Up Status Required';
    } else if (leadProvider.searchUserController.text.isEmpty ||
        userDetailsName == null ||
        userDetailsName.isEmpty) {
      errorMessage = 'Please Assign Staff';
    } else if (dropDownProvider.isFollowupRequiredNew() &&
        leadProvider.nextFollowUpDateController.text.isEmpty) {
      errorMessage = 'Please select followup Date';
    } else if (settingsProvider.selectedBranchId! <= 0 &&
        settingsProvider.selectedDepartmentId <= 0) {
      errorMessage = 'Please select Branch And Department';
    } else if (validation?.isValid == false) {
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

  Padding _addFollowUpSection({
    required SettingsProvider settingsProvider,
    required LeadsProvider leadProvider,
    required DropDownProvider dropDownProvider,
    required AudioFileProvider audioProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 4),
          CommonDropdown<int>(
            hintText: 'Status*',

            // ✅ Filter out null IDs
            items: _filteredFollowUpStatuses
                .where((status) => status.statusId != null)
                .map((status) => DropdownItem<int>(
                      id: status.statusId!, // ✅ guaranteed unique
                      name: status.statusName ?? '',
                    ))
                .toList(),

            controller: leadProvider.statusController,

            onItemSelected: (selectedId) async {
              dropDownProvider.setSelectedStatusId(selectedId);

              if (selectedId != null) {
                final selectedItem = dropDownProvider.followUpData.firstWhere(
                  (status) => status.statusId == selectedId,
                  orElse: () => SearchLeadStatusModel(statusId: selectedId, statusName: ''),
                );

                // ✅ Sync controller text
                leadProvider.statusController.text =
                    selectedItem.statusName ?? '';

                if (selectedItem.isShowFollowupDate == 1) {
                  int durationVal = int.tryParse(selectedItem.statusDuration ?? '') ?? 0;
                  DateTime baseDate = originalFollowUpDate ?? DateTime.now();
                  DateTime targetDate = baseDate.add(Duration(days: durationVal));
                  leadProvider.nextFollowUpDateController.text =
                      DateFormat('dd MMM yyyy').format(targetDate);
                } else {
                  leadProvider.nextFollowUpDateController.clear();
                }

                // Check if selected status has isAmount == 1
                final statusData = await settingsProvider
                    .getStatusById(context, selectedId.toString());
                final transferStatusesData = await settingsProvider
                    .getTransferStatusById(context, selectedId.toString());

                bool mainHasAmount = (statusData.isNotEmpty && statusData.first.isAmount == 1) ||
                                     (transferStatusesData.isNotEmpty && transferStatusesData.first.isAmount == 1);

                // Extract department info before setState so we can use it outside
                int? prefillDeptId;
                String prefillDeptName = '';
                if (transferStatusesData.isNotEmpty &&
                    transferStatusesData.first.departmentId != null &&
                    transferStatusesData.first.departmentId! > 0) {
                  prefillDeptId = transferStatusesData.first.departmentId;
                  prefillDeptName = transferStatusesData.first.departmentName ?? '';
                }

                if (mounted) {
                  setState(() {
                    showAmountForMain = mainHasAmount;
                    showAmountForSecondary = false; // reset secondary when main changes
                    showTransferStatus = transferStatusesData.isNotEmpty &&
                        transferStatusesData.first.isTransferStatus == 1;
                    showTime = transferStatusesData.isNotEmpty && transferStatusesData.first.isTime == 1;
                    showTransfer = transferStatusesData.isNotEmpty && transferStatusesData.first.isTransfer == 1;
                    _filteredTransferStatuses = transferStatusesData.isNotEmpty
                        ? transferStatusesData.first.transferStatuses
                                ?.map((s) => SearchLeadStatusModel(
                                      statusId: s.subStatusId,
                                      statusName: s.subStatusName,
                                    ))
                                .toList() ??
                            []
                        : [];

                    // Pre-fill department from transfer status API response
                    if (prefillDeptId != null) {
                      settingsProvider.selectedDepartmentId = prefillDeptId;
                      leadProvider.departmentController.text = prefillDeptName;
                    }
                  });

                  // Fetch and pre-fill assigned user after department is set
                  final effectiveDeptId = prefillDeptId ?? settingsProvider.selectedDepartmentId;
                  if (effectiveDeptId != null && effectiveDeptId > 0) {
                    dropDownProvider.fetchAndSetAssignedUser(
                      context: context,
                      leadId: leadProvider.customerId.toString(),
                      branchId: settingsProvider.selectedBranchId,
                      departmentId: effectiveDeptId,
                      leadProvider: leadProvider,
                    );
                  }
                }
              }

            },

            // ✅ Only set value if it exists EXACTLY ONCE
            selectedValue: dropDownProvider.selectedStatusId ?? 0,
          ),
          if (showTransferStatus) const SizedBox(height: 16),
          if (showTransferStatus)
            CommonDropdown<int>(
              hintText: 'Secondary Status',

              // ✅ Filter out null IDs
              items: _filteredTransferStatuses
                  .where((status) => status.statusId != null)
                  .map((status) => DropdownItem<int>(
                        id: status.statusId!, // ✅ guaranteed unique
                        name: status.statusName ?? '',
                      ))
                  .toList(),

              controller: leadProvider.transferStatusController,

              onItemSelected: (selectedId) async {
                dropDownProvider.setSelectedTransferStatusId(selectedId);

                if (selectedId != null) {
                  final selectedItem = _filteredTransferStatuses.firstWhere(
                    (status) => status.statusId == selectedId,
                    orElse: () => SearchLeadStatusModel(statusId: selectedId, statusName: ''),
                  );

                  // ✅ Sync controller text
                  leadProvider.transferStatusController.text =
                      selectedItem.statusName ?? '';

                  // Check if secondary status requires amount
                  final statusData = await settingsProvider
                      .getStatusById(context, selectedId.toString());
                  final transferStatusesData = await settingsProvider
                      .getTransferStatusById(context, selectedId.toString());

                  bool secondaryHasAmount = (statusData.isNotEmpty && statusData.first.isAmount == 1) ||
                                           (transferStatusesData.isNotEmpty && transferStatusesData.first.isAmount == 1);

                  if (mounted) {
                    setState(() {
                      showAmountForSecondary = secondaryHasAmount;
                    });
                  }
                }
              },

              // ✅ Only set value if it exists EXACTLY ONCE
              selectedValue: dropDownProvider.selectedTransferStatusId ?? 0,
            ),
          if (showAmount) ...[
            const SizedBox(height: 16),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: amountController,
              hintText: 'Amount',
              labelText: '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
            ),
          ],
          const SizedBox(height: 16),

          if (showTransfer) ...[
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
                setState(() {
                  settingsProvider.selectedBranchId = selectedId;
                  final selectedBranch = settingsProvider.branchModel
                      .firstWhere((branch) => branch.branchId == selectedId);
                  leadProvider.branchController.text =
                      selectedBranch.branchName ?? '';

                  settingsProvider.setSelectedDepartmentId(0);
                  leadProvider.departmentController.clear();
                  dropDownProvider.setSelectedUserId(0);
                  leadProvider.searchUserController.clear();

                  dropDownProvider.filterStaffByBranchAndDepartment(
                    branchId: selectedId,
                    departmentId: null,
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            CommonDropdown<int>(
              key: ValueKey(settingsProvider.selectedBranchId),
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
                setState(() {
                  settingsProvider.selectedDepartmentId = selectedId;
                  final selectedDepartment = settingsProvider.departmentModel
                      .firstWhere((dept) => dept.departmentId == selectedId);
                  leadProvider.departmentController.text =
                      selectedDepartment.departmentName ?? '';

                  dropDownProvider.setSelectedUserId(0);
                  leadProvider.searchUserController.clear();

                  dropDownProvider.filterStaffByBranchAndDepartment(
                    branchId: settingsProvider.selectedBranchId,
                    departmentId: selectedId,
                  );

                  dropDownProvider.fetchAndSetAssignedUser(
                    context: context,
                    leadId: leadProvider.customerId.toString(),
                    branchId: settingsProvider.selectedBranchId,
                    departmentId: selectedId,
                    leadProvider: leadProvider,
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            Consumer<DropDownProvider>(
              builder: (context, dropDownProvider, child) {
                return CustomAutocompleteSearch<SearchUserDetails>(
                  focusNode: staffNode,
                  showOptionsOnTap: true,
                  maxHeight: 300,
                  optionsViewOpenDirection: OptionsViewOpenDirection.down,
                  items: dropDownProvider.filteredStaffData,
                  displayStringFunction: (staff) => staff.userDetailsName ?? '',
                  defaultText: leadProvider.searchUserController.text,
                  labelText: 'Assigned Staff*',
                  controller: leadProvider.searchUserController,
                  suffixIcon: const Icon(Icons.search),
                  onSelected: (SearchUserDetails selected) {
                    dropDownProvider.setSelectedUserId(
                      selected.userDetailsId,
                    );

                    leadProvider.searchUserController.text =
                        selected.userDetailsName ?? '';
                  },
                  onChanged: (value) {
                    dropDownProvider.filterStaff(value);
                  },
                  onSearch: (query) async {
                    dropDownProvider.filterStaff(query);
                  },
                );
              },
            )
            // CommonDropdown<int>(
            //   hintText: 'Assigned Staff*',
            //   items: dropDownProvider.filteredStaffData
            //       .map((staff) => DropdownItem<int>(
            //             id: staff.userDetailsId,
            //             name: staff.userDetailsName,
            //           ))
            //       .toList(),
            //   controller: leadProvider.searchUserController,
            //   onItemSelected: (selectedId) {
            //     setState(() {
            //       dropDownProvider.setSelectedUserId(selectedId);
            //       final selectedStaff = dropDownProvider.filteredStaffData
            //           .firstWhere((staff) => staff.userDetailsId == selectedId);
            //       leadProvider.searchUserController.text =
            //           selectedStaff.userDetailsName;
            //     });
            //   },
            //   selectedValue: dropDownProvider.selectedUserId,
            //   enabled: settingsProvider.selectedBranchId != null,
            // ),
          ],

          const SizedBox(height: 16),

          CustomTextfieldWidgetMobile(
            controller: leadProvider.messageController,
            labelText: 'Remarks',
            focusNode: _leadNameFocusNode,
            maxLines: 4,
            minLines: 2,
          ),

          const SizedBox(height: 16),

          if (dropDownProvider.isFollowupRequiredNew())
            CustomTextField(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    leadProvider.nextFollowUpDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
              ),
              labelText: '',
            ),
          const SizedBox(height: 16),
          if (showTime)
            CustomTextField(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  // Format as 12-hour with AM/PM or 24-hour as needed
                  leadProvider.followUpTimeController.text =
                      picked.format(context);
                  // OR for custom format (e.g., 14:30):
                  // leadProvider.nextFollowUpDateController.text =
                  //     '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                }
              },
              readOnly: true,
              height: 54,
              controller: leadProvider.followUpTimeController,
              hintText: 'Time*', // Updated hint
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time), // Changed icon
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    leadProvider.followUpTimeController.text =
                        picked.format(context);
                  }
                },
              ),
              labelText: '',
            ),

          if (dropDownProvider.isFollowupRequiredNew())
            const SizedBox(height: 16),

          if (dropDownProvider.selectedStatusId != null &&
              dropDownProvider.selectedStatusId != 0)
            if (leadProvider.customFieldList.isNotEmpty)
              CustomFieldSectionWidget(
                controllerKey: CustomFieldControllerkey.leadStatus.value,
                key: customFieldLeadStatusKey,
                showMore: (settingsProvider.menuIsViewMap[67] ?? 0) == 1,
                onFieldValuesChanged: (p0) {
                  print("kikisdhuqe $p0");
                  var f = [];
                  for (var element in p0) {
                    f.add(element.toJson());
                  }
                  print("kikisdhuqe de $f");
                },
                customFields: leadProvider.customFieldList,
                initialFieldValues: leadProvider.customFieldList
                    .map((e) => FieldValueModel(
                        customFieldId: e.customFieldId, value: e.datavalue))
                    .toList(),
              ),

          const SizedBox(height: 16),

          // Audio Recording Section
          if ((settingsProvider.menuIsViewMap[67] ?? 0) == 1)
            _buildAudioSection(audioProvider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAudioSection(AudioFileProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: provider.isRecording
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: provider.isRecording ? Colors.red : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Recording Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isRecording) ...[
                      Icon(
                        provider.isRecordingPaused
                            ? Icons.pause
                            : Icons.fiber_manual_record,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isRecordingPaused
                            ? 'Recording Paused'
                            : 'Recording...',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.formattedRecordingDuration,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      ...[],
                  ],
                ),

                // Web-specific instructions
                if (kIsWeb) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Web Recording: Allow microphone access when prompted',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Recording Control Buttons
                if (!provider.isRecording) ...[
                  // Recording start buttons
                  if (kIsWeb) ...[
                    // Two options for web recording
                    Column(
                      children: [
                        // Primary recording button (record package)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              provider.debugRecordingState();
                              await provider.startRecording();
                              provider.debugRecordingState();
                            },
                            icon: const Icon(Icons.mic, size: 20),
                            label: const Text('Start Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 8,
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await provider.addAudioFile();
                            },
                            icon: const Icon(Icons.audiotrack, size: 20),
                            label: const Text('Add Audio file'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Mobile recording button
                    ElevatedButton.icon(
                      onPressed: () async {
                        provider.debugRecordingState();
                        await provider.startRecording();
                        provider.debugRecordingState();
                      },
                      icon: const Icon(Icons.mic, size: 20),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  // Recording control buttons (pause, stop, cancel)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Pause/Resume Button (only for record package, not native web)
                      if (provider.nativeMediaRecorder == null) ...[
                        ElevatedButton.icon(
                          onPressed: provider.isRecordingPaused
                              ? provider.resumeRecording
                              : provider.pauseRecording,
                          icon: Icon(
                              provider.isRecordingPaused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              size: 20),
                          label: Text(
                              provider.isRecordingPaused ? 'Resume' : 'Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],

                      // Stop Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          print('=== STOPPING RECORDING ===');
                          provider.debugRecordingState();

                          // Use appropriate stop method based on which recorder is active
                          if (kIsWeb && provider.nativeMediaRecorder != null) {
                            await provider.stopNativeWebRecording();
                          } else {
                            await provider.stopRecording();
                          }

                          provider.debugRecordingState();
                        },
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      // Cancel Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          print('=== CANCELLING RECORDING ===');
                          provider.debugRecordingState();
                          await provider.cancelRecording();
                          provider.debugRecordingState();
                        },
                        icon: const Icon(Icons.cancel, size: 20),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.audio_file, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Audio Files (${provider.audios.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.audios.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.audiotrack, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No audio files yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Record audio or upload files to get started',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            Column(
              children: provider.audios.asMap().entries.map((entry) {
                int index = entry.key;
                AudioFile audioFile = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: audioFile.isRecording
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          audioFile.isRecording ? Icons.mic : Icons.audiotrack,
                          color:
                              audioFile.isRecording ? Colors.red : Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audioFile.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (audioFile.isRecording) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'RECORDED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  '${(audioFile.data.length / 1024).toStringAsFixed(1)} KB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '.${audioFile.extension}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (audioFile.isPlaying) {
                                provider.pauseAudio(index);
                              } else {
                                provider.playAudio(index);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                audioFile.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => provider.stopAudio(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Remove Audio File'),
                                    content: Text(
                                        'Remove "${audioFile.name}" from this follow-up?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider.removeAudio(index);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Audio file "${audioFile.name}" removed.'),
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Text('Remove',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
