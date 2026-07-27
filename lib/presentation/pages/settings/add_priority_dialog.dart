import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/priority_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddPriorityDialog extends StatefulWidget {
  final bool isEdit;
  final PriorityModel? priority;
  const AddPriorityDialog({
    super.key,
    required this.isEdit,
    this.priority,
  });

  @override
  State<AddPriorityDialog> createState() => _AddPriorityDialogState();
}

class _AddPriorityDialogState extends State<AddPriorityDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedColorHex = "#FF0000";

  final List<Color> colorOptions = [
    const Color(0xffFF0000), // Red
    const Color(0xffFF8C00), // Orange
    const Color(0xffFFD700), // Gold
    const Color(0xff32CD32), // Green
    const Color(0xff1E90FF), // Blue
    const Color(0xff8A2BE2), // Purple
    const Color(0xffA8A8A8), // Grey
  ];

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.priority != null) {
      _nameController.text = widget.priority!.priorityName;
      _selectedColorHex = widget.priority!.colorCode.isNotEmpty 
          ? widget.priority!.colorCode 
          : "#FF0000";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter priority name';
    }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
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
              child: const Text(
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isEdit ? 'Edit Priority' : 'Add Priority',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
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
            ? MediaQuery.sizeOf(context).width / 2.5
            : MediaQuery.sizeOf(context).width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: _nameController,
                hintText: 'Priority name*',
                labelText: '',
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Color',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey3,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: colorOptions.map((color) {
                    final hex = colorToHex(color);
                    final isSelected = _selectedColorHex.toUpperCase() == hex.toUpperCase();

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorHex = hex;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: isSelected ? 35 : 25,
                              height: isSelected ? 35 : 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(77),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
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
            final validationError = validateInputs();
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }

            await settingsProvider.savePriority(
              context: context,
              priorityId: widget.isEdit ? widget.priority?.priorityId ?? 0 : 0,
              priorityName: _nameController.text.trim(),
              colorCode: _selectedColorHex,
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
