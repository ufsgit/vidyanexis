import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddCampaignWidget extends StatefulWidget {
  final bool isEdit;
  final int campaignId;
  final String campaignName;
  final String campaignIdString;
  final String userIds;

  const AddCampaignWidget({
    super.key,
    required this.isEdit,
    this.campaignId = 0,
    this.campaignName = '',
    this.campaignIdString = '',
    this.userIds = '',
  });

  @override
  State<AddCampaignWidget> createState() => _AddCampaignWidgetState();
}

class _AddCampaignWidgetState extends State<AddCampaignWidget> {
  List<int> selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (widget.isEdit) {
      settingsProvider.campaignNameController.text = widget.campaignName;
      settingsProvider.campaignIdStringController.text = widget.campaignIdString;
      // Always fetch from server to get accurate pre-checked users
      _fetchCampaignDetails();
    } else {
      settingsProvider.campaignNameController.clear();
      settingsProvider.campaignIdStringController.clear();
      selectedUserIds = [];
    }
  }

  Future<void> _fetchCampaignDetails() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final campaign = await settingsProvider.getCampaignById(
        context, widget.campaignId.toString());
    if (campaign != null && campaign.userIds.isNotEmpty) {
      if (mounted) {
        setState(() {
          selectedUserIds = campaign.userIds
              .split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.parse(s))
              .toList();
        });
      }
    }
  }

  void _showUserSelectionDialog() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Select Users',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: settingsProvider.searchUserDetails.length,
                itemBuilder: (context, index) {
                  final user = settingsProvider.searchUserDetails[index];
                  final isSelected = selectedUserIds.contains(user.userDetailsId);
                  return CheckboxListTile(
                    title: Text(user.userDetailsName),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedUserIds.add(user.userDetailsId);
                        } else {
                          selectedUserIds.remove(user.userDetailsId);
                        }
                      });
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: AppStyles.isWebScreen(context) ? 500 : double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit ? 'Edit Campaign' : 'Add New Campaign',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: settingsProvider.campaignNameController,
              hintText: 'Campaign Name',
              labelText: 'Campaign Name',
              readOnly: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: settingsProvider.campaignIdStringController,
              hintText: 'Campaign ID String (e.g. CMP001)',
              labelText: 'Campaign ID String',
              readOnly: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Users: ${selectedUserIds.length}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedUserIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedUserIds.map((id) {
                  final userIndex = settingsProvider.searchUserDetails
                      .indexWhere((u) => u.userDetailsId == id);
                  String displayName = 'User $id';
                  if (userIndex != -1) {
                    displayName =
                        settingsProvider.searchUserDetails[userIndex].userDetailsName;
                  }
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            InkWell(
              onTap: _showUserSelectionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedUserIds.isEmpty
                          ? 'Select Users'
                          : 'Change Selected Users',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Icon(Icons.people, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                CustomElevatedButton(
                  backgroundColor: AppColors.primaryBlue,
                  borderColor: AppColors.primaryBlue,
                  textColor: Colors.white,
                  onPressed: () {
                    if (settingsProvider.campaignNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter campaign name')),
                      );
                      return;
                    }
                    settingsProvider.saveCampaign(
                      context: context,
                      campaignId: widget.campaignId.toString(),
                      userIds: selectedUserIds.join(','),
                    );
                  },
                  buttonText: widget.isEdit ? 'Update' : 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
