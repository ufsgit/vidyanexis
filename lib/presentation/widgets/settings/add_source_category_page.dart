import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddSourceCategoryPage extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String editId;

  const AddSourceCategoryPage({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
  });

  @override
  State<AddSourceCategoryPage> createState() => _AddSourceCategoryPageState();
}

class _AddSourceCategoryPageState extends State<AddSourceCategoryPage> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.sourceCategoryController.text.trim().isEmpty) {
      return 'Please enter Source Category Name';
    }

    // if (settingsProvider.selectedColor == null) {
    //   return 'Please select a category color';
    // }
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
        settingsProvider.sourceCategoryController.text = widget.status;
      });
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
            widget.isEdit ? 'Edit Source Category' : 'Add Source Category',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.sourceCategoryController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.sourceCategoryController,
                      hintText: 'Source Category Name*',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.sourceCategoryController.clear();
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

            settingsProvider.addSourceCategory(
              context: context,
              sourceCategoryId: widget.editId,
              sourceCategoryName:
                  settingsProvider.sourceCategoryController.text,
            );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
