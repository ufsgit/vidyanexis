import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:techtify/presentation/widgets/settings/add_category_widget.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchCategoryApi('', context);
      settingsProvider.searchCategoryController.clear();
    });
    super.initState();
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
            width: constraints.maxWidth < minContentWidth
                ? minContentWidth
                : constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        'Category Page',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue800),
                      ),
                      const Spacer(),
                      // Container(
                      //   width: MediaQuery.of(context).size.width / 3.5,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(color: Colors.grey[300]!),
                      //   ),
                      //   child: TextField(
                      //     controller: settingsProvider.searchCategoryController,
                      //     onChanged: (query) {
                      //       print(query);
                      //       settingsProvider.searchCategoryApi(
                      //           query, context);
                      //     },
                      //     decoration: const InputDecoration(
                      //       hintText: 'Search here....',
                      //       prefixIcon: Icon(Icons.search),
                      //       border: InputBorder.none,
                      //       contentPadding: EdgeInsets.symmetric(
                      //         horizontal: 16,
                      //         vertical: 4,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 16),
                      if (settingsProvider.menuIsSaveMap[36] == 1)
                        CustomOutlinedSvgButton(
                          onPressed: () async {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return const AddCategoryWidget(
                                  editId: '0',
                                  isEdit: false,
                                );
                              },
                            );
                          },
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New Category',
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
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 12,
                          );
                        },
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: settingsProvider.searchCategory.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                          settingsProvider.searchCategory[index]
                                              .categoryName,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (settingsProvider.menuIsEditMap[36] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AddCategoryWidget(
                                                editId: settingsProvider
                                                    .searchCategory[index]
                                                    .categoryId
                                                    .toString(),
                                                isEdit: true,
                                                data: settingsProvider
                                                    .searchCategory[index],
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
                                  if (settingsProvider.menuIsDeleteMap[36] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
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
                                                          .deleteCategory(
                                                              context,
                                                              settingsProvider
                                                                  .searchCategory[
                                                                      index]
                                                                  .categoryId);
                                                      Navigator.pop(context);
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
                      )
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
