import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import 'package:vidyanexis/controller/models/category_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddCategoryWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final CategoryModel? data;

  const AddCategoryWidget({
    super.key,
    required this.isEdit,
    required this.editId,
    this.data,
  });

  @override
  State<AddCategoryWidget> createState() => _AddCategoryWidgetState();
}

class _AddCategoryWidgetState extends State<AddCategoryWidget> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.categoryNameController.text.trim().isEmpty) {
      return 'Please enter Category Name';
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
        settingsProvider.categoryNameController.text =
            widget.data?.categoryName ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Category' : 'Add Category',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlue800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: AppStyles.isWebScreen(context) ? 800 : double.infinity,
          child: Column(
            children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Category Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.categoryNameController,
                    hintText: 'Category Name*',
                    labelText: '',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: AppStyles.isWebScreen(context) ? MainAxisAlignment.end : MainAxisAlignment.center,
              children: [
                ResponsiveButtonWrapper(
                  child: CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {
                      settingsProvider.categoryNameController.clear();
                      Navigator.pop(context);
                    },
                    radius: 12,
                    backgroundColor: AppColors.whiteColor,
                    borderColor: const Color(0xFFE2E8F0),
                    textColor: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 16),
                ResponsiveButtonWrapper(
                  child: CustomElevatedButton(
                    buttonText: 'Save',
                    onPressed: () async {
                      final validationError = validateInputs(context, settingsProvider);
                      if (validationError != null) {
                        showErrorDialog(context, validationError);
                        return;
                      }
                      settingsProvider.addCategoryName(
                        context: context,
                        statusId: widget.editId,
                        statusName: settingsProvider.categoryNameController.text,
                      );
                    },
                    radius: 12,
                    backgroundColor: AppColors.secondaryBlue,
                    borderColor: AppColors.secondaryBlue,
                    textColor: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}
