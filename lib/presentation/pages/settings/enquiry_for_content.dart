import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/settings/permission_handling_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_enquiry_for_widget.dart';
import 'package:vidyanexis/presentation/pages/settings/add_enquiry_for_mobile_page.dart';

class EnquiryForContent extends StatefulWidget {
  const EnquiryForContent({super.key});

  @override
  State<EnquiryForContent> createState() => _EnquiryForContentState();
}

class _EnquiryForContentState extends State<EnquiryForContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchEnquiryForData('', context);
      settingsProvider.searchEnquiryForController.clear();
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

  void _openAddDialog() {
    final isWeb = AppStyles.isWebScreen(context);
    if (isWeb) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const AddEnquiryFor(
            editId: '0',
            isEdit: false,
            sourceId: '0',
            sourceName: '',
            status: '',
            data: null,
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEnquiryForMobilePage(
            editId: '0',
            isEdit: false,
            sourceId: '0',
            sourceName: '',
            status: '',
            data: null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Column(
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
                  itemCount: settingsProvider.searchEnquiryFor.length,
                  itemBuilder: (context, index) {
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
                                  settingsProvider
                                      .searchEnquiryFor[index].enquiryForName,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 200,
                            child: CustomOutlinedSvgButton(
                              showIcon: false,
                              onPressed: () async {
                                print(settingsProvider
                                    .searchEnquiryFor[index].enquiryForId
                                    .toString());
                                await settingsProvider
                                    .getMenuPermissionDataPrint(
                                        settingsProvider.searchEnquiryFor[index]
                                            .enquiryForId
                                            .toString(),
                                        context);
                                settingsProvider.searchPermissionPrint(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PermissionHandlingPage(
                                      userId: settingsProvider
                                          .searchEnquiryFor[index].enquiryForId
                                          .toString(),
                                      userName: settingsProvider
                                          .searchEnquiryFor[index]
                                          .enquiryForName,
                                      isPrintPermission: true,
                                    ),
                                  ),
                                );
                              },
                              svgPath: 'assets/images/Print.svg',
                              label: 'Permissions',
                              breakpoint: 860,
                              foregroundColor: AppColors.primaryBlue,
                              backgroundColor: Colors.white,
                              borderSide:
                                  BorderSide(color: AppColors.primaryBlue),
                            ),
                          ),
                          if (settingsProvider.menuIsEditMap[17].toString() ==
                              '1')
                            TextButton(
                                onPressed: () {
                                  final isWeb = AppStyles.isWebScreen(context);
                                  if (isWeb) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddEnquiryFor(
                                          editId: settingsProvider
                                              .searchEnquiryFor[index]
                                              .enquiryForId
                                              .toString(),
                                          sourceId: settingsProvider
                                              .searchEnquiryFor[index]
                                              .sourceCategoryId
                                              .toString(),
                                          sourceName: settingsProvider
                                              .searchEnquiryFor[index]
                                              .sourceCategoryName
                                              .toString(),
                                          status: settingsProvider
                                              .searchEnquiryFor[index]
                                              .enquiryForName,
                                          isEdit: true,
                                          data: settingsProvider
                                              .searchEnquiryFor[index],
                                        );
                                      },
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEnquiryForMobilePage(
                                          editId: settingsProvider
                                              .searchEnquiryFor[index]
                                              .enquiryForId
                                              .toString(),
                                          sourceId: settingsProvider
                                              .searchEnquiryFor[index]
                                              .sourceCategoryId
                                              .toString(),
                                          sourceName: settingsProvider
                                              .searchEnquiryFor[index]
                                              .sourceCategoryName
                                              .toString(),
                                          status: settingsProvider
                                              .searchEnquiryFor[index]
                                              .enquiryForName,
                                          isEdit: true,
                                          data: settingsProvider
                                              .searchEnquiryFor[index],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Edit',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue),
                                )),
                          if (settingsProvider.menuIsDeleteMap[17].toString() ==
                              '1')
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
                                              settingsProvider.deleteEnquiryFor(
                                                  context,
                                                  settingsProvider
                                                      .searchEnquiryFor[index]
                                                      .enquiryForId);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style:
                                                  TextStyle(color: Colors.red),
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
