import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/models/customer_details_model.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/models/expense_type_model.dart';
import 'package:vidyanexis/controller/models/get_user_model.dart'
    show GetUserModel;
import 'package:vidyanexis/controller/models/project_model.dart';
import 'package:vidyanexis/controller/models/project_type_model.dart'
    show ProjectTypeModel;
import 'package:vidyanexis/controller/models/tax_slab_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/dotted_border_container.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/gst_calculator.dart';

class AddExpenseManagement extends StatefulWidget {
  final bool isEdit;
  ExpenseModel expenseModel = ExpenseModel();

  AddExpenseManagement({
    super.key,
    required this.isEdit,
    required this.expenseModel,
  });

  @override
  State<AddExpenseManagement> createState() => _AddExpenseManagementState();
}

class _AddExpenseManagementState extends State<AddExpenseManagement> {
  final settingsProvider = Provider.of<SettingsProvider>(
      navigatorKey.currentState!.context,
      listen: false);
  final expenseProvider = Provider.of<ExpenseProvider>(
      navigatorKey.currentState!.context,
      listen: false);
  final imageUploadProvider = Provider.of<ImageUploadProvider>(
      navigatorKey.currentState!.context,
      listen: false);

  Future<List<ProjectTypeModel>>? _projectTypeFuture;
  Future<List<ProjectModel>>? _projectFuture;

  Future<List<ExpenseTypeModel>>? _expenseTypeFuture;
  Future<List<CustomerModel>>? _customerTypeFuture;

  Future<List<TaxSlabModel>>? _taxSlabFuture;

  // String? validateInputs(
  //     BuildContext context, ExpenseProvider expenseProvider) {
  //   return null;
  // }
  // In the AddExpenseManagement class (paste.txt file)
// Find this method around line 45-48 and replace it:

