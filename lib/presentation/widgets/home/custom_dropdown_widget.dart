import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CommonDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<DropdownItem<T>> items;
  final TextEditingController? controller;
  final ValueChanged<T> onItemSelected;
  final T? selectedValue;
  final bool enabled;
  final bool isMultiLine;
  final Widget? labelWidget;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool showError;
  final double? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;

  const CommonDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.controller,
    required this.onItemSelected,
    this.selectedValue,
    this.enabled = true,
    this.isMultiLine = false,
    this.labelWidget,
    this.prefixIcon,
    this.suffixIcon,
    this.floatingLabelBehavior,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.showError = false,
  });

  @override
  State<CommonDropdown<T>> createState() => _CommonDropdownState<T>();
}

class _CommonDropdownState<T> extends State<CommonDropdown<T>> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _syncTextWithSelectedValue();
  }

  @override
  void didUpdateWidget(CommonDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _textController = widget.controller!;
    }
    if (widget.selectedValue != oldWidget.selectedValue ||
        widget.items != oldWidget.items) {
      _syncTextWithSelectedValue();
    }
  }

  void _syncTextWithSelectedValue() {
    if (widget.selectedValue != null) {
      DropdownItem<T>? matchingItem;
      for (final item in widget.items) {
        if (item.id == widget.selectedValue) {
          matchingItem = item;
          break;
        }
      }
      if (matchingItem != null) {
        if (_textController.text != matchingItem.name) {
          _textController.text = matchingItem.name;
        }
      } else {
        if (_textController.text.isNotEmpty && widget.controller == null) {
          _textController.clear();
        }
      }
    } else {
      if (_textController.text.isNotEmpty && widget.controller == null) {
        _textController.clear();
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasAsterisk = widget.hintText.contains('*');

    return LayoutBuilder(builder: (context, constraints) {
      return RawAutocomplete<DropdownItem<T>>(
        focusNode: _focusNode,
        textEditingController: _textController,
        displayStringForOption: (option) => option.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (!widget.enabled) return const Iterable.empty();
          final query = textEditingValue.text.toLowerCase().trim();
          if (query.isEmpty) {
            return widget.items;
          }
          final matches = widget.items.where(
            (item) => item.name.toLowerCase().contains(query),
          );
          if (matches.isEmpty) {
            return widget.items;
          }
          return matches;
        },
        onSelected: (DropdownItem<T> option) {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          _textController.text = option.name;
          widget.onItemSelected(option.id);
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return Stack(
            children: [
              SizedBox(
                width: constraints.biggest.width,
                child: TextFormField(
                  controller: textEditingController,
                  focusNode: fieldFocusNode,
                  enabled: widget.enabled,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                  onTap: () {
                    if (!widget.enabled) return;
                    if (!fieldFocusNode.hasFocus) {
                      fieldFocusNode.requestFocus();
                    }
                    final currentText = textEditingController.text;
                    textEditingController.text = '$currentText ';
                    Future.microtask(() {
                      textEditingController.text = currentText;
                      textEditingController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: textEditingController.text.length,
                      );
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: InkWell(
                      onTap: widget.enabled
                          ? () {
                              if (fieldFocusNode.hasFocus) {
                                fieldFocusNode.unfocus();
                              } else {
                                fieldFocusNode.requestFocus();
                                final currentText = textEditingController.text;
                                textEditingController.text = '$currentText ';
                                Future.microtask(() {
                                  textEditingController.text = currentText;
                                });
                              }
                            }
                          : null,
                      child: widget.suffixIcon ??
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: widget.enabled
                                ? AppColors.textBlack
                                : AppColors.textGrey2,
                          ),
                    ),
                    label: widget.labelWidget ??
                        RichText(
                          text: TextSpan(
                            text: widget.hintText.replaceAll('*', ''),
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
                        ),
                    floatingLabelBehavior: widget.floatingLabelBehavior ??
                        FloatingLabelBehavior.auto,
                    floatingLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.showError
                          ? Colors.red
                          : (widget.focusedBorderColor ?? AppColors.bluebutton),
                    ),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey3,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 10),
                      borderSide: BorderSide(
                        color: widget.showError
                            ? Colors.red
                            : (widget.borderColor ?? AppColors.textGrey2),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 10),
                      borderSide: BorderSide(
                        color: widget.showError
                            ? Colors.red
                            : (widget.focusedBorderColor ??
                                AppColors.bluebutton),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 10),
                      borderSide: BorderSide(
                        color: widget.showError
                            ? Colors.red
                            : (widget.borderColor ??
                                (AppStyles.isWebScreen(context)
                                    ? AppColors.textGrey2
                                    : AppColors.grey)),
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              if (widget.showError)
                Positioned(
                  right: 36,
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
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<DropdownItem<T>> onSelected,
          Iterable<DropdownItem<T>> options,
        ) {
          final screenHeight = MediaQuery.of(context).size.height;
          final maxHeight = screenHeight * 0.35;

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                  maxWidth: constraints.biggest.width,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF1F5F9),
                            ),
                          ),
                        ),
                        child: Text(
                          option.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                          maxLines: widget.isMultiLine ? null : 1,
                          overflow: widget.isMultiLine
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class DropdownItem<T> {
  final T id;
  final String name;
  final String? address;
  final String? unit;
  final String? category;
  final int? no;

  DropdownItem({
    required this.id,
    required this.name,
    this.address,
    this.unit,
    this.category,
    this.no,
  });
}
