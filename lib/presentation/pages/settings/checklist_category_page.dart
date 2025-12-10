import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/models/checklist_category_model.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_checklist_category_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_new_enquiry_widget.dart';

class CheckListCategoryPage extends StatefulWidget {
  const CheckListCategoryPage({super.key});

  @override
  State<CheckListCategoryPage> createState() => _CheckListCategoryPageState();
}

class _CheckListCategoryPageState extends State<CheckListCategoryPage> {
  final searchController = TextEditingController();
  Future<List<CheckListCategoryModel>>? categoryListFuture;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getData();
    });
    super.initState();
  }

  getData() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    categoryListFuture =
        settingsProvider.getCheckListCategory(searchController.text, context);
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
                        'Checklist Category',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue800),
                      ),
                      const Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            print(query);
                            getData();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search here....',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (settingsProvider.menuIsSaveMap[6] == 1)
                        CustomOutlinedSvgButton(
                          onPressed: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AddCheckListCategoryPage(
                                    checkListCategoryModel:
                                        CheckListCategoryModel());
                              },
                            ).then((value) {
                              if (null != value && value) {
                                getData();
                              }
                            });
                          },
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New CheckList Category',
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
                  child: Column(
                    children: [
                      FutureBuilder<List<CheckListCategoryModel>>(
                          future: categoryListFuture,
                          builder: (contextBuilder, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Loading state
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<CheckListCategoryModel> categoryList =
                                snapshot.data ?? [];
                            return ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 12,
                                );
                              },
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: categoryList.length,
                              itemBuilder: (context, index) {
                                CheckListCategoryModel categoryModel =
                                    categoryList[index];
                                return Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                              color: AppColors.surfaceGrey,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: Text(
                                                categoryModel
                                                        .checkListCategoryName ??
                                                    "",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (settingsProvider
                                                .menuIsEditMap[39] ==
                                            1)
                                          TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AddCheckListCategoryPage(
                                                        checkListCategoryModel:
                                                            categoryModel);
                                                  },
                                                ).then((value) {
                                                  if (null != value && value) {
                                                    getData();
                                                  }
                                                });
                                              },
                                              child: Text(
                                                'Edit',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .primaryBlue),
                                              )),
                                        if (settingsProvider
                                                .menuIsDeleteMap[39] ==
                                            1)
                                          TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm Delete'),
                                                      content: const Text(
                                                          'Are you sure you want to delete?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            settingsProvider
                                                                .deleteCheckListCategory(
                                                                    context,
                                                                    categoryModel
                                                                        .checkListCategoryId
                                                                        .toString())
                                                                .then((value) {
                                                              if (null !=
                                                                      value &&
                                                                  value) {
                                                                getData();
                                                              }
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'Delete',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.textRed),
                                              ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          })
                    ],
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
