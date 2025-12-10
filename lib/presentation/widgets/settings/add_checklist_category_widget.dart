import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/checklist_category_model.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddCheckListCategoryPage extends StatefulWidget {
  CheckListCategoryModel checkListCategoryModel = CheckListCategoryModel();

  AddCheckListCategoryPage({
    super.key,
    required this.checkListCategoryModel,
  });

  @override
  State<AddCheckListCategoryPage> createState() =>
      _AddCheckListCategoryPageState(this.checkListCategoryModel);
}

class _AddCheckListCategoryPageState extends State<AddCheckListCategoryPage> {
  _AddCheckListCategoryPageState(this.checkListCategoryModel);
  final categoryController = TextEditingController();
  CheckListCategoryModel checkListCategoryModel = CheckListCategoryModel();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (checkListCategoryModel.checkListCategoryId.isGreaterThanZero()) {
        categoryController.text =
            checkListCategoryModel.checkListCategoryName ?? "";
      }
    });
    super.initState();
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
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            checkListCategoryModel.checkListCategoryId.isGreaterThanZero()
                ? 'Edit checkList item'
                : 'Add checkList item',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              categoryController.clear();
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
                      controller: categoryController,
                      hintText: 'Item Name*',
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
            categoryController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (categoryController.text.trim().isEmpty) {
              showErrorDialog(context, "Please enter valid item");
              return;
            } else {
              checkListCategoryModel.checkListCategoryName =
                  categoryController.text;
              settingsProvider.addCheckListCategory(
                context: context,
                categoryModel: checkListCategoryModel,
              );
            }
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
