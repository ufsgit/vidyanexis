import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomerDetailCustomTab extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const CustomerDetailCustomTab({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onTabChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: isSelected
                      ? const EdgeInsets.symmetric(vertical: 4, horizontal: 2)
                      : const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isSelected ? Colors.white : Colors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondaryBlue
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
