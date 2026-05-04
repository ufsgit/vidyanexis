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
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.searchCampaignData('', context);
      settingsProvider.searchCampaignController.clear();
      // Ensure users are loaded for the selection dialog
      settingsProvider.getUserDetails('', context);
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
                ? (constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth)
                : MediaQuery.of(context).size.width - 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddCampaignWidget(
                            isEdit: false,
                          ),
                        );
                      },
                      svgPath: 'assets/images/Plus.svg',
                      label: 'New Campaign',
                      breakpoint: 860,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryBlue,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // List section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: settingsProvider.campaignList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final campaign = settingsProvider.campaignList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campaign.campaignName,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'ID: ${campaign.campaignIdString}',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 12),
                                    if (campaign.createdDate.isNotEmpty)
                                      Text(
                                        'Created: ${campaign.createdDate.split('T').first}',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (campaign.userIds.isNotEmpty)
                              Text(
                                'Users: ${campaign.userIds.split(',').where((s) => s.isNotEmpty).length}',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12),
                              ),
                            const SizedBox(width: 24),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddCampaignWidget(
                                    isEdit: true,
                                    campaignId: campaign.campaignId,
                                    campaignName: campaign.campaignName,
                                    campaignIdString: campaign.campaignIdString,
                                    userIds: campaign.userIds,
                                    enquirySourceId: campaign.enquirySourceId,
                                  ),
                                );
                              },
                              child: Text(
                                'Edit',
                                style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Campaign'),
                                    content: const Text(
                                        'Are you sure you want to delete this campaign?'),
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
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
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
          ),
        );
      },
    );
  }
}
