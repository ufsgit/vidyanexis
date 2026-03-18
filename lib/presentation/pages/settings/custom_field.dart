import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_custom_field.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../controller/models/custom_field_model.dart';
import '../../../controller/settings_provider.dart';
import '../../widgets/home/custom_outlined_icon_button_widget.dart';

class CustomField extends StatefulWidget {
  const CustomField({super.key});

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  Future<List<CustomFieldModel>>? customfieldListFuture;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getData();
    });
    super.initState();
  }

  Future<void> getData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.getCustomField(context);
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: AppStyles.isWebScreen(context)
                ? constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth
                : MediaQuery.of(context).size.width - 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        'Custom Field',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue800),
                      ),
                      Spacer(),
                      if (settingsProvider.menuIsSaveMap[60] == 1)
                        CustomOutlinedSvgButton(
                          onPressed: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return const AddCustomField(
                                  editId: '0',
                                  isEdit: false,
                                  status: '',
                                );
                              },
                            );
                          },
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New Custom Field',
                          breakpoint: 860,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryBlue,
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: settingsProvider.customFieldModelList.length,
                    itemBuilder: (context, index) {
                      CustomFieldModel fieldModel =
                          settingsProvider.customFieldModelList[index];
                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                height: 22,
                                decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Text(
                                      fieldModel.customFieldName.toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (settingsProvider.menuIsEditMap[60] == 1)
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddCustomField(
                                            editId: '0',
                                            isEdit: true,
                                            status: '',
                                            customFieldTypeModel: fieldModel,
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryBlue),
                                    )),
                              if (settingsProvider.menuIsDeleteMap[60] == 1)
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  settingsProvider
                                                      .deleteCustomField(
                                                          context,
                                                          fieldModel
                                                              .customFieldId
                                                              .toString())
                                                      .then((value) {
                                                    if (null != value &&
                                                        value) {
                                                      getData();
                                                    }
                                                  });
                                                  // Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textRed),
                                    ))
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
        );
      },
    );
  }
}
