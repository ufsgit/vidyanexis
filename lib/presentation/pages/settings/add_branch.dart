import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/models/branch_model.dart';
import 'package:techtify/controller/models/task_type_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddBranch extends StatefulWidget {
  final bool isEdit;
  final BranchModel? branch;
  final String editId;
  final TaskTypeModel? taskType;

  const AddBranch({
    super.key,
    required this.isEdit,
    this.branch,
    required this.editId,
    this.taskType,
  });

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.branchController.text.trim().isEmpty) {
      return 'Please enter branch';
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
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.branchController.text =
            widget.branch!.branchName ?? "";
        settingsProvider.addressController.text = widget.branch!.address ?? "";
        settingsProvider.pinCodeController.text = widget.branch!.pincode ?? "";
        settingsProvider.contactPersonController.text =
            widget.branch!.contactPerson ?? "";
        settingsProvider.emailBranchController.text =
            widget.branch!.email ?? "";
        settingsProvider.phoneController.text = widget.branch!.phone ?? "";
      });
    } else {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.clearBranchFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Branch' : 'Add Branch',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.branchController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 2.2,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Type Text Field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.branchController,
              hintText: 'Branch name*',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.addressController,
              hintText: 'Address',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.phoneController,
              hintText: 'Phone',
              labelText: '',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.pinCodeController,
              hintText: 'Pin code',
              labelText: '',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.emailBranchController,
              hintText: 'Email',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.contactPersonController,
              hintText: 'Contact Person',
              labelText: '',
            ),

            const SizedBox(height: 20),
          ],
        )),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.branchController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }
            settingsProvider.saveBranch(
                context: context, branchId: widget.editId);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
