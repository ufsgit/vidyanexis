import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/job_sheet_page.dart';
import 'package:vidyanexis/presentation/widgets/common/document_preview_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';

import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_form_filler_view.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield_search.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/task_audio_recording_widget.dart';

class ProcessFlowDialog extends StatefulWidget {
  final TaskReportModel task;

  const ProcessFlowDialog({
    super.key,
    required this.task,
  });

  @override
  State<ProcessFlowDialog> createState() => ProcessFlowDialogState();
}

class ProcessFlowDialogState extends State<ProcessFlowDialog> {
  late Future<List<TaskTypeStatusModel>> statusOptionsFuture;
  late TaskTypeStatusModel selectedStatus;
  SubStatus? selectedSubStatus;
  bool isSaving = false;
  bool isInitialized = false;
  bool showScheduleNotes = false;
  bool showDescription = false;
  bool showFollowUpDate = false;
  FocusNode staffFocusNode = FocusNode();
  final Map<int, String> _uploadedDocUrls = {}; // docTypeId → url
  final Map<int, double> _uploadProgress = {}; // docTypeId → 0.0–1.0
  final Set<int> _uploadingDocs = {}; // currently uploading

  @override
  void initState() {
    super.initState();

    statusOptionsFuture = getStatusType(widget.task.taskTypeId.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskPageProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      reportsProvider.clearTaskUserAssignments();
      reportsProvider.descriptionController.clear();
      final imageProvider =
          Provider.of<ImageUploadProvider>(context, listen: false);
      imageProvider.clearFiles();

      // Clear any previously recorded audio
      final audioProvider =
          Provider.of<AudioFileProvider>(context, listen: false);
      audioProvider.clearAudios();

      if (widget.task.nextFollowupDate != null &&
          widget.task.nextFollowupDate!.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(widget.task.nextFollowupDate!);
          reportsProvider.followUpDateController.text =
              DateFormat('dd MMM yyyy').format(dt);
          showFollowUpDate = true;
        } catch (e) {
          reportsProvider.followUpDateController.text =
              widget.task.nextFollowupDate!;
          showFollowUpDate = true;
        }
      }

      dropDownProvider.getDocumentType(context);

      debugPrint(
          "DEBUG: Opening dialog for Task: ${widget.task.taskId}, Type: ${widget.task.taskTypeId}");

      // Clear previous forms to ensure fresh load and show spinner
      formProvider.clearForms();

      // Initial proactive fetch
      formProvider.getFormDataByCustomer(
        widget.task.customerId.toString(),
        taskTypeId: widget.task.taskTypeId.toString(),
        enquiryForId: widget.task.enquiryForId.toString(),
        taskId: widget.task.taskId.toString(),
      );
    });
  }

  @override
  void dispose() {
    // Clear description on close
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final reportsProvider =
            Provider.of<TaskPageProvider>(context, listen: false);
        reportsProvider.clearDescription();
        staffFocusNode.dispose();
      }
    });
    super.dispose();
  }

  Future<List<TaskTypeStatusModel>> getStatusType(String taskTypeId) async {
    DropDownProvider provider = DropDownProvider();
    return provider.getStatusByTaskTypeId(context, taskTypeId, '3');
  }

  void _refreshData() {
    final reportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
    int statusId = selectedStatus.statusId ?? 0;
    int tasktypeId = selectedStatus.taskTypeId ?? 0;
    int customerId = widget.task.customerId;
    int enquiryForId = widget.task.enquiryForId;
    reportsProvider.fetchTaskTypesWithCustomFields(
        tasktypeId, statusId, customerId, enquiryForId, context,
        forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Subtle grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        titleSpacing: 0,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  bool fromLead = widget.task.isLead == '1' ? true : false;
                  final sideprovider = Provider.of<SidebarProvider>(context,listen: false);
                  if (widget.task.isLead == '1'){
                    sideprovider.name = 'Lead /';
                  } else {
                    sideprovider.name = 'Customer /';
                  }
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CustomerDetailPageMobile(
                          fromLead: fromLead, customerId: widget.task.customerId);
                    },
                  ));
                },
                child: Text(
                  widget.task.customerName,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1A7AE8).withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF1A7AE8).withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "| ${widget.task.taskTypeName}",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<TaskTypeStatusModel>>(
        future: statusOptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const CommonEmptyState(
                message: 'Error loading status options');
          } else {
            final statusOptions = snapshot.data!;

            if (!isInitialized) {
              // Priority 1: Match by exact ID
              int? matchingIndex = statusOptions.indexWhere(
                (status) => status.statusId == widget.task.taskStatusId,
              );

              // Priority 2: Match by common names if ID fails (case-insensitive)
              if (matchingIndex == -1) {
                String currentStatusName =
                    widget.task.taskStatusName.toLowerCase();
                matchingIndex = statusOptions.indexWhere((status) {
                  String optionName = (status.statusName ?? "").toLowerCase();
                  return optionName == currentStatusName ||
                      (currentStatusName.contains("progress") &&
                          optionName.contains("progress")) ||
                      (currentStatusName.contains("complete") &&
                          optionName.contains("complete"));
                });
              }

              selectedStatus = matchingIndex != -1
                  ? statusOptions[matchingIndex]
                  : statusOptions.first;

              isInitialized = true;

              int statusId = selectedStatus.statusId ?? 0;
              int tasktypeId = selectedStatus.taskTypeId ?? 0;
              int customerId = widget.task.customerId;
              int enquiryForId = widget.task.enquiryForId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                reportsProvider.fetchTaskTypes(
                    tasktypeId, statusId, customerId, enquiryForId, context);

                // Always ensure forms are fetched with the determined initial task type
                // The provider's internal check will still prevent redundant network calls
                final formProvider =
                    Provider.of<FormProvider>(context, listen: false);
                formProvider.getFormDataByCustomer(
                  customerId.toString(),
                  taskTypeId: tasktypeId.toString(),
                  enquiryForId: enquiryForId.toString(),
                  taskId: widget.task.taskId.toString(),
                );
              });
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        children: [
                          if (settingsProvider.jobSheet == 1) ...[
                            Center(
                              child: SizedBox(
                                height: 32,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      minimumSize: const Size(80, 32),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobSheetPage(
                                          taskId: widget.task.taskId,
                                          customerId: int.tryParse(widget
                                                  .task.customerId
                                                  .toString()) ??
                                              0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Job Sheet',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Status Segmented Control (Wrap instead of horizontal scroll)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: statusOptions.map((status) {
                                bool isSelected =
                                    selectedStatus.statusId == status.statusId;
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedStatus = status;
                                      selectedSubStatus = null;
                                    });

                                    int statusId = selectedStatus.statusId ?? 0;
                                    int tasktypeId =
                                        selectedStatus.taskTypeId ?? 0;
                                    int customerId = widget.task.customerId;
                                    int enquiryForId = widget.task.enquiryForId;

                                    await reportsProvider.fetchTaskTypes(
                                        tasktypeId,
                                        statusId,
                                        customerId,
                                        enquiryForId,
                                        context);

                                    final formProvider =
                                        Provider.of<FormProvider>(context,
                                            listen: false);
                                    debugPrint(
                                        "DEBUG: Status changed to ${status.statusName}, refreshing forms for taskTypeId: $tasktypeId");
                                    await formProvider.getFormDataByCustomer(
                                      customerId.toString(),
                                      taskTypeId: tasktypeId.toString(),
                                      enquiryForId: enquiryForId.toString(),
                                      taskId: widget.task.taskId.toString(),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFF8FAFC)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color.fromARGB(
                                                255, 82, 145, 245)
                                            : const Color(0xFFCBD5E1),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      status.statusName ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF1E293B),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          if (selectedStatus.subStatuses != null &&
                              selectedStatus.subStatuses!.any((s) =>
                                  s.subStatusId != null &&
                                  s.subStatusId != 0 &&
                                  s.subStatusName != null &&
                                  s.subStatusName!.isNotEmpty)) ...[
                            const SizedBox(height: 12),
                            _buildFieldLabel('Select Sub Status'),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1), width: 1.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<SubStatus>(
                                  value: selectedSubStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    border: InputBorder.none,
                                  ),
                                  hint: Text(
                                    'Choose Sub Status',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 13,
                                    ),
                                  ),
                                  onChanged: (newVal) {
                                    setState(() {
                                      selectedSubStatus = newVal;
                                    });
                                  },
                                  items: selectedStatus.subStatuses!
                                      .where((s) =>
                                          s.subStatusId != null &&
                                          s.subStatusId != 0 &&
                                          s.subStatusName != null &&
                                          s.subStatusName!.isNotEmpty)
                                      .map((sub) => DropdownMenuItem<SubStatus>(
                                            value: sub,
                                            child: Text(
                                              sub.subStatusName ?? '',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                color: const Color(0xFF1E293B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          // CustomField
                          Consumer<TaskPageProvider>(
                            builder: (context, reportsProvider, child) {
                              if (reportsProvider.showCustomFields.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  CustomFieldSectionWidget(
                                    key:
                                        customFieldTaskStatusKey, // Make sure this GlobalKey is defined
                                    customFields:
                                        reportsProvider.showCustomFields,
                                    controllerKey:
                                        'task_status_${widget.task.taskId}', // Unique key
                                    showEditButton: false,
                                    enabled: true,
                                    showMore: false,
                                    onFieldValuesChanged: (values) {
                                      int statusId =
                                          selectedStatus.statusId ?? 0;
                                      int tasktypeId =
                                          selectedStatus.taskTypeId ?? 0;
                                      int customerId = widget.task.customerId;
                                      int enquiryForId =
                                          widget.task.enquiryForId;
                                      reportsProvider
                                          .fetchTaskTypesWithCustomFields(
                                              tasktypeId,
                                              statusId,
                                              customerId,
                                              enquiryForId,
                                              context);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // --- Section: Tasks ---
                          Consumer<TaskPageProvider>(
                            builder: (context, reportsProvider, child) {
                              if (reportsProvider.taskTypeModel.isNotEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader('SELECT TASKS'),
                                    const SizedBox(height: 8),
                                    ...reportsProvider.taskTypeModel
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      var task = entry.value;
                                      bool isSelected = reportsProvider
                                          .selectedTaskTypeIds
                                          .contains(task.uniqueId ??
                                              task.taskTypeId.toString());
                                      return Column(
                                        children: [
                                          const SizedBox(height: 8),
                                          _buildInteractiveCard(
                                            onTap: () => reportsProvider
                                                .toggleTaskTypeSelection(task
                                                        .uniqueId ??
                                                    task.taskTypeId.toString()),
                                            isSelected: isSelected,
                                            trailingAction: settingsProvider
                                                        .taskDuplicateButton ==
                                                    1
                                                ? GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () {
                                                      reportsProvider
                                                          .duplicateTask(index);
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                              vertical: 4),
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                            title: task.departmentName !=
                                                        null &&
                                                    task.departmentName!
                                                        .isNotEmpty
                                                ? '${task.taskTypeName} (${task.departmentName})'
                                                : task.taskTypeName,
                                          ),
                                          //User DropDown
                                          if (task.showUser == 1)
                                            Consumer<DropDownProvider>(
                                              builder: (context,
                                                  dropDownProvider, child) {
                                                // Compute staff list for this department only
                                                List<SearchUserDetails>
                                                    getDepartmentStaff(
                                                        dynamic departmentId) {
                                                  if (departmentId == null ||
                                                      departmentId
                                                          .toString()
                                                          .trim()
                                                          .isEmpty ||
                                                      departmentId
                                                              .toString()
                                                              .trim() ==
                                                          "0") {
                                                    return [];
                                                  }

                                                  final targetDeptList =
                                                      departmentId
                                                          .toString()
                                                          .trim()
                                                          .split(',')
                                                          .map((e) => e.trim())
                                                          .where((e) =>
                                                              e.isNotEmpty)
                                                          .toList();

                                                  return dropDownProvider
                                                      .searchUserDetails
                                                      .where((staff) {
                                                    if (staff.workingStatus !=
                                                        "1") return false;

                                                    final staffDeptList = (staff
                                                                .departmentId ??
                                                            '')
                                                        .toString()
                                                        .trim()
                                                        .split(',')
                                                        .map((e) => e.trim())
                                                        .where(
                                                            (e) => e.isNotEmpty)
                                                        .toList();

                                                    List<String>
                                                        transferDeptList = [];
                                                    if (staff
                                                            .transferDepartments !=
                                                        null) {
                                                      if (staff
                                                              .transferDepartments
                                                          is Iterable) {
                                                        for (var t in staff
                                                            .transferDepartments) {
                                                          if (t is Map) {
                                                            final tId = t[
                                                                        "Department_Id"]
                                                                    ?.toString() ??
                                                                t["department_id"]
                                                                    ?.toString();
                                                            if (tId != null) {
                                                              transferDeptList
                                                                  .add(tId
                                                                      .trim());
                                                            }
                                                          } else if (t !=
                                                              null) {
                                                            transferDeptList
                                                                .addAll(t
                                                                    .toString()
                                                                    .split(',')
                                                                    .map((e) =>
                                                                        e.trim()));
                                                          }
                                                        }
                                                      } else {
                                                        transferDeptList.addAll(
                                                            staff
                                                                .transferDepartments
                                                                .toString()
                                                                .split(',')
                                                                .map((e) =>
                                                                    e.trim()));
                                                      }
                                                    }

                                                    return targetDeptList.any(
                                                        (dept) =>
                                                            staffDeptList
                                                                .contains(
                                                                    dept) ||
                                                            transferDeptList
                                                                .contains(
                                                                    dept));
                                                  }).toList();
                                                }

                                                final departmentStaff =
                                                    getDepartmentStaff(
                                                        task.departmentIds);

                                                // Default selected user name
                                                final taskKey = task.uniqueId ??
                                                    task.taskTypeId.toString();
                                                int? assignedUserId =
                                                    reportsProvider
                                                            .taskTypeToUserMap[
                                                        taskKey];
                                                String defaultUserName = '';

                                                final leadProvider =
                                                    Provider.of<LeadsProvider>(
                                                        context,
                                                        listen: false);
                                                final int loginUserId = leadProvider
                                                            .loginUserId !=
                                                        0
                                                    ? leadProvider.loginUserId
                                                    : (int.tryParse(
                                                            reportsProvider
                                                                .loginUserId) ??
                                                        0);

                                                if (assignedUserId != null) {
                                                  try {
                                                    final matchedStaff =
                                                        dropDownProvider
                                                            .staffData
                                                            .firstWhere(
                                                      (s) =>
                                                          s.userDetailsId ==
                                                          assignedUserId,
                                                    );
                                                    defaultUserName = matchedStaff
                                                            .userDetailsName ??
                                                        '';
                                                  } catch (_) {}
                                                } else if (loginUserId != 0) {
                                                  try {
                                                    final loggedInStaff =
                                                        departmentStaff
                                                            .firstWhere(
                                                      (s) =>
                                                          s.userDetailsId ==
                                                          loginUserId,
                                                    );
                                                    assignedUserId =
                                                        loggedInStaff
                                                            .userDetailsId;
                                                    defaultUserName = loggedInStaff
                                                            .userDetailsName ??
                                                        '';
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (reportsProvider
                                                                  .taskTypeToUserMap[
                                                              taskKey] ==
                                                          null) {
                                                        reportsProvider.setTaskUser(
                                                            taskKey,
                                                            loggedInStaff
                                                                .userDetailsId);
                                                      }
                                                    });
                                                  } catch (_) {}
                                                }

                                                return CustomAutocompleteSearch<
                                                    SearchUserDetails>(
                                                  key: ValueKey(
                                                      'user_search_${taskKey}_${assignedUserId ?? 0}'),
                                                  showOptionsOnTap: true,
                                                  maxHeight: 300,
                                                  optionsViewOpenDirection:
                                                      OptionsViewOpenDirection
                                                          .down,
                                                  items: departmentStaff,
                                                  displayStringFunction:
                                                      (staff) =>
                                                          staff
                                                              .userDetailsName ??
                                                          '',
                                                  defaultText: defaultUserName,
                                                  labelText: 'User',
                                                  suffixIcon:
                                                      const Icon(Icons.search),
                                                  onTap: () {},
                                                  onSelected: (SearchUserDetails
                                                      selected) {
                                                    dropDownProvider
                                                        .setSelectedUserId(
                                                            selected
                                                                .userDetailsId);

                                                    reportsProvider.setTaskUser(
                                                      taskKey,
                                                      selected.userDetailsId,
                                                    );
                                                  },
                                                  onChanged: (_) {},
                                                  onSearch: (_) async {},
                                                );
                                              },
                                            )
                                        ],
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          if (settingsProvider.taskRemarkMandatory == 1) ...[
                            _buildFieldLabel('Add Remark'),
                            _buildInputField(
                              controller: reportsProvider.remarksController,
                              hint: 'Enter Remark...',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // --- Section: Schedule & Notes ---
                          _buildExpansionCard(
                            onTap: () {
                              setState(() {
                                showScheduleNotes = !showScheduleNotes;
                              });
                            },
                            isExpanded: showScheduleNotes,
                            title: 'Schedule & Notes',
                            icon: Icons.event_note_outlined,
                            children: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (selectedStatus.followup == 1 ||
                                    selectedStatus.viewDateFollowup == 1) ...[
                                  _buildFieldLabel('Next FollowUp Date'),
                                  _buildInputField(
                                    controller:
                                        reportsProvider.followUpDateController,
                                    hint: 'Choose FollowUp Date',
                                    icon: Icons.calendar_today,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2101),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary: Color(0xFF1A7AE8),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        reportsProvider
                                                .followUpDateController.text =
                                            DateFormat('dd MMM yyyy')
                                                .format(pickedDate);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (selectedStatus.isTime == 1) ...[
                                  _buildFieldLabel('Next FollowUp Time'),
                                  _buildInputField(
                                    controller:
                                        reportsProvider.followUpTimeController,
                                    hint: 'Choose FollowUp Time',
                                    icon: Icons.access_time,
                                    readOnly: true,
                                    onTap: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        reportsProvider.followUpTimeController
                                            .text = pickedTime.format(context);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (settingsProvider.taskRemarkMandatory ==
                                    0) ...[
                                  _buildFieldLabel('Add Remark'),
                                  _buildInputField(
                                    controller:
                                        reportsProvider.remarksController,
                                    hint: 'Enter Remark...',
                                    maxLines: 4,
                                  ),
                                ],
                                _buildFieldLabel('Add Notes'),
                                _buildInputField(
                                  controller:
                                      reportsProvider.descriptionController,
                                  hint: 'Enter detailed description...',
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 16),
                                // Voice Note / Audio Recording
                                const TaskAudioRecordingWidget(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Consumer<FormProvider>(
                            builder: (context, formProvider, child) {
                              if (formProvider.isFetchingCustomerForms) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              final forms = formProvider.customerForms
                                  .where((f) =>
                                      f.id.isNotEmpty &&
                                      f.id != "0" &&
                                      f.name.isNotEmpty)
                                  .toList();

                              if (forms.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              // Deduplicate forms locally for this dialog to ensure "One button per form type"
                              // We prioritize the "Definition" (instanceId == null) so that clicking it
                              // opens a fresh form.
                              final Map<String, FormModel> uniqueForms = {};
                              for (var f in forms) {
                                if (!uniqueForms.containsKey(f.id)) {
                                  uniqueForms[f.id] = f;
                                } else {
                                  // If we already have one, prefer the definition (null instanceId)
                                  if (f.instanceId == null &&
                                      uniqueForms[f.id]!.instanceId != null) {
                                    uniqueForms[f.id] = f;
                                  }
                                }
                              }
                              final displayForms = uniqueForms.values.toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('Available Forms'),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: displayForms.map((form) {
                                      return ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1A7AE8),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        icon: const Icon(Icons.description,
                                            size: 16),
                                        label: Text(
                                          (form.name.isNotEmpty
                                                  ? form.name
                                                  : "Form")
                                              .toUpperCase(),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        onPressed: () {
                                          _showTestFormDialog(context, form);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),

                          // --- Section: Pending Documents ---
                          Consumer<TaskPageProvider>(
                            builder: (context, reportsProvider, child) {
                              if (reportsProvider
                                  .documentTypeModel.isNotEmpty) {
                                final settingsProvider =
                                    Provider.of<SettingsProvider>(context,
                                        listen: false);
                                bool isDocumentButtonEnabled =
                                    settingsProvider.documentButtonTaskStatus ==
                                        1;

                                if (isDocumentButtonEnabled) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader('PENDING DOCUMENTS'),
                                      const SizedBox(height: 8),
                                      CustomElevatedButton(
                                        onPressed: () async {
                                          await showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) =>
                                                ImageUploadAlert(
                                              customerId: widget.task.customerId
                                                  .toString(),
                                            ),
                                          );
                                        },
                                        buttonText: 'Upload Documents',
                                        backgroundColor: AppColors.appViolet,
                                        borderColor: AppColors.appViolet,
                                        textColor: Colors.white,
                                        radius: 4,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildSectionHeader('PENDING DOCUMENTS'),
                                        InkWell(
                                          onTap: () async {
                                            await showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) =>
                                                  ImageUploadAlert(
                                                customerId: widget
                                                    .task.customerId
                                                    .toString(),
                                                taskId: widget.task.taskId
                                                    .toString(),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 4, bottom: 2),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.appViolet
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: AppColors.appViolet
                                                      .withOpacity(0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.upload_file_rounded,
                                                    size: 14,
                                                    color: AppColors.appViolet),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Upload Other',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'PlusJakartaSans',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.appViolet,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.02),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: reportsProvider
                                            .documentTypeModel.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(
                                                height: 1,
                                                indent: 16,
                                                endIndent: 16,
                                                color: Color(0xFFF1F5F9)),
                                        itemBuilder: (context, index) {
                                          final doc = reportsProvider
                                              .documentTypeModel[index];
                                          final docId = doc.documentTypeId ?? 0;

                                          return _buildDocumentTile(
                                            title: doc.documentTypeName ?? '',
                                            isMandatory: doc.isMandatory,
                                            uploadedUrl:
                                                _uploadedDocUrls[docId],
                                            isUploading:
                                                _uploadingDocs.contains(docId),
                                            progress: _uploadProgress[docId],
                                            onTap: () => _handleDocumentUpload(
                                              context: context,
                                              doc: doc,
                                              reportsProvider: reportsProvider,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),

                          // --- Section: Mandatory Tasks ---
                          const SizedBox(height: 8),
                          Consumer<TaskPageProvider>(
                            builder: (context, reportsProvider, child) {
                              if (reportsProvider.statusData.isNotEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader('MANDATORY TASKS'),
                                    const SizedBox(height: 8),
                                    ...reportsProvider.statusData.map((task) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: const Color(0xFFFECACA)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline,
                                                color: Color(0xFFDC2626),
                                                size: 18),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "${task.taskTypeName} - ${task.requiredStatuses}",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF991B1B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Floating Bottom Buttons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF8FAFC).withOpacity(0),
                          const Color(0xFFF8FAFC).withOpacity(0.9),
                          const Color(0xFFF8FAFC),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    // Validation logic
                                    if (reportsProvider.statusData.isNotEmpty) {
                                      // Show warning (reusing existing alert logic but styled)
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              "Required Status Incomplete"),
                                          content: const Text(
                                              "Please complete the required tasks first."),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }

                                    final settingsProvider =
                                        Provider.of<SettingsProvider>(context,
                                            listen: false);
                                    //Remark Mandatory Check
                                    int remarkMandatoty =
                                        settingsProvider.taskRemarkMandatory;
                                    if (remarkMandatoty == 1 &&
                                        reportsProvider
                                            .remarksController.text.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            titlePadding:
                                                const EdgeInsets.fromLTRB(
                                                    24, 24, 24, 8),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    24, 0, 24, 16),
                                            actionsPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10),
                                            title: Row(
                                              children: [
                                                Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: AppColors.darkGreen),
                                                const SizedBox(width: 10),
                                                const Text("Unable to Save",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20)),
                                              ],
                                            ),
                                            content: const Text(
                                                "Remark Missing",
                                                style: TextStyle(fontSize: 16)),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      AppColors.darkGreen,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    // Custom Fields Mandatory Check
                                    final bool hasMandatoryCustomFields =
                                        reportsProvider.showCustomFields
                                            .any((f) => f.isMandatory == 1);
                                    if (hasMandatoryCustomFields) {
                                      List<String> customFieldErrors = [];
                                      if (customFieldTaskStatusKey
                                              .currentState !=
                                          null) {
                                        final validation =
                                            customFieldTaskStatusKey
                                                .currentState!
                                                .validateForm();
                                        if (!validation.isValid ||
                                            validation.errors.isNotEmpty) {
                                          customFieldErrors =
                                              validation.errors.isNotEmpty
                                                  ? validation.errors
                                                  : [
                                                      "Please fill mandatory custom fields"
                                                    ];
                                        }
                                      }
                                      if (customFieldErrors.isEmpty) {
                                        for (final f in reportsProvider
                                            .showCustomFields) {
                                          if (f.isMandatory == 1 &&
                                              f.customFieldId != null) {
                                            final val = customFieldTaskStatusKey
                                                    .currentState
                                                    ?.getFieldValue(
                                                        f.customFieldId!)
                                                    ?.value ??
                                                f.datavalue;
                                            final fieldType =
                                                CustomFieldType.fromValue(
                                                    f.customFieldTypeId);
                                            if (fieldType ==
                                                CustomFieldType.checkbox) {
                                              final availableOptions = (f
                                                          .checkboxValues ??
                                                      [])
                                                  .map((o) => o.checkBoxValues
                                                      ?.toString()
                                                      .trim()
                                                      .toLowerCase())
                                                  .where((o) =>
                                                      o != null && o.isNotEmpty)
                                                  .toSet();
                                              bool selected = false;
                                              if (val != null &&
                                                  val.trim().isNotEmpty &&
                                                  val != "0" &&
                                                  val.toLowerCase() !=
                                                      "false") {
                                                final parts = val
                                                    .split(',')
                                                    .map((e) => e.trim())
                                                    .where((e) =>
                                                        e.isNotEmpty &&
                                                        e != "0" &&
                                                        e.toLowerCase() !=
                                                            "false")
                                                    .toList();
                                                if (availableOptions
                                                    .isNotEmpty) {
                                                  selected = parts.any((p) =>
                                                      availableOptions.contains(
                                                          p.toLowerCase()));
                                                } else {
                                                  selected = parts.isNotEmpty;
                                                }
                                              }
                                              if (!selected) {
                                                customFieldErrors.add(
                                                    '${f.customFieldName ?? "Custom field"} is required');
                                              }
                                            } else if (fieldType ==
                                                    CustomFieldType
                                                        .fileUpload ||
                                                fieldType ==
                                                    CustomFieldType.signature) {
                                              final hasPending =
                                                  customFieldTaskStatusKey
                                                          .currentState
                                                          ?.getPendingFileBytes()
                                                          .containsKey(f
                                                              .customFieldId!) ??
                                                      false;
                                              final hasVal = val != null &&
                                                  val.trim().isNotEmpty;
                                              if (!hasVal && !hasPending) {
                                                customFieldErrors.add(
                                                    '${f.customFieldName ?? "Custom field"} is required');
                                              }
                                            } else {
                                              if (val == null ||
                                                  val.trim().isEmpty) {
                                                customFieldErrors.add(
                                                    '${f.customFieldName ?? "Custom field"} is required');
                                              }
                                            }
                                          }
                                        }
                                      }

                                      if (customFieldErrors.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              titlePadding:
                                                  const EdgeInsets.fromLTRB(
                                                      24, 24, 24, 8),
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      24, 0, 24, 16),
                                              actionsPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                              title: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color:
                                                          AppColors.darkGreen),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Unable to Save",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'PlusJakartaSans',
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Custom Fields Not Filled",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'PlusJakartaSans',
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (customFieldErrors
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    ...customFieldErrors
                                                        .map((err) => Text(
                                                              "• $err",
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    'PlusJakartaSans',
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 14,
                                                              ),
                                                            )),
                                                  ],
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        AppColors.darkGreen,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }
                                    }

                                    bool hasPendingMandatoryDocs =
                                        reportsProvider.documentTypeModel
                                            .any((doc) {
                                      final int docId = doc.documentTypeId;
                                      final bool isUploaded =
                                          _uploadedDocUrls[docId] != null &&
                                              _uploadedDocUrls[docId]!
                                                  .isNotEmpty;
                                      return doc.isMandatory && !isUploaded;
                                    });
                                    if (hasPendingMandatoryDocs) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          titlePadding:
                                              const EdgeInsets.fromLTRB(
                                                  24, 24, 24, 8),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  24, 0, 24, 16),
                                          actionsPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 10),
                                          title: Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  color: AppColors.darkGreen),
                                              const SizedBox(width: 10),
                                              const Text(
                                                "Unable to Save",
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: const Text(
                                            "Documents Not Uploaded",
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    AppColors.darkGreen,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isSaving = true;
                                    });

                                    try {
                                      // Upload audio files if any
                                      final audioProvider =
                                          Provider.of<AudioFileProvider>(
                                              context,
                                              listen: false);
                                      List<Map<String, String>>
                                          uploadedAudioFiles = [];
                                      if (audioProvider.audios.isNotEmpty) {
                                        uploadedAudioFiles =
                                            await audioProvider.uploadAllAudios(
                                          widget.task.taskId.toString(),
                                          context,
                                        );
                                      }

                                      bool isSuccess = await reportsProvider
                                          .changeTaskStatus(
                                              context,
                                              selectedStatus,
                                              widget.task.taskId,
                                              widget.task.locationTracking == 1
                                                  ? await reportsProvider
                                                      .getCurrentLocation()
                                                  : null,
                                              subStatus: selectedSubStatus,
                                              audioFiles: uploadedAudioFiles);

                                      if (isSuccess) {
                                        audioProvider.clearAudios();
                                        Navigator.of(context).pop(true);
                                      } else {
                                        setState(() {
                                          isSaving = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Failed to update status')),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isSaving = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF1A7AE8).withOpacity(0.8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 2,
                              shadowColor:
                                  const Color(0xFF1A7AE8).withOpacity(0.2),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Save',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showTestFormDialog(BuildContext context, FormModel form) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomFormFillerView(
            form: form,
            taskId: widget.task.taskId,
            customerId: widget.task.customerId,
            taskTypeId: widget.task.taskTypeId.toString(),
            enquiryForId: widget.task.enquiryForId,
            formDataDetailsId: form.instanceId?.toString(),
            onSaved: () {
              // Refresh forms or parent data if needed
            },
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2, top: 0),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard({
    required VoidCallback onTap,
    required bool isSelected,
    required String title,
    String? subtitle,
    Widget? trailingAction,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: const Color(0xFF64748B)),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingAction != null) ...[
                trailingAction,
                const SizedBox(width: 8),
              ],
              // //black tick box
              // AnimatedContainer(
              //   duration: const Duration(milliseconds: 200),
              //   width: 22,
              //   height: 22,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: isSelected
              //         ? const Color(0xFF1E293B)
              //         : Colors.transparent,
              //     border: Border.all(
              //       color: isSelected
              //           ? const Color(0xFF1E293B)
              //           : const Color(0xFFCBD5E1),
              //       width: 1.2,
              //     ),
              //   ),
              //   child: isSelected
              //       ? const Icon(Icons.check, size: 14, color: Colors.white)
              //       : null,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionCard({
    required VoidCallback onTap,
    required bool isExpanded,
    required String title,
    IconData? icon,
    Widget? children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF1A7AE8).withOpacity(0.4)
              : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? const Color(0xFF1A7AE8).withOpacity(0.06)
                : Colors.black.withOpacity(0.01),
            blurRadius: isExpanded ? 10 : 4,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 20,
                        color: isExpanded
                            ? const Color(0xFF1A7AE8).withOpacity(0.8)
                            : const Color(0xFF64748B)),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isExpanded
                            ? const Color(0xFF1A7AE8).withOpacity(0.8)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded
                          ? const Color(0xFF1A7AE8).withOpacity(0.8)
                          : const Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: children,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Faint grey background for inputs
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        enableInteractiveSelection: false,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: const Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 13,
          ),
          suffixIcon: icon != null
              ? Icon(icon, size: 18, color: const Color(0xFF94A3B8))
              : null,
        ),
      ),
    );
  }

  Future<void> _showPickOptions(
      BuildContext context, ImageUploadProvider provider) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF1A7AE8)),
              title: const Text('Upload Document'),
              onTap: () async {
                await provider.addFileMobile();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDocumentUpload({
    required BuildContext context,
    required dynamic doc,
    required TaskPageProvider reportsProvider,
  }) async {
    final int docId = doc.documentTypeId;

    // Guard: skip if the server returned a document type with no valid ID.
    if (docId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot upload: this document type has no valid ID. '
              'Please contact your administrator.'),
        ),
      );
      return;
    }

    final imageProvider =
        Provider.of<ImageUploadProvider>(context, listen: false);
    // Do NOT call clearFiles() here — files from other rows must be preserved
    // so all pending documents are uploaded together in one batch.
    imageProvider.setCutomerId(widget.task.customerId.toString());
    imageProvider.updateDocumentType(docId, doc.documentTypeName);

    await _showPickOptions(context, imageProvider);

    // Check only files belonging to THIS document type
    final pickedForThisDoc = imageProvider.fileInfoList
        .where((f) => f['docTypeId'] == docId)
        .toList();
    if (pickedForThisDoc.isEmpty) return;

    final file = pickedForThisDoc.first;
    final fileName = file['name'] as String? ?? 'document';
    final bytes = file['data'] as Uint8List?;
    final mime = file['mimeType'] as String?;

    final shouldUpload = await showDocumentPreviewDialog(
      context: context,
      fileName: fileName,
      bytes: bytes,
      mimeType: mime,
    );
    if (shouldUpload != true) {
      // Remove only the files the user just picked for this doc type;
      // keep everything else staged.
      imageProvider.removeFilesForDocType(docId);
      return;
    }

    // Gmail-style: progress on the row only
    setState(() {
      _uploadingDocs.add(docId);
      _uploadProgress[docId] = 0.05;
    });

    Timer? progressTimer;
    progressTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!_uploadingDocs.contains(docId)) {
        progressTimer?.cancel();
        return;
      }
      setState(() {
        final current = _uploadProgress[docId] ?? 0.0;
        if (current < 0.9) {
          _uploadProgress[docId] = current + 0.04;
        }
      });
    });

    try {
      final uploadedUrls = await imageProvider.uploadAllDocumentsGrouped(
        context,
        shouldPop: false,
        taskId: widget.task.taskId.toString(),
      );

      progressTimer.cancel();

      if (uploadedUrls.isNotEmpty) {
        // finish bar to 100%
        setState(() {
          _uploadProgress[docId] = 1.0;
        });
        await Future.delayed(const Duration(milliseconds: 250));

        // keep in list, only mark uploaded — NO fetchTaskTypes
        setState(() {
          _uploadingDocs.remove(docId);
          _uploadProgress.remove(docId);
          _uploadedDocUrls[docId] = uploadedUrls.first;
        });
      } else {
        setState(() {
          _uploadingDocs.remove(docId);
          _uploadProgress.remove(docId);
        });
      }
    } catch (e) {
      progressTimer.cancel();
      setState(() {
        _uploadingDocs.remove(docId);
        _uploadProgress.remove(docId);
      });
    }
  }

  Widget _buildDocumentTile({
    required String title,
    required VoidCallback onTap,
    String? uploadedUrl,
    double? progress,
    bool isUploading = false,
    bool isMandatory = false,
  }) {
    final bool isUploaded = uploadedUrl != null && uploadedUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: (isUploaded || isUploading) ? null : onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text.rich(
            TextSpan(
              text: title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
              children: [
                if (isMandatory)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          trailing: isUploaded
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _openViewer(context, uploadedUrl!, title),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1A7AE8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                  ],
                )
              : isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        value: progress,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.upload_rounded,
                        size: 16,
                        color: const Color(0xFF1A7AE8).withOpacity(0.8),
                      ),
                    ),
        ),
      ],
    );
  }

  void _openViewer(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 48,
              left: 16,
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
