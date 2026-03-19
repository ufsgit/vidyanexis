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
  final ValueChanged<bool>? onHoverChange;

  const MultiLevelHoverMenu({
    super.key,
    required this.title,
    this.leadingIcon,
    required this.children,
    this.onTap,
    this.isSubMenu = true,
    this.hoverColor,
    this.onHoverChange,
  });

  @override
  State<MultiLevelHoverMenu> createState() => _MultiLevelHoverMenuState();
}

class _MultiLevelHoverMenuState extends State<MultiLevelHoverMenu> {
  final MenuController _controller = MenuController();
  Timer? _hoverTimer;

  void _handleHover(bool isHovering) {
    _hoverTimer?.cancel();
    // Notify parent to stay open/close
    widget.onHoverChange?.call(isHovering);

    if (isHovering) {
      _hoverTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      _hoverTimer = Timer(const Duration(milliseconds: 1000), () {
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
        alignmentOffset: widget.isSubMenu ? const Offset(-5, 0) : Offset.zero,
        menuChildren: widget.children.map((child) {
          // If the child is also a MultiLevelHoverMenu, pass our hover handler
          if (child is MultiLevelHoverMenu) {
            return MultiLevelHoverMenu(
              title: child.title,
              leadingIcon: child.leadingIcon,
              onTap: child.onTap,
              isSubMenu: child.isSubMenu,
              hoverColor: child.hoverColor,
              onHoverChange: (isChildHovering) {
                _handleHover(isChildHovering);
              },
              children: child.children,
            );
          }
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
              overlayColor:
                  widget.hoverColor ?? AppColors.appViolet.withOpacity(0.05),
            ),
            onPressed: widget.onTap ??
                () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
            leadingIcon: widget.leadingIcon,
            trailingIcon: widget.isSubMenu
                ? Icon(Icons.chevron_right, size: 16, color: Colors.grey[600])
                : null,
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
