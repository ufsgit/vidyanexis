import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class TileWidget extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final String? iconAssetPath;
  final List<Widget> children;
  final double minTileHeight;
  final double leadingWidth;
  final double leadingHeight;
  final Widget? leading;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final Color? dividerColor;
  final bool showDivider;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? tilePadding;
  final bool initiallyExpanded;
  final FontWeight? fontWeight;

  const TileWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.iconAssetPath,
    required this.children,
    this.subtitle,
    this.minTileHeight = 44,
    this.leadingWidth = 24,
    this.leadingHeight = 24,
    this.fontWeight = FontWeight.w600,
    this.titleStyle,
    this.subtitleStyle,
    this.trailing,
    this.dividerColor,
    this.showDivider = true,
    this.contentPadding,
    this.tilePadding,
    this.initiallyExpanded = false,
    this.leading,
  })  : assert(iconAssetPath != null || leading != null,
            'Either iconAssetPath or leading must be provided'),
        assert(title != null || titleWidget != null,
            'Either title or titleWidget must be provided');

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          minTileHeight: widget.minTileHeight,
          tilePadding: widget.tilePadding,
          trailing: widget.trailing ??
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textGrey4,
              ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          childrenPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          leading: widget.leading ??
              (widget.iconAssetPath != null
                  ? SizedBox(
                      height: widget.leadingHeight,
                      width: widget.leadingWidth,
                      child: Image.asset(widget.iconAssetPath!),
                    )
                  : null),
          title: widget.titleWidget ??
              Text(
                widget.title!,
                style: widget.titleStyle ??
                    GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: widget.fontWeight,
                      color: AppColors.textBlack,
                    ),
              ),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: widget.subtitleStyle ??
                      GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey3,
                      ),
                )
              : null,
          children: widget.children,
        ),
        if (widget.showDivider)
          Divider(
            color: widget.dividerColor ?? AppColors.grey,
          ),
      ],
    );
  }
}
