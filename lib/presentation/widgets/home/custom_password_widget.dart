import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomPasswordWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isObscureText;
  final TextInputType keyboardType;
  final double height;
  final bool showError;
  final bool readOnly;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final GestureTapCallback? onTap;
  final int minLines;
  final FocusNode? focusNode;

  const CustomPasswordWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.isObscureText = false,
    this.keyboardType = TextInputType.text,
    required this.height,
    this.showError = false,
    this.inputFormatters,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.minLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    bool hasAsterisk = hintText.contains('*');
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: showError ? Colors.red : AppColors.textGrey2,
      //   ),
      // ),
      // height: height,
      child: Stack(
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            onTap: onTap,
            obscureText: isObscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              // labelText: hintText,
              label: RichText(
                text: TextSpan(
                  text: hintText.replaceAll('*',
                      ''), // Regular text part (remove asterisk for normal part)
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey3,
                  ),
                  children: <TextSpan>[
                    if (hasAsterisk) // Only add the red asterisk if it's present
                      const TextSpan(
                        text: ' *', // The asterisk part
                        style: TextStyle(
                            color: Colors.red), // Red color for asterisk
                      ),
                  ],
                ),
              ), // Hint displayed as label
              floatingLabelBehavior:
                  FloatingLabelBehavior.auto, // Always show the label
              hintText: labelText,
              suffixIcon: suffixIcon,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey3,
              ),
              floatingLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16, // Slightly smaller size for floating label
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1, // Color for floating label
              ),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: BorderSide(
                  color: AppColors.textGrey2, // Border color
                  width: 1, // Border width
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: BorderSide(
                  color: AppColors.textGrey2, // Border color
                  width: 1, // Border width
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                borderSide: BorderSide(
                  color: AppColors.textGrey2, // Border color
                  width: 1, // Border width
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            ),
            readOnly: readOnly,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, // Custom font size for the input text
              fontWeight:
                  FontWeight.w600, // Custom font weight for the input text
              color: AppColors.textBlack, // Color for the input text
            ),
          ),
          if (showError)
            Positioned(
              right: 12,
              top: 8,
              child: Text(
                '*',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
