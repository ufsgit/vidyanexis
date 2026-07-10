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
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getData();
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  Future<void> getData() async {
    settingsProvider.getCustomField(context);
  }

  void _openAddDialog() {
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
    ).then((value) {
      if (null != value && value) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final isWeb = AppStyles.isWebScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              final query = settingsProvider.customFieldSearchQuery;
              final filteredList = settingsProvider.customFieldModelList
                  .where((field) => (field.customFieldName ?? "")
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 12,
                        );
                      },
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        CustomFieldModel fieldModel = filteredList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey,
                                        borderRadius: BorderRadius.circular(4)),
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
                              const SizedBox(width: 8),
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
                                      ).then((value) {
                                        if (null != value && value) {
                                          getData();
                                        }
                                      });
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
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );

        if (isWeb) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: content,
          );
        } else {
          return content;
        }
      },
    );
  }
}
