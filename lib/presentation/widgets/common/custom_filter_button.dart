import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFilter;

  const CustomFilterButton({
    super.key,
    required this.onPressed,
    this.isFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Filter',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilter
                ? AppColors.primaryBlue.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Image.asset(
            'assets/images/filter.png',
            width: 24,
            height: 24,
            color: isFilter ? AppColors.primaryBlue : Colors.black87,
          ),
        ),
      ),
    );
  }
}
