import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/models/search_status_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddStatus extends StatefulWidget {
  final bool isEdit;
  final SearchStatusModel? status;
  const AddStatus({
    super.key,
    required this.isEdit,
    this.status,
  });

  @override
  State<AddStatus> createState() => _AddStatusState();
}

class _AddStatusState extends State<AddStatus> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.statusPageController.text.trim().isEmpty) {
      return 'Please enter Status';
    }
    if (settingsProvider.statusFollowUpController.text.isEmpty) {
      return 'Please select Follow-up Status';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.status != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.statusPageController.text =
            widget.status?.statusName ?? "";
        final followUp = widget.status?.followup == 1;
        settingsProvider.setFollowupId(followUp ? 1 : 0);
        settingsProvider.statusFollowUpController.text =
            followUp ? 'Yes' : 'No';
      });
    } else {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.setFollowupId(-1);
      settingsProvider.statusPageController.clear();
      settingsProvider.statusFollowUpController.clear();
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.isEdit ? 'Edit Status' : 'Add Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              settingsProvider.statusPageController.clear();
              settingsProvider.statusFollowUpController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 6,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Name Field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.statusPageController,
              hintText: 'Status name*',
              labelText: '',
            ),

            const SizedBox(height: 20),
            CommonDropdown<int>(
              selectedValue: settingsProvider.selectedStatusId,
              hintText: 'Follow-up Status*',
              items: [
                DropdownItem<int>(id: 1, name: 'Yes'),
                DropdownItem<int>(id: 0, name: 'No'),
              ],
              controller: settingsProvider.statusFollowUpController,
              onItemSelected: (selectedId) {
                settingsProvider.setFollowupId(selectedId);
                settingsProvider.statusFollowUpController.text =
                    selectedId == 1 ? 'Yes' : 'No';
              },
            )
          ],
        )),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.statusPageController.clear();
            settingsProvider.statusFollowUpController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }

            await settingsProvider.saveStatus(
              context: context,
              followUp: settingsProvider.statusFollowUpController.text == "Yes",
              statusId: widget.isEdit ? widget.status?.statusId : 0,
            );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
