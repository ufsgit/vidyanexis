import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

enum PopupMenuOptions { edit, delete }

class CustomPopMenuButtonWidget extends StatelessWidget {
  final Function(PopupMenuOptions) onOptionSelected;
  final Widget? icon;

  const CustomPopMenuButtonWidget({
    super.key,
    required this.onOptionSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupMenuOptions>(
      icon: icon ??
          Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: AppColors.textGrey4,
          ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 3,
      constraints: const BoxConstraints.tightFor(
        width: 110,
        height: 80,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white, // White background
      onSelected: onOptionSelected,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          height: 35,
          value: PopupMenuOptions.edit,
          child: Row(
            children: [
              SizedBox(
                  height: 14,
                  width: 14,
                  child:
                      Icon(Icons.edit, size: 14, color: AppColors.textBlack)),
              SizedBox(width: 8),
              CustomText(
                'Edit',
                fontSize: 14,
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
        PopupMenuItem(
          height: 35,
          value: PopupMenuOptions.delete,
          child: Row(
            children: [
              SizedBox(
                  height: 14,
                  width: 14,
                  child: Icon(Icons.delete, size: 14, color: AppColors.btnRed)),
              SizedBox(width: 8),
              CustomText(
                'Delete',
                fontSize: 14,
                color: AppColors.btnRed,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
      ],
    );
  }
}
