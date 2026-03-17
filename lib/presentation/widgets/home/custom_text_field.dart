import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CustomTextField extends StatelessWidget {
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
  final Function(String)? onChanged;
  final int? maxlength;
  final bool? enabled;
  final String? Function(String?)? validator;
  final double? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;


  const CustomTextField({
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
    this.onChanged,
    this.maxlength,
    this.validator,
    this.enabled,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
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
            enabled: enabled,
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
            minLines: minLines,
            maxLength: maxlength,
            maxLines: 5,
            obscureText: isObscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              // labelText: hintText,
              label: Text.rich(
                TextSpan(
                  text: hintText.replaceAll('*', ''),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey4,
                  ),
                  children: <TextSpan>[
                    if (hasAsterisk)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                softWrap: true,
              ),
              floatingLabelBehavior:
                  FloatingLabelBehavior.always, // Always show the label
              hintText: labelText,
              suffixIcon: suffixIcon,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey4,
              ),
              floatingLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14, // Slightly smaller size for floating label
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1, // Color for floating label
              ),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10), // Rounded corners
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.textGrey2, // Border color
                  width: 1, // Border width
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10), // Rounded corners
                borderSide: BorderSide(
                  color: focusedBorderColor ?? AppColors.textGrey2, // Border color
                  width: 1, // Border width
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10), // Rounded corners
                borderSide: BorderSide(
                  color: borderColor ?? (AppStyles.isWebScreen(context)
                      ? AppColors.textGrey2
                      : AppColors.grey), // Border color
                  width: 1, // Border width
                ),
              ),

              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            ),
            readOnly: readOnly,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, // Custom font size for the input text
              fontWeight:
                  FontWeight.w500, // Custom font weight for the input text
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
