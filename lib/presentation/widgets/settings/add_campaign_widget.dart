import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

class AddCampaignWidget extends StatefulWidget {
  final bool isEdit;
  final int campaignId;
  final String campaignName;
  final String campaignIdString;
  final String userIds;
  final int enquirySourceId;
  final int enquiryForId;

  const AddCampaignWidget({
    super.key,
    required this.isEdit,
    this.campaignId = 0,
    this.campaignName = '',
    this.campaignIdString = '',
    this.userIds = '',
    this.enquirySourceId = 0,
    this.enquiryForId = 0,
  });

  @override
  State<AddCampaignWidget> createState() => _AddCampaignWidgetState();
}

class _AddCampaignWidgetState extends State<AddCampaignWidget> {
  List<int> selectedUserIds = [];
  int? selectedEnquirySourceId;
  int? selectedEnquiryForId;

  @override
  void initState() {
    super.initState();
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);

    // Fetch Enquiry Sources and Enquiry For
    dropDownProvider.getEnquirySource(context);
    dropDownProvider.getEnquiryFor(context);

    if (widget.isEdit) {
      settingsProvider.campaignNameController.text = widget.campaignName;
      settingsProvider.campaignIdStringController.text =
          widget.campaignIdString;
      selectedEnquirySourceId =
          widget.enquirySourceId != 0 ? widget.enquirySourceId : null;
      selectedEnquiryForId =
          widget.enquiryForId != 0 ? widget.enquiryForId : null;
      // Always fetch from server to get accurate pre-checked users
      _fetchCampaignDetails();
    } else {
      settingsProvider.campaignNameController.clear();
      settingsProvider.campaignIdStringController.clear();
      selectedUserIds = [];
      selectedEnquirySourceId = null;
      selectedEnquiryForId = null;
    }
  }

  Future<void> _fetchCampaignDetails() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final campaign = await settingsProvider.getCampaignById(
        context, widget.campaignId.toString());
    if (campaign != null) {
      if (mounted) {
        setState(() {
          if (campaign.userIds.isNotEmpty) {
            selectedUserIds = campaign.userIds
                .split(',')
                .where((s) => s.isNotEmpty)
                .map((s) => int.parse(s))
                .toList();
          }
          if (campaign.enquirySourceId != 0) {
            selectedEnquirySourceId = campaign.enquirySourceId;
          }
          if (campaign.enquiryForId != 0) {
            selectedEnquiryForId = campaign.enquiryForId;
          }
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
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: settingsProvider.searchUserDetails.length,
                itemBuilder: (context, index) {
                  final user = settingsProvider.searchUserDetails[index];
                  final isSelected =
                      selectedUserIds.contains(user.userDetailsId);
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
    final isMobile = !AppStyles.isWebScreen(context);

    Widget buildFormContent(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            Text(
              widget.isEdit ? 'Edit Campaign' : 'Add New Campaign',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 24),
          ],
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
          Consumer<DropDownProvider>(
            builder: (context, dropDownProvider, child) {
              return CommonDropdown<int>(
                hintText: 'Enquiry Source',
                items: dropDownProvider.enquiryData
                    .map((source) => DropdownItem<int>(
                          id: source.enquirySourceId,
                          name: source.enquirySourceName,
                        ))
                    .toList(),
                onItemSelected: (selectedId) {
                  setState(() {
                    selectedEnquirySourceId = selectedId;
                  });
                },
                selectedValue: selectedEnquirySourceId,
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer<DropDownProvider>(
            builder: (context, dropDownProvider, child) {
              return CommonDropdown<int>(
                hintText: 'Enquiry For',
                items: dropDownProvider.enquiryForList
                    .map((source) => DropdownItem<int>(
                          id: source.enquiryForId,
                          name: source.enquiryForName,
                        ))
                    .toList(),
                onItemSelected: (selectedId) {
                  setState(() {
                    selectedEnquiryForId = selectedId;
                  });
                },
                selectedValue: selectedEnquiryForId,
              );
            },
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
                  displayName = settingsProvider
                      .searchUserDetails[userIndex].userDetailsName;
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppColors.secondaryBlue.withOpacity(0.3)),
                  ),
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryBlue,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                borderRadius: BorderRadius.circular(4),
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
              CustomElevatedButton(
                buttonText: 'Cancel',
                onPressed: () => Navigator.pop(context),
                radius: 4,
                backgroundColor: Colors.white,
                borderColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF64748B),
              ),
              const SizedBox(width: 16),
              CustomElevatedButton(
                radius: 4,
                backgroundColor: AppColors.secondaryBlue,
                borderColor: AppColors.secondaryBlue,
                textColor: Colors.white,
                onPressed: () {
                  if (settingsProvider.campaignNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter campaign name')),
                    );
                    return;
                  }
                  if (selectedEnquirySourceId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select enquiry source')),
                    );
                    return;
                  }

                  if (selectedEnquiryForId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select enquiry for')),
                    );
                    return;
                  }

                  final dropDownProvider =
                      Provider.of<DropDownProvider>(context, listen: false);
                  final selectedSource = dropDownProvider.enquiryData
                      .firstWhere((element) =>
                          element.enquirySourceId == selectedEnquirySourceId);
                  final selectedFor = dropDownProvider.enquiryForList
                      .firstWhere((element) =>
                          element.enquiryForId == selectedEnquiryForId);

                  settingsProvider.saveCampaign(
                    context: context,
                    campaignId: widget.campaignId.toString(),
                    userIds: selectedUserIds.join(','),
                    enquirySourceId: selectedEnquirySourceId ?? 0,
                    enquirySourceName: selectedSource.enquirySourceName,
                    enquiryForId: selectedEnquiryForId ?? 0,
                    enquiryForName: selectedFor.enquiryForName,
                  );
                },
                buttonText: widget.isEdit ? 'Update' : 'Save',
              ),
            ],
          ),
        ],
      );
    }

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.isEdit ? 'Edit Campaign' : 'Add New Campaign',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: buildFormContent(context),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        child: buildFormContent(context),
      ),
    );
  }
}
