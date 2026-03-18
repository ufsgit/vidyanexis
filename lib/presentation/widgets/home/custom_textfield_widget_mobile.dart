// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:solaris_admin/constants/app_colors.dart';
// import 'package:solaris_admin/presentation/widgets/home/custom_text_widget.dart';
// import 'package:solaris_admin/utils/extensions.dart';
// import 'package:solaris_admin/utils/widgets.dart';

// class CustomTextfieldWidgetMobile extends FormField<String> {
//   final TextEditingController? controller;
//   final EdgeInsetsGeometry? margin;
//   final TextInputAction? textInputAction;
//   final double? hintFontSize;
//   final String? labelText;
//   final bool showAsUpperLabel;
//   final String? counterText;
//   final Color? fillColor;
//   final FocusNode? focusNode;
//   final bool obscureText;
//   final void Function(String)? onChanged;
//   final void Function(String)? onSubmitted;
//   final void Function()? onTap;
//   final TextInputType? keyBoardType;
//   final TextCapitalization textCapitalization;
//   final bool changeColor;
//   final bool readOnly;
//   final bool enabled;
//   final Iterable<String>? autofillHints;
//   final void Function()? onIconTap;
//   final Widget? suffixIcon;
//   final Widget? suffix;
//   final Widget? prefixIcon;
//   final Widget? prefix;
//   final int? maxLength;
//   final Color? textColor;
//   final int? maxLines;
//   final int? minLines;
//   final TextAlign? textAlign;
//   final List<TextInputFormatter>? inputFormatters;
//   final EdgeInsetsGeometry? contentPadding;

//   CustomTextfieldWidgetMobile({
//     super.key,
//     this.controller,
//     this.margin,
//     this.textInputAction,
//     this.hintFontSize,
//     this.labelText,
//     this.showAsUpperLabel = true,
//     this.counterText,
//     this.fillColor,
//     this.focusNode,
//     this.obscureText = false,
//     this.onChanged,
//     this.onSubmitted,
//     this.onTap,
//     this.keyBoardType,
//     this.textCapitalization = TextCapitalization.none,
//     this.changeColor = false,
//     this.readOnly = false,
//     this.enabled = true,
//     this.autofillHints,
//     this.onIconTap,
//     this.suffixIcon,
//     this.suffix,
//     this.prefixIcon,
//     this.prefix,
//     this.maxLength,
//     this.textColor,
//     this.maxLines = 1,
//     this.minLines,
//     this.textAlign = TextAlign.start,
//     this.inputFormatters,
//     this.contentPadding,
//     FormFieldValidator<String>? validator,
//   }) : super(
//           validator: validator,
//           builder: (FormFieldState<String> state) {
//             final TextEditingController _controller = controller??TextEditingController();

//             final FocusNode _focusNode = focusNode ?? FocusNode();

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Text Field Container
//                 Container(
//                   height:(maxLines != null && maxLines > 1) || (minLines != null && minLines > 1) ? null : 40,
//                   alignment: Alignment.center,
//                   margin: margin,
//                   padding: EdgeInsets.zero, // Ensures no unwanted extra padding
//                   decoration: BoxDecoration(
//                     color: fillColor ?? AppColors.scaffoldColor,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: state.hasError ? Colors.red : AppColors.textGrey3,
//                       width: 1,
//                     ),
//                   ),
//                   child: TextFormField(
//                     autofocus: true,
//                     showCursor: true,
//                     onTapOutside: (event) => hideKeyboard(),
//                     autofillHints: autofillHints,
//                     enabled: enabled,
//                     readOnly: readOnly,
//                     controller: _controller,
//                     focusNode: _focusNode,
//                     textInputAction: textInputAction,
//                     obscureText: obscureText,
//                     inputFormatters: inputFormatters,
//                     onChanged: (value) {
//                       state.didChange(value);
//                       if (onChanged != null) onChanged(value);
//                       _focusNode.requestFocus();
//                     },
//                     onFieldSubmitted: onSubmitted,
//                     onTap: onTap,
//                     enableInteractiveSelection: true,
//                     maxLines: maxLines,
//                     minLines: minLines,

//                     keyboardType: keyBoardType,
//                     textCapitalization: textCapitalization,
//                     cursorColor: AppColors.bluebutton,
//                     style: GoogleFonts.plusJakartaSans(
//                       color: textColor ?? AppColors.textBlack,
//                       fontSize: 14,

//                       height: 1, // This ensures text doesn't shift
//                       fontWeight: FontWeight.w500,
//                     ),
//                     textAlignVertical:
//                         TextAlignVertical.center, // Keeps text centered
//                     textAlign: textAlign ?? TextAlign.start,
//                     decoration: InputDecoration(
//                       filled: false,
//                       hintText: labelText ?? "placeholder",
//                       counterText: counterText,
//                       fillColor: fillColor ?? AppColors.scaffoldColor,
//                       hintStyle: GoogleFonts.plusJakartaSans(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       isDense: true,
//                       isCollapsed: true, // Prevents layout shifts
//                       contentPadding: contentPadding ??
//                           const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 10),
//                       suffix: suffix,
//                       suffixIcon: controller?.text.isNotEmpty == true
//                           ? IconButton(
//                               onPressed: () {
//                                 controller?.clear();
//                               },
//                               icon: Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.shade300,
//                                 ),
//                                 child: const Icon(Icons.close,
//                                     size: 14, color: Colors.black),
//                               ),
//                             )
//                           : suffixIcon,
//                       prefix: prefix,
//                       errorStyle: const TextStyle(
//                           fontSize: 0, height: 0), // Hide inline error
//                       border: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                     ),
//                     validator: validator,
//                     maxLength: maxLength,
//                   ),
//                 ),
//                 // Space for error text outside the border
//                 if (state.hasError)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4, left: 10),
//                     child: Text(
//                       state.errorText!,
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         );
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/widgets.dart';

