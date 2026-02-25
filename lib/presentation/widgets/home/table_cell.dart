import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final String title;
  final Widget? data;
  final Color color;
  final double? fontSize;
  final double? width;
  final int flex;
  final EdgeInsetsGeometry? padding;
  final bool isBold;

  const TableWidget({
    super.key,
    this.title = '',
    this.data,
    this.color = const Color(0xFF172230),
    this.fontSize,
    this.width,
    this.flex = 0,
    this.padding,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return width == null
          ? Expanded(
              flex: flex,
              child: Padding(
                  padding: padding ??
                      const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                  child: Align(alignment: Alignment.centerLeft, child: data)),
            )
          : SizedBox(
              width: width,
              child: Padding(
                  padding: padding ??
                      const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                  child: Align(alignment: Alignment.centerLeft, child: data)),
            );
    } else {
      return width == null
          ? Expanded(
              flex: flex,
              child: Padding(
                padding: padding ??
                    const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight:
                              isBold ? FontWeight.w600 : FontWeight.normal,
                          color: color,
                          fontSize: fontSize)),
                ),
              ),
            )
          : SizedBox(
              width: width,
              child: Padding(
                padding: padding ??
                    const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight:
                              isBold ? FontWeight.w600 : FontWeight.normal,
                          color: color,
                          fontSize: fontSize)),
                ),
              ),
            );
    }
  }
}
