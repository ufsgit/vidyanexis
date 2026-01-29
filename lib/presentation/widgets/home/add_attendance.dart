import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:intl/intl.dart';
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
      dev.log('Validation failed: User name is empty', name: 'AddAttendance');
      return 'Please choose user';
    }

    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    if (dropDownProvider.selectedUserId == null ||
        dropDownProvider.selectedUserId == 0) {
      dev.log('Validation failed: selectedUserId is null or 0',
          name: 'AddAttendance');
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
  String userType = '';
  bool isCheckedIn = false;

  Future<void> _initUserData() async {
    try {
      final attendanceProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      // Log initial state
      dev.log('Initializing user data...', name: 'AddAttendance');

      if (widget.isEdit) {
        dev.log('Edit mode: Setting user from widget props',
            name: 'AddAttendance');
        attendanceProvider.assignToFollowUpController.text = widget.user;
        dropDownProvider.setSelectedUserId(widget.userId);
        return; // In edit mode, we respect the passed values
      }

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? prefUserId = preferences.getString('userId');
      String? prefUserName = preferences.getString('userName');
      String? prefUserType = preferences.getString('userType');

      dev.log(
          'Fetched from SharedPreferences: userId=$prefUserId, userName=$prefUserName, userType=$prefUserType',
          name: 'AddAttendance');

      userId = int.tryParse(prefUserId ?? "0") ?? 0;
      userName = prefUserName ?? "";
      userType = prefUserType ?? "";

      // Fallback: If SharedPreferences is empty or incomplete, try to resolve from DropDownProvider
      if ((userId == 0 || userName.isEmpty) &&
          dropDownProvider.searchUserDetails.isNotEmpty) {
        dev.log(
            'SharedPreferences data incomplete, attempting fallback from DropDownProvider',
            name: 'AddAttendance');

        if (userId != 0 && userName.isEmpty) {
          try {
            final matchedUser = dropDownProvider.searchUserDetails.firstWhere(
              (u) => u.userDetailsId == userId,
            );
            userName = matchedUser.userDetailsName ?? "";
            dev.log('Resolved userName from userId: $userName',
                name: 'AddAttendance');
          } catch (_) {}
        } else if (userId == 0 && userName.isNotEmpty) {
          try {
            final matchedUser = dropDownProvider.searchUserDetails.firstWhere(
              (u) => u.userDetailsName == userName,
            );
            userId = matchedUser.userDetailsId ?? 0;
            dev.log('Resolved userId from userName: $userId',
                name: 'AddAttendance');
          } catch (_) {}
        }
      }

      if (userId != 0) {
        dropDownProvider.setSelectedUserId(userId);
        bool status =
            await attendanceProvider.checkIsCheckedIn(userId, forceApi: true);
        isCheckedIn = status;
        dev.log('User status checked: isCheckedIn=$isCheckedIn',
            name: 'AddAttendance');
      }
      if (userName.isNotEmpty) {
        attendanceProvider.assignToFollowUpController.text = userName;
      }

      dev.log('User data bound: userId=$userId, userName=$userName',
          name: 'AddAttendance');

      if (mounted) setState(() {});
    } catch (e) {
      dev.log('Error initializing user data: $e',
          name: 'AddAttendance', error: e);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendanceProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);

      // attendanceProvider.assignToFollowUpController.clear();
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      attendanceProvider.assignToFollowUpController.clear();

      // Fetch user details first to ensure we have the list for matching if needed
      dropDownProvider.getUserDetails(context);
      //  if (widget.isEdit) {
      //   attendanceProvider.assignToFollowUpController.text = widget.user;
      //   dropDownProvider.setSelectedUserId(widget.userId);
      // }
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      // userName = preferences.getString('userName') ?? "";
      // dropDownProvider.setSelectedUserId(userId);
      // attendanceProvider.assignToFollowUpController.text = userName;
      await _initUserData();
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
                          onItemSelected: (selectedId) async {
                            dropDownProvider.setSelectedUserId(selectedId);
                            final selectedItem =
                                dropDownProvider.searchUserDetails.firstWhere(
                              (user) => user.userDetailsId == selectedId,
                            );
                            attendanceProvider.assignToFollowUpController.text =
                                selectedItem.userDetailsName ?? '';

                            // Check status for the newly selected user
                            bool status = await attendanceProvider
                                .checkIsCheckedIn(selectedId, forceApi: true);
                            setState(() {
                              isCheckedIn = status;
                            });
                          },
                          enabled: userType == "1" || userId == 1,
                          selectedValue: dropDownProvider.searchUserDetails.any(
                                  (item) =>
                                      item.userDetailsId ==
                                      dropDownProvider.selectedUserId)
                              ? dropDownProvider.selectedUserId
                              : null),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // const Spacer()
                ],
              ),
              if (isCheckedIn &&
                  attendanceProvider.currentCheckInTime.isNotEmpty) ...[
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  String formattedTime = attendanceProvider.currentCheckInTime;
                  try {
                    DateTime dt = DateTime.parse(formattedTime);
                    formattedTime = DateFormat('hh:mm a').format(dt);
                  } catch (_) {}

                  return Row(
                    children: [
                      Text(
                        'Checked in at: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appViolet,
                        ),
                      ),
                    ],
                  );
                }),
              ],
              if (!isCheckedIn &&
                  attendanceProvider.isCompletedToday &&
                  attendanceProvider.currentCheckOutTime.isNotEmpty) ...[
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  String formattedTime = attendanceProvider.currentCheckOutTime;
                  try {
                    DateTime dt = DateTime.parse(formattedTime);
                    formattedTime = DateFormat('hh:mm a').format(dt);
                  } catch (_) {}

                  return Row(
                    children: [
                      Text(
                        'Checked out at: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.btnRed,
                        ),
                      ),
                    ],
                  );
                }),
              ],
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
          buttonText: isCheckedIn
              ? 'Check Out'
              : (attendanceProvider.isCompletedToday
                  ? 'Attendance Completed'
                  : 'Check In'),
          onPressed: () async {
            if (!isCheckedIn && attendanceProvider.isCompletedToday) {
              return; // Already completed today
            }
            final validationErrorBeforeRetry =
                validateInputs(context, attendanceProvider);
            if (validationErrorBeforeRetry != null) {
              dev.log('First validation failed, retrying user detection...',
                  name: 'AddAttendance');
              await _initUserData();
              final validationErrorAfterRetry =
                  validateInputs(context, attendanceProvider);
              if (validationErrorAfterRetry != null) {
                showErrorDialog(context, validationErrorAfterRetry);
                return;
              }
            }
            String employeeCode = "";
            try {
              if (dropDownProvider.selectedUserId != null) {
                final user = dropDownProvider.searchUserDetails.firstWhere(
                  (u) => u.userDetailsId == dropDownProvider.selectedUserId,
                );
                employeeCode = user.empCode ?? "";
              }
            } catch (_) {}

            await attendanceProvider.getLocation(context: context);

            bool success = false;
            if (isCheckedIn) {
              success = await attendanceProvider.saveAttendance(
                dropDownProvider.selectedUserId ?? 0,
                context,
                checkOutTime: DateTime.now().toString(),
                employeeCode: employeeCode,
                closeOnSuccess: true,
              );
            } else {
              success = await attendanceProvider.saveAttendance(
                dropDownProvider.selectedUserId ?? 0,
                context,
                checkInTime: DateTime.now().toString(),
                employeeCode: employeeCode,
                closeOnSuccess: false,
              );
              if (success) {
                setState(() {
                  isCheckedIn = true;
                });
              }
            }
          },
          backgroundColor: isCheckedIn
              ? AppColors.btnRed
              : (attendanceProvider.isCompletedToday
                  ? AppColors.grey
                  : AppColors.bluebutton),
          borderColor: isCheckedIn
              ? AppColors.btnRed
              : (attendanceProvider.isCompletedToday
                  ? AppColors.grey
                  : AppColors.bluebutton),
          textColor: (!isCheckedIn && attendanceProvider.isCompletedToday)
              ? AppColors.textRed
              : AppColors.whiteColor,
        ),
      ],
    );
  }
}
