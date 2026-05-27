import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

class AddTaskTypeMobilePage extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String editId;
  final TaskTypeModel? taskType;

  const AddTaskTypeMobilePage({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
    this.taskType,
  });

  @override
  State<AddTaskTypeMobilePage> createState() => _AddTaskTypeMobilePageState();
}

class _AddTaskTypeMobilePageState extends State<AddTaskTypeMobilePage> {
  // ── Validation ───────────────────────────────────────────────────────────
  String? _validateInputs(SettingsProvider settingsProvider) {
    if (settingsProvider.taskTypeController.text.trim().isEmpty) {
      return 'Please enter Task Type';
    }
    if (settingsProvider.durationController.text.trim().isEmpty) {
      return 'Please enter Duration';
    }
    if (settingsProvider.departmentUserController.text.isEmpty ||
        settingsProvider.selectedDepartmentId <= 0) {
      return 'Please select a Department';
    }
    if (settingsProvider.defaultStatusController.text.isEmpty ||
        settingsProvider.selectedDefaultStatusId <= 0) {
      return 'Please select a Status';
    }
    if (_selectedStatusIds.isEmpty) {
      return 'Please select at least one Lead Status';
    }
    for (var statusId in _selectedStatusIds) {
      if (statusId <= 0) {
        return 'One or more selected statuses are invalid';
      }
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Status selection state ───────────────────────────────────────────────
  final Map<int, bool> _selectedStatuses = {};
  List<int> get _selectedStatusIds => _selectedStatuses.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
  bool _selectAll = false;

  // ── Enquiry For selection state ──────────────────────────────────────────
  final Map<int, bool> _selectedEnquiryFor = {};
  List<int> get _selectedEnquiryForIds => _selectedEnquiryFor.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
  bool _selectAllEnquiryFor = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getEnquiryFor(context);

      _selectedEnquiryFor.clear();
      _selectAllEnquiryFor = false;

      settingsProvider.selectedDepartmentId = 0;
      settingsProvider.selectedDefaultStatus = 0;
      settingsProvider.departmentUserController.clear();
      settingsProvider.durationController.clear();
      settingsProvider.taskTypeDescriptionController.clear();
      settingsProvider.defaultStatusController.clear();
      _selectedStatuses.clear();
      settingsProvider.toggleConversionCheckbox(false);
      settingsProvider.toggleLocation(false);
      settingsProvider.toggleCommission(false);
      settingsProvider.toggleManualCreation(false);
      settingsProvider.toggleEnquiryForVisible(false);

      settingsProvider.getSearchLeadStatus('', "3", context);

      if (widget.isEdit) {
        settingsProvider.taskTypeController.text = widget.status;

        if (widget.taskType?.duration != null) {
          settingsProvider.durationController.text =
              widget.taskType!.duration.toString();
        }
        if (widget.taskType?.orderBy != null) {
          settingsProvider.orderByController.text =
              widget.taskType!.orderBy.toString();
        }

        settingsProvider
            .toggleConversionCheckbox(widget.taskType?.conversionTask != 0);
        settingsProvider
            .toggleLocation(widget.taskType?.locationTracking != 0);
        settingsProvider
            .toggleCommission(widget.taskType?.commissionNumber != 0);
        settingsProvider
            .toggleManualCreation(widget.taskType?.manualCreation != 0);
        settingsProvider
            .toggleEnquiryForVisible(widget.taskType?.enquiryForVisible != 0);

        settingsProvider.taskTypeDescriptionController.text =
            widget.taskType?.description ?? '';

        // Department
        if (widget.taskType?.departmentIds != null &&
            widget.taskType!.departmentIds.isNotEmpty) {
          final departmentId =
              int.tryParse(widget.taskType?.departmentIds ?? '0') ?? 0;
          if (departmentId > 0) {
            settingsProvider.selectedDepartmentId = departmentId;
            final department = settingsProvider.departmentModel.firstWhere(
              (d) => d.departmentId == departmentId,
              orElse: () =>
                  DepartmentModel(departmentId: 0, departmentName: ''),
            );
            settingsProvider.departmentUserController.text =
                department.departmentName ?? '';
          }
        }

        // Default status
        if (widget.taskType?.defaultStatusId != null &&
            widget.taskType?.defaultStatusId != 0) {
          settingsProvider.selectedDefaultStatus =
              widget.taskType?.defaultStatusId ?? 0;
          final status = settingsProvider.searchType.firstWhere(
            (s) => s.statusId == widget.taskType?.defaultStatusId,
            orElse: () => SearchLeadStatusModel(
                stageId: 0,
                stageName: '',
                statusId: 0,
                statusName: '',
                customFields: [],
                progressValue: 0,
                colorCode: '',
                followup: -1,
                isRegistered: -1,
                statusOrder: -1,
                viewInId: 0,
                viewInName: ''),
          );
          if (status.statusId != null && status.statusId! > 0) {
            settingsProvider.defaultStatusController.text =
                status.statusName ?? '';
          }
        }

        // Selected statuses
        if (widget.taskType?.statuses != null &&
            widget.taskType!.statuses.isNotEmpty) {
          for (var s in widget.taskType!.statuses) {
            if (s.statusId > 0) _selectedStatuses[s.statusId] = true;
          }
          _updateSelectAllState();
        }

        // Selected enquiry for
        if (widget.taskType?.enquiryFor != null &&
            widget.taskType!.enquiryFor!.isNotEmpty) {
          for (var item in widget.taskType!.enquiryFor!) {
            if (item.enquiryForId > 0) {
              _selectedEnquiryFor[item.enquiryForId] = true;
            }
          }
          _updateSelectAllEnquiryForState();
        }
      }
    });
  }

  // ── Select-all helpers ────────────────────────────────────────────────────
  void _toggleSelectAll(SettingsProvider sp) {
    setState(() {
      _selectAll = !_selectAll;
      for (var s in sp.searchType) {
        if (s.statusId != null && s.statusId! > 0) {
          _selectedStatuses[s.statusId!] = _selectAll;
        }
      }
    });
  }

  void _updateSelectAllState() {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    if (sp.searchType.isEmpty) {
      setState(() => _selectAll = false);
      return;
    }
    bool all = true;
    int validCount = 0;
    for (var s in sp.searchType) {
      if (s.statusId != null && s.statusId! > 0) {
        validCount++;
        _selectedStatuses.putIfAbsent(s.statusId!, () => false);
        if (!(_selectedStatuses[s.statusId!] ?? false)) all = false;
      }
    }
    setState(() => _selectAll = all && validCount > 0);
  }

  void _toggleSelectAllEnquiryFor(DropDownProvider dp) {
    setState(() {
      _selectAllEnquiryFor = !_selectAllEnquiryFor;
      for (var item in dp.enquiryForList) {
        if (item.enquiryForId > 0) {
          _selectedEnquiryFor[item.enquiryForId] = _selectAllEnquiryFor;
        }
      }
    });
  }

  void _updateSelectAllEnquiryForState() {
    final dp = Provider.of<DropDownProvider>(context, listen: false);
    if (dp.enquiryForList.isEmpty) {
      setState(() => _selectAllEnquiryFor = false);
      return;
    }
    bool all = true;
    for (var item in dp.enquiryForList) {
      if (item.enquiryForId > 0) {
        if (!(_selectedEnquiryFor[item.enquiryForId] ?? false)) {
          all = false;
          break;
        }
      }
    }
    setState(() => _selectAllEnquiryFor = all);
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void _handleSave(SettingsProvider settingsProvider) async {
    final error = _validateInputs(settingsProvider);
    if (error != null) {
      _showErrorSnackBar(error);
      return;
    }

    final taskTypeStatus = _selectedStatuses.entries
        .where((e) => e.value)
        .map((e) => {"Status_Id": e.key})
        .toList();

    final enquiryForList = _selectedEnquiryFor.entries
        .where((e) => e.value)
        .map((e) => {"EnquiryFor_Id": e.key})
        .toList();

    final requestData = {
      "Task_Type_Id":
          widget.isEdit ? int.tryParse(widget.editId) ?? 0 : 0,
      "Task_Type_Name": settingsProvider.taskTypeController.text,
      "Task_Type_Color": "",
      "Task_Type_Image": "",
      "Department_Ids": settingsProvider.selectedDepartmentId.toString(),
      "Branch_Ids": "",
      "default_status_id": settingsProvider.selectedDefaultStatusId,
      "Duration":
          int.tryParse(settingsProvider.durationController.text) ?? 0,
      "Description": settingsProvider.taskTypeDescriptionController.text,
      "task_type_status": taskTypeStatus,
      "Is_Active": settingsProvider.isConversionChecked ? 1 : 0,
      "Location_Tracking": settingsProvider.isLocationTracking ? 1 : 0,
      "Commission_Number": settingsProvider.isCommissionChecked ? 1 : 0,
      "Manual_Creation": settingsProvider.isManualCreation ? 1 : 0,
      "order_by":
          int.tryParse(settingsProvider.orderByController.text) ?? 0,
      "Enquiry_For_Ids": enquiryForList,
      "Enquiry_For_Visible": settingsProvider.isEnquiryForVisible ? 1 : 0,
    };

    settingsProvider.addTaskType(context: context, data: requestData);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            settingsProvider.taskTypeController.clear();
            settingsProvider.durationController.clear();
            settingsProvider.departmentTaskController.clear();
            settingsProvider.defaultStatusController.clear();
            settingsProvider.taskTypeDescriptionController.clear();
            settingsProvider.toggleCommission(false);
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
        title: Text(
          widget.isEdit ? 'Edit Task Type' : 'Add Task Type',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E232C),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Details card ─────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('DETAILS'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: settingsProvider.taskTypeController,
                            hintText: 'Task Type name *',
                            labelText: '',
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: settingsProvider.durationController,
                            hintText: 'Duration (days) *',
                            labelText: '',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: settingsProvider.orderByController,
                            hintText: 'Order By',
                            labelText: '',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CommonDropdown<int>(
                            hintText: 'Department *',
                            selectedValue: widget.isEdit
                                ? settingsProvider.selectedDepartmentId
                                : null,
                            items: settingsProvider.departmentModel
                                .map((d) => DropdownItem<int>(
                                      id: d.departmentId,
                                      name: d.departmentName ?? '',
                                    ))
                                .toList(),
                            controller:
                                settingsProvider.departmentUserController,
                            onItemSelected: (id) {
                              settingsProvider.selectedDepartmentId = id;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: CommonDropdown<int>(
                            hintText: 'Default Status *',
                            selectedValue: widget.isEdit
                                ? settingsProvider.selectedDefaultStatusId
                                : null,
                            items: settingsProvider.searchType
                                .map((s) => DropdownItem<int>(
                                      id: s.statusId ?? 0,
                                      name: s.statusName ?? '',
                                    ))
                                .toList(),
                            controller:
                                settingsProvider.defaultStatusController,
                            onItemSelected: (id) {
                              settingsProvider.selectedDefaultStatus = id;
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller:
                              settingsProvider.taskTypeDescriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Description',
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Options card ──────────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('OPTIONS'),
                        const SizedBox(height: 8),
                        _CheckRow(
                          label: 'Conversion Task',
                          value: settingsProvider.isConversionChecked,
                          onChanged: (v) =>
                              settingsProvider.toggleConversionCheckbox(v!),
                        ),
                        _CheckRow(
                          label: 'Location Tracking',
                          value: settingsProvider.isLocationTracking,
                          onChanged: (v) =>
                              settingsProvider.toggleLocation(v!),
                        ),
                        _CheckRow(
                          label: 'Amount',
                          value: settingsProvider.isCommissionChecked,
                          onChanged: (v) =>
                              settingsProvider.toggleCommission(v!),
                        ),
                        _CheckRow(
                          label: 'Manual Creation',
                          value: settingsProvider.isManualCreation,
                          onChanged: (v) =>
                              settingsProvider.toggleManualCreation(v!),
                        ),
                        _CheckRow(
                          label: 'Show Enquiry For',
                          value: settingsProvider.isEnquiryForVisible,
                          onChanged: (v) =>
                              settingsProvider.toggleEnquiryForVisible(v!),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Manage Status card ────────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _SectionLabel('MANAGE STATUS'),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  _toggleSelectAll(settingsProvider),
                              child: Text(
                                _selectAll ? 'Deselect All' : 'Select All',
                                style: TextStyle(
                                  color: AppColors.appViolet,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        settingsProvider.searchType.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                    child: Text('No lead statuses available')),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: settingsProvider.searchType.length,
                                itemBuilder: (context, index) {
                                  final status =
                                      settingsProvider.searchType[index];
                                  final statusId = status.statusId;
                                  if (statusId == null) {
                                    return const SizedBox.shrink();
                                  }
                                  _selectedStatuses.putIfAbsent(
                                      statusId, () => false);

                                  return _StatusRow(
                                    index: index,
                                    name: status.statusName ?? 'Unknown',
                                    isSelected:
                                        _selectedStatuses[statusId] ?? false,
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedStatuses[statusId] =
                                            val ?? false;
                                        _updateSelectAllState();
                                      });
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  // ── Enquiry For card (conditional) ────────────────────────
                  if (settingsProvider.isEnquiryForVisible) ...[
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _SectionLabel('ENQUIRY FOR'),
                              const Spacer(),
                              TextButton(
                                onPressed: () => _toggleSelectAllEnquiryFor(
                                    dropDownProvider),
                                child: Text(
                                  _selectAllEnquiryFor
                                      ? 'Deselect All'
                                      : 'Select All',
                                  style: TextStyle(
                                    color: AppColors.appViolet,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          dropDownProvider.enquiryForList.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                      child:
                                          Text('No enquiry for data available')),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      dropDownProvider.enquiryForList.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        dropDownProvider.enquiryForList[index];
                                    final id = item.enquiryForId;
                                    _selectedEnquiryFor.putIfAbsent(
                                        id, () => false);

                                    return _StatusRow(
                                      index: index,
                                      name: item.enquiryForName,
                                      isSelected:
                                          _selectedEnquiryFor[id] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedEnquiryFor[id] =
                                              val ?? false;
                                          _updateSelectAllEnquiryForState();
                                        });
                                      },
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom save bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {
                      settingsProvider.taskTypeController.clear();
                      settingsProvider.taskTypeDescriptionController.clear();
                      Navigator.pop(context);
                    },
                    radius: 4,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFE2E8F0),
                    textColor: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomElevatedButton(
                    buttonText: 'Save',
                    onPressed: () => _handleSave(settingsProvider),
                    radius: 4,
                    backgroundColor: AppColors.secondaryBlue,
                    borderColor: AppColors.secondaryBlue,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable sub-widgets ────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _StatusRow extends StatelessWidget {
  final int index;
  final String name;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _StatusRow({
    required this.index,
    required this.name,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondaryBlue.withOpacity(0.06)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected
              ? AppColors.secondaryBlue.withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.appViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appViolet,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? const Color(0xFF1E232C) : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: AppColors.secondaryBlue,
          ),
        ],
      ),
    );
  }
}
