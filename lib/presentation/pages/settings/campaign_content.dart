import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_campaign_widget.dart';

class CampaignContent extends StatefulWidget {
  const CampaignContent({super.key});

  @override
  State<CampaignContent> createState() => _CampaignContentState();
}

class _CampaignContentState extends State<CampaignContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchCampaignData('', context);
      settingsProvider.searchCampaignController.clear();
      // Ensure users are loaded for the selection dialog
      settingsProvider.getUserDetails('', context);
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
    if (!AppStyles.isWebScreen(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddCampaignWidget(
            isEdit: false,
          ),
        ),
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => const AddCampaignWidget(
          isEdit: false,
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
              if (isWeb) ...[
                // Header section
                Row(
                  children: [
                    Text(
                      'Campaign Management',
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
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                      ),
                      child: TextField(
                        controller: settingsProvider.searchCampaignController,
                        onChanged: (query) {
                          settingsProvider.searchCampaignData(query, context);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search campaigns...',
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
                    CustomOutlinedSvgButton(
                      onPressed: _openAddDialog,
                      svgPath: 'assets/images/Plus.svg',
                      label: 'New Campaign',
                      breakpoint: 860,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryBlue,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              // List section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: settingsProvider.campaignList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final campaign = settingsProvider.campaignList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: AppColors.surfaceGrey,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(
                                          campaign.campaignName,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'ID: ${campaign.campaignIdString}',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500),
                                    ),
                                    if (campaign.createdDate.isNotEmpty) ...[
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      Text(
                                        'Created: ${campaign.createdDate.split('T').first}',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                    if (campaign.userIds.isNotEmpty) ...[
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      Text(
                                        'Users: ${campaign.userIds.split(',').where((s) => s.isNotEmpty).length}',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (!AppStyles.isWebScreen(context)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCampaignWidget(
                                      isEdit: true,
                                      campaignId: campaign.campaignId,
                                      campaignName: campaign.campaignName,
                                      campaignIdString: campaign.campaignIdString,
                                      userIds: campaign.userIds,
                                      enquirySourceId: campaign.enquirySourceId,
                                      enquiryForId: campaign.enquiryForId,
                                    ),
                                  ),
                                );
                              } else {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => AddCampaignWidget(
                                    isEdit: true,
                                    campaignId: campaign.campaignId,
                                    campaignName: campaign.campaignName,
                                    campaignIdString: campaign.campaignIdString,
                                    userIds: campaign.userIds,
                                    enquirySourceId: campaign.enquirySourceId,
                                    enquiryForId: campaign.enquiryForId,
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
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        settingsProvider.deleteCampaign(
                                            context, campaign.campaignId);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'Delete',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textRed),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (settingsProvider.campaignList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No campaigns found',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey, fontSize: 16),
                    ),
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
