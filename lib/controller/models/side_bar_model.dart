import 'package:flutter/material.dart';

class SidebarOption {
  final String title;
  final String iconPath;
  final Widget baseContent;
  final Widget? overlayContent; // Optional overlay content

  SidebarOption({
    required this.title,
    required this.iconPath,
    required this.baseContent,
    this.overlayContent,
  });
}
