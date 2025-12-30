import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CommonDropdown<T> extends StatelessWidget {
  final String hintText;
  final List<DropdownItem<T>> items;
  final TextEditingController? controller;
  final ValueChanged<T> onItemSelected;
  final T? selectedValue;
  final bool enabled; // Added enabled property

  const CommonDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.controller,
    required this.onItemSelected,
    this.selectedValue,
    this.enabled = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    bool hasAsterisk = hintText.contains('*');

    // Ensure the selectedValue is valid (not null, not invalid, and exists in the items list)
    T? validValue = selectedValue;
    if (validValue != null && !items.any((item) => item.id == validValue)) {
      validValue = null; // or handle it appropriately if needed
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.biggest.width,
        child: DropdownButtonFormField<T>(
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack),
          isDense: true,
          iconSize: 18,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled
                ? null
                : AppColors.textGrey2, // Icon color changes when disabled
          ),
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                text: hintText.replaceAll('*', ''),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey4,
                ),
                children: <TextSpan>[
                  if (hasAsterisk)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey1,
            ),
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textGrey2, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textGrey2, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: (AppStyles.isWebScreen(context)
                      ? AppColors.textGrey2
                      : AppColors.grey),
                  width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          ),
          // Handle selectedValue properly, it should be a valid id in items
          value: validValue,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item.id,
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          selectedItemBuilder: enabled
              ? (BuildContext context) {
                  return items.map<Widget>((item) {
                    return SizedBox(
                      width: constraints.biggest.width - 50,
                      child: Text(
                        item.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                }
              : null,
          onChanged: enabled
              ? (T? value) {
                  if (value != null) {
                    final selectedItem =
                        items.firstWhere((item) => item.id == value);
                    controller?.text = selectedItem.name;
                    onItemSelected(selectedItem.id);
                  }
                }
              : null, // Set onChanged to null when disabled
        ),
      );
    });
  }
}

class DropdownItem<T> {
  final T id;
  final String name;
  final String? address;
  final String? unit;
  final String? category;
  final int? no;

  DropdownItem({
    required this.id,
    required this.name,
    this.address,
    this.unit,
    this.category,
    this.no,
  });
}
