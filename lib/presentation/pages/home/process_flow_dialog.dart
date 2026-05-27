import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
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
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';

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
  bool isSaving = false;
  bool isInitialized = false;
  bool showScheduleNotes = false;
  bool showDescription = false;
  bool showFollowUpDate = false;

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

      reportsProvider.descriptionController.clear();
      final imageProvider =
          Provider.of<ImageUploadProvider>(context, listen: false);
      imageProvider.clearFiles();

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
    reportsProvider.fetchTaskTypes(
        tasktypeId, statusId, customerId, enquiryForId, context);
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CustomerDetailPageMobile(
                          fromLead: false, customerId: widget.task.customerId);
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
            return const Center(child: Text('Error loading status options'));
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
                          // Status Segmented Control (Wrap instead of horizontal scroll)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
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
                                          ? const Color(0xFF1A7AE8)
                                              .withOpacity(0.1)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF1A7AE8)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      (status.statusName ?? '').toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isSelected
                                            ? const Color(0xFF1A7AE8)
                                            : const Color(0xFF64748B),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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
                                        .map((task) {
                                      bool isSelected = reportsProvider
                                          .selectedTaskTypeIds
                                          .contains(task.taskTypeId.toString());
                                      return _buildInteractiveCard(
                                        onTap: () => reportsProvider
                                            .toggleTaskTypeSelection(
                                                task.taskTypeId.toString()),
                                        isSelected: isSelected,
                                        title: task.departmentName != null &&
                                                task.departmentName!.isNotEmpty
                                            ? '${task.taskTypeName} (${task.departmentName})'
                                            : task.taskTypeName,
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),

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
                                _buildFieldLabel('Next FollowUp Date'),
                                _buildInputField(
                                  controller:
                                      reportsProvider.followUpDateController,
                                  hint: 'Choose FollowUp Date',
                                  icon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
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
                                _buildFieldLabel('Add Notes'),
                                _buildInputField(
                                  controller:
                                      reportsProvider.descriptionController,
                                  hint: 'Enter detailed description...',
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),

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
                                  const SizedBox(height: 24),
                                  Text(
                                    'CUSTOM FIELDS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
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
                                  ),
                                ],
                              );
                            },
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
                                                BorderRadius.circular(10),
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
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader('PENDING DOCUMENTS'),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
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
                                          var doc = reportsProvider
                                              .documentTypeModel[index];
                                          return _buildDocumentTile(
                                            title: doc.documentTypeName,
                                            onTap: () async {
                                              final imageProvider = Provider.of<
                                                      ImageUploadProvider>(
                                                  context,
                                                  listen: false);
                                              imageProvider.clearFiles();
                                              imageProvider.setCutomerId(widget
                                                  .task.customerId
                                                  .toString());
                                              imageProvider.updateDocumentType(
                                                  doc.documentTypeId,
                                                  doc.documentTypeName);

                                              await _showPickOptions(
                                                  context, imageProvider);

                                              if (imageProvider
                                                  .fileInfoList.isNotEmpty) {
                                                await imageProvider
                                                    .uploadAllDocumentsGrouped(
                                                        context,
                                                        shouldPop: false);
                                                _refreshData();
                                              }
                                            },
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
                                              BorderRadius.circular(10),
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
                                  borderRadius: BorderRadius.circular(12)),
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

                                    if (reportsProvider
                                        .documentTypeModel.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Unable to Save"),
                                          content: const Text(
                                              "Documents not uploaded."),
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

                                    setState(() {
                                      isSaving = true;
                                    });

                                    try {
                                      bool isSuccess = await reportsProvider
                                          .changeTaskStatus(
                                              context,
                                              selectedStatus,
                                              widget.task.taskId,
                                              widget.task.locationTracking == 1
                                                  ? await reportsProvider
                                                      .getCurrentLocation()
                                                  : null);

                                      if (isSuccess) {
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
                                  borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A7AE8).withOpacity(0.4)
                : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1A7AE8).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
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
              color: isSelected
                  ? const Color(0xFF1A7AE8).withOpacity(0.8)
                  : const Color(0xFF1E293B),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: const Color(0xFF64748B)),
                )
              : null,
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF1A7AE8).withOpacity(0.6)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1A7AE8).withOpacity(0.4)
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
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
        borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1A7AE8)),
              title: const Text('Take Photo'),
              onTap: () async {
                await provider.addPhotoMobile(allowCamera: true);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF1A7AE8)),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                await provider.addPhotoMobile(allowCamera: false);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF1A7AE8)),
              title: const Text('Upload Document (PDF/Image)'),
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

  Widget _buildDocumentTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.upload_rounded,
            size: 16, color: const Color(0xFF1A7AE8).withOpacity(0.8)),
      ),
    );
  }
}
