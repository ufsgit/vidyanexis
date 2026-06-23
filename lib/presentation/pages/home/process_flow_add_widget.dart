import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/process_flow_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/models/task_flow_model.dart';
import 'package:vidyanexis/controller/process_flow_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class ProcessFlowAddWidget extends StatefulWidget {
  final bool isEdit;
  ProcessFlowModel processFlowModel; // Add this for edit mode

  ProcessFlowAddWidget({
    super.key,
    required this.isEdit,
    required this.processFlowModel,
  });

  @override
  State<ProcessFlowAddWidget> createState() => _ProcessFlowAddWidgetState();
}

class _ProcessFlowAddWidgetState extends State<ProcessFlowAddWidget> {
  late ProcessFlowProvider processFlowProvider;
  final TextEditingController taskTypeController = TextEditingController();
  final TextEditingController taskStatusController = TextEditingController();
  final TextEditingController enquiryForController = TextEditingController();
  final TextEditingController leadStatusController = TextEditingController();
  final TextEditingController templateIdController = TextEditingController();
  bool isEditingMandatoryTask = false;
  bool isSavingData = false;
  int? selectedMandatoryTaskIndex;
  late final Future<
      (
        List<TaskTypeModel>,
        List<TaskTypeStatusModel>,
        List<DepartmentModel>,
        List<BranchModel>,
        List<DocumentTypeModel>,
        List<EnquiryForModel>,
        List<SearchLeadStatusModel>,
      )> _taskDataFuture;
  Future<List<TaskTypeModel>>? _taskTypeByDepartmentFuture;

  // For editing
  int? selectedTaskFlowIndex;
  bool isEditingTaskFlow = false;

  // For Custom Fields
  final List<CustomFieldModel> _selectedCustomFields = [];
  final Map<int, String> _customFieldValues = {};
  final Map<int, TextEditingController> _customFieldControllers = {};

  // For Show Custom Fields
  final List<CustomFieldModel> _showCustomFields = [];

  void _onDrawerClosed(BuildContext context) {
    // Also reset the process flow provider
    // processFlowProvider.reset();
  }

