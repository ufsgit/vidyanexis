import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';

// Moved outside the class to fix the generic function issue
bool defaultEquals<T>(T a, T b) => a == b;

class StatusDropdownWidget<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T> onChanged;
  final String label;
  final String statusName;
  final double? containerWidth;
  final double? width;
  final double? dropdownHeight;
  final String Function(T) displayStringFor;
  final bool Function(T, T) areItemsEqual;
  final bool enabled; // Whether the dropdown is enabled

  const StatusDropdownWidget({
    Key? key,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.containerWidth,
    this.label = 'Status',
    this.width,
    this.dropdownHeight = 200, // Default height of 200
    required this.displayStringFor,
    required this.areItemsEqual,
    required this.statusName,
    this.enabled = true, // Default enabled by default
  }) : super(key: key);

  @override
  State<StatusDropdownWidget<T>> createState() =>
      _StatusDropdownWidgetState<T>();
}

class _StatusDropdownWidgetState<T> extends State<StatusDropdownWidget<T>> {
  late T selectedValue;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode();

  // Keep track of the rendered text size
  final GlobalKey _textKey = GlobalKey();
  Size _textSize = Size.zero;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ?? widget.items.first;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _removeOverlay();
      }
    });

    // Calculate initial text size in post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextSize();
    });
  }

  void _calculateTextSize() {
    if (_textKey.currentContext != null) {
      final RenderBox renderBox =
          _textKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _textSize = renderBox.size;
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return; // Only open if enabled
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  void _showOverlay() {
    _focusNode.requestFocus();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Find maximum width for dropdown items
    double maxItemWidth = 0;
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    );

    for (T item in widget.items) {
      textPainter.text = TextSpan(
        text: widget.displayStringFor(item),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      maxItemWidth =
          maxItemWidth < textPainter.width ? textPainter.width : maxItemWidth;
    }

    // Add padding and the check icon width
    maxItemWidth += 50; // 16 padding on both sides + 18 check icon

    // Calculate final width
    // If custom width is provided, use it
    // Otherwise use the wider of dropdown width or maxItemWidth
    double overlayWidth;
    if (widget.width != null) {
      overlayWidth = widget.width!;
    } else {
      overlayWidth = size.width > maxItemWidth ? size.width : maxItemWidth;
      // Default to 90% of screen width if needed
      if (overlayWidth < 100) {
        overlayWidth = MediaQuery.sizeOf(context).width / 1.1;
      }
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: widget.containerWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            child: Container(
              height: widget
                  .dropdownHeight, // Use provided height or default to 200
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.items.map((item) {
                    final isSelected =
                        widget.areItemsEqual(item, selectedValue);
                    return InkWell(
                      onTap: !widget.enabled
                          ? null
                          : () {
                              setState(() {
                                selectedValue = item;
                              });
                              widget.onChanged(item);
                              _removeOverlay();

                              // Recalculate text size after selection changes
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _calculateTextSize();
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.grey300
                                : AppColors.whiteColor),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: CustomText(
                                widget.displayStringFor(item),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _focusNode,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            height: 28,
            width: widget.width, // Apply custom width if provided
            decoration: BoxDecoration(
              color: AppColors.scaffoldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            '${widget.statusName}:',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          CustomText(
                            key: _textKey,
                            widget.items.isEmpty
                                ? widget.label
                                : widget.displayStringFor(selectedValue),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textGrey3,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
