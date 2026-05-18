import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/search_user_model.dart';
import 'package:vidyanexis/controller/models/search_working_status_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_password_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class SettingsAddUserWidget extends StatefulWidget {
  final bool isEdit;
  final String? userName;
  final String? email;
  final String? mobileNo;
  final String? password;
  final String? newPassword;
  final String? userId;
  final String? userStatusId;
  final int? departmentId;

  final String? userType;
  bool? appLogin;
  final String? empCode;
  final String? designation;
  final String? doj;
  final int? branchId;
  final List<DepartmentModel>? transferDepartments;

  SettingsAddUserWidget(
      {super.key,
      required this.isEdit,
      this.userName,
      this.email,
      this.mobileNo,
      this.password,
      this.newPassword,
      this.userId,
      this.userStatusId,
      this.departmentId,
      this.userType,
      this.appLogin,
      this.empCode,
      this.designation,
      this.doj,
      this.branchId,
      this.transferDepartments});

  @override
  State<SettingsAddUserWidget> createState() => _SettingsAddUserWidgetState();
}

class _SettingsAddUserWidgetState extends State<SettingsAddUserWidget> {
  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);

        settingsProvider.workingStatusController.text = '';
        settingsProvider.emailIdController.text = widget.email!;
        settingsProvider.mobileNoController.text = widget.mobileNo!;
        settingsProvider.confirmPasswordController.text = widget.password!;
        settingsProvider.passWordController.text = widget.password!;
        settingsProvider.userNameController.text = widget.userName!;
        settingsProvider.employeeCodeController.text = widget.empCode!;
        settingsProvider.dateOfJoinController.text = widget.doj!;
        settingsProvider.designationController.text = widget.designation!;
        settingsProvider.toggleAppLogin(widget.appLogin ?? false);
        final userWorkingStatus =
            settingsProvider.searchWorkingStatus.firstWhere(
          (status) =>
              status.workingStatusId == int.parse(widget.userStatusId ?? ''),
          orElse: () => SearchWorkingStatusModel(
            workingStatusId: 0,
            workingStatusName: '',
          ),
        );

        if (userWorkingStatus.workingStatusId != 0) {
          settingsProvider.selectedWorkingStatusId =
              userWorkingStatus.workingStatusId;
          settingsProvider.workingStatusController.text =
              userWorkingStatus.workingStatusName;
        }
        final userDepartmentId = settingsProvider.departmentModel.firstWhere(
          (status) => status.departmentId == widget.departmentId,
          orElse: () => DepartmentModel(
            departmentId: 0,
            departmentName: '',
          ),
        );

        if (userDepartmentId.departmentId != 0) {
          settingsProvider.selectedDepartmentId = userDepartmentId.departmentId;
          settingsProvider.departmentUserController.text =
              userDepartmentId.departmentName;
        }
        final branchId = settingsProvider.branchModel.firstWhere(
          (status) => status.branchId == widget.branchId,
          orElse: () => BranchModel(),
        );

        if (branchId.branchId != 0) {
          settingsProvider.selectedBranchId = branchId.branchId ?? 0;
          settingsProvider.branchController.text = branchId.branchName ?? "";
        }
        final userType = settingsProvider.searchUserType.firstWhere(
          (status) => status.userTypeId == int.parse(widget.userType ?? ''),
          orElse: () => SearchUserTypeModel(
            userTypeId: 0,
            userTypeName: '',
          ),
        );

        if (userType.userTypeId != 0) {
          settingsProvider.selectedUserTypeId = userType.userTypeId;
          settingsProvider.userTypeController.text = userType.userTypeName;
        }

        if (widget.transferDepartments != null) {
          settingsProvider.setTransferDepartments(widget.transferDepartments!);
        }
      });
    }
  }

  void _showTransferDepartmentDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Select Transfer Departments',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryBlue,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: settingsProvider.departmentModel.map((dept) {
                    bool isSelected = settingsProvider
                        .selectedTransferDepartments
                        .any((element) =>
                            element.departmentId == dept.departmentId);
                    return CheckboxListTile(
                      title: Text(dept.departmentName),
                      value: isSelected,
                      activeColor: AppColors.secondaryBlue,
                      onChanged: (bool? value) {
                        settingsProvider.toggleTransferDepartment(dept);
                        setDialogState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.secondaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTransferDepartmentField(
      BuildContext context, SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showTransferDepartmentDialog(context, settingsProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textGrey2, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transfer Departments',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey3,
                  ),
                ),
                Icon(Icons.add_circle_outline,
                    color: AppColors.secondaryBlue, size: 20),
              ],
            ),
          ),
        ),
        if (settingsProvider.selectedTransferDepartments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: settingsProvider.selectedTransferDepartments.map((dept) {
              return Chip(
                label: Text(
                  dept.departmentName,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: AppColors.secondaryBlue,
                deleteIcon: Icon(Icons.close, size: 14, color: Colors.white),
                onDeleted: () {
                  settingsProvider.toggleTransferDepartment(dept);
                },
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.secondaryBlue),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    void showErrorDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.secondaryBlue,
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
                    color: AppColors.secondaryBlue,
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

    bool validateFields(
        BuildContext context, SettingsProvider settingsProvider) {
      // Check for empty fields
      if (settingsProvider.userNameController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please enter user name');
        return false;
      }

      if (settingsProvider.userTypeController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please select user type');
        return false;
      }

      if (settingsProvider.passWordController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please enter password');
        return false;
      }

      if (settingsProvider.confirmPasswordController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please confirm password');
        return false;
      }

      // Check password matching
      if (settingsProvider.passWordController.text !=
          settingsProvider.confirmPasswordController.text) {
        showErrorDialog(context, 'Passwords do not match');
        return false;
      }

      if (settingsProvider.mobileNoController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please enter mobile number');
        return false;
      }

      // Basic email validation
      String email = settingsProvider.emailIdController.text.trim();
      if (email.isEmpty) {
        showErrorDialog(context, 'Please enter email ID');
        return false;
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        showErrorDialog(context, 'Please enter a valid email address');
        return false;
      }

      if (settingsProvider.workingStatusController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please select working status');
        return false;
      }
      if (settingsProvider.departmentUserController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please select department');
        return false;
      }
      if (settingsProvider.branchController.text.trim().isEmpty) {
        showErrorDialog(context, 'Please select branch');
        return false;
      }
      return true;
    }

    Widget buildContent() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (!AppStyles.isWebScreen(context)) ...[
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.userNameController,
                  hintText: 'User Name *',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CommonDropdown<int>(
                  hintText: 'User Type *',
                  selectedValue: widget.isEdit
                      ? settingsProvider.selectedUserTypeId
                      : null,
                  items: settingsProvider.searchUserType
                      .map((source) => DropdownItem<int>(
                            id: source.userTypeId,
                            name: source.userTypeName,
                          ))
                      .toList(),
                  controller: settingsProvider.userTypeController,
                  onItemSelected: (selectedId) {
                    settingsProvider.selectedUserTypeId = selectedId;
                  },
                ),
                const SizedBox(height: 16),
                CustomPasswordWidget(
                  suffixIcon: IconButton(
                    icon: Icon(
                      settingsProvider.newpasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textGrey3,
                    ),
                    onPressed: () =>
                        settingsProvider.toggleNewPasswordVisibility(),
                  ),
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.passWordController,
                  hintText: 'Password *',
                  labelText: '',
                  isObscureText: !settingsProvider.newpasswordVisible,
                ),
                const SizedBox(height: 16),
                CustomPasswordWidget(
                  suffixIcon: IconButton(
                    icon: Icon(
                      settingsProvider.passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textGrey3,
                    ),
                    onPressed: () =>
                        settingsProvider.togglePasswordVisibility(),
                  ),
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.confirmPasswordController,
                  hintText: 'Confirm Password *',
                  labelText: '',
                  isObscureText: !settingsProvider.passwordVisible,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.mobileNoController,
                  hintText: 'Mobile No *',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.emailIdController,
                  hintText: 'Email ID *',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CommonDropdown<int>(
                  hintText: 'Working Status *',
                  selectedValue: widget.isEdit
                      ? settingsProvider.selectedWorkingStatusId
                      : null,
                  items: settingsProvider.searchWorkingStatus
                      .map((source) => DropdownItem<int>(
                            id: source.workingStatusId,
                            name: source.workingStatusName,
                          ))
                      .toList(),
                  controller: settingsProvider.workingStatusController,
                  onItemSelected: (selectedId) {
                    settingsProvider.selectedWorkingStatusId = selectedId;
                  },
                ),
                const SizedBox(height: 16),
                CommonDropdown<int>(
                  hintText: 'Department*',
                  selectedValue: widget.isEdit
                      ? settingsProvider.selectedDepartmentId
                      : null,
                  items: settingsProvider.departmentModel
                      .map((source) => DropdownItem<int>(
                            id: source.departmentId,
                            name: source.departmentName,
                          ))
                      .toList(),
                  controller: settingsProvider.departmentUserController,
                  onItemSelected: (selectedId) {
                    settingsProvider.selectedDepartmentId = selectedId;
                  },
                ),
                const SizedBox(height: 16),
                _buildTransferDepartmentField(context, settingsProvider),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.employeeCodeController,
                  hintText: 'Employee Code',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.designationController,
                  hintText: 'Designation',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CommonDropdown<int>(
                  hintText: 'Branch*',
                  selectedValue:
                      widget.isEdit ? settingsProvider.selectedBranchId : null,
                  items: settingsProvider.branchModel
                      .map((source) => DropdownItem<int>(
                            id: source.branchId ?? 0,
                            name: source.branchName ?? '',
                          ))
                      .toList(),
                  controller: settingsProvider.branchController,
                  onItemSelected: (selectedId) {
                    settingsProvider.selectedBranchId = selectedId;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      settingsProvider.dateOfJoinController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                  readOnly: true,
                  height: 54,
                  controller: settingsProvider.dateOfJoinController,
                  hintText: 'Date of Joining',
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
                        settingsProvider.dateOfJoinController.text =
                            DateFormat('dd MMM yyyy').format(picked);
                      }
                    },
                  ),
                  labelText: '',
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.userNameController,
                        hintText: 'User Name *',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CommonDropdown<int>(
                        hintText: 'User Type *',
                        selectedValue: widget.isEdit
                            ? settingsProvider.selectedUserTypeId
                            : null,
                        items: settingsProvider.searchUserType
                            .map((source) => DropdownItem<int>(
                                  id: source.userTypeId,
                                  name: source.userTypeName ?? '',
                                ))
                            .toList(),
                        controller: settingsProvider.userTypeController,
                        onItemSelected: (selectedId) {
                          settingsProvider.selectedUserTypeId = selectedId;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: CustomPasswordWidget(
                        suffixIcon: IconButton(
                          icon: Icon(
                            settingsProvider.newpasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textGrey3,
                          ),
                          onPressed: () =>
                              settingsProvider.toggleNewPasswordVisibility(),
                        ),
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.passWordController,
                        hintText: 'Password *',
                        labelText: '',
                        isObscureText: !settingsProvider.newpasswordVisible,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomPasswordWidget(
                        suffixIcon: IconButton(
                          icon: Icon(
                            settingsProvider.passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textGrey3,
                          ),
                          onPressed: () =>
                              settingsProvider.togglePasswordVisibility(),
                        ),
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.confirmPasswordController,
                        hintText: 'Confirm Password *',
                        labelText: '',
                        isObscureText: !settingsProvider.passwordVisible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.mobileNoController,
                        hintText: 'Mobile No *',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.emailIdController,
                        hintText: 'Email ID *',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: CommonDropdown<int>(
                        hintText: 'Working Status *',
                        selectedValue: widget.isEdit
                            ? settingsProvider.selectedWorkingStatusId
                            : null,
                        items: settingsProvider.searchWorkingStatus
                            .map((source) => DropdownItem<int>(
                                  id: source.workingStatusId,
                                  name: source.workingStatusName ?? '',
                                ))
                            .toList(),
                        controller: settingsProvider.workingStatusController,
                        onItemSelected: (selectedId) {
                          settingsProvider.selectedWorkingStatusId = selectedId;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CommonDropdown<int>(
                        hintText: 'Department*',
                        selectedValue: widget.isEdit
                            ? settingsProvider.selectedDepartmentId
                            : null,
                        items: settingsProvider.departmentModel
                            .map((source) => DropdownItem<int>(
                                  id: source.departmentId,
                                  name: source.departmentName ?? '',
                                ))
                            .toList(),
                        controller: settingsProvider.departmentUserController,
                        onItemSelected: (selectedId) {
                          settingsProvider.selectedDepartmentId = selectedId;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTransferDepartmentField(context, settingsProvider),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.employeeCodeController,
                        hintText: 'Employee Code',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.designationController,
                        hintText: 'Designation',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: CommonDropdown<int>(
                        hintText: 'Branch*',
                        selectedValue: widget.isEdit
                            ? settingsProvider.selectedBranchId
                            : null,
                        items: settingsProvider.branchModel
                            .map((source) => DropdownItem<int>(
                                  id: source.branchId ?? 0,
                                  name: source.branchName ?? '',
                                ))
                            .toList(),
                        controller: settingsProvider.branchController,
                        onItemSelected: (selectedId) {
                          settingsProvider.selectedBranchId = selectedId;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            settingsProvider.dateOfJoinController.text =
                                DateFormat('dd MMM yyyy').format(picked);
                          }
                        },
                        readOnly: true,
                        height: 54,
                        controller: settingsProvider.dateOfJoinController,
                        hintText: 'Date of Joining',
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
                              settingsProvider.dateOfJoinController.text =
                                  DateFormat('dd MMM yyyy').format(picked);
                            }
                          },
                        ),
                        labelText: '',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allow App Login',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enable this option to grant the user access to log in through the mobile app.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: settingsProvider.allowAppLogin,
                      onChanged: (bool value) {
                        settingsProvider.toggleAppLogin(value);
                      },
                      trackOutlineColor:
                          WidgetStatePropertyAll(AppColors.textGrey3),
                      activeThumbColor: AppColors.whiteColor,
                      activeTrackColor: AppColors.secondaryBlue,
                      inactiveThumbColor: AppColors.textGrey1,
                      inactiveTrackColor: AppColors.whiteColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!AppStyles.isWebScreen(context)) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Cancel',
                        onPressed: () {
                          settingsProvider.resetStates();
                          Navigator.pop(context);
                        },
                        radius: 12,
                        backgroundColor: AppColors.whiteColor,
                        borderColor: const Color(0xFFE2E8F0),
                        textColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: settingsProvider.isAddingUser
                            ? 'Saving...'
                            : 'Save',
                        onPressed: settingsProvider.isAddingUser
                            ? null
                            : () async {
                                if (validateFields(context, settingsProvider)) {
                                  await settingsProvider.addUser(
                                      context: context,
                                      userDetailsId: widget.userId.toString(),
                                      userDetailsName: settingsProvider
                                          .userNameController.text,
                                      password: settingsProvider
                                          .passWordController.text,
                                      workingStatus: settingsProvider
                                          .selectedWorkingStatusId
                                          .toString(),
                                      userType: settingsProvider
                                          .selectedUserTypeId
                                          .toString(),
                                      addressName1: '',
                                      addressName2: '',
                                      addressName3: '',
                                      addressName4: '',
                                      mobile: settingsProvider
                                          .mobileNoController.text,
                                      countryCodeName: '',
                                      gmail: settingsProvider
                                          .emailIdController.text,
                                      appLogin: settingsProvider.allowAppLogin
                                          ? '1'
                                          : '0',
                                      departmentId: settingsProvider
                                          .selectedDepartmentId
                                          .toString(),
                                      departmentName: settingsProvider
                                          .departmentUserController.text,
                                      branchId: settingsProvider
                                          .selectedBranchId
                                          .toString(),
                                      branchName: settingsProvider
                                          .branchController.text);

                                  settingsProvider.resetStates();
                                  Navigator.pop(context);
                                }
                              },
                        radius: 12,
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      );
    }

    if (!AppStyles.isWebScreen(context)) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.isEdit ? 'Edit User' : 'Add New User',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              settingsProvider.resetStates();
              Navigator.pop(context);
            },
          ),
        ),
        body: buildContent(),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit User' : 'Add New User',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.resetStates();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: buildContent(),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.resetStates();
            Navigator.pop(context);
          },
          radius: 12,
          backgroundColor: AppColors.whiteColor,
          borderColor: const Color(0xFFE2E8F0),
          textColor: const Color(0xFF64748B),
        ),
        CustomElevatedButton(
          buttonText: settingsProvider.isAddingUser ? 'Saving...' : 'Save',
          onPressed: settingsProvider.isAddingUser
              ? null
              : () async {
                  if (validateFields(context, settingsProvider)) {
                    await settingsProvider.addUser(
                        context: context,
                        userDetailsId: widget.userId.toString(),
                        userDetailsName:
                            settingsProvider.userNameController.text,
                        password: settingsProvider.passWordController.text,
                        workingStatus:
                            settingsProvider.selectedWorkingStatusId.toString(),
                        userType:
                            settingsProvider.selectedUserTypeId.toString(),
                        addressName1: '',
                        addressName2: '',
                        addressName3: '',
                        addressName4: '',
                        mobile: settingsProvider.mobileNoController.text,
                        countryCodeName: '',
                        gmail: settingsProvider.emailIdController.text,
                        appLogin: settingsProvider.allowAppLogin ? '1' : '0',
                        departmentId:
                            settingsProvider.selectedDepartmentId.toString(),
                        departmentName:
                            settingsProvider.departmentUserController.text,
                        branchId: settingsProvider.selectedBranchId.toString(),
                        branchName: settingsProvider.branchController.text);

                    settingsProvider.resetStates();
                    Navigator.pop(context);
                  }
                },
          radius: 12,
          backgroundColor: AppColors.secondaryBlue,
          borderColor: AppColors.secondaryBlue,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