  @override
  void initState() {
    super.initState();

    processFlowProvider =
        Provider.of<ProcessFlowProvider>(context, listen: false);
    if (widget.processFlowModel.flowId.isGreaterThanZero()) {
      processFlowProvider.processFlowModel = widget.processFlowModel;
    }
    _taskDataFuture = processFlowProvider.getAllTskTypeStatus(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProv =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProv.getCustomField(context);
      processFlowProvider.showLeadStatus = false;

      if (null != widget.processFlowModel.flowId &&
          widget.processFlowModel.flowId! > 0) {
        await processFlowProvider.getProcessFlowById(
            context, widget.processFlowModel.flowId!);
        _initializeSavedCustomFields(settingsProv.customFieldModelList);
        templateIdController.text =
            processFlowProvider.processFlowModel.templateId ?? '';
        _showCustomFields.clear();
        _showCustomFields.addAll(processFlowProvider.showCustomFields);
      }
    });
  }

  @override
  void dispose() {
    taskTypeController.dispose();
    taskStatusController.dispose();
    templateIdController.dispose();
    enquiryForController.dispose();
    leadStatusController.dispose();
    for (var controller in _customFieldControllers.values) {
      controller.dispose();
    }
    processFlowProvider.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessFlowProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppStyles.isWebScreen(context)
            ? null
            : AppBar(
                title: Text(
                  widget.isEdit ? 'Edit Process flow' : 'Add Process flow',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textBlue800,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: const Color(0xFFF7FAF9),
                elevation: 0,
                leading: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textGrey4,
                    ),
                    iconSize: 24,
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                radius: 4,
                buttonText: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                  _onDrawerClosed(context);
                },
                backgroundColor: Colors.white,
                borderColor: AppColors.appViolet,
                textColor: AppColors.appViolet,
              ),
              const SizedBox(width: 12),
              isSavingData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : CustomElevatedButton(
                      radius: 4,
                      buttonText: 'Save',
                      onPressed: saveData,
                      backgroundColor: AppColors.secondaryBlue,
                      borderColor: AppColors.secondaryBlue,
                      textColor: Colors.white,
                    ),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(16.0), children: [
            if (AppStyles.isWebScreen(context))
              Text(
                widget.isEdit ? 'Edit Process flow' : 'Add Process flow',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 16),
            FutureBuilder<
                    (
                      List<TaskTypeModel>,
                      List<TaskTypeStatusModel>,
                      List<DepartmentModel>,
                      List<BranchModel>,
                      List<DocumentTypeModel>,
                      List<EnquiryForModel>,
                      List<SearchLeadStatusModel>,
                    )>(
                future: _taskDataFuture,
                builder: (contextBuilder, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Loading state
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<TaskTypeModel> taskTypeList = snapshot.data?.$1 ?? [];
                  List<TaskTypeStatusModel> taskTypeStatusList =
                      snapshot.data?.$2 ?? [];
                  List<DepartmentModel> departmentList =
                      snapshot.data?.$3 ?? [];
                  List<BranchModel> branchList = snapshot.data?.$4 ?? [];
                  List<DocumentTypeModel> documentTypeList =
                      snapshot.data?.$5 ?? [];
                  List<EnquiryForModel> enquiryForList =
                      snapshot.data?.$6 ?? [];
                  List<SearchLeadStatusModel> searchLeadStatusList =
                      snapshot.data?.$7 ?? [];

                  final isWeb = AppStyles.isWebScreen(context);
                  final settingsProvider =
                      Provider.of<SettingsProvider>(context);

                  final enquiryForDropdown = CommonDropdown<EnquiryForModel>(
                    hintText: 'Enquiry For *',
                    items: enquiryForList
                        .map((status) => DropdownItem<EnquiryForModel>(
                              id: status,
                              name: status.enquiryForName,
                            ))
                        .toList(),
                    controller: enquiryForController,
                    selectedValue: enquiryForList
                        .where((element) =>
                            element.enquiryForId ==
                            processFlowProvider.processFlowModel.enquiryForId)
                        .firstOrNull,
                    onItemSelected: (EnquiryForModel? newValue) {
                      if (newValue != null) {
                        processFlowProvider.processFlowModel.enquiryForId =
                            newValue.enquiryForId;
                        processFlowProvider.processFlowModel.enquiryForName =
                            newValue.enquiryForName;

                        processFlowProvider.setProcessFlowModel(
                            processFlowProvider.processFlowModel);
                        setState(() {});
                      }
                    },
                  );

                  final leadStatusDropdown =
                      CommonDropdown<SearchLeadStatusModel>(
                    hintText: 'Update in lead/ Customer',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: processFlowProvider.showLeadStatus,
                        onChanged: (value) {
                          processFlowProvider.showLeadStatus = value ?? false;
                        },
                      ),
                    ),
                    items: searchLeadStatusList
                        .map((status) => DropdownItem<SearchLeadStatusModel>(
                              id: status,
                              name: status.statusName ?? '',
                            ))
                        .toList(),
                    controller: leadStatusController,
                    selectedValue: searchLeadStatusList
                        .where((element) =>
                            element.statusId ==
                            processFlowProvider.processFlowModel.leadStatusId)
                        .firstOrNull,
                    onItemSelected: (SearchLeadStatusModel? newValue) {
                      if (newValue != null) {
                        processFlowProvider.processFlowModel.leadStatusId =
                            newValue.statusId ?? 0;
                        processFlowProvider.processFlowModel.leadStatusName =
                            newValue.statusName ?? '';

                        processFlowProvider.setProcessFlowModel(
                            processFlowProvider.processFlowModel);
                        setState(() {});
                      }
                    },
                  );

                  final leadStatusWidget = processFlowProvider.showLeadStatus
                      ? leadStatusDropdown
                      : InputDecorator(
                          isEmpty: true,
                          decoration: InputDecoration(
                            labelText: "Update in lead/ Customer",
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGrey3,
                            ),
                            floatingLabelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey1,
                            ),
                            prefixIcon: Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: processFlowProvider.showLeadStatus,
                                onChanged: (value) {
                                  processFlowProvider.showLeadStatus =
                                      value ?? false;
                                },
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppColors.textGrey2, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: isWeb
                                      ? AppColors.textGrey2
                                      : AppColors.grey,
                                  width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                          ),
                          child: const SizedBox(height: 0),
                        );

                  final taskTypeDropdown = CommonDropdown<TaskTypeModel>(
                    hintText: 'Task type *',
                    items: taskTypeList
                        .map((status) => DropdownItem<TaskTypeModel>(
                              id: status,
                              name: status.taskTypeName,
                            ))
                        .toList(),
                    controller: taskTypeController,
                    selectedValue: taskTypeList
                        .where((element) =>
                            element.taskTypeId ==
                            processFlowProvider.processFlowModel.taskTypeId)
                        .firstOrNull,
                    onItemSelected: (TaskTypeModel? newValue) {
                      if (newValue != null) {
                        processFlowProvider.processFlowModel.taskTypeId =
                            newValue.taskTypeId;
                        processFlowProvider.processFlowModel.taskTypeName =
                            newValue.taskTypeName;

                        processFlowProvider.processFlowModel.statusId = 0;
                        processFlowProvider.processFlowModel.statusName = "";

                        processFlowProvider.setProcessFlowModel(
                            processFlowProvider.processFlowModel);
                        // Clear task status when task type changes

                        taskStatusController.clear();
                        setState(() {});
                      }
                    },
                  );

                  final taskTypeStatusDropdown =
                      CommonDropdown<TaskTypeStatusModel>(
                    hintText: 'Task type status *',
                    items: taskTypeStatusList
                        .where((element) =>
                            processFlowProvider.processFlowModel.taskTypeId ==
                            element.taskTypeId)
                        .map((status) => DropdownItem<TaskTypeStatusModel>(
                              id: status,
                              name: status.statusName ?? "NA",
                            ))
                        .toList(),
                    controller: taskStatusController,
                    key: ValueKey(
                        processFlowProvider.processFlowModel.taskTypeId),
                    onItemSelected: (TaskTypeStatusModel? newValue) {
                      if (newValue != null) {
                        processFlowProvider.processFlowModel.statusId =
                            newValue.statusId;
                        processFlowProvider.processFlowModel.statusName =
                            newValue.statusName;
                        processFlowProvider.setProcessFlowModel(
                            processFlowProvider.processFlowModel);
                        setState(() {});
                      }
                    },
                    selectedValue: taskTypeStatusList
                        .where((element) => (element.taskTypeId ==
                                processFlowProvider
                                    .processFlowModel.taskTypeId &&
                            element.statusId ==
                                processFlowProvider.processFlowModel.statusId))
                        .firstOrNull,
                  );

                  final branchDropdown = CommonDropdown<int>(
                    hintText: 'Branch *',
                    isMultiLine: true,
                    items: branchList
                        .map((status) => DropdownItem<int>(
                              id: status.branchId!,
                              name: status.branchName!,
                            ))
                        .toList(),
                    onItemSelected: (int? newValue) {
                      if (newValue != null) {
                        processFlowProvider.taskFlowModel.branchId = newValue;
                        processFlowProvider.setTaskFlowModel(
                            processFlowProvider.taskFlowModel);
                      }
                    },
                    selectedValue: processFlowProvider.taskFlowModel.branchId,
                  );

                  final departmentDropdown = CommonDropdown<int>(
                    hintText: 'Department *',
                    items: departmentList
                        .map((status) => DropdownItem<int>(
                              id: status.departmentId,
                              name: status.departmentName,
                            ))
                        .toList(),
                    onItemSelected: (int? newValue) {
                      if (newValue != null) {
                        processFlowProvider.taskFlowModel.departmentId =
                            newValue;
                        processFlowProvider.setTaskFlowModel(
                            processFlowProvider.taskFlowModel);
                      }
                      processFlowProvider.taskFlowModel.taskTypeId = 0;
                      processFlowProvider
                          .setTaskFlowModel(processFlowProvider.taskFlowModel);
                      _taskTypeByDepartmentFuture =
                          processFlowProvider.getTaskTypeByDepartment(
                              context, newValue.toString());
                    },
                    selectedValue:
                        processFlowProvider.taskFlowModel.departmentId ?? 0,
                  );

                  final departmentTaskTypeDropdown =
                      FutureBuilder<List<TaskTypeModel>>(
                          future: _taskTypeByDepartmentFuture,
                          builder: (contextBuilder, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return CommonDropdown<int>(
                              hintText: 'Task type *',
                              items: (snapshot.data ?? [])
                                  .map((status) => DropdownItem<int>(
                                        id: status.taskTypeId,
                                        name: status.taskTypeName,
                                      ))
                                  .toList(),
                              onItemSelected: (int? newValue) {
                                if (newValue != null) {
                                  processFlowProvider.taskFlowModel.taskTypeId =
                                      newValue;
                                  processFlowProvider.setTaskFlowModel(
                                      processFlowProvider.taskFlowModel);
                                }
                              },
                              selectedValue: processFlowProvider
                                      .taskFlowModel.taskTypeId ??
                                  0,
                            );
                          });

                  final mandatoryTaskTypeDropdown = IgnorePointer(
                    ignoring: isEditingMandatoryTask,
                    child: CommonDropdown<int>(
                      hintText: 'Task type',
                      items: taskTypeList
                          .map((status) => DropdownItem<int>(
                                id: status.taskTypeId,
                                name: status.taskTypeName,
                              ))
                          .toList(),
                      onItemSelected: (int? newValue) {
                        if (newValue != null) {
                          int existIndex = processFlowProvider.mandatoryTaskList
                              .indexWhere(
                                  (element) => element.taskTypeId == newValue);

                          if (existIndex == -1) {
                            MandatoryTaskModel model = MandatoryTaskModel(
                              taskTypeId: newValue,
                              statusIds: processFlowProvider
                                      .mandatoryTaskModel.statusIds ??
                                  [],
                            );
                            processFlowProvider.setMandatoryTaskModel(model);
                            setState(() {});
                          } else {
                            showToastInDialog(
                                'Task type already exist', context);

                            processFlowProvider.setMandatoryTaskModel(
                                MandatoryTaskModel(
                                    taskTypeId: null, statusIds: []));
                            setState(() {});
                          }
                        }
                      },
                      selectedValue:
                          processFlowProvider.mandatoryTaskModel.taskTypeId ??
                              0,
                    ),
                  );

                  final assignStatusButton = TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Assign Status'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      foregroundColor: AppColors.secondaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      if (processFlowProvider.mandatoryTaskModel.taskTypeId
                          .isGreaterThanZero()) {
                        showStatusTypeDialog(selectedMandatoryTaskIndex ?? -1,
                            taskTypeStatusList);
                      } else {
                        showToastInDialog('Please select a task type', context);
                      }
                    },
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isWeb
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: enquiryForDropdown),
                                    const SizedBox(width: 10),
                                    Expanded(child: taskTypeDropdown),
                                    const SizedBox(width: 10),
                                    Expanded(child: taskTypeStatusDropdown),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: leadStatusWidget),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child:
                                            Container()), // remove this to add new fields
                                    const SizedBox(width: 10),
                                    Expanded(child: Container()),
                                  ],
                                )
                              ],
                            )
                          : Column(
                              children: [
                                enquiryForDropdown,
                                const SizedBox(height: 16),
                                taskTypeDropdown,
                                const SizedBox(height: 16),
                                taskTypeStatusDropdown,
                                const SizedBox(height: 16),
                                leadStatusWidget,
                              ],
                            ),
                      const SizedBox(height: 16),
                      _buildCustomFieldsSection(
                          settingsProvider.customFieldModelList),
                      const SizedBox(height: 16),
                      Text(
                        'Show Custom Fields',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textBlue800,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showShowCustomFieldsDialog(
                            settingsProvider.customFieldModelList),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            readOnly: true,
                            controller: TextEditingController(),
                            height: 54,
                            hintText: 'Select Custom Fields',
                            labelText: '',
                            suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ),
                      ),
                      if (_showCustomFields.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                _showCustomFields.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final field = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.appViolet,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      field.customFieldName ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showCustomFields.removeAt(idx);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: templateIdController,
                        hintText: 'Template ID',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create task',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textBlue800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      isWeb
                          ? Row(
                              children: [
                                Expanded(child: branchDropdown),
                                const SizedBox(width: 10),
                                Expanded(child: departmentDropdown),
                                const SizedBox(width: 10),
                                Expanded(child: departmentTaskTypeDropdown),
                              ],
                            )
                          : Column(
                              children: [
                                branchDropdown,
                                const SizedBox(height: 16),
                                departmentDropdown,
                                const SizedBox(height: 16),
                                departmentTaskTypeDropdown,
                              ],
                            ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomElevatedButton(
                            radius: 4,
                            buttonText: isEditingTaskFlow
                                ? 'Update Task'
                                : 'Add Task to Flow',
                            onPressed: () {
                              _addTaskToFlow();
                            },
                            backgroundColor: AppColors.secondaryBlue,
                            borderColor: AppColors.secondaryBlue,
                            textColor: AppColors.whiteColor,
                          ),
                          if (isEditingTaskFlow)
                            TextButton(
                              onPressed: () {
                                // Cancel editing mode
                                isEditingTaskFlow = false;
                                selectedTaskFlowIndex = null;
                                processFlowProvider.taskFlowModel =
                                    TaskFlowModel();
                                setState(() {});
                              },
                              child: const Text('Cancel Editing'),
                            ),
                        ],
                      ),
                      _buildTaskFlowList(
                          taskTypeList, departmentList, branchList),
                      const SizedBox(height: 24),
                      Text(
                        'Mandatory task',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textBlue800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      isWeb
                          ? Row(
                              children: [
                                Expanded(child: mandatoryTaskTypeDropdown),
                                const SizedBox(width: 10),
                                assignStatusButton,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                mandatoryTaskTypeDropdown,
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: assignStatusButton,
                                ),
                              ],
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomElevatedButton(
                              radius: 4,
                              buttonText:
                                  isEditingMandatoryTask ? 'Update' : "Add",
                              onPressed: _addMandatoryTask,
                              backgroundColor: AppColors.secondaryBlue,
                              borderColor: AppColors.secondaryBlue,
                              textColor: AppColors.whiteColor,
                            ),
                            const SizedBox(width: 8),
                            if (isEditingMandatoryTask)
                              TextButton(
                                onPressed: () {
                                  // Cancel editing mode
                                  isEditingMandatoryTask = false;
                                  selectedMandatoryTaskIndex = null;
                                  processFlowProvider.setMandatoryTaskModel(
                                      MandatoryTaskModel(
                                          taskTypeId: null, statusIds: []));
                                  setState(() {});
                                },
                                child: const Text('Cancel Editing'),
                              ),
                          ],
                        ),
                      ),
                      _buildMandatoryTaskList(taskTypeList, taskTypeStatusList),
                      const SizedBox(height: 24),
                      Text(
                        'Mandatory Document',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textBlue800,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Consumer<ProcessFlowProvider>(
                        builder: (context, provider, child) {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: documentTypeList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final doc = documentTypeList[index];
                              bool isSelected = provider.selectedDocuments.any(
                                  (selected) =>
                                      selected.documentTypeId ==
                                      doc.documentTypeId);
                              return InkWell(
                                onTap: () =>
                                    provider.toggleDocumentSelection(doc),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.documentTypeName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            color: AppColors.textBlue800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor: AppColors.secondaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: (bool? value) {
                                            provider
                                                .toggleDocumentSelection(doc);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  );
                })
          ]),
        ),
      );
    });
  }

  Widget _buildMandatoryTaskList(
      List<TaskTypeModel> taskTypes, List<TaskTypeStatusModel> statusList) {
    if (processFlowProvider.mandatoryTaskList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.check_circle_outline_rounded,
                    size: 32, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'No mandatory tasks added yet',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.secondaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mandatory Tasks',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textBlue800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${processFlowProvider.mandatoryTaskList.length} ${processFlowProvider.mandatoryTaskList.length == 1 ? 'task' : 'tasks'}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: processFlowProvider.mandatoryTaskList.length,
          itemBuilder: (context, index) {
            final task = processFlowProvider.mandatoryTaskList[index];

            // Get task type name
            final typeName = taskTypes
                    .where((element) => element.taskTypeId == task.taskTypeId)
                    .firstOrNull
                    ?.taskTypeName ??
                "N/A";

            // Get status names
            final statusIds = task.statusIds ?? [];
            final statusNames = statusIds.map((id) {
              return statusList
                      .where((status) => status.statusId.toString() == id)
                      .firstOrNull
                      ?.statusName ??
                  "Unknown";
            }).join(", ");

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.secondaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlue800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  statusNames.isEmpty
                                      ? 'No statuses assigned'
                                      : statusNames,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                        InkWell(
                          onTap: () {
                            _editMandatoryTask(index, taskTypes);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to remove this mandatory task?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      processFlowProvider
                                          .removeMandatory(index);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void showStatusTypeDialog(
      int index, List<TaskTypeStatusModel> taskTypeStatusList) {
    List<String> selectedStatusIds =
        processFlowProvider.mandatoryTaskModel.statusIds ?? [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select status'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: taskTypeStatusList
                      .where((element) =>
                          processFlowProvider.mandatoryTaskModel.taskTypeId ==
                          element.taskTypeId)
                      .map((status) => DropdownItem<TaskTypeStatusModel>(
                            id: status,
                            name: status.statusName ?? "NA",
                          ))
                      .toList()
                      .map((status) {
                    bool isSelected = selectedStatusIds
                        .contains(status.id.statusId.toString());

                    return ListTile(
                      title: Text(status.name ?? ''),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.radio_button_unchecked,
                              color: Colors.grey),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedStatusIds
                                .remove(status.id.statusId.toString());
                          } else {
                            selectedStatusIds
                                .add(status.id.statusId.toString());
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                CustomElevatedButton(
                  radius: 4,
                  onPressed: () {
                    Navigator.pop(context); // Close dialog without saving
                  },
                  buttonText: 'Cancel',
                  backgroundColor: AppColors.whiteColor,
                  borderColor: AppColors.secondaryBlue,
                  textColor: AppColors.secondaryBlue,
                ),
                CustomElevatedButton(
                  radius: 4,
                  onPressed: () {
                    processFlowProvider.mandatoryTaskModel.statusIds =
                        selectedStatusIds;
                    Navigator.pop(context); // Close dialog and save
                  },
                  buttonText: "Confirm",
                  backgroundColor: AppColors.secondaryBlue,
                  borderColor: AppColors.secondaryBlue,
                  textColor: AppColors.whiteColor,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addMandatoryTask() {
    if (processFlowProvider.mandatoryTaskModel.taskTypeId == null ||
        !processFlowProvider.mandatoryTaskModel.taskTypeId
            .isGreaterThanZero()) {
      showToastInDialog('Please select a task type', context);
      return;
    }
    if (processFlowProvider.mandatoryTaskModel.statusIds == null ||
        processFlowProvider.mandatoryTaskModel.statusIds!.isEmpty) {
      showToastInDialog('Please assign at least one status', context);
      return;
    }

    if (isEditingMandatoryTask && selectedMandatoryTaskIndex != null) {
      processFlowProvider.updateMandatoryTask(
          selectedMandatoryTaskIndex!, processFlowProvider.mandatoryTaskModel);
      isEditingMandatoryTask = false;
      selectedMandatoryTaskIndex = null;
    } else {
      processFlowProvider.updateMandatoryTask(
          -1, processFlowProvider.mandatoryTaskModel);
    }

    processFlowProvider.setMandatoryTaskModel(MandatoryTaskModel());
    setState(() {});
  }

  void _editMandatoryTaskFlow(
      int index,
      TaskFlowModel task,
      List<BranchModel> branches,
      List<DepartmentModel> departments,
      List<TaskTypeModel> taskTypes) {
    isEditingTaskFlow = true;
    selectedTaskFlowIndex = index;

    // Set the task flow model for editing
    processFlowProvider.setTaskFlowModel(task);

    setState(() {});
  }

  void _editMandatoryTask(int index, List<TaskTypeModel> taskTypes) {
    isEditingMandatoryTask = true;
    selectedMandatoryTaskIndex = index;

    // Get the mandatory task from the list
    final mandatoryTask = processFlowProvider.mandatoryTaskList[index];

    // Set the mandatory task model for editing
    processFlowProvider.setMandatoryTaskModel(mandatoryTask);

    // Find the task type name
    // final taskType = taskTypes.firstWhere(
    //       (type) => type.taskTypeId == mandatoryTask.taskTypeId,
    //   orElse: () => TaskTypeModel(),
    // );

    setState(() {});
  }

  void _initializeSavedCustomFields(List<CustomFieldModel> allCustomFields) {
    if (processFlowProvider.savedCustomFields.isEmpty) return;

    _selectedCustomFields.clear();
    _customFieldValues.clear();

    for (var saved in processFlowProvider.savedCustomFields) {
      final int? fieldId =
          int.tryParse(saved["custom_field_id"]?.toString() ?? '');
      if (fieldId == null) continue;

      final fieldModel = allCustomFields.firstWhere(
        (element) => element.customFieldId == fieldId,
        orElse: () => CustomFieldModel(
            customFieldId: fieldId, customFieldName: "Field $fieldId"),
      );

      _selectedCustomFields.add(fieldModel);
      _customFieldValues[fieldId] = saved["value"]?.toString() ?? '';

      // Initialize controller if applicable
      final type = CustomFieldType.fromValue(fieldModel.customFieldTypeId);
      if (type != CustomFieldType.dropdown &&
          type != CustomFieldType.checkbox) {
        _customFieldControllers[fieldId] =
            TextEditingController(text: saved["value"]?.toString() ?? '');
      }
    }
    setState(() {});
  }

  Widget _buildCustomFieldsSection(List<CustomFieldModel> allCustomFields) {
    final availableCustomFields = allCustomFields
        .where((field) => !_selectedCustomFields
            .any((selected) => selected.customFieldId == field.customFieldId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Fields',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textBlue800,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        CommonDropdown<CustomFieldModel>(
          key: ValueKey(
              'custom_fields_dropdown_${_selectedCustomFields.length}'),
          hintText: 'Select custom field to add',
          items: availableCustomFields
              .map((field) => DropdownItem<CustomFieldModel>(
                    id: field,
                    name: field.customFieldName ?? 'Unnamed Field',
                  ))
              .toList(),
          onItemSelected: (CustomFieldModel? selectedField) {
            if (selectedField != null) {
              setState(() {
                _selectedCustomFields.add(selectedField);
                _customFieldValues[selectedField.customFieldId!] = '';
                final type =
                    CustomFieldType.fromValue(selectedField.customFieldTypeId);
                if (type != CustomFieldType.dropdown &&
                    type != CustomFieldType.checkbox) {
                  _customFieldControllers[selectedField.customFieldId!] =
                      TextEditingController();
                }
              });
            }
          },
        ),
        if (_selectedCustomFields.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedCustomFields.length,
            itemBuilder: (context, index) {
              final field = _selectedCustomFields[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildCustomFieldInputWidget(field),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedCustomFields.removeWhere((element) =>
                              element.customFieldId == field.customFieldId);
                          _customFieldValues.remove(field.customFieldId);
                          _customFieldControllers[field.customFieldId]
                              ?.dispose();
                          _customFieldControllers.remove(field.customFieldId);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCustomFieldInputWidget(CustomFieldModel field) {
    final type = CustomFieldType.fromValue(field.customFieldTypeId);
    final value = _customFieldValues[field.customFieldId] ?? '';

    if (type == CustomFieldType.dropdown) {
      return CommonDropdown<String>(
        hintText: field.customFieldName ?? 'Select value',
        items: (field.dropDownValues ?? [])
            .map((val) => DropdownItem<String>(id: val, name: val))
            .toList(),
        selectedValue: value.isNotEmpty ? value : null,
        onItemSelected: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _customFieldValues[field.customFieldId!] = newValue;
            });
          }
        },
      );
    } else if (type == CustomFieldType.checkbox) {
      final options = field.checkBoxValues ?? [];
      List<String> selectedList =
          value.split(',').where((e) => e.isNotEmpty).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.customFieldName ?? 'Select values',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlue800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: options.map((opt) {
              final isChecked = selectedList.contains(opt);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: AppColors.secondaryBlue,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          if (!selectedList.contains(opt)) {
                            selectedList.add(opt);
                          }
                        } else {
                          selectedList.remove(opt);
                        }
                        _customFieldValues[field.customFieldId!] =
                            selectedList.join(',');
                      });
                    },
                  ),
                  Text(
                    opt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    } else if (type == CustomFieldType.datePicker) {
      final controller = _customFieldControllers[field.customFieldId] ??
          TextEditingController(text: value);
      return CustomTextField(
        controller: controller,
        hintText: field.customFieldName ?? 'Select Date',
        readOnly: true,
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            final formattedDate = "${picked.year.toString().padLeft(4, '0')}-"
                "${picked.month.toString().padLeft(2, '0')}-"
                "${picked.day.toString().padLeft(2, '0')}";
            setState(() {
              _customFieldValues[field.customFieldId!] = formattedDate;
              controller.text = formattedDate;
            });
          }
        },
      );
    } else {
      final controller = _customFieldControllers[field.customFieldId] ??
          TextEditingController(text: value);
      return CustomTextField(
        controller: controller,
        hintText: field.customFieldName ?? 'Enter value',
        keyboardType: type == CustomFieldType.numberOnly
            ? TextInputType.number
            : TextInputType.text,
        onChanged: (val) {
          _customFieldValues[field.customFieldId!] = val;
        },
      );
    }
  }

  void _showShowCustomFieldsDialog(List<CustomFieldModel> allCustomFields) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Select Custom Fields'),
              content: SizedBox(
                width: AppStyles.isWebScreen(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCustomFields.length,
                  itemBuilder: (context, index) {
                    final field = allCustomFields[index];
                    final selectedItemIndex = _showCustomFields.indexWhere(
                        (e) => e.customFieldId == field.customFieldId);
                    bool isSelected = selectedItemIndex != -1;
                    final selectedItem = isSelected
                        ? _showCustomFields[selectedItemIndex]
                        : null;

                    return InkWell(
                      onTap: () {
                        setStateDialog(() {
                          if (isSelected) {
                            _showCustomFields.removeAt(selectedItemIndex);
                          } else {
                            _showCustomFields.add(field);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade400
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.blue.shade400
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                field.customFieldName ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.blue.shade700
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected && selectedItem != null)
                              Checkbox(
                                value: selectedItem.isChecked == 1,
                                onChanged: (bool? val) {
                                  setStateDialog(() {
                                    selectedItem.isChecked =
                                        (val == true) ? 1 : 0;
                                    field.isChecked = (val == true) ? 1 : 0;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void saveData() async {
    // Validate necessary conditions
    if (processFlowProvider.processFlowModel.enquiryForId.isNullOrZero()) {
      showToastInDialog('Please select a enuiry for', context);

      return;
    }
    if (processFlowProvider.processFlowModel.taskTypeId.isNullOrZero()) {
      showToastInDialog('Please select a task type', context);

      return;
    }

    if (processFlowProvider.processFlowModel.statusId.isNullOrZero()) {
      showToastInDialog('Please select a task status', context);

      return;
    }

    if (processFlowProvider.taskFlowList.isEmpty) {
      showToastInDialog('Please add at least one task to the flow', context);

      return;
    }

    // Save custom fields
    processFlowProvider.savedCustomFields = _selectedCustomFields.map((field) {
      final value = _customFieldValues[field.customFieldId] ?? '';
      return {
        "custom_field_id": field.customFieldId,
        "value": value,
      };
    }).toList();

    processFlowProvider.processFlowModel.templateId = templateIdController.text;
    processFlowProvider.showCustomFields = _showCustomFields;

    isSavingData = true;
    setState(() {});
    try {
      // Call the provider method to save the process flow
      final result = await processFlowProvider.saveFollowUp(context);
      isSavingData = false;
      setState(() {});
      if (result.$1) {
        showToastInDialog('Process flow saved successfully', context);

        processFlowProvider.getProcessFlow(context);

        // Close the dialog
        Navigator.of(context).pop();
        _onDrawerClosed(context);
      } else {
        showToastInDialog(result.$2, context);
      }
    } catch (e) {
      isSavingData = false;
      setState(() {});

      showToastInDialog('Error saving process flow: $e', context);
    }
  }

  void _addTaskToFlow() {
    // Validate required fields

    if (processFlowProvider.taskFlowModel.branchId == null ||
        processFlowProvider.taskFlowModel.departmentId == null ||
        processFlowProvider.taskFlowModel.taskTypeId == null ||
        processFlowProvider.taskFlowModel.taskTypeId == 0) {
      showToastInDialog(
          'Please select branch, department, and task type', context);

      return;
    }

    if (isEditingTaskFlow && selectedTaskFlowIndex != null) {
      // Update existing task flow
      processFlowProvider.updateTaskFlow(
          selectedTaskFlowIndex!, processFlowProvider.taskFlowModel);
      isEditingTaskFlow = false;
      selectedTaskFlowIndex = null;
    } else {
      // Add new task flow
      processFlowProvider.updateTaskFlow(-1, processFlowProvider.taskFlowModel);
      isEditingTaskFlow = false;
      selectedTaskFlowIndex = null;
    }
    TaskFlowModel emptyModel = TaskFlowModel();

    emptyModel.branchId = null;
    emptyModel.departmentId = null;
    emptyModel.taskTypeId = null;

    // Set the empty model using the provider method
    processFlowProvider.setTaskFlowModel(emptyModel);

    // setState(() {});
  }

  void _editTaskFlow(int index, TaskFlowModel task, List<BranchModel> branches,
      List<DepartmentModel> departments, List<TaskTypeModel> taskTypes) {
    isEditingTaskFlow = true;
    selectedTaskFlowIndex = index;

    // Set the task flow model for editing
    processFlowProvider.setTaskFlowModel(task);

    // branchController.text = branches
    //     .where((element)=> element.branchId ==task.branchId).firstOrNull?.branchName??"na";
    // departmentController.text = departments
    //     .where((element)=> element.departmentId==task.departmentId).firstOrNull?.departmentName??"na";
    //
    // flowTaskTypeController.text = taskTypes
    //     .where((element)=> element.taskTypeId==task.taskTypeId).firstOrNull?.taskTypeName??"na";

    setState(() {});
  }

  Widget _buildTaskFlowList(List<TaskTypeModel> taskTypes,
      List<DepartmentModel> departments, List<BranchModel> branches) {
    if (processFlowProvider.taskFlowList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.format_list_bulleted_rounded,
                    size: 32, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks added yet',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.assignment_rounded,
                color: AppColors.secondaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Added Tasks',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textBlue800,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${processFlowProvider.taskFlowList.length} ${processFlowProvider.taskFlowList.length == 1 ? 'task' : 'tasks'}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: processFlowProvider.taskFlowList.length,
          itemBuilder: (context, index) {
            final task = processFlowProvider.taskFlowList[index];

            final branchName = branches
                    .where((element) => element.branchId == task.branchId)
                    .firstOrNull
                    ?.branchName ??
                "N/A";
            final deptName = departments
                    .where(
                        (element) => element.departmentId == task.departmentId)
                    .firstOrNull
                    ?.departmentName ??
                "N/A";
            final typeName = taskTypes
                    .where((element) => element.taskTypeId == task.taskTypeId)
                    .firstOrNull
                    ?.taskTypeName ??
                "N/A";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.secondaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlue800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 13, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$branchName | $deptName',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                        InkWell(
                          onTap: () {
                            _editTaskFlow(
                                index, task, branches, departments, taskTypes);
                            _taskTypeByDepartmentFuture =
                                processFlowProvider.getTaskTypeByDepartment(
                                    context, task.departmentId.toString());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to remove this task?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      processFlowProvider.removeTaskFlow(index);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
