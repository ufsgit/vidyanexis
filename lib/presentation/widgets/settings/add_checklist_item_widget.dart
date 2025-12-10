import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/controller/expense_provider.dart';
import 'package:techtify/controller/models/checklist_category_model.dart';
import 'package:techtify/controller/models/checklist_item_model.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddCheckListItemPage extends StatefulWidget {
  CheckListItemModel checkListItemModel = CheckListItemModel();

  AddCheckListItemPage({
    super.key,
    required this.checkListItemModel,
  });

  @override
  State<AddCheckListItemPage> createState() =>
      _AddCheckListItemPageState(this.checkListItemModel);
}

class _AddCheckListItemPageState extends State<AddCheckListItemPage> {
  _AddCheckListItemPageState(this.checkListItemModel);
  final itemController = TextEditingController();
  CheckListItemModel checkListItemModel = CheckListItemModel();
  Future<List<CheckListCategoryModel>>? categoryListFuture;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      categoryListFuture = settingsProvider.getCheckListCategory("", context);

      if (checkListItemModel.checkListItemId.isGreaterThanZero()) {
        itemController.text = checkListItemModel.checkListItemName ?? "";
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
            checkListItemModel.checkListCategoryId.isGreaterThanZero()
                ? 'Edit checklist item'
                : 'Add checklist item',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              itemController.clear();
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
                      controller: itemController,
                      hintText: 'Item Name*',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<CheckListCategoryModel>>(
                        future: categoryListFuture,
                        builder: (contextBuilder, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Loading state
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return CommonDropdown<int>(
                            hintText: 'Category name *',
                            items: (snapshot.data ?? [])
                                .map((status) => DropdownItem<int>(
                                      id: status.checkListCategoryId ?? 0,
                                      name: status.checkListCategoryName ?? "",
                                    ))
                                .toList(),
                            // controller: flowTaskTypeController,
                            onItemSelected: (int? newValue) {
                              if (newValue != null) {
                                checkListItemModel.checkListCategoryId =
                                    newValue;
                              }
                            },
                            selectedValue:
                                checkListItemModel.checkListCategoryId ?? 0,
                          );
                        }),
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
            itemController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (itemController.text.trim().isEmpty) {
              showErrorDialog(context, "Please enter valid item");
              return;
            } else if (checkListItemModel.checkListCategoryId.isNullOrZero()) {
              showErrorDialog(context, "Please enter valid category");
              return;
            } else {
              checkListItemModel.checkListItemName = itemController.text;
              settingsProvider.addCheckListItem(
                context: context,
                itemModel: checkListItemModel,
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
