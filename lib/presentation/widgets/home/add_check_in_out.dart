import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/models/attendance_details_model.dart';
import 'package:provider/provider.dart';
import 'package:techtify/controller/check_in_out_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
import 'package:techtify/utils/extensions.dart';
import 'package:techtify/constants/app_colors.dart';

class AddCheckInOutWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;

  const AddCheckInOutWidget({
    super.key,
    required this.isEdit,
    required this.editId,
  });

  @override
  State<AddCheckInOutWidget> createState() => _AddCheckInOutWidgetState();
}

class _AddCheckInOutWidgetState extends State<AddCheckInOutWidget> {
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
      content: _buildDialogContent(context),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Consumer<CheckInOutProvider>(
      builder: (context, attendanceProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Container(
          color: Colors.white,
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // List content
              Expanded(
                child: _buildAttendanceList(attendanceProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList(CheckInOutProvider provider) {
    return ListView.builder(
      itemCount: provider.attendanceDetails.length,
      itemBuilder: (context, index) {
        return AttendanceItemRow(
          item: provider.attendanceDetails[index],
          isEdit: widget.isEdit,
          provider: provider,
        );
      },
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    final attendanceProvider = Provider.of<CheckInOutProvider>(context);

    return [
      CustomElevatedButton(
        buttonText: 'Cancel',
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: AppColors.whiteColor,
        borderColor: AppColors.appViolet,
        textColor: AppColors.appViolet,
      ),
      CustomElevatedButton(
        buttonText: 'Save',
        onPressed: () async {
          // Filter only selected and edited items
          final editedList = attendanceProvider.attendanceDetails
              .where((item) {
                final isLocked = widget.isEdit && item.status == 1;

                if (isLocked) return false; // Skip locked data

                final hasCheckIn =
                    item.checkInDateControllers.text.trim().isNotEmpty ||
                        item.checkInTimeControllers.text.trim().isNotEmpty;
                final hasCheckOut =
                    item.checkOutDateControllers.text.trim().isNotEmpty ||
                        item.checkOutTimeControllers.text.trim().isNotEmpty;

                final isEditedOrFilled =
                    item.isEdited || hasCheckIn || hasCheckOut;
                final isIncluded = item.isSelected;

                return isIncluded || isEditedOrFilled;
              })
              .map((item) => {
                    "User_Details_Id": item.userDetailsId,
                    "User_Details_Name": item.userDetailsName,
                    "Employee_Code": item.employeeCode,
                    "Attendance_Master_Id": widget.editId,
                    "Check_In_Date":
                        item.checkInDateControllers.text.toyyyymmdd(),
                    "Check_In_Time_Only":
                        item.checkInTimeControllers.text.to24HourTime(),
                    "Check_Out_Date":
                        item.checkOutDateControllers.text.toyyyymmdd(),
                    "Check_Out_Time_Only":
                        item.checkOutTimeControllers.text.to24HourTime(),
                    "Status": item.isSelected ? 1 : 0,
                  })
              .toList();

          if (editedList.isEmpty) {
            showErrorDialog(context, "No Attendance Selected");
            return;
          }
          // Now pass the editedList to saveAttendance
          attendanceProvider.saveAttendance(context, editedList);
        },
        backgroundColor: AppColors.appViolet,
        borderColor: AppColors.appViolet,
        textColor: AppColors.whiteColor,
      ),
    ];
  }
}

// Extracted into a separate StatelessWidget for better performance
class AttendanceItemRow extends StatelessWidget {
  final AttendanceDetails item;
  final bool isEdit;
  final CheckInOutProvider provider;

  const AttendanceItemRow({
    super.key,
    required this.isEdit,
    required this.provider,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // Check if item is locked (status=1 and in edit mode)
    bool isLocked = isEdit && item.status == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: AppStyles.isWebScreen(context)
          ? Row(
              children: [
                // First row: Employee name and checkbox
                Checkbox(
                  value: isLocked ? true : item.isSelected,
                  onChanged: isLocked
                      ? null // Disable checkbox if locked
                      : (val) {
                          provider.updateStatus(item, val ?? false);
                          if (val == true) {
                            item.isEdited = true;
                          } else {
                            item.isEdited = false;
                          }
                        },
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 300.0,
                  ),
                  child: Text(
                    item.userDetailsName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Second row: Check-in fields
                Expanded(
                  child: _buildDateField(
                    context,
                    item.checkInDateControllers,
                    'Check In Date',
                    isLocked,
                    item,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(
                    context,
                    item.checkInTimeControllers,
                    'Check In Time',
                    isLocked,
                    item,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDateField(
                    context,
                    item.checkOutDateControllers,
                    'Check Out Date',
                    isLocked,
                    item,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(
                    context,
                    item.checkOutTimeControllers,
                    'Check Out Time',
                    isLocked,
                    item,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isLocked ? true : item.isSelected,
                      onChanged: isLocked
                          ? null
                          : (val) {
                              provider.updateStatus(item, val ?? false);
                              item.isEdited = val ?? false;
                            },
                    ),
                    Expanded(
                      child: Text(
                        item.userDetailsName,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDateField(context, item.checkInDateControllers,
                    'Check In Date', isLocked, item),
                const SizedBox(height: 8),
                _buildTimeField(context, item.checkInTimeControllers,
                    'Check In Time', isLocked, item),
                const SizedBox(height: 8),
                _buildDateField(context, item.checkOutDateControllers,
                    'Check Out Date', isLocked, item),
                const SizedBox(height: 8),
                _buildTimeField(context, item.checkOutTimeControllers,
                    'Check Out Time', isLocked, item),
                const Divider(thickness: 1),
              ],
            ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    bool isLocked,
    dynamic item,
  ) {
    return CustomTextField(
      controller: controller,
      readOnly: true,
      height: 45, // Reduced height
      onTap: isLocked
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.text = picked.toString().toyyyymmdd();
                item.isEdited = true;
              }
            },
      hintText: hint,
      labelText: '',
      suffixIcon: const Icon(Icons.calendar_today, size: 18),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    bool isLocked,
    dynamic item,
  ) {
    return CustomTextField(
      controller: controller,
      readOnly: true,
      height: 45, // Reduced height
      onTap: isLocked
          ? null
          : () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                controller.text = time.format(context);
                item.isEdited = true;
              }
            },
      hintText: hint,
      labelText: '',
      suffixIcon: const Icon(Icons.access_time, size: 18),
    );
  }
}
