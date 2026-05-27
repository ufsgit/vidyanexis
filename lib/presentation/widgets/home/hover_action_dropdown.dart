import 'dart:async';
import 'package:flutter/material.dart';

class HoverActionItem {
  final String title;
  final IconData icon;
  final String value;
  final Color? iconColor;
  final VoidCallback onTap;

  HoverActionItem({
    required this.title,
    required this.icon,
    required this.value,
    this.iconColor,
    required this.onTap,
  });
}

class HoverActionDropdown extends StatefulWidget {
  final List<HoverActionItem> items;
  final Widget? trailing;
  final double width;

  const HoverActionDropdown({
    super.key,
    required this.items,
    this.trailing,
    this.width = 180,
  });

  @override
  State<HoverActionDropdown> createState() => _HoverActionDropdownState();
}

class _HoverActionDropdownState extends State<HoverActionDropdown> {
  final MenuController _controller = MenuController();
  Timer? _hoverTimer;
  bool _isHovered = false;

  void _updateHover(bool isIn) {
    _hoverTimer?.cancel();
    setState(() {
      _isHovered = isIn;
    });

    if (isIn) {
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      _hoverTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted && _controller.isOpen) {
          _controller.close();
        }
      });
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateHover(true),
      onExit: (_) => _updateHover(false),
      cursor: SystemMouseCursors.click,
      child: MenuAnchor(
        controller: _controller,
        alignmentOffset: const Offset(0, 0),
        style: MenuStyle(
          padding:
              WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          elevation: WidgetStateProperty.all(8),
          shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        menuChildren: widget.items.map((item) {
          return MouseRegion(
            onEnter: (_) => _updateHover(true),
            onExit: (_) => _updateHover(false),
            child: MenuItemButton(
              onPressed: () {
                _controller.close();
                item.onTap();
              },
              style: MenuItemButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                surfaceTintColor: Colors.transparent,
                overlayColor: Colors.grey.withOpacity(0.05),
              ),
              leadingIcon: Icon(
                item.icon,
                size: 18,
                color: item.iconColor ?? Colors.grey[700],
              ),
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          );
        }).toList(),
        builder: (context, controller, child) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.grey[100] : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: _isHovered ? Colors.grey[800] : Colors.grey[500],
            ),
          );
        },
      ),
    );
  }
}