class CustomTextfieldWidgetMobile extends StatefulWidget {
  const CustomTextfieldWidgetMobile(
      {super.key,
      this.controller,
      this.hintFontSize,
      this.labelText,
      this.showAsUpperLabel,
      this.margin,
      this.textInputAction,
      this.focusNode,
      this.onChanged,
      this.obscureText = false,
      this.onTap,
      this.onSubmitted,
      this.keyBoardType,
      this.textCapitalization = TextCapitalization.none,
      this.errorText,
      this.changeColor,
      this.fillColor,
      this.readOnly = false,
      this.enabled = true,
      this.autofillHints,
      this.onIconTap,
      this.suffixIcon,
      this.suffix,
      this.validator,
      this.maxLength,
      this.inputFormatters,
      this.textColor,
      this.maxLines = 1,
      this.minLines = 1,
      this.counterText,
      this.textAlign,
      this.prefixIcon,
      this.prefix,
      this.contentPadding,
      this.showError = false});
  final TextEditingController? controller;
  final EdgeInsetsGeometry? margin;
  final TextInputAction? textInputAction;
  final double? hintFontSize;
  final String? labelText;
  final bool? showAsUpperLabel;
  final String? counterText;
  final Color? fillColor;
  final FocusNode? focusNode;
  final bool? obscureText;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final void Function()? onTap;
  final TextInputType? keyBoardType;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final bool? changeColor;
  final bool? readOnly;
  final bool? enabled;
  final Iterable<String>? autofillHints;
  final void Function()? onIconTap;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? Function(String? value)? validator;
  final int? maxLength;
  final Color? textColor;
  final int? maxLines;
  final int? minLines;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final bool showError;

  @override
  State<CustomTextfieldWidgetMobile> createState() =>
      _CustomTextfieldWidgetMobileState();
}

class _CustomTextfieldWidgetMobileState
    extends State<CustomTextfieldWidgetMobile> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Only dispose if we created the focus node
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    // Only dispose if we created the controller
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: widget.showError
                ? Border.all(color: Colors.red, width: 1)
                : Border.all(color: AppColors.grey)),
        child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller!,
            builder: (context, value, child) {
              return Stack(
                children: [
                  IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        if (widget.prefixIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Center(child: widget.prefixIcon!),
                          ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((widget.showAsUpperLabel ?? true) &&
                                  !widget.labelText.isNullOrEmpty())
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10.0, top: 8),
                                  child: CustomText(
                                    textAlign: TextAlign.start,
                                    widget.labelText,
                                    fontSize: 12,
                                    color: widget.showError
                                        ? Colors.red
                                        : AppColors.textGrey4,
                                    fontWeight: FontWeight.w500,
                                    softWrap: true,
                                  ),
                                ),
                              TextFormField(
                                onTapOutside: (event) => hideKeyboard(),
                                autofillHints: widget.autofillHints,
                                enabled: widget.enabled,
                                readOnly: widget.readOnly!,
                                controller: _controller,
                                focusNode: _focusNode,
                                textInputAction: widget.textInputAction,
                                obscureText: widget.obscureText!,
                                inputFormatters: widget.inputFormatters,
                                onChanged: widget.onChanged,
                                onFieldSubmitted: widget.onSubmitted,
                                maxLines: widget.maxLines,
                                minLines: widget.minLines,
                                onTap: widget.onTap,
                                keyboardType: widget.keyBoardType,
                                textCapitalization: widget.textCapitalization,
                                cursorColor: AppColors.bluebutton,
                                style: GoogleFonts.plusJakartaSans(
                                    color:
                                        widget.textColor ?? AppColors.textBlack,
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500),
                                textAlign: widget.textAlign ?? TextAlign.start,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: isDarkMode(context)
                                        ? AppColors.whiteColor
                                        : AppColors.textBlack,
                                    fontSize: widget.hintFontSize ?? 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                  ),
                                  filled: false,
                                  hintText: (widget.showAsUpperLabel ?? true) ? null : widget.labelText,
                                  counterText: widget.counterText,
                                  fillColor: widget.fillColor ??
                                      (isDarkMode(context)
                                          ? AppColors.textBlack
                                          : Colors.white),
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: widget.showError
                                        ? Colors.red
                                        : AppColors.textGrey4,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: widget.contentPadding ??
                                      const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 8,
                                          bottom: 12),
                                  suffix: widget.suffix,
                                  prefix: widget.prefix,
                                  errorText: widget.errorText,
                                  errorStyle: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: "Inter",
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator: widget.validator,
                                maxLength: widget.maxLength,
                              ),
                            ],
                          ),
                        ),
                        if (widget.suffixIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 5),
                            child: Center(child: widget.suffixIcon!),
                          ),
                      ])),
                  if (widget.showError)
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
              );
            }),
      ),
    );
  }
}
