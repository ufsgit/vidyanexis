import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class ResponsiveButtonWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveButtonWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AppStyles.isWebScreen(context)) {
      return SizedBox(width: 140, child: child);
    }
    return Expanded(child: child);
  }
}
