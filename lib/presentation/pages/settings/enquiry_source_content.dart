import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_new_enquiry_widget.dart';

class EnquirySourceContent extends StatefulWidget {
  const EnquirySourceContent({super.key});

  @override
  State<EnquirySourceContent> createState() => _EnquirySourceContentState();
}

class _EnquirySourceContentState extends State<EnquirySourceContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchEnquiryStatusData('', context);
      settingsProvider.searchEnquiryController.clear();
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AddEnquirySource(
          editId: '0',
          isEdit: false,
          status: '',
        );
      },
    );
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
              if (isWeb) ...[
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        'Enquiry Source',
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
                          controller: settingsProvider.searchEnquiryController,
                          onChanged: (query) {
                            print(query);
                            settingsProvider.searchEnquiryStatusData(
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
                          onPressed: _openAddDialog,
                          svgPath: 'assets/images/Plus.svg',
                          label: 'New Enquiry Source',
                          breakpoint: 860,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.secondaryBlue,
                          borderSide:
                              BorderSide(color: AppColors.secondaryBlue),
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
                  itemCount: settingsProvider.searchEnquiryStatus.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(12),
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
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  settingsProvider.searchEnquiryStatus[index]
                                      .enquirySourceName,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (settingsProvider.menuIsEditMap[6] == 1)
                            TextButton(
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddEnquirySource(
                                        editId: settingsProvider
                                            .searchEnquiryStatus[index]
                                            .enquirySourceId
                                            .toString(),
                                        status: settingsProvider
                                            .searchEnquiryStatus[index]
                                            .enquirySourceName,
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
                          if (settingsProvider.menuIsDeleteMap[6] == 1)
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
                                              settingsProvider.deleteEnquiry(
                                                  context,
                                                  settingsProvider
                                                      .searchEnquiryStatus[
                                                          index]
                                                      .enquirySourceId);
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
