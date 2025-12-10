import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:techtify/presentation/widgets/settings/add_new_enquiry_widget.dart';
import 'package:techtify/presentation/widgets/settings/add_source_category_page.dart';
import 'package:techtify/presentation/widgets/settings/add_stage.dart';

class SourceCategoryPage extends StatefulWidget {
  const SourceCategoryPage({super.key});

  @override
  State<SourceCategoryPage> createState() => _SourceCategoryPageState();
}

class _SourceCategoryPageState extends State<SourceCategoryPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchsourceCategoryData('', context);
      settingsProvider.searchSourceCategoryController.clear();
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
                        'Source Category',
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
                          controller:
                              settingsProvider.searchSourceCategoryController,
                          onChanged: (query) {
                            print(query);
                            settingsProvider.searchsourceCategoryData(
                                query, context);
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
                                return const AddSourceCategoryPage(
                                  editId: '0',
                                  isEdit: false,
                                  status: '',
                                );
                              },
                            );
                          },
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New Source Category',
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
                        itemCount: settingsProvider.searchSourceCategory.length,
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
                                          settingsProvider
                                              .searchSourceCategory[index]
                                              .sourceName,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AddSourceCategoryPage(
                                              editId: settingsProvider
                                                  .searchSourceCategory[index]
                                                  .sourceId
                                                  .toString(),
                                              status: settingsProvider
                                                  .searchSourceCategory[index]
                                                  .sourceName,
                                              isEdit: true,
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
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
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
                                                        .deleteSourceCategory(
                                                            context,
                                                            settingsProvider
                                                                .searchSourceCategory[
                                                                    index]
                                                                .sourceId);
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
