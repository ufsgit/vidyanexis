import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';

class AddAttendanceWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final String user;
  final int userId;

  const AddAttendanceWidget({
    super.key,
    required this.isEdit,
    required this.editId,
    required this.user,
    required this.userId,
  });

  @override
  State<AddAttendanceWidget> createState() => _AddAttendanceWidgetState();
}

class _AddAttendanceWidgetState extends State<AddAttendanceWidget> {
  String? validateInputs(
      BuildContext context, AttendanceReportProvider attendanceProvider) {
    if (attendanceProvider.assignToFollowUpController.text.trim().isEmpty) {
      return 'Please choose user';
    }

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

  int userId = 0;
  String userName = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendanceProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);

      attendanceProvider.assignToFollowUpController.clear();
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      if (widget.isEdit) {
        attendanceProvider.assignToFollowUpController.text = widget.user;
        dropDownProvider.setSelectedUserId(widget.userId);
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      dropDownProvider.setSelectedUserId(userId);
      attendanceProvider.assignToFollowUpController.text = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Attendance' : 'Add Attendance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
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
        // height: MediaQuery.sizeOf(context).height / 4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: CommonDropdown<int>(
                          hintText: 'Choose User*',
                          items: dropDownProvider.searchUserDetails
                              .map((status) => DropdownItem<int>(
                                    id: status.userDetailsId!,
                                    name: status.userDetailsName ?? '',
                                  ))
                              .toList(),
                          controller:
                              attendanceProvider.assignToFollowUpController,
                          onItemSelected: (selectedId) {
                            dropDownProvider.setSelectedUserId(selectedId);
                            final selectedItem =
                                dropDownProvider.searchUserDetails.firstWhere(
                              (user) => user.userDetailsId == selectedId,
                            );
                            attendanceProvider.assignToFollowUpController.text =
                                selectedItem.userDetailsName ?? '';
                          },
                          enabled: userId == 1,
                          selectedValue: dropDownProvider.selectedUserId),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // const Spacer()
                ],
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            attendanceProvider.assignToFollowUpController.clear();

            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, attendanceProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }
            attendanceProvider.saveAttendance(
                dropDownProvider.selectedUserId ?? 0, context);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
