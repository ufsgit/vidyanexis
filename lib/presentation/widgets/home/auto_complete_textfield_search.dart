import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CustomAutocompleteSearch<T extends Object> extends StatefulWidget {
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
  final double? maxHeight;
  final Future<void> Function(String)? onSearch; // Async callback

  const CustomAutocompleteSearch({
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
    this.onSearch,
  });

  @override
  State<CustomAutocompleteSearch<T>> createState() =>
      _CustomAutocompleteSearchState<T>();
}

class _CustomAutocompleteSearchState<T extends Object>
    extends State<CustomAutocompleteSearch<T>> {
  late TextEditingController _textController;
  late FocusNode _localFocusNode;
  final ScrollController _scrollController = ScrollController();

  // Workaround to force open options programmatically
  void _forceOptionsOpen() {
    Future.microtask(() {
      if (!_localFocusNode.hasFocus) {
        _localFocusNode.requestFocus();
      }
      var originalText = _textController.text;
      _textController.text = "$originalText ";
      Future.microtask(() {
        _textController.text = originalText;
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.value.text.length,
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.defaultText);
    _localFocusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(CustomAutocompleteSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _textController.dispose();
      }
      _textController =
          widget.controller ?? TextEditingController(text: widget.defaultText);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _localFocusNode.dispose();
      }
      _localFocusNode = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _textController.dispose();
    if (widget.focusNode == null) _localFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasAsterisk = (widget.labelText ?? '').contains('*');

    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<T>(
        optionsViewOpenDirection:
            widget.optionsViewOpenDirection ?? OptionsViewOpenDirection.down,
        focusNode: _localFocusNode,
        textEditingController: _textController,
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.toLowerCase().trim();

          if (query.isEmpty) {
            return widget.items;
          }

          return widget.items.where((item) {
            return widget
                .displayStringFunction(item)
                .toLowerCase()
                .contains(query);
          });
        },
        onSelected: (T option) {
          if (_localFocusNode.hasFocus) {
            _localFocusNode.unfocus();
          }
          return widget.onSelected(option);
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return Container(
            child: Stack(
              children: [
                TextFormField(
                  enabled: widget.enabled ?? true,
                  focusNode: fieldFocusNode,
                  controller: widget.controller ?? textEditingController,
                  onChanged: (widget.disableSearch ?? false)
                      ? (value) {
                          (widget.controller ?? textEditingController).clear();
                        }
                      : (value) {
                          widget.onChanged?.call(value);
                        },
                  onTap: () {
                    final controller =
                        widget.controller ?? textEditingController;

                    if (!fieldFocusNode.hasFocus) {
                      fieldFocusNode.requestFocus();
                    }

                    // Show all options
                    widget.onChanged?.call('');

                    // Simple & effective force open
                    Future.delayed(const Duration(milliseconds: 50), () {
                      final text = controller.text;
                      controller.text = '$text ';
                      controller.selection =
                          TextSelection.collapsed(offset: text.length);

                      Future.delayed(const Duration(milliseconds: 20), () {
                        controller.text = text;
                        controller.selection =
                            TextSelection.collapsed(offset: text.length);
                      });
                    });
                  },
                  validator: widget.validator,
                  minLines: 1,
                  maxLength: null,
                  maxLines: 5,
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: (widget.labelText ?? '').replaceAll('*', ''),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey4,
                        ),
                        children: <TextSpan>[
                          if (hasAsterisk)
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: '',
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: InkWell(
                      onTap: () async {
                        if (widget.onSearch != null) {
                          await widget.onSearch!(_textController.text);
                          // Delay forcing open until after potential rebuild from state update
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _forceOptionsOpen();
                          });
                        } else if (_textController.text.isNotEmpty) {
                          _textController.clear();
                        }
                      },
                      child: widget.suffixIcon ??
                          (_textController.text.isEmpty
                              ? Image.asset(
                                  "assets/icons/arrow_down_icon.png",
                                  width: 22,
                                  height: 22,
                                )
                              : Icon(
                                  Icons.clear_outlined,
                                  color: AppColors.textBlack,
                                  size: 16,
                                )),
                    ),
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey4,
                    ),
                    floatingLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey1,
                    ),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.textGrey2,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppStyles.isWebScreen(context)
                            ? AppColors.textGrey2
                            : AppColors.grey,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 12),
                  ),
                  readOnly: widget.disableSearch ?? false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                  onFieldSubmitted: (String value) {
                    onFieldSubmitted();
                    if (widget.onSubmitted != null) {
                      widget.onSubmitted!(value);
                    }
                  },
                ),
              ],
            ),
          );
        },
        displayStringForOption: (T option) =>
            widget.displayStringFunction(option),
        optionsViewBuilder: (
          BuildContext context,
          void Function(T) onSelected,
          Iterable<T> options,
        ) {
          final screenHeight = MediaQuery.of(context).size.height;
          final calculatedMaxHeight = widget.maxHeight ?? (screenHeight * 0.4);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Align(
              alignment:
                  widget.optionsViewOpenDirection == OptionsViewOpenDirection.up
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
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: RawScrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          thumbColor: Colors.grey.withOpacity(0.5),
                          radius: const Radius.circular(8),
                          thickness: 6,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
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
                                            padding: const EdgeInsets.all(6.0),
                                            child: Text(
                                              widget.displayStringFunction(
                                                  option),
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
          );
        },
      ),
    );
  }
}
