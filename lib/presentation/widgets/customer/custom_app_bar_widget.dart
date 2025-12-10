import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String richText;
  final String richText2;

  final bool isEdit;
  final VoidCallback onLeadingPressed;
  final VoidCallback onSavePressed;
  final Widget? leadingIcon;
  final Color backgroundColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final Color titleColor;
  final String saveButtonText;
  final TextStyle? saveButtonStyle;
  final Widget? content;

  // New properties for clickable TextSpan
  final bool isRichTextClickable;
  final VoidCallback? onRichTextPressed;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.richText = '',
    this.richText2 = '',
    this.isEdit = false,
    required this.onLeadingPressed,
    required this.onSavePressed,
    this.leadingIcon = const Icon(Icons.close, color: Colors.grey),
    this.backgroundColor = Colors.white,
    this.titleFontSize = 16,
    this.titleFontWeight = FontWeight.w600,
    this.titleColor = Colors.black,
    this.saveButtonText = 'Save',
    this.saveButtonStyle,
    this.content,
    this.isRichTextClickable = false,
    this.onRichTextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: onLeadingPressed,
        icon: leadingIcon ??
            const Icon(
              Icons.close,
              color: Colors.grey,
            ),
      ),
      titleSpacing: 0,
      title: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            color: titleColor,
            fontSize: titleFontSize,
            fontWeight: titleFontWeight,
          ),
          children: [
            TextSpan(text: title.isEmpty ? (isEdit ? 'Edit' : 'Add') : title),
            TextSpan(
              text: richText,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.bluebutton,
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
                // Add underline if clickable to indicate it's interactive
                decoration:
                    isRichTextClickable ? TextDecoration.underline : null,
              ),
              // Make TextSpan clickable only if enabled
              recognizer: isRichTextClickable && onRichTextPressed != null
                  ? (TapGestureRecognizer()..onTap = onRichTextPressed)
                  : null,
            ),
            TextSpan(
              text: richText2,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.bluebutton,
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onSavePressed,
          child: Text(
            saveButtonText,
            style: saveButtonStyle ??
                const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
