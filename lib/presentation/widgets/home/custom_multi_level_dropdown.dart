import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class MultiLevelHoverMenu extends StatefulWidget {
  final String title;
  final Widget? leadingIcon;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool isSubMenu;
  final Color? hoverColor;

  const MultiLevelHoverMenu({
    super.key,
    required this.title,
    this.leadingIcon,
    required this.children,
    this.onTap,
    this.isSubMenu = true,
    this.hoverColor,
  });

  @override
  State<MultiLevelHoverMenu> createState() => _MultiLevelHoverMenuState();
}

class _MultiLevelHoverMenuState extends State<MultiLevelHoverMenu> {
  final MenuController _controller = MenuController();
  Timer? _hoverTimer;

  // Add a slight delay for both opening and closing to prevent flickering
  void _handleHover(bool isHovering) {
    _hoverTimer?.cancel();
    if (isHovering) {
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      _hoverTimer = Timer(const Duration(milliseconds: 200), () {
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
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: MenuAnchor(
        controller: _controller,
        // Position the submenu to the right of the current item with a slight overlap
        // By default submenus open at the top-right of the item in Flutter's MenuAnchor
        alignmentOffset: widget.isSubMenu ? const Offset(-10, 0) : Offset.zero,
        menuChildren: widget.children.map((child) {
          return MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: child,
          );
        }).toList(),
        builder: (context, controller, child) {
          return MenuItemButton(
            style: MenuItemButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              surfaceTintColor: Colors.transparent,
              overlayColor: widget.hoverColor ?? AppColors.appViolet.withOpacity(0.05),
            ),
            onPressed: widget.onTap ?? () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            leadingIcon: widget.leadingIcon,
            trailingIcon: widget.isSubMenu ? Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]) : null,
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }
}
