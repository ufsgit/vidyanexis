import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class DottedBorderContainer extends StatelessWidget {
  DottedBorderContainer(
      {super.key,
      this.width = 110,
      this.height = 110,
      this.image = 'assets/icons/icon_camera.svg'});
  double width;
  double height;
  String image;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.whiteColor,
        ),
        width: width,
        height: height,
        child: Center(
          child: SvgPicture.asset(
            image,
            height: 30,
            width: 30,
          ),
        ),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.appViolet.withOpacity(.5) // Border color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashWidth = 8; // Width of each dash
    double dashSpace = 5; // Space between dashes
    double startX = 0;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(8), // Corner radius
        ),
      );

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the painter needs to repaint, false otherwise
    return false;
  }
}
