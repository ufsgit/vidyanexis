import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // Content customization
  final String? title;
  final Widget? customTitle;
  final Widget? leadingWidget;
  final bool showFilterIcon;

  // Styling customization
  final TextStyle? titleStyle;
  final double? leadingWidth;
  final EdgeInsetsGeometry? leadingPadding;
  final double leadingIconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double appBarElevation;
  final double searchIconSize;
  final double filterIconSize;
  final EdgeInsetsGeometry actionsPadding;

  // Functionality
  final Function(String) onSearch;
  final double height;
  final TextEditingController? searchController;
  final void Function()? onFilterTap;
  final void Function()? onClearTap;
  final void Function()? onSearchTap;
  final void Function()? onExcelTap;

  final String searchHintText;
  final TextStyle? searchHintStyle;
  final TextStyle? searchTextStyle;
  final InputDecoration? searchDecoration;
  final bool showSearch;
  final bool showExcel;

  const CustomAppBar({
    super.key,
    this.title,
    this.customTitle,
    this.leadingWidget,
    required this.onSearch,
    this.searchController,
    this.height = kToolbarHeight,
    this.onFilterTap,
    this.onClearTap,
    this.showFilterIcon = true,
    this.onSearchTap,
    this.onExcelTap,
    // Styling defaults
    this.titleStyle,
    this.leadingWidth = 40,
    this.leadingPadding = const EdgeInsets.only(left: 16),
    this.leadingIconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.appBarElevation = 0,
    this.searchIconSize = 24,
    this.filterIconSize = 24,
    this.actionsPadding = const EdgeInsets.only(right: 10),
    this.searchHintText = 'Search...',
    this.searchHintStyle,
    this.searchTextStyle,
    this.searchDecoration,
    this.showSearch = true,
    this.showExcel = false,
  }) : assert(title != null || customTitle != null,
            'Either title or customTitle must be provided');

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SidebarProvider>(context);

    return AppBar(
      surfaceTintColor: AppColors.scaffoldColor,
      backgroundColor: widget.backgroundColor ?? AppColors.whiteColor,
      elevation: widget.appBarElevation,
      leadingWidth: widget.leadingWidth,
      leading: widget.leadingWidget ?? _defaultLeading(context),
      title: searchProvider.isSearching
          ? _buildSearchField(searchProvider)
          : widget.customTitle ?? _defaultTitle(),
      actions: _buildActions(searchProvider, widget.onFilterTap,
          widget.onClearTap, widget.onSearchTap, widget.onExcelTap),
    );
  }

  Widget _defaultLeading(BuildContext context) {
    return Padding(
      padding: widget.leadingPadding!,
      child: InkWell(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Icon(
          Icons.menu,
          size: widget.leadingIconSize,
          color: widget.iconColor,
        ),
      ),
    );
  }

  Widget _defaultTitle() {
    return Text(
      widget.title!,
      style: widget.titleStyle ??
          const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSearchField(SidebarProvider searchProvider) {
    FocusNode searchFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocus.requestFocus();
    });

    return TextField(
      controller: widget.searchController,
      focusNode: searchFocus,
      autofocus: true,
      decoration: widget.searchDecoration ??
          InputDecoration(
            hintText: widget.searchHintText,
            border: InputBorder.none,
            hintStyle:
                widget.searchHintStyle ?? const TextStyle(color: Colors.grey),
          ),
      style: widget.searchTextStyle ?? const TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      onChanged: searchProvider.setSearchQuery,
      onSubmitted: widget.onSearch,
    );
  }

  List<Widget> _buildActions(
      SidebarProvider searchProvider,
      void Function()? onFilterTap,
      void Function()? onClear,
      void Function()? onSearchTap,
      void Function()? onExcelTap) {
    if (searchProvider.isSearching) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.clear,
              color: widget.iconColor,
              size: widget.searchIconSize,
            ),
            onPressed: onClear,
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: widget.actionsPadding,
        child: Row(
          children: [
            if (widget.showSearch)
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: onSearchTap,
              ),
            if (widget.showExcel)
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: onExcelTap,
              ),

            // if (widget.showFilterIcon)
            //   InkWell(
            //     onTap: onFilterTap,
            //     child: SvgPicture.asset(
            //       "assets/images/filter_icon_svg.svg",
            //       width: widget.filterIconSize,
            //       height: widget.filterIconSize,
            //       color: widget.iconColor,
            //     ),
            //   ),
          ],
        ),
      ),
    ];
  }
}
