import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/presentation/widgets/home/custom_textfield_widget_mobile.dart';
import 'package:techtify/utils/extensions.dart';

class CustomAutocomplete<T extends Object> extends StatelessWidget {
  final List<T> items;
  final String Function(T model) displayStringFunction;
  final String defaultText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? showAsUpperLabel;
  final void Function(T model) onSelected;
  final void Function(String value)? onChanged;
  final FocusNode? focusNode;
  final OptionsViewOpenDirection? optionsViewOpenDirection;
  final bool? enabled;
  final bool? disableSearch;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? value)? validator;
  final void Function(String)? onSubmitted;
  final bool showOptionsOnTap;
  final double? maxHeight; // Add optional maxHeight parameter

  const CustomAutocomplete({
    super.key,
    required this.items,
    required this.displayStringFunction,
    required this.onSelected,
    required this.defaultText,
    this.labelText,
    this.onChanged,
    this.showAsUpperLabel,
    this.focusNode,
    this.enabled,
    this.disableSearch,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.validator,
    this.onSubmitted,
    this.optionsViewOpenDirection,
    this.showOptionsOnTap = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with default text if not provided
    final TextEditingController textController =
        controller ?? TextEditingController(text: defaultText);

    // Create a local focus node if one isn't provided
    final FocusNode localFocusNode = focusNode ?? FocusNode();

    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<T>(
        optionsViewOpenDirection:
            optionsViewOpenDirection ?? OptionsViewOpenDirection.down,
        focusNode: localFocusNode,
        textEditingController: textController,
        optionsBuilder: (TextEditingValue textEditingValue) {
          // Show all options immediately on focus if text is empty and showOptionsOnTap is true
          if (textEditingValue.text.isEmpty && showOptionsOnTap) {
            return items;
          } else if (textEditingValue.text.isEmpty) {
            return items;
          } else {
            List<T> matches = List<T>.from(items);
            matches.retainWhere((option) {
              final String displayString = displayStringFunction(option);
              return displayString
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
            return matches;
          }
        },
        onSelected: (T option) {
          if (localFocusNode.hasFocus) {
            localFocusNode.unfocus();
          }
          return onSelected(option);
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return SizedBox(
            width: constraints.biggest.width,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: textEditingController,
              builder: (context, value, child) {
                return CustomTextfieldWidgetMobile(
                  labelText: labelText ?? '',
                  controller: controller ?? textEditingController,
                  enabled: enabled ?? true,
                  readOnly: disableSearch ?? false,
                  onChanged: (disableSearch ?? false)
                      ? (value) {
                          (controller ?? textEditingController).clear();
                        }
                      : onChanged,
                  inputFormatters: inputFormatters,
                  validator: validator,
                  suffixIcon: InkWell(
                    onTap: () {
                      // Improved suffix icon behavior
                      if (fieldFocusNode.hasFocus) {
                        // If already focused, toggle selection or clear
                        if (textEditingController.text.isNullOrEmpty()) {
                          // Force show options by simulating text change
                          textEditingController.text = " ";
                          textEditingController.text = "";
                        } else {
                          textEditingController.clear();
                          if (onChanged != null) {
                            onChanged!("");
                          }
                        }
                      } else {
                        // If not focused, focus and show options
                        fieldFocusNode.requestFocus();
                        // Force refresh to show options
                        textEditingController.text = " ";
                        textEditingController.text = "";
                      }
                    },
                    child: suffixIcon ??
                        (textEditingController.text.isNullOrEmpty()
                            ? Image.asset(
                                "assets/icons/arrow_down_icon.png",
                                width: 22,
                                height: 22,
                              )
                            : Icon(
                                textEditingController.text.isNullOrEmpty()
                                    ? Icons.keyboard_arrow_down
                                    : Icons.clear_outlined,
                                color: AppColors.textBlack,
                                size: 16,
                              )),
                  ),
                  prefixIcon: prefixIcon,
                  // showAsUpperLabel: showAsUpperLabel,
                  onTap: () {
                    // Improved onTap behavior to ensure options appear on first tap
                    if (!fieldFocusNode.hasFocus) {
                      fieldFocusNode.requestFocus();

                      // Force options to show by simulating text change
                      if (showOptionsOnTap) {
                        final originalText = textEditingController.text;
                        // Add a space and remove it to trigger options display
                        textEditingController.text = "$originalText ";
                        Future.microtask(() {
                          textEditingController.text = originalText;
                          // Select all text for easy replacement
                          textEditingController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset:
                                textEditingController.value.text.length,
                          );
                        });
                      }
                    }

                    if (disableSearch ?? false) {
                      fieldFocusNode.requestFocus();
                      textEditingController.clear();
                      if (onChanged != null) {
                        onChanged!("");
                      }
                    }
                  },
                  focusNode: fieldFocusNode,
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                    if (onSubmitted != null) {
                      onSubmitted!(value);
                    }
                  },
                );
              },
            ),
          );
        },
        displayStringForOption: (T option) => displayStringFunction(option),
        optionsViewBuilder: (
          BuildContext context,
          void Function(T) onSelected,
          Iterable<T> options,
        ) {
          // Calculate appropriate maximum height for dropdown
          final screenHeight = MediaQuery.of(context).size.height;
          final calculatedMaxHeight = maxHeight ??
              (screenHeight *
                  0.4); // Default to 40% of screen height if not specified

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, callBack) {
              FocusScope.of(context).unfocus();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Remove focus when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: Align(
                alignment:
                    optionsViewOpenDirection == OptionsViewOpenDirection.up
                        ? Alignment.bottomLeft
                        : Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Material(
                    shadowColor: const Color(0xffb8b8b826),
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: calculatedMaxHeight,
                          maxWidth: constraints.biggest.width,
                        ),
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification:
                              (OverscrollIndicatorNotification overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: RawScrollbar(
                            thumbVisibility: true,
                            thumbColor: Colors.grey.withOpacity(0.5),
                            radius: const Radius.circular(8),
                            thickness: 6,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              // Remove primary to allow nested scrolling
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final T option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 4),
                                      child: Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                displayStringFunction(option),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
