import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/constants/app_colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.style,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final textSpan = TextSpan(
              text: widget.text,
              style: widget.style,
            );

            final textPainter = TextPainter(
              text: textSpan,
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            );

            textPainter.layout(maxWidth: constraints.maxWidth);
            _hasOverflow = textPainter.didExceedMaxLines;

            return Text(
              widget.text,
              maxLines: _expanded ? null : widget.maxLines,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: widget.style,
            );
          },
        ),
        if (_hasOverflow)
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Text(
              _expanded ? 'Read Less' : 'Read More',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.bluebutton,
              ),
            ),
          ),
      ],
    );
  }
}
