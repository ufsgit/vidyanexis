import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class MeAllToggleSwitch extends StatelessWidget {
  final String value; // 'myown' or 'all'
  final ValueChanged<String> onChanged;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry itemPadding;

  const MeAllToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 28,
    this.fontSize = 11,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    final bool isAll = value == 'all';

    return Container(
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (isAll) onChanged('myown');
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: itemPadding,
              decoration: BoxDecoration(
                color: !isAll ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: !isAll
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                'ME',
                style: TextStyle(
                  color: !isAll ? AppColors.primaryBlue : const Color(0xFF64748B),
                  fontWeight: !isAll ? FontWeight.bold : FontWeight.w500,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (!isAll) onChanged('all');
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: itemPadding,
              decoration: BoxDecoration(
                color: isAll ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isAll
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                'ALL',
                style: TextStyle(
                  color: isAll ? AppColors.primaryBlue : const Color(0xFF64748B),
                  fontWeight: isAll ? FontWeight.bold : FontWeight.w500,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
