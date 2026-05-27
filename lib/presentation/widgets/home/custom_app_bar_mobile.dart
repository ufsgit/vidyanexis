import 'package:flutter/material.dart';

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
  final Function(String)? onChanged;
  final double height;
  final TextEditingController? searchController;
  final void Function()? onFilterTap;
  final void Function()? onClearTap;
  final void Function()? onSearchTap;
  final void Function()? onExcelTap;
  final void Function()? onPdfTap;
  final void Function(int)? onSortTap;
  final bool showSort;

  final String searchHintText;
  final TextStyle? searchHintStyle;
  final TextStyle? searchTextStyle;
  final InputDecoration? searchDecoration;
  final bool showSearch;
  final bool showExcel;
  final bool showPdf;
  final void Function()? onOrderTap;
  final String? sortOrder;
  final bool showOrder;
  final bool showTransfer;
  final void Function()? onTransferTap;

  final bool showLogo;
  final bool showUserName;
  final bool showAddIcon;
  final void Function()? onAddTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.customTitle,
    this.leadingWidget,
    required this.onSearch,
    this.onChanged,
    this.searchController,
    this.height = kToolbarHeight,
    this.onFilterTap,
    this.onClearTap,
    this.showFilterIcon = true,
    this.onSearchTap,
    this.onExcelTap,
    this.onPdfTap,
    this.showLogo = true,
    this.showUserName = true,
    this.showAddIcon = false,
    this.onAddTap,
    // Styling defaults
    this.titleStyle,
    this.leadingWidth = 56,
    this.leadingPadding = const EdgeInsets.only(left: 8),
    this.leadingIconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.appBarElevation = 0,
    this.searchIconSize = 24,
    this.filterIconSize = 24,
    this.actionsPadding = const EdgeInsets.only(right: 8),
    this.searchHintText = 'Search...',
    this.searchHintStyle,
    this.searchTextStyle,
    this.searchDecoration,
    this.showSearch = true,
    this.showExcel = false,
    this.showPdf = false,
    this.showTransfer = false,
    this.onTransferTap,
    this.onSortTap,
    this.onOrderTap,
    this.sortOrder,
    this.showOrder = false,
    this.showSort = false,
  }) : assert(title != null || customTitle != null,
            'Either title or customTitle must be provided');

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SidebarProvider>(context);

    if (searchProvider.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_searchFocus.hasFocus) {
          _searchFocus.requestFocus();
        }
      });
    }

    return AppBar(
      surfaceTintColor: AppColors.scaffoldColor,
      backgroundColor: widget.backgroundColor ?? AppColors.whiteColor,
      elevation: widget.appBarElevation,
      leadingWidth: widget.leadingWidth,
      leading: widget.leadingWidget ?? _defaultLeading(context),
      title: searchProvider.isSearching
          ? _buildSearchField(searchProvider)
          : widget.customTitle ?? _defaultTitle(),
      actions: _buildActions(
          searchProvider,
          widget.onFilterTap,
          widget.onClearTap,
          widget.onSearchTap,
          widget.onExcelTap,
          widget.onPdfTap,
          widget.onSortTap,
          widget.onOrderTap,
          widget.sortOrder),
    );
  }

  Widget _defaultLeading(BuildContext context) {
    return Padding(
      padding: widget.leadingPadding ?? EdgeInsets.zero,
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.sort,
            size: 20,
            color: widget.iconColor ?? AppColors.textBlue800,
          ),
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }

  Widget _defaultTitle() {
    return Text(
      widget.title!,
      overflow: TextOverflow.ellipsis,
      style: widget.titleStyle ??
          const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSearchField(SidebarProvider searchProvider) {
    return TextField(
      controller: widget.searchController,
      focusNode: _searchFocus,
      autofocus: true,
      decoration: widget.searchDecoration ??
          InputDecoration(
            hintText: widget.searchHintText,
            border: InputBorder.none,
            hintStyle:
                widget.searchHintStyle ?? const TextStyle(color: Colors.grey),
            suffixIcon: widget.onFilterTap != null
                ? IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: widget.iconColor ?? Colors.black,
                      size: widget.filterIconSize,
                    ),
                    onPressed: widget.onFilterTap,
                  )
                : null,
          ),
      style: widget.searchTextStyle ?? const TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      onChanged: (query) {
        searchProvider.setSearchQuery(query);
        if (widget.onChanged != null) {
          widget.onChanged!(query);
        }
      },
      onSubmitted: widget.onSearch,
    );
  }

  List<Widget> _buildActions(
      SidebarProvider searchProvider,
      void Function()? onFilterTap,
      void Function()? onClear,
      void Function()? onSearchTap,
      void Function()? onExcelTap,
      void Function()? onPdfTap,
      void Function(int)? onSortTap,
      void Function()? onOrderTap,
      String? sortOrder) {
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
            if (widget.showFilterIcon && onFilterTap != null && !widget.showSearch)
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: widget.iconColor,
                  size: widget.filterIconSize,
                ),
                onPressed: onFilterTap,
              ),
            if (widget.showSearch)
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: onSearchTap,
              ),
            if (widget.showAddIcon && widget.onAddTap != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: InkWell(
                  onTap: widget.onAddTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            if (widget.showSort)
              PopupMenuButton<int>(
                icon: Icon(
                  Icons.sort,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onSelected: onSortTap,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0, child: Text('Default')),
                  const PopupMenuItem(value: 1, child: Text('ID No')),
                  const PopupMenuItem(value: 2, child: Text('Creation Date')),
                  const PopupMenuItem(value: 3, child: Text('Followup Date')),
                ],
              ),
            if (widget.showOrder && onOrderTap != null)
              IconButton(
                icon: Icon(
                  sortOrder == 'ASC'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: onOrderTap,
                tooltip: sortOrder == 'ASC' ? 'Ascending' : 'Descending',
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
            if (widget.showPdf)
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: onPdfTap,
              ),
            if (widget.showTransfer)
              IconButton(
                icon: Icon(
                  Icons.compare_arrows,
                  color: widget.iconColor,
                  size: widget.searchIconSize,
                ),
                onPressed: widget.onTransferTap,
              ),
          ],
        ),
      ),
    ];
  }
}