  String? validateInputs(
      BuildContext context, ExpenseProvider expenseProvider) {
    if (expenseProvider.userController.text.trim().isEmpty) {
      return 'Expense user is required';
      // } else if (expenseProvider.dateController.text.trim().isEmpty) {
      //   return 'Date is required';
    } else if (expenseProvider.projectController.text.trim().isEmpty) {
      return 'Select Project is required';
    } else if (expenseProvider.expenseTypeController.text.trim().isEmpty) {
      return 'Expense type is required';
    } else if (expenseProvider.leadController.text.trim().isEmpty) {
      return 'Lead/Customer is requried';
    } else if (expenseProvider.amountController.text.trim().isEmpty) {
      return 'Amount is required';
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

  @override
  void dispose() {
    super.dispose();
    expenseProvider.taxPercentageController.clear();
    expenseProvider.userController.clear();
    expenseProvider.igstController.clear();
    expenseProvider.cgstController.clear();
    expenseProvider.sgstController.clear();
    expenseProvider.amountController.clear();
    expenseProvider.uploadedFilePaths.clear();
    expenseProvider.commentController.clear();
    expenseProvider.expenseHeadController.clear();
    expenseProvider.expenseTypeController.clear();
    expenseProvider.dateController.clear();
  }

  String userId = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";
      expenseProvider.userController.text = userName;
      if (widget.isEdit) {
        expenseProvider.userController.text =
            widget.expenseModel.userName ?? "NA";
        expenseProvider.dateController.text =
            widget.expenseModel.entryDate ?? "NA";
        expenseProvider.expenseTypeController.text =
            widget.expenseModel.expenseTypeName ?? "NA";
        expenseProvider.amountController.text =
            (widget.expenseModel.amount ?? 0).toStringAsFixed(2);
        expenseProvider.taxPercentageController.text =
            (widget.expenseModel.gstPercentage ?? 0).toStringAsFixed(2);
        expenseProvider.amountWithoutTaxController.text =
            (widget.expenseModel.netAmount ?? 0).toStringAsFixed(2);
        expenseProvider.cgstController.text =
            (widget.expenseModel.cgstAmount ?? 0).toStringAsFixed(2);
        expenseProvider.sgstController.text =
            (widget.expenseModel.sgstAmount ?? 0).toStringAsFixed(2);
        expenseProvider.expenseHeadController.text =
            (widget.expenseModel.expenseHead ?? "");
        expenseProvider.commentController.text =
            (widget.expenseModel.comment ?? "");
        expenseProvider.projectController.text =
            (widget.expenseModel.projectName ?? "");
        expenseProvider.projectTypeController.text =
            (widget.expenseModel.projectTypeName ?? "");
        expenseProvider.leadController.text =
            (widget.expenseModel.customerName ?? "");
      }

      _projectFuture = settingsProvider.searchProjects("", context);
      _expenseTypeFuture = settingsProvider.getExpenseType("", context);
      _customerTypeFuture = settingsProvider.getCustomerDropDown(context);
      _projectTypeFuture = settingsProvider.searchProjectTypes("", context);
      _taxSlabFuture = settingsProvider.searchTaxSlab(context, '0');
      settingsProvider.getUserDetails('', context);
    });
  }

  // Helper method to determine if we're on a small screen
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Helper method to get responsive padding
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.all(16);
    } else if (screenWidth < 1200) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Helper method to get responsive dialog width
  double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth * 0.95; // 95% of screen width on mobile
    } else if (screenWidth < 1200) {
      return screenWidth * 0.7; // 70% of screen width on tablet
    } else {
      return screenWidth * 0.5; // 50% of screen width on desktop
    }
  }

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseFontSize * 0.9;
    } else if (screenWidth < 1200) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isSmallScreen = _isSmallScreen(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 40,
        vertical: isSmallScreen ? 24 : 40,
      ),
      content: Container(
        width: _getDialogWidth(context),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: _getResponsivePadding(context),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isEdit
                          ? 'Edit Expense Management'
                          : 'Add Expense Management',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: _getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    iconSize: isSmallScreen ? 20 : 24,
                  )
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: _getResponsivePadding(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User and Date Row
                    isSmallScreen
                        ? Column(
                            children: [
                              _buildUserDropdown(settingsProvider),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildDateField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: _buildUserDropdown(settingsProvider)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDateField()),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Project Type and Project Row
                    isSmallScreen
                        ? Column(
                            children: [
                              _buildProjectTypeDropdown(),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildProjectDropdown(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _buildProjectTypeDropdown()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildProjectDropdown()),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Expense Type and Amount Row
                    isSmallScreen
                        ? Column(
                            children: [
                              _buildExpenseTypeDropDown(),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildAmountFieldWithGst(),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildCustomerDropDown()
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildExpenseTypeDropDown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCustomerDropDown()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildAmountFieldWithGst(),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // GST Fields (if applicable)
                    if (widget.expenseModel.isGst ?? false)
                      _buildGstFields(isSmallScreen),

                    // Expense Head and Comment Row
                    isSmallScreen
                        ? Column(
                            children: [
                              _buildExpenseHeadField(),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildCommentField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _buildExpenseHeadField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildCommentField()),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // File Upload
                    _buildFileUpload(context),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: _getResponsivePadding(context),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: isSmallScreen
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            buttonText: 'Save',
                            onPressed: _handleSave,
                            backgroundColor: AppColors.appViolet,
                            borderColor: AppColors.appViolet,
                            textColor: AppColors.whiteColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            buttonText: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            backgroundColor: AppColors.whiteColor,
                            borderColor: AppColors.appViolet,
                            textColor: AppColors.appViolet,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomElevatedButton(
                          buttonText: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                          backgroundColor: AppColors.whiteColor,
                          borderColor: AppColors.appViolet,
                          textColor: AppColors.appViolet,
                        ),
                        const SizedBox(width: 16),
                        CustomElevatedButton(
                          buttonText: 'Save',
                          onPressed: _handleSave,
                          backgroundColor: AppColors.appViolet,
                          borderColor: AppColors.appViolet,
                          textColor: AppColors.whiteColor,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDropdown(SettingsProvider settingsProvider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentUserDetailsWithAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('Loading...'),
          );
        }

        final userData = snapshot.data!;
        bool isAdmin = userData['isAdmin'] as bool;
        int? currentUserId = userData['userId'] as int?;
        String? currentUserName = userData['userName'] as String?;

        // Build dropdown items based on user role
        List<DropdownItem<int>> dropdownItems;
        int? dropdownValue;
        bool isEnabled;

        if (isAdmin) {
          // Admin: Show all users
          dropdownItems = settingsProvider.searchUserDetails
              .map((status) => DropdownItem<int>(
                    id: status.userDetailsId,
                    name: status.userDetailsName,
                  ))
              .toList();

          // For admin, use the selected value from the model or current user
          dropdownValue = widget.isEdit
              ? widget.expenseModel.userDetailsId
              : int.tryParse(userId) ?? currentUserId ?? 0;

          isEnabled = true; // Admin can change the user
        } else {
          // Non-admin staff: Show only their own name
          dropdownItems = [
            DropdownItem<int>(
              id: currentUserId ?? 0,
              name: currentUserName ?? 'Current User',
            ),
          ];

          // For non-admin, always use their own ID
          dropdownValue = currentUserId ?? 0;

          // Set the model value to current user if not editing
          if (!widget.isEdit) {
            widget.expenseModel.userDetailsId = currentUserId;
            widget.expenseModel.userName = currentUserName;
            expenseProvider.userController.text = currentUserName ?? '';
          }

          isEnabled = false; // Disable dropdown for non-admin users
        }

        return CommonDropdown<int>(
          hintText: 'User*',
          selectedValue: dropdownValue,
          items: dropdownItems,
          controller: expenseProvider.userController,
          onItemSelected: (selectedId) {
            widget.expenseModel.userDetailsId = selectedId;
            // Find and set the user name
            final selectedUser = settingsProvider.searchUserDetails.firstWhere(
              (user) => user.userDetailsId == selectedId,
              orElse: () => settingsProvider.searchUserDetails.first,
            );
            widget.expenseModel.userName = selectedUser.userDetailsName;
          },
          enabled: isEnabled,
        );
      },
    );
  }

  // Widget _buildUserDropdown(SettingsProvider settingsProvider) {
  //   // Disable dropdown if userId is not '1'
  //   bool isDisabled = userId != '1';
  //   return CommonDropdown<int>(
  //     hintText: 'User*',
  //     selectedValue: widget.isEdit
  //         ? widget.expenseModel.userDetailsId
  //         : int.tryParse(userId) ?? 0,
  //     items: settingsProvider.searchUserDetails
  //         .map((status) => DropdownItem<int>(
  //               id: status.userDetailsId,
  //               name: status.userDetailsName,
  //             ))
  //         .toList(),
  //     controller: expenseProvider.userController,
  //     onItemSelected: (selectedId) {
  //       widget.expenseModel.userDetailsId = selectedId;
  //     },
  //     enabled: !isDisabled,
  //   );
  // }

  Widget _buildDateField() {
    return CustomTextField(
      readOnly: true,
      height: 54,
      controller: expenseProvider.dateController,
      hintText: 'Date',
      labelText: '',
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          expenseProvider.dateController.text =
              DateFormat('dd MMM yyyy').format(picked);
          widget.expenseModel.entryDate =
              expenseProvider.dateController.text.toyyyymmdd();
        }
      },
    );
  }

  Widget _buildProjectTypeDropdown() {
    return FutureBuilder<List<ProjectTypeModel>>(
      future: _projectTypeFuture,
      builder: (contextBuilder, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<ProjectTypeModel> projectTypeList = snapshot.data ?? [];
        return CommonDropdown<int>(
          hintText: 'Select Project Type',
          selectedValue:
              widget.isEdit ? widget.expenseModel.projectTypeId : null,
          items: projectTypeList
              .map((status) => DropdownItem<int>(
                    id: status.projectTypeId!,
                    name: status.projectTypeName ?? "",
                  ))
              .toList(),
          controller: expenseProvider.projectTypeController,
          onItemSelected: (selectedId) {
            widget.expenseModel.projectTypeId = selectedId;
            widget.expenseModel.projectTypeName = projectTypeList
                .where((e) => e.projectTypeId == selectedId)
                .single
                .projectTypeName;
          },
        );
      },
    );
  }

  Widget _buildProjectDropdown() {
    return FutureBuilder<List<ProjectModel>>(
      future: _projectFuture,
      builder: (contextBuilder, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<ProjectModel> projectList = snapshot.data ?? [];
        return CommonDropdown<int>(
          hintText: 'Select Project*',
          selectedValue: widget.isEdit ? widget.expenseModel.projectId : null,
          items: projectList
              .map((status) => DropdownItem<int>(
                    id: status.projectId!,
                    name: status.projectName ?? "",
                  ))
              .toList(),
          controller: expenseProvider.projectController,
          onItemSelected: (selectedId) {
            widget.expenseModel.projectId = selectedId;
            widget.expenseModel.projectName = projectList
                .where((e) => e.projectId == selectedId)
                .single
                .projectName;
          },
        );
      },
    );
  }

  Widget _buildExpenseTypeDropDown() {
    return FutureBuilder<List<ExpenseTypeModel>>(
      future: _expenseTypeFuture,
      builder: (contextBuilder, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<ExpenseTypeModel> expenseTypeList = snapshot.data ?? [];
        return CommonDropdown<int>(
          hintText: 'Expense Type*',
          selectedValue:
              widget.isEdit ? widget.expenseModel.expenseTypeId : null,
          items: expenseTypeList
              .map((status) => DropdownItem<int>(
                    id: status.expenseTypeId!,
                    name: status.expenseTypeName ?? "",
                  ))
              .toList(),
          controller: expenseProvider.expenseTypeController,
          onItemSelected: (selectedId) {
            widget.expenseModel.expenseTypeId = selectedId;
            widget.expenseModel.expenseTypeName = expenseTypeList
                .where((e) => e.expenseTypeId == selectedId)
                .single
                .expenseTypeName;
          },
        );
      },
    );
  }

  Widget _buildCustomerDropDown() {
    return FutureBuilder<List<CustomerModel>>(
      future: _customerTypeFuture,
      builder: (contextBuilder, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<CustomerModel> customerTypeList = snapshot.data ?? [];
        return CommonDropdown<int>(
          hintText: 'Select Lead/Customer*',
          selectedValue: widget.isEdit ? widget.expenseModel.customerId : null,
          items: customerTypeList
              .map((status) => DropdownItem<int>(
                    id: int.parse(status.customerId!),
                    name: status.customerName ?? "",
                  ))
              .toList(),
          controller: expenseProvider.leadController,
          onItemSelected: (selectedId) {
            widget.expenseModel.customerId = selectedId;
            widget.expenseModel.customerName = customerTypeList
                .where((e) => e.customerId == selectedId.toString())
                .single
                .customerName;
          },
        );
      },
    );
  }

  Widget _buildAmountFieldWithGst() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            readOnly: false,
            height: 54,
            controller: expenseProvider.amountController,
            hintText: 'Amount*',
            labelText: '',
            onChanged: (value) {
              calculateGst(expenseProvider.taxPercentageController.text);
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
            ],
          ),
        ),
        const SizedBox(width: 8),
        Checkbox(
          value: widget.expenseModel.isGst ?? false,
          onChanged: (value) {
            setState(() {
              widget.expenseModel.isGst = value;
              double amount =
                  double.tryParse(expenseProvider.amountController.text) ?? 0;
              setGstAmount(isClearPercentage: true, netAmt: amount);
            });
          },
        ),
        Flexible(
          child: Text(
            "Is GST",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGstFields(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTaxPercentageField()),
              const SizedBox(width: 12),
              Expanded(child: _buildAmountWithoutTaxField()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCgstField()),
              const SizedBox(width: 12),
              Expanded(child: _buildSgstField()),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTaxPercentageField()),
              const SizedBox(width: 16),
              Expanded(child: _buildAmountWithoutTaxField()),
              const SizedBox(width: 16),
              Expanded(child: _buildCgstField()),
              const SizedBox(width: 16),
              Expanded(child: _buildSgstField()),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    }
  }

  Widget _buildTaxPercentageField() {
    return CustomTextField(
      readOnly: false,
      height: 54,
      controller: expenseProvider.taxPercentageController,
      hintText: 'Tax Percentage',
      labelText: '',
      onChanged: (value) {
        calculateGst(value);
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
    );
  }

  Widget _buildAmountWithoutTaxField() {
    return CustomTextField(
      readOnly: true,
      height: 54,
      controller: expenseProvider.amountWithoutTaxController,
      hintText: 'Amount without tax',
      labelText: '',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ],
    );
  }

  Widget _buildCgstField() {
    return CustomTextField(
      readOnly: true,
      height: 54,
      controller: expenseProvider.cgstController,
      hintText: 'CGST',
      labelText: '',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ],
    );
  }

  Widget _buildSgstField() {
    return CustomTextField(
      readOnly: true,
      height: 54,
      controller: expenseProvider.sgstController,
      hintText: 'SGST',
      labelText: '',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ],
    );
  }

  Widget _buildExpenseHeadField() {
    return CustomTextField(
      readOnly: false,
      height: 54,
      controller: expenseProvider.expenseHeadController,
      hintText: 'Expense head',
      labelText: '',
    );
  }

  Widget _buildCommentField() {
    return CustomTextField(
      readOnly: false,
      height: 54,
      controller: expenseProvider.commentController,
      hintText: 'Comment',
      labelText: '',
    );
  }

  Widget _buildFileUpload(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final uploadHeight = screenWidth < 600 ? 100.0 : 130.0;

    return InkWell(
      onTap: () {
        imageUploadProvider.addFileMobile().then((onValue) {
          // widget.expenseModel.fileBytes = onValue?.$1;
          // widget.expenseModel.fileType = onValue?.$2;
          setState(() {});
        });
      },
      child: Container(
        color: Colors.white,
        height: uploadHeight,
        width: double.infinity,
        child: Center(
          child: widget.expenseModel.fileBytes == null
              ? !widget.expenseModel.filePath.isNullOrEmpty()
                  ? Image.network(
                      HttpUrls.imgBaseUrl + widget.expenseModel.filePath!,
                      width: 100,
                      height: uploadHeight * 0.8,
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(HttpUrls.imgBaseUrl +
                                widget.expenseModel.filePath!);
                            try {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              print('Could not launch $url: $e');
                            }
                          },
                          child: Container(
                            color: Colors.grey[200],
                            width: 80,
                            height: 80,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 40,
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
                    )
                  : Stack(
                      children: [
                        DottedBorderContainer(
                          height: uploadHeight,
                          width: double.infinity,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                              'Upload document',
                              fontWeight: FontWeight.w400,
                              fontSize: _getResponsiveFontSize(context, 14),
                              color: AppColors.textGrey4,
                            ),
                          ),
                        )
                      ],
                    )
              : widget.expenseModel.fileType == "image"
                  ? Image.memory(
                      widget.expenseModel.fileBytes!,
                      width: 100,
                      height: uploadHeight * 0.8,
                      fit: BoxFit.contain,
                    )
                  : CustomText(
                      (widget.expenseModel.fileType ?? "") + " file",
                      fontSize: _getResponsiveFontSize(context, 14),
                    ),
        ),
      ),
    );
  }

  // Helper method to determine file type from bytes
  String _determineFileType(Uint8List data) {
    if (data.length >= 4) {
      if (data[0] == 0x25 &&
          data[1] == 0x50 &&
          data[2] == 0x44 &&
          data[3] == 0x46) {
        return 'application/pdf'; // PDF
      } else if (data[0] == 0xFF &&
          data[1] == 0xD8 &&
          data[data.length - 2] == 0xFF &&
          data[data.length - 1] == 0xD9) {
        return 'image/jpeg'; // JPEG
      } else if (data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return 'image/png'; // PNG
      }
    }
    return 'unknown';
  }

  // Helper method to check if file is image
  bool _isImageFile(Uint8List data) {
    String fileType = _determineFileType(data);
    return fileType.startsWith('image/');
  }

  // Helper method to check if file is PDF
  bool _isPdfFile(Uint8List data) {
    String fileType = _determineFileType(data);
    return fileType == 'application/pdf';
  }

  // Public method to check file type - can be called from outside
  Map<String, dynamic> checkFileType(Uint8List fileBytes) {
    String fileType = _determineFileType(fileBytes);
    bool isImage = _isImageFile(fileBytes);
    bool isPdf = _isPdfFile(fileBytes);

    return {
      'fileType': fileType,
      'isImage': isImage,
      'isPdf': isPdf,
    };
  }

  void _handleSave() async {
    final validationError = validateInputs(context, expenseProvider);
    if (validationError != null) {
      showErrorDialog(context, validationError);
      return;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userId = preferences.getString('userId') ?? "";
    widget.expenseModel.amount =
        double.tryParse(expenseProvider.amountController.text) ?? 0;
    widget.expenseModel.entryBy = int.parse(userId);
    widget.expenseModel.comment = expenseProvider.commentController.text;
    widget.expenseModel.expenseHead =
        expenseProvider.expenseHeadController.text;
    widget.expenseModel.expenseTypeName =
        expenseProvider.expenseTypeController.text;
    widget.expenseModel.entryDate =
        expenseProvider.dateController.text.toyyyymmdd();
    widget.expenseModel.projectName = expenseProvider.projectController.text;
    widget.expenseModel.projectTypeName =
        expenseProvider.projectTypeController.text;
    widget.expenseModel.customerName = expenseProvider.leadController.text;

    // Set userDetailsId
    if (widget.expenseModel.userDetailsId == null) {
      final user = settingsProvider.searchUserDetails.firstWhere(
          (u) => u.userDetailsName == expenseProvider.userController.text,
          orElse: () => GetUserModel(
              userDetailsId: 0,
              userDetailsName: '',
              password: '',
              workingStatus: '',
              userType: '',
              roleId: '',
              address1: '',
              address2: '',
              address3: '',
              address4: '',
              mobile: '',
              email: '',
              otp: '',
              countryCodeId: '',
              countryCodeName: '',
              deleteStatus: '',
              departmentId: '',
              departmentName: '',
              branchId: '',
              branchName: '',
              allowAppLogin: '',
              empCode: '',
              designation: '',
              doj: ''));
      if (user.userDetailsId != 0) {
        widget.expenseModel.userDetailsId = user.userDetailsId;
        widget.expenseModel.userName = user.userDetailsName;
      } else {
        showErrorDialog(context, 'No valid user found.');
        return;
      }
    }

    // Set projectTypeId
    if (widget.expenseModel.projectTypeId == null) {
      final projectTypeList = await _projectTypeFuture;
      final projectType = projectTypeList?.firstWhere(
        (pt) =>
            pt.projectTypeName == expenseProvider.projectTypeController.text,
        orElse: () => ProjectTypeModel(projectTypeId: 0, projectTypeName: ''),
      );
      if (projectType != null && projectType.projectTypeId != 0) {
        widget.expenseModel.projectTypeId = projectType.projectTypeId;
        widget.expenseModel.projectTypeName = projectType.projectTypeName;
      } else {
        showErrorDialog(
            context, 'No matching project type found for the selected name.');
        return;
      }
    }

    // Set projectId
    if (widget.expenseModel.projectId == null) {
      final projectList = await _projectFuture;
      final project = projectList?.firstWhere(
        (p) => p.projectName == expenseProvider.projectController.text,
        orElse: () => ProjectModel(projectId: 0, projectName: ''),
      );
      if (project != null && project.projectId != 0) {
        widget.expenseModel.projectId = project.projectId;
        widget.expenseModel.projectName = project.projectName;
      } else {
        showErrorDialog(
            context, 'No matching project found for the selected name.');
        return;
      }
    }

    // Set expenseTypeId
    if (widget.expenseModel.expenseTypeId == null) {
      final expenseTypeList = await _expenseTypeFuture;
      final expenseType = expenseTypeList?.firstWhere(
        (e) => e.expenseTypeName == expenseProvider.expenseTypeController.text,
        orElse: () => ExpenseTypeModel(
            expenseTypeId: 0, expenseTypeName: '', deleteStatus: 0),
      );
      if (expenseType != null && expenseType.expenseTypeId != 0) {
        widget.expenseModel.expenseTypeId = expenseType.expenseTypeId;
        widget.expenseModel.expenseTypeName = expenseType.expenseTypeName;
      } else {
        showErrorDialog(
            context, 'No matching expense type found for the selected name.');
        return;
      }
    }

    // Set customerId
    if (widget.expenseModel.customerId == null) {
      final customerTypeList = await _customerTypeFuture;
      final customer = customerTypeList?.firstWhere(
        (c) => c.customerName == expenseProvider.leadController.text,
        orElse: () =>
            CustomerModel(customerId: '0', customerName: '', isRegistered: ''),
      );
      if (customer != null && customer.customerId != '0') {
        widget.expenseModel.customerId = int.parse(customer.customerId!);
        widget.expenseModel.customerName = customer.customerName;
      } else {
        showErrorDialog(
            context, 'No matching customer found for the selected name.');
        return;
      }
    }

    // Recalculate GST if applicable
    if (widget.expenseModel.isGst ?? false) {
      calculateGst(expenseProvider.taxPercentageController.text);
    }

    if (widget.expenseModel.fileBytes != null) {
      // Check file type before saving
      String fileType = _determineFileType(widget.expenseModel.fileBytes!);
      bool isImage = _isImageFile(widget.expenseModel.fileBytes!);
      bool isPdf = _isPdfFile(widget.expenseModel.fileBytes!);

      print('File type: $fileType');
      print('Is Image: $isImage');
      print('Is PDF: $isPdf');

      String? filepath = await expenseProvider.saveToAws(
          widget.expenseModel.fileBytes!, fileType, "expense", context);
      if (!filepath.isNullOrEmpty()) {
        widget.expenseModel.filePath = filepath;
      }
    }

    if (!(widget.expenseModel.isGst ?? false)) {
      widget.expenseModel.netAmount = widget.expenseModel.amount;
    }

//need to recheck if error
    expenseProvider.saveExpense(
        widget.expenseModel, widget.isEdit as BuildContext, context as String);
  }

  void calculateGst(String taxPercentage) {
    double cgst = 0;
    double sgst = 0;
    double netAmt = 0;
    double percentage = 0;

    if (widget.expenseModel.isGst ?? false) {
      double amount =
          double.tryParse(expenseProvider.amountController.text) ?? 0;

      if (taxPercentage.isNullOrEmpty()) {
        percentage = 0;
      }
      percentage = double.tryParse(taxPercentage) ?? 0;

      Map<String, double>? gstData = GSTCalculator.calculateInclusiveGST(
        totalAmount: amount,
        gstRate: percentage,
        isInterState: false,
      );
      cgst = gstData['cgst'] ?? 0;
      sgst = gstData['cgst'] ?? 0;
      netAmt = (amount - (cgst + sgst));
    } else {
      netAmt =
          double.tryParse(expenseProvider.amountWithoutTaxController.text) ?? 0;
    }
    setGstAmount(
        cgst: cgst, sgst: sgst, netAmt: netAmt, percentage: percentage);
  }

  void setGstAmount({
    double cgst = 0,
    double sgst = 0,
    double netAmt = 0,
    double percentage = 0,
    bool isClearPercentage = false,
  }) {
    widget.expenseModel.cgstAmount = cgst;
    widget.expenseModel.sgstAmount = sgst;
    widget.expenseModel.netAmount = netAmt;
    widget.expenseModel.gstPercentage = percentage;

    if (isClearPercentage) {
      expenseProvider.taxPercentageController.text =
          percentage.toStringAsFixed(2);
    }
    expenseProvider.cgstController.text = cgst.toStringAsFixed(2);
    expenseProvider.sgstController.text = sgst.toStringAsFixed(2);
    expenseProvider.amountWithoutTaxController.text = netAmt.toStringAsFixed(2);
  }

  Future<Map<String, dynamic>> _getCurrentUserDetailsWithAdmin() async {
    final preferences = await SharedPreferences.getInstance();

    String userType = preferences.getString('userType') ?? '0';

    return {
      'userId': int.tryParse(preferences.getString('userId') ?? '0'),
      'userName': preferences.getString('userName') ?? 'Current User',
      'isAdmin':
          userType == '1', // Adjust this based on your admin user type value
    };
  }
}
