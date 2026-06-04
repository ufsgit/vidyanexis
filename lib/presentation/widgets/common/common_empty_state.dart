import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final double? height;

  const CommonEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: height ?? 300,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
