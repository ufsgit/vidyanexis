import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/checklist_category_model.dart';
import 'package:vidyanexis/controller/models/checklist_item_model.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCheckListManagementWidget extends StatefulWidget {
  DocumentChecklistModel documentChecklistModel = DocumentChecklistModel();
  AddCheckListManagementWidget(
      {super.key, required this.documentChecklistModel});

  @override
  State<AddCheckListManagementWidget> createState() =>
      _AddCheckListManagementWidgetState();
}

class _AddCheckListManagementWidgetState
    extends State<AddCheckListManagementWidget> {
  late SettingsProvider settingsProvider;
  Future<List<CheckListCategoryModel>>? categoryListFuture;
  List<CheckListCategoryModel> categoryList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    categoryListFuture = settingsProvider.getDocumentChecklistDetails(
        (widget.documentChecklistModel.documentCheckListMasterId ?? 0)
            .toString(),
        context);
  }

// Add this validation method to your class
  bool _hasAtLeastOneCheckedItem() {
    for (var category in categoryList) {
      if (category.items != null) {
        for (var item in category.items!) {
          if (item.isChecked == true) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _showValidationDialog(BuildContext context) {
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
            'Please select at least one checkbox before saving.',
            style: TextStyle(
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AppStyles.isWebScreen(context)
              ? MediaQuery.of(context).size.width / 2
              : MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                // color: AppColors.appViolet.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.documentChecklistModel.documentCheckListMasterId
                            .isGreaterThanZero()
                        ? Icons.edit_note
                        : Icons.add_task,
                    color: AppColors.appViolet,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.documentChecklistModel.documentCheckListMasterId
                            .isGreaterThanZero()
                        ? 'Edit Checklist'
                        : 'Add Checklist',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textGrey1,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: FutureBuilder<List<CheckListCategoryModel>>(
                  future: categoryListFuture,
                  builder: (contextBuilder, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.appViolet),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading categories...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    categoryList = snapshot.data ?? [];

                    if (categoryList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 30),
                            Icon(Icons.category_outlined,
                                size: 60,
                                color: AppColors.textGrey1.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try refreshing or adding new categories',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey1.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryList.map((categoryModel) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textGrey1.withOpacity(0.15),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.appViolet.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.list_alt,
                                  color: AppColors.appViolet,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                categoryModel.checkListCategoryName ?? "",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              iconColor: AppColors.appViolet,
                              collapsedIconColor: AppColors.textGrey1,
                              childrenPadding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 0,
                              ),
                              children: [
                                if ((categoryModel.items ?? []).isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: AppColors.textGrey1
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'No items in this category',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.textGrey1
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ...List.generate(
                                  (categoryModel.items ?? []).length,
                                  (position) {
                                    CheckListItemModel itemModel =
                                        categoryModel.items![position];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: itemModel.isChecked ?? false
                                            ? AppColors.appViolet
                                                .withOpacity(0.05)
                                            : Colors.grey.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (itemModel.isChecked ?? false)
                                              ? AppColors.appViolet
                                                  .withOpacity(0.2)
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      child: Theme(
                                        data: ThemeData(
                                          checkboxTheme: CheckboxThemeData(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            itemModel.checkListItemName ?? '',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                          value: itemModel.isChecked ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              itemModel.isChecked = value;
                                            });
                                          },
                                          activeColor: AppColors.appViolet,
                                          checkColor: Colors.white,
                                          controlAffinity:
                                              ListTileControlAffinity.trailing,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 0),
                                          dense: true,
                                          isThreeLine: false,
                                          secondary: (itemModel.isChecked ??
                                                  false)
                                              ? Icon(
                                                  Icons.check_circle_outline,
                                                  color: AppColors.appViolet,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.appViolet,
                      side: BorderSide(color: AppColors.appViolet),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_hasAtLeastOneCheckedItem()) {
                        _showValidationDialog(context);
                        return;
                      }

                      if (widget
                          .documentChecklistModel.documentCheckListMasterId
                          .isNullOrZero()) {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        String userId = preferences.getString('userId') ?? "";
                        String userName =
                            preferences.getString('userName') ?? "";
                        widget.documentChecklistModel.entryDate =
                            DateTime.now().toString();
                        widget.documentChecklistModel.userId =
                            int.parse(userId);
                        widget.documentChecklistModel.usrName = userName;
                        widget.documentChecklistModel
                            .documentCheckListMasterId = 0;
                      }
                      await settingsProvider.saveDocumentCheckList(
                        context: context,
                        categoryList: categoryList,
                        checkListModel: widget.documentChecklistModel,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appViolet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // const Icon(Icons.save, size: 18),
                        // const SizedBox(width: 8),
                        Text(
                          "Save",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
