import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddTaskType extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String editId;
  final TaskTypeModel? taskType;

  const AddTaskType({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
    this.taskType,
  });

  @override
  State<AddTaskType> createState() => _AddTaskTypeState();
}

class _AddTaskTypeState extends State<AddTaskType> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
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

    // Validate that selected status IDs are all valid (greater than 0)
    for (var statusId in _selectedStatusIds) {
      if (statusId <= 0) {
        return 'One or more selected statuses are invalid';
      }
    }

    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
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
            message,
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
  }

  // Map to store the selected status items
  Map<int, bool> _selectedStatuses = {};
  List<int> get _selectedStatusIds => _selectedStatuses.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.selectedDepartmentId = 0;
      settingsProvider.selectedDefaultStatus = 0;
      settingsProvider.departmentUserController.clear();
      settingsProvider.durationController.clear();

      settingsProvider.defaultStatusController.clear();
      _selectedStatuses.clear();
      settingsProvider.toggleConversionCheckbox(false);
      settingsProvider.toggleLocation(false);

      settingsProvider.getSearchLeadStatus('', "3", context);

      if (widget.isEdit) {
        settingsProvider.taskTypeController.text = widget.status;
        if (widget.taskType?.duration != null) {
          settingsProvider.durationController.text =
              widget.taskType!.duration.toString();
        } else {
          settingsProvider.durationController.clear();
        }
        bool isActive = widget.taskType?.conversionTask == 1 ? true : false;
        bool isLocationTracking =
            widget.taskType?.locationTracking == 1 ? true : false;

        settingsProvider.toggleConversionCheckbox(isActive);
        settingsProvider.toggleLocation(isLocationTracking);

        // Handle department ID if available
        if (widget.taskType?.departmentIds != null &&
            widget.taskType!.departmentIds.isNotEmpty) {
          final departmentId =
              int.tryParse(widget.taskType?.departmentIds ?? '0') ?? 0;

          if (departmentId > 0) {
            settingsProvider.selectedDepartmentId = departmentId;

            // Find department name for display
            final department = settingsProvider.departmentModel.firstWhere(
              (dept) => dept.departmentId == departmentId,
              orElse: () =>
                  DepartmentModel(departmentId: 0, departmentName: ''),
            );

            settingsProvider.departmentUserController.text =
                department.departmentName ?? '';
          }
        }

        // Prefill default status if available
        if (widget.taskType?.defaultStatusId != null &&
            widget.taskType?.defaultStatusId != 0) {
          settingsProvider.selectedDefaultStatus =
              widget.taskType?.defaultStatusId ?? 0;

          // Find status name for display
          final status = settingsProvider.searchType.firstWhere(
            (status) => status.statusId == widget.taskType?.defaultStatusId,
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

        // Set selected statuses if available
        if (widget.taskType?.statuses != null &&
            widget.taskType!.statuses.isNotEmpty) {
          for (var status in widget.taskType!.statuses) {
            if (status.statusId != null && status.statusId! > 0) {
              _selectedStatuses[status.statusId!] = true;
            }
          }
          _updateSelectAllState();
        }
        // settingsProvider.toggleFeedbackCheckbox(
        //     widget.taskType?.feedback == 1 ? true : false);
        // settingsProvider
        //     .toggleOTPCheckbox(widget.taskType?.otp == 1 ? true : false);

        // // If editing, pre-select statuses that were previously selected
        // // This would require the taskType model to include this information
        // if (widget.taskType != null &&
        //     widget.taskType!.taskTypeStatus != null) {
        //   for (var status in widget.taskType!.taskTypeStatus!) {
        //     if (status.statusId != null) {
        //       _selectedStatuses[status.statusId!] = true;
        //     }
        //   }

        //   // Update _selectAll based on current selections
        //   _updateSelectAllState();
        // }
      }
    });
  }

  void _toggleSelectAll() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _selectAll = !_selectAll;
      for (var status in settingsProvider.searchType) {
        if (status.statusId != null && status.statusId! > 0) {
          _selectedStatuses[status.statusId!] = _selectAll;
        }
      }
    });
  }

  void _updateSelectAllState() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.searchType.isEmpty) {
      setState(() {
        _selectAll = false;
      });
      return;
    }

    bool allSelected = true;
    int validStatusCount = 0;

    for (var status in settingsProvider.searchType) {
      if (status.statusId != null && status.statusId! > 0) {
        validStatusCount++;
        if (!_selectedStatuses.containsKey(status.statusId)) {
          _selectedStatuses[status.statusId!] = false;
        }

        if (!(_selectedStatuses[status.statusId!] ?? false)) {
          allSelected = false;
        }
      }
    }

    setState(() {
      _selectAll = allSelected && validStatusCount > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = isWeb
              ? MediaQuery.of(context).size.width * 0.8
              : MediaQuery.of(context).size.width * 0.95;
          final dialogHeight = MediaQuery.of(context).size.height * 0.8;

          return Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Fixed height
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.isEdit ? 'Edit Task Type' : 'Add Task Type',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        settingsProvider.taskTypeController.clear();
                        settingsProvider.durationController.clear();
                        settingsProvider.departmentTaskController.clear();
                        settingsProvider.defaultStatusController.clear();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content - Flexible/Scrollable
                Expanded(
                  child: isWeb
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Details Section - Make it scrollable
                            Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Details',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomTextField(
                                          readOnly: false,
                                          height: 54,
                                          controller: settingsProvider
                                              .taskTypeController,
                                          hintText: 'Task Type name*',
                                          labelText: '',
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomTextField(
                                          readOnly: false,
                                          height: 54,
                                          controller: settingsProvider
                                              .durationController,
                                          hintText: 'Duration*',
                                          labelText: '',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CommonDropdown<int>(
                                          hintText: 'Department*',
                                          selectedValue: widget.isEdit
                                              ? settingsProvider
                                                  .selectedDepartmentId
                                              : null,
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
                                          controller: settingsProvider
                                              .departmentUserController,
                                          onItemSelected: (selectedId) {
                                            settingsProvider
                                                    .selectedDepartmentId =
                                                selectedId;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CommonDropdown<int>(
                                          hintText: 'Status*',
                                          selectedValue: widget.isEdit
                                              ? settingsProvider
                                                  .selectedDefaultStatusId
                                              : null,
                                          items: settingsProvider.searchType
                                              .map((source) =>
                                                  DropdownItem<int>(
                                                    id: source.statusId ?? 0,
                                                    name:
                                                        source.statusName ?? '',
                                                  ))
                                              .toList(),
                                          controller: settingsProvider
                                              .defaultStatusController,
                                          onItemSelected: (selectedId) {
                                            settingsProvider
                                                    .selectedDefaultStatus =
                                                selectedId;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      CheckboxListTile(
                                        title: const Text(
                                          "Conversion Task",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value: settingsProvider
                                            .isConversionChecked,
                                        onChanged: (value) {
                                          settingsProvider
                                              .toggleConversionCheckbox(value!);
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(height: 10),
                                      CheckboxListTile(
                                        title: const Text(
                                          "Location Tracking",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value:
                                            settingsProvider.isLocationTracking,
                                        onChanged: (value) {
                                          settingsProvider
                                              .toggleLocation(value!);
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.grey[300],
                            ),

                            // Status Section for Web - Already has proper structure
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header - Fixed
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Manage Status',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // Column headers - Fixed
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                              width: 48,
                                              child:
                                                  Center(child: Text('No.'))),
                                          Expanded(child: Text('Status Name')),
                                          Center(
                                            child: Checkbox(
                                              value: _selectAll,
                                              onChanged: (value) =>
                                                  _toggleSelectAll(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // List - Scrollable
                                    Expanded(
                                      child: settingsProvider.searchType.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  'No lead statuses available'))
                                          : ListView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              itemCount: settingsProvider
                                                  .searchType.length,
                                              itemBuilder: (context, index) {
                                                final status = settingsProvider
                                                    .searchType[index];
                                                final statusId =
                                                    status.statusId;

                                                if (statusId == null) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                if (!_selectedStatuses
                                                    .containsKey(statusId)) {
                                                  _selectedStatuses[statusId] =
                                                      false;
                                                }

                                                return Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4,
                                                      horizontal: 8),
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 2,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 48,
                                                        child: Center(
                                                            child: Text(
                                                                '${index + 1}')),
                                                      ),
                                                      Expanded(
                                                          child: Text(status
                                                                  .statusName ??
                                                              'Unknown')),
                                                      SizedBox(
                                                        width: 24,
                                                        child: Checkbox(
                                                          value:
                                                              _selectedStatuses[
                                                                      statusId] ??
                                                                  false,
                                                          onChanged:
                                                              (bool? value) {
                                                            setState(() {
                                                              _selectedStatuses[
                                                                      statusId] =
                                                                  value ??
                                                                      false;
                                                              _updateSelectAllState();
                                                            });
                                                          },
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : // Mobile Layout - Stacked vertically
                      SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Details Section for Mobile
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Details',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 54,
                                      controller:
                                          settingsProvider.taskTypeController,
                                      hintText: 'Task Type name*',
                                      labelText: '',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 54,
                                      controller:
                                          settingsProvider.durationController,
                                      hintText: 'Duration*',
                                      labelText: '',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CommonDropdown<int>(
                                      hintText: 'Department*',
                                      selectedValue: widget.isEdit
                                          ? settingsProvider
                                              .selectedDepartmentId
                                          : null,
                                      items: settingsProvider.departmentModel
                                          .map((source) => DropdownItem<int>(
                                                id: source.departmentId,
                                                name:
                                                    source.departmentName ?? '',
                                              ))
                                          .toList(),
                                      controller: settingsProvider
                                          .departmentUserController,
                                      onItemSelected: (selectedId) {
                                        settingsProvider.selectedDepartmentId =
                                            selectedId;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CommonDropdown<int>(
                                      hintText: 'Status*',
                                      selectedValue: widget.isEdit
                                          ? settingsProvider
                                              .selectedDefaultStatusId
                                          : null,
                                      items: settingsProvider.searchType
                                          .map((source) => DropdownItem<int>(
                                                id: source.statusId ?? 0,
                                                name: source.statusName ?? '',
                                              ))
                                          .toList(),
                                      controller: settingsProvider
                                          .defaultStatusController,
                                      onItemSelected: (selectedId) {
                                        settingsProvider.selectedDefaultStatus =
                                            selectedId;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  CheckboxListTile(
                                      title: const Text(
                                        "Conversion Task",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value:
                                          settingsProvider.isConversionChecked,
                                      onChanged: (value) {
                                        settingsProvider
                                            .toggleConversionCheckbox(value!);
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero),
                                  const SizedBox(height: 10),
                                  CheckboxListTile(
                                      title: const Text(
                                        "Location Tracking",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value:
                                          settingsProvider.isLocationTracking,
                                      onChanged: (value) {
                                        settingsProvider.toggleLocation(value!);
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero),
                                  const SizedBox(height: 30),
                                ],
                              ),

                              // Divider
                              Container(
                                height: 1,
                                color: Colors.grey[300],
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),

                              // Status Section for Mobile - Optimized Design
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Manage Status',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectAll = !_selectAll;
                                                for (var status
                                                    in settingsProvider
                                                        .searchType) {
                                                  if (status.statusId != null) {
                                                    _selectedStatuses[
                                                            status.statusId!] =
                                                        _selectAll;
                                                  }
                                                }
                                              });
                                            },
                                            child: Text(
                                              _selectAll
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
                                    ),
                                    Expanded(
                                      child: settingsProvider.searchType.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  'No lead statuses available'))
                                          : ListView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              itemCount: settingsProvider
                                                  .searchType.length,
                                              itemBuilder: (context, index) {
                                                final status = settingsProvider
                                                    .searchType[index];
                                                final statusId =
                                                    status.statusId;

                                                if (statusId == null) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                if (!_selectedStatuses
                                                    .containsKey(statusId)) {
                                                  _selectedStatuses[statusId] =
                                                      false;
                                                }

                                                return Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 2,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .appViolet
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${index + 1}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColors
                                                                  .appViolet,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          status.statusName ??
                                                              'Unknown',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Checkbox(
                                                        value:
                                                            _selectedStatuses[
                                                                    statusId] ??
                                                                false,
                                                        onChanged:
                                                            (bool? value) {
                                                          setState(() {
                                                            _selectedStatuses[
                                                                    statusId] =
                                                                value ?? false;
                                                            _updateSelectAllState();
                                                          });
                                                        },
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      buttonText: 'Cancel',
                      onPressed: () {
                        settingsProvider.taskTypeController.clear();
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.white,
                      borderColor: AppColors.appViolet,
                      textColor: AppColors.appViolet,
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      buttonText: 'Save',
                      onPressed: () async {
                        final validationError =
                            validateInputs(context, settingsProvider);
                        if (validationError != null) {
                          showErrorDialog(context, validationError);
                          return;
                        }

                        final taskTypeStatus = _selectedStatuses.entries
                            .where((entry) => entry.value)
                            .map((entry) => {"Status_Id": entry.key})
                            .toList();

                        final requestData = {
                          "Task_Type_Id": widget.isEdit
                              ? int.tryParse(widget.editId) ?? 0
                              : 0,
                          "Task_Type_Name":
                              settingsProvider.taskTypeController.text,
                          "Task_Type_Color": "",
                          "Task_Type_Image": "",
                          "Department_Ids":
                              settingsProvider.selectedDepartmentId.toString(),
                          "Branch_Ids": "",
                          "default_status_id":
                              settingsProvider.selectedDefaultStatusId,
                          "Duration": int.tryParse(
                                  settingsProvider.durationController.text) ??
                              0,
                          "task_type_status": taskTypeStatus,
                          "Is_Active":
                              settingsProvider.isConversionChecked ? 1 : 0,
                          "Location_Tracking":
                              settingsProvider.isLocationTracking ? 1 : 0
                        };

                        settingsProvider.addTaskType(
                            context: context, data: requestData);
                      },
                      backgroundColor: AppColors.appViolet,
                      borderColor: AppColors.appViolet,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}












      // Checkboxes for Feedback & OTP
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // Feedback Checkbox
            //     Expanded(
            //       child: GestureDetector(
            //         onTap: () => settingsProvider.toggleFeedbackCheckbox(
            //             settingsProvider.isFeedbackChecked != 1),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 8, horizontal: 12),
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: Colors.grey[300]!),
            //           ),
            //           child: Row(
            //             children: [
            //               Checkbox(
            //                 value: settingsProvider.isFeedbackChecked == 1,
            //                 onChanged: (bool? value) {
            //                   settingsProvider
            //                       .toggleFeedbackCheckbox(value ?? false);
            //                 },
            //               ),
            //               const SizedBox(width: 5),
            //               const Text(
            //                 "Enable Feedback",
            //                 style: TextStyle(fontSize: 16),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),

            //     const SizedBox(width: 10),

            //     // OTP Checkbox
            //     Expanded(
            //       child: GestureDetector(
            //         onTap: () => settingsProvider
            //             .toggleOTPCheckbox(settingsProvider.isOTPChecked != 1),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 8, horizontal: 12),
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: Colors.grey[300]!),
            //           ),
            //           child: Row(
            //             children: [
            //               Checkbox(
            //                 value: settingsProvider.isOTPChecked == 1,
            //                 onChanged: (bool? value) {
            //                   settingsProvider
            //                       .toggleOTPCheckbox(value ?? false);
            //                 },
            //               ),
            //               const SizedBox(width: 5),
            //               const Text(
            //                 "Enable OTP",
            //                 style: TextStyle(fontSize: 16),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),