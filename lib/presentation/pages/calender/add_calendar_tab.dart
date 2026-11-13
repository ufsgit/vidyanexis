import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/calendar_tab_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/calendar_tab_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddCalendarTab extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final String customerId;

  const AddCalendarTab({
    super.key,
    required this.isEdit,
    required this.editId,
    required this.customerId,
  });

  @override
  State<AddCalendarTab> createState() => _AddCalendarTabState();
}

class _AddCalendarTabState extends State<AddCalendarTab> {
  final _formKey = GlobalKey<FormState>();
  int _itemIdCounter = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<CalendarTabProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      provider.clearForm();
      if (settingsProvider.departmentModel.isEmpty) {
        settingsProvider.searchDepartment('', context);
      }
      if (dropDownProvider.searchUserDetails.isEmpty) {
        dropDownProvider.getUserDetails(context);
      }
      if (widget.isEdit && widget.editId != '0') {
        await provider.loadForEdit(widget.editId, widget.customerId, context);
      }
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Cannot save',
          style: TextStyle(
            color: AppColors.appViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(CalendarTabProvider provider) async {
    final now = DateTime.now();
    DateTime initial = now;
    if (provider.itemDateController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(provider.itemDateController.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.itemDateController.text =
          DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  void _addItem(CalendarTabProvider provider) {
    final date = provider.itemDateController.text.trim();
    final desc = provider.itemDescriptionController.text.trim();

    if (date.isEmpty) {
      _showError('Please select a date.');
      return;
    }

    final item = CalendarItemModel(
      id: provider.editingItemIndex != null
          ? provider.calendarItems[provider.editingItemIndex!].id
          : 'item_local_${_itemIdCounter++}',
      date: date,
      description: desc,
      departmentId: provider.selectedDepartmentId.toString(),
      departmentName: provider.departmentController.text,
      userId: provider.selectedUserId.toString(),
      userName: provider.searchUserController.text,
    );
    provider.addOrUpdateCalendarItem(item);
    setState(() {});
  }

  Future<void> _save(CalendarTabProvider provider) async {
    if (provider.nameController.text.trim().isEmpty) {
      _showError('Name is required.');
      return;
    }
    if (provider.calendarItems.isEmpty) {
      _showError('Please add at least one date.');
      return;
    }

    final success = await provider.saveCalendar(
      customerId: widget.customerId,
      isEdit: widget.isEdit,
      editId: widget.editId,
      context: context,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? 'Calendar updated successfully'
              : 'Calendar created successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      _showError('Failed to save. Please try again.');
    }
  }

  String _fmt(String raw) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarTabProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    // Wider dialog on web so 4 fields fit in one row
    final maxW = isWeb ? 920.0 : MediaQuery.of(context).size.width * 0.95;
    final isEditingItem = provider.editingItemIndex != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 12,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxW,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded,
                      color: AppColors.primaryBlue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isEdit ? 'Edit Calendar' : 'Add Calendar',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      provider.clearForm();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      CustomTextField(
                        height: 54,
                        controller: provider.nameController,
                        hintText: 'Name *',
                        labelText: '',
                        keyboardType: TextInputType.text,
                        focusNode: FocusNode(),
                      ),
                      const SizedBox(height: 16),

                      // Date + Description group
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isEditingItem
                                ? Colors.orange.shade300
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ---- 4 fields: single row on web, stacked on mobile ----
                            if (isWeb)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Date
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () => _pickDate(provider),
                                      child: AbsorbPointer(
                                        child: CustomTextField(
                                          height: 54,
                                          controller:
                                              provider.itemDateController,
                                          hintText: 'Date *',
                                          labelText: '',
                                          keyboardType: TextInputType.text,
                                          focusNode: FocusNode(),
                                          suffixIcon: IconButton(
                                            onPressed: () =>
                                                _pickDate(provider),
                                            icon: Icon(
                                              Icons.calendar_today_outlined,
                                              size: 18,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 2. Department
                                  Expanded(
                                    flex: 3,
                                    child: Consumer2<SettingsProvider,
                                        DropDownProvider>(
                                      builder: (context, settingsProvider,
                                          dropDownProvider, child) {
                                        return CommonDropdown<int>(
                                          key: ValueKey(settingsProvider
                                              .selectedBranchId),
                                          hintText: 'Department',
                                          selectedValue:
                                              provider.selectedDepartmentId,
                                          items: settingsProvider
                                              .departmentModel
                                              .map((dept) => DropdownItem<int>(
                                                    id: dept.departmentId,
                                                    name: dept.departmentName ??
                                                        '',
                                                  ))
                                              .toList(),
                                          controller:
                                              provider.departmentController,
                                          onItemSelected: (selectedId) {
                                            provider.selectedDepartmentId =
                                                selectedId;

                                            final selectedDept =
                                                settingsProvider.departmentModel
                                                    .firstWhere((d) =>
                                                        d.departmentId ==
                                                        selectedId);

                                            provider.departmentController.text =
                                                selectedDept.departmentName ??
                                                    '';

                                            // Reset staff selection
                                            provider.selectedUserId = null;
                                            provider.searchUserController
                                                .clear();

                                            final branchId = settingsProvider
                                                .selectedBranchId;
                                            dropDownProvider
                                                .filterStaffByBranchAndDepartment(
                                              branchId: (branchId != null &&
                                                      branchId > 0)
                                                  ? branchId
                                                  : null,
                                              departmentId: selectedId,
                                            );

                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 3. Assigned Staff
                                  Expanded(
                                    flex: 3,
                                    child: Consumer2<CalendarTabProvider,
                                        DropDownProvider>(
                                      builder: (context, calendarProvider,
                                          dropDownProvider, child) {
                                        return CommonDropdown<int>(
                                          key: ValueKey(
                                              '${calendarProvider.selectedDepartmentId}_${dropDownProvider.filteredStaffData.length}'),
                                          hintText: 'Assigned Staff',
                                          selectedValue:
                                              calendarProvider.selectedUserId,
                                          items: dropDownProvider
                                              .filteredStaffData
                                              .map((staff) => DropdownItem<int>(
                                                    id: staff.userDetailsId,
                                                    name:
                                                        staff.userDetailsName ??
                                                            '',
                                                  ))
                                              .toList(),
                                          controller: calendarProvider
                                              .searchUserController,
                                          enabled: calendarProvider
                                                  .selectedDepartmentId !=
                                              null,
                                          onItemSelected: (selectedId) {
                                            calendarProvider.selectedUserId =
                                                selectedId;

                                            final selectedStaff =
                                                dropDownProvider
                                                    .filteredStaffData
                                                    .firstWhere((s) =>
                                                        s.userDetailsId ==
                                                        selectedId);

                                            calendarProvider
                                                    .searchUserController.text =
                                                selectedStaff.userDetailsName ??
                                                    '';

                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 4. Description
                                  Expanded(
                                    flex: 3,
                                    child: CustomTextField(
                                      height: 54,
                                      controller:
                                          provider.itemDescriptionController,
                                      hintText: 'Description',
                                      labelText: '',
                                      keyboardType: TextInputType.text,
                                      focusNode: FocusNode(),
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Mobile: stacked (original layout)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  GestureDetector(
                                    onTap: () => _pickDate(provider),
                                    child: AbsorbPointer(
                                      child: CustomTextField(
                                        height: 54,
                                        controller: provider.itemDateController,
                                        hintText: 'Date *',
                                        labelText: '',
                                        keyboardType: TextInputType.text,
                                        focusNode: FocusNode(),
                                        suffixIcon: IconButton(
                                          onPressed: () => _pickDate(provider),
                                          icon: Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Consumer2<SettingsProvider, DropDownProvider>(
                                    builder: (context, settingsProvider,
                                        dropDownProvider, child) {
                                      return CommonDropdown<int>(
                                        key: ValueKey(
                                            settingsProvider.selectedBranchId),
                                        hintText: 'Department',
                                        selectedValue:
                                            provider.selectedDepartmentId,
                                        items: settingsProvider.departmentModel
                                            .map((dept) => DropdownItem<int>(
                                                  id: dept.departmentId,
                                                  name:
                                                      dept.departmentName ?? '',
                                                ))
                                            .toList(),
                                        controller:
                                            provider.departmentController,
                                        onItemSelected: (selectedId) {
                                          provider.selectedDepartmentId =
                                              selectedId;

                                          final selectedDept = settingsProvider
                                              .departmentModel
                                              .firstWhere((d) =>
                                                  d.departmentId == selectedId);

                                          provider.departmentController.text =
                                              selectedDept.departmentName ?? '';

                                          provider.selectedUserId = null;
                                          provider.searchUserController.clear();

                                          final branchId =
                                              settingsProvider.selectedBranchId;
                                          dropDownProvider
                                              .filterStaffByBranchAndDepartment(
                                            branchId: (branchId != null &&
                                                    branchId > 0)
                                                ? branchId
                                                : null,
                                            departmentId: selectedId,
                                          );

                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Consumer2<CalendarTabProvider,
                                      DropDownProvider>(
                                    builder: (context, calendarProvider,
                                        dropDownProvider, child) {
                                      return CommonDropdown<int>(
                                        key: ValueKey(
                                            '${calendarProvider.selectedDepartmentId}_${dropDownProvider.filteredStaffData.length}'),
                                        hintText: 'Assigned Staff',
                                        selectedValue:
                                            calendarProvider.selectedUserId,
                                        items: dropDownProvider
                                            .filteredStaffData
                                            .map((staff) => DropdownItem<int>(
                                                  id: staff.userDetailsId,
                                                  name: staff.userDetailsName ??
                                                      '',
                                                ))
                                            .toList(),
                                        controller: calendarProvider
                                            .searchUserController,
                                        enabled: calendarProvider
                                                .selectedDepartmentId !=
                                            null,
                                        onItemSelected: (selectedId) {
                                          calendarProvider.selectedUserId =
                                              selectedId;

                                          final selectedStaff = dropDownProvider
                                              .filteredStaffData
                                              .firstWhere((s) =>
                                                  s.userDetailsId ==
                                                  selectedId);

                                          calendarProvider
                                                  .searchUserController.text =
                                              selectedStaff.userDetailsName ??
                                                  '';

                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    height: 54,
                                    controller:
                                        provider.itemDescriptionController,
                                    hintText: 'Description',
                                    labelText: '',
                                    keyboardType: TextInputType.text,
                                    focusNode: FocusNode(),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _addItem(provider),
                                icon: Icon(
                                  isEditingItem ? Icons.check : Icons.add,
                                  size: 18,
                                ),
                                label: Text(
                                  isEditingItem ? 'Update Item' : 'Add Item',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: isEditingItem
                                      ? Colors.orange.shade600
                                      : AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Added items
                      if (provider.calendarItems.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              'Added Items',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.calendarItems.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(provider.calendarItems.length,
                            (index) {
                          final item = provider.calendarItems[index];
                          final editing = provider.editingItemIndex == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: editing
                                  ? Colors.orange.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: editing
                                    ? Colors.orange.shade300
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlue
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                _fmt(item.date),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            if (item.departmentName.isNotEmpty)
                                              Flexible(
                                                child: Text(
                                                  item.departmentName,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBlack,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            if (item.userName.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  item.userName,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (item.description.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            item.description,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: const Color(0xFF333333),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'No description',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      provider.editCalendarItem(index);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.edit_outlined,
                                        size: 18, color: AppColors.primaryBlue),
                                    splashRadius: 18,
                                    tooltip: 'Edit',
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      provider.removeCalendarItem(index);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    splashRadius: 18,
                                    tooltip: 'Remove',
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      provider.clearForm();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed:
                        provider.isLoading ? null : () => _save(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEdit ? 'Update' : 'Save',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
