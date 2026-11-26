import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

import 'package:vidyanexis/constants/app_styles.dart';

class AddCompanyDetails extends StatefulWidget {
  final bool isEdit;
  final String companyId;

  const AddCompanyDetails({
    super.key,
    required this.isEdit,
    required this.companyId,
  });

  @override
  State<AddCompanyDetails> createState() => _AddCompanyDetailsState();
}

class _AddCompanyDetailsState extends State<AddCompanyDetails> {
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final formattedHour = hour.toString().padLeft(2, '0');
    return '$formattedHour:$minute $period';
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      timeStr = timeStr.trim();
      if (timeStr.isEmpty) return null;
      final isPm = timeStr.toUpperCase().contains('PM');
      final isAm = timeStr.toUpperCase().contains('AM');
      final cleanStr = timeStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final parts = cleanStr.split(':');
      if (parts.length < 2) return null;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String _getStartTime(String text) {
    if (text.contains('-')) {
      return text.split('-')[0].trim();
    }
    return text.trim();
  }

  String _getEndTime(String text) {
    if (text.contains('-')) {
      final parts = text.split('-');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    return '';
  }

  void _showWorkingTimeDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    TimeOfDay? startTime = _parseTimeOfDay(
        _getStartTime(settingsProvider.cworkingTimeController.text));
    TimeOfDay? endTime = _parseTimeOfDay(
        _getEndTime(settingsProvider.cworkingTimeController.text));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final startStr =
                startTime != null ? _formatTimeOfDay(startTime!) : '';
            final endStr = endTime != null ? _formatTimeOfDay(endTime!) : '';

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              title: Row(
                children: [
                  Text(
                    'Select Working Time',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Starting Time Tile
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime ??
                                    const TimeOfDay(hour: 9, minute: 0),
                                helpText: 'SELECT STARTING TIME',
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startTime = picked;
                                });
                                if (endTime == null && dialogContext.mounted) {
                                  final endPicked = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        const TimeOfDay(hour: 18, minute: 0),
                                    helpText: 'SELECT ENDING TIME',
                                  );
                                  if (endPicked != null) {
                                    setDialogState(() {
                                      endTime = endPicked;
                                    });
                                  }
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: startTime != null
                                      ? AppColors.secondaryBlue
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Starting Time',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: startTime != null
                                            ? AppColors.secondaryBlue
                                            : AppColors.textGrey4,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          startTime != null
                                              ? startStr
                                              : 'Choose time',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: startTime != null
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: startTime != null
                                                ? AppColors.textBlack
                                                : AppColors.textGrey3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'to',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Ending Time Tile
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime ??
                                    const TimeOfDay(hour: 18, minute: 0),
                                helpText: 'SELECT ENDING TIME',
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  endTime = picked;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: endTime != null
                                      ? AppColors.secondaryBlue
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ending Time',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: endTime != null
                                            ? AppColors.secondaryBlue
                                            : AppColors.textGrey4,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          endTime != null
                                              ? endStr
                                              : 'Choose time',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: endTime != null
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: endTime != null
                                                ? AppColors.textBlack
                                                : AppColors.textGrey3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (startTime != null && endTime != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.secondaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Working Hours: $startStr - $endStr',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              actions: [
                if (settingsProvider.cworkingTimeController.text.isNotEmpty ||
                    startTime != null ||
                    endTime != null)
                  TextButton(
                    onPressed: () {
                      settingsProvider.cworkingTimeController.clear();
                      Navigator.pop(dialogContext);
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                CustomElevatedButton(
                  buttonText: 'Cancel',
                  onPressed: () => Navigator.pop(dialogContext),
                  radius: 4,
                  backgroundColor: AppColors.whiteColor,
                  borderColor: const Color(0xFFE2E8F0),
                  textColor: const Color(0xFF64748B),
                ),
                CustomElevatedButton(
                  buttonText: 'Done',
                  onPressed: () {
                    if (startTime == null || endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please select both starting and ending time'),
                        ),
                      );
                      return;
                    }
                    settingsProvider.cworkingTimeController.text =
                        '$startStr - $endStr';
                    Navigator.pop(dialogContext);
                  },
                  radius: 4,
                  backgroundColor: AppColors.secondaryBlue,
                  borderColor: AppColors.secondaryBlue,
                  textColor: AppColors.whiteColor,
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    return null;
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
            borderRadius: BorderRadius.circular(4),
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
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    Widget buildContent() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (!AppStyles.isWebScreen(context)) ...[
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cnameController,
                  hintText: 'Name',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cmobileController,
                  hintText: 'Mobile',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress1Controller,
                  hintText: 'Address',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress2Controller,
                  hintText: 'City',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress3Controller,
                  hintText: 'District',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress4Controller,
                  hintText: 'State',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cphoneController,
                  hintText: 'Phone',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cemailController,
                  hintText: 'Email',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cgstNoController,
                  hintText: 'GST NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cpanNoController,
                  hintText: 'PAN NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.ccinNoController,
                  hintText: 'CIN NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.ccompanyCodeController,
                  hintText: 'Company Code',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cuserCountController,
                  hintText: 'User Count',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: true,
                  height: 54,
                  controller: settingsProvider.cworkingTimeController,
                  hintText: 'Working Time',
                  labelText: '',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time,
                        color: Color(0xFF64748B), size: 20),
                    onPressed: () =>
                        _showWorkingTimeDialog(context, settingsProvider),
                  ),
                  onTap: () =>
                      _showWorkingTimeDialog(context, settingsProvider),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cnameController,
                        hintText: 'Name',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cmobileController,
                        hintText: 'Mobile',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.caddress1Controller,
                        hintText: 'Address',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.caddress2Controller,
                        hintText: 'City',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.caddress3Controller,
                        hintText: 'District',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.caddress4Controller,
                        hintText: 'State',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cphoneController,
                        hintText: 'Phone',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cemailController,
                        hintText: 'Email',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cgstNoController,
                        hintText: 'GST NO',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cpanNoController,
                        hintText: 'PAN NO',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.ccinNoController,
                        hintText: 'CIN NO',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.ccompanyCodeController,
                        hintText: 'Company Code',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cuserCountController,
                        hintText: 'User Count',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        height: 54,
                        controller: settingsProvider.cworkingTimeController,
                        hintText: 'Working Time',
                        labelText: '',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time,
                              color: Color(0xFF64748B), size: 20),
                          onPressed: () =>
                              _showWorkingTimeDialog(context, settingsProvider),
                        ),
                        onTap: () =>
                            _showWorkingTimeDialog(context, settingsProvider),
                      ),
                    ),
                  ],
                ),
              ],
              if (settingsProvider.companyDetails.isNotEmpty &&
                  settingsProvider.companyDetails[0].permissions.isNotEmpty) ...[
                ...settingsProvider.companyDetails[0].permissions.map((perm) {
                  String displayTitle = perm.displayCaption.isNotEmpty
                      ? perm.displayCaption
                      : settingsProvider.getPermissionCaption(
                          perm.companyPermissionId,
                          'Permission ${perm.companyPermissionId}');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '$displayTitle :   ${perm.value == 1 ? "On" : "Off"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: perm.value == 1,
                          onChanged: (bool value) {
                            settingsProvider.updateCompanyPermission(
                                perm.companyPermissionId, value ? 1 : 0);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 10),
              CustomElevatedButton(
                buttonText: 'Upload Image',
                onPressed: () async {
                  await settingsProvider.addFile();
                },
                radius: 4,
                backgroundColor: AppColors.whiteColor,
                borderColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF64748B),
              ),
              const SizedBox(height: 10),
              settingsProvider.images.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      physics: const ClampingScrollPhysics(),
                      itemCount: settingsProvider.images.length,
                      itemBuilder: (context, index) {
                        final image = settingsProvider.images[index];
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () =>
                                    settingsProvider.removeImage(image),
                                child: const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(),
              const SizedBox(height: 24.0),
              if (!AppStyles.isWebScreen(context)) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Cancel',
                        onPressed: () {
                          settingsProvider.enquiryForController.clear();
                          Navigator.pop(context);
                        },
                        radius: 4,
                        backgroundColor: AppColors.whiteColor,
                        borderColor: const Color(0xFFE2E8F0),
                        textColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Save',
                        onPressed: () async {
                          final validationError =
                              validateInputs(context, settingsProvider);
                          if (validationError != null) {
                            showErrorDialog(context, validationError);
                            return;
                          }
                          await settingsProvider.uploadImagesToAws(
                              '1', context);
                          await settingsProvider.saveCompanyDetails(
                            context: context,
                            companyId: widget.companyId,
                          );
                        },
                        radius: 4,
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      );
    }

    if (!AppStyles.isWebScreen(context)) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.isEdit ? 'Edit Company Details' : 'Add Company Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              settingsProvider.enquiryForController.clear();
              Navigator.pop(context);
            },
          ),
        ),
        body: buildContent(),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Company Details' : 'Add Company Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.enquiryForController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: buildContent(),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.enquiryForController.clear();
            Navigator.pop(context);
          },
          radius: 4,
          backgroundColor: AppColors.whiteColor,
          borderColor: const Color(0xFFE2E8F0),
          textColor: const Color(0xFF64748B),
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }
            await settingsProvider.uploadImagesToAws('1', context);
            await settingsProvider.saveCompanyDetails(
              context: context,
              companyId: widget.companyId,
            );
          },
          radius: 4,
          backgroundColor: AppColors.secondaryBlue,
          borderColor: AppColors.secondaryBlue,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
