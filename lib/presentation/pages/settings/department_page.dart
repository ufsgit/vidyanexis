import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/settings/add_department_page.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  late SettingsProvider settingsProvider;
  Map<int, List<CustomFieldModel>> selectedCustomFields = {};

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchDepartmentController.clear();
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchEnquiryForData('', context);
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AddDepartment(
          editId: '0',
          isEdit: false,
          department: '',
        );
      },
    );
  }

  // Open dialog to manage custom fields for a department
  void _enquiryForDialog(DepartmentModel dept) async {
    await settingsProvider.getDepartmentCustomFields(
      departmentId: dept.departmentId ?? 0,
      context: context,
    );

    // Local state for dialog
    Map<int, List<CustomFieldModel>> selectedCustomFields = {};

    // Populate from fetched mappings
    for (var mapping in settingsProvider.departmentCustomFieldMappings) {
      if (mapping.departmentId == dept.departmentId) {
        selectedCustomFields[mapping.enquiryForId] =
            List.from(mapping.customFields);
      }
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.settings, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    "Custom Fields - ${dept.departmentName}",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: SizedBox(
                width: 780,
                height: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select custom fields for each Enquiry For",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: settingsProvider.searchEnquiryFor.length,
                        itemBuilder: (context, index) {
                          final enquiryFor =
                              settingsProvider.searchEnquiryFor[index];
                          final selectedFields =
                              selectedCustomFields[enquiryFor.enquiryForId] ??
                                  [];

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        enquiryFor.enquiryForName,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _showCustomFieldSelector(
                                          context,
                                          enquiryFor,
                                          setDialogState,
                                          selectedCustomFields,
                                        ),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text("Select Fields"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedFields.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedFields
                                          .map((field) => Chip(
                                                label: Text(
                                                    field.customFieldName ??
                                                        ''),
                                                backgroundColor: AppColors
                                                    .primaryBlue
                                                    .withOpacity(0.1),
                                                deleteIconColor:
                                                    AppColors.primaryBlue,
                                                onDeleted: () {
                                                  setDialogState(() {
                                                    selectedCustomFields[
                                                            enquiryFor
                                                                .enquiryForId]
                                                        ?.removeWhere((f) =>
                                                            f.customFieldId ==
                                                            field
                                                                .customFieldId);

                                                    if (selectedCustomFields[
                                                                enquiryFor
                                                                    .enquiryForId]
                                                            ?.isEmpty ??
                                                        true) {
                                                      selectedCustomFields
                                                          .remove(enquiryFor
                                                              .enquiryForId);
                                                    }
                                                  });
                                                },
                                              ))
                                          .toList(),
                                    )
                                  else
                                    const Text("No fields selected yet",
                                        style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    await settingsProvider.saveDepartmentCustomFields(
                      departmentId: dept.departmentId,
                      mapping: selectedCustomFields,
                      context: context,
                    );
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Updated selector method
  void _showCustomFieldSelector(
    BuildContext context,
    EnquiryForModel enquiryFor,
    StateSetter setDialogState, // Outer dialog refresher
    Map<int, List<CustomFieldModel>> selectedCustomFields, // Pass by reference
  ) {
    List<CustomFieldModel> availableFields = [];

    if (enquiryFor.customFields != null &&
        enquiryFor.customFields!.isNotEmpty) {
      for (var item in enquiryFor.customFields!) {
        try {
          availableFields.add(CustomFieldModel.fromJson(item));
        } catch (e) {
          debugPrint('Error parsing custom field: $e');
        }
      }
    } else {
      availableFields = settingsProvider.customFieldModelList;
    }

    // Deduplicate
    final uniqueFields = <int, CustomFieldModel>{};
    for (var field in availableFields) {
      uniqueFields[field.customFieldId ?? 0] = field;
    }
    availableFields = uniqueFields.values.toList();

    final tempSelected = List<CustomFieldModel>.from(
        selectedCustomFields[enquiryFor.enquiryForId] ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Select Fields for ${enquiryFor.enquiryForName}",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: 480,
                height: 420,
                child: ListView.builder(
                  itemCount: availableFields.length,
                  itemBuilder: (context, index) {
                    final field = availableFields[index];
                    final isSelected = tempSelected
                        .any((f) => f.customFieldId == field.customFieldId);

                    return CheckboxListTile(
                      title: Text(field.customFieldName ?? ""),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setInnerState(() {
                          if (value == true) {
                            if (!tempSelected.any((f) =>
                                f.customFieldId == field.customFieldId)) {
                              tempSelected.add(field);
                            }
                          } else {
                            tempSelected.removeWhere(
                                (f) => f.customFieldId == field.customFieldId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    setDialogState(() {
                      // ← This refreshes outer dialog
                      if (tempSelected.isNotEmpty) {
                        selectedCustomFields[enquiryFor.enquiryForId] =
                            List.from(tempSelected);
                      } else {
                        selectedCustomFields.remove(enquiryFor.enquiryForId);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    const double minContentWidth = 900.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: isWeb
                ? (constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth)
                : constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: settingsProvider.departmentModel.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final dept = settingsProvider.departmentModel[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dept.departmentName,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                _enquiryForDialog(dept);
                              },
                              icon:
                                  const Icon(Icons.settings_outlined, size: 18),
                              label: const Text("Choose Custom Fields"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                side: const BorderSide(
                                    color: AppColors.primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButtons(
                                context, settingsProvider, index),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
      BuildContext context, SettingsProvider provider, int index) {
    final dept = provider.departmentModel[index];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (provider.menuIsEditMap[42] == 1)
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddDepartment(
                editId: dept.departmentId.toString(),
                department: dept.departmentName,
                isEdit: true,
              ),
            ),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
          ),
        if (provider.menuIsDeleteMap[42] == 1)
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirm Delete"),
                content: const Text(
                    "Are you sure you want to delete this department?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  TextButton(
                    onPressed: () async {
                      await provider.deleteDepartment(
                          context, dept.departmentId);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.delete_outline, color: AppColors.textRed),
          ),
      ],
    );
  }
}
