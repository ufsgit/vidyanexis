import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';

class SearchableBottomSheetDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<DropdownItem<T>> items;
  final TextEditingController? controller;
  final ValueChanged<T?> onItemSelected;
  final T? selectedValue;
  final bool enabled;
  final bool showError;
  final double? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SearchableBottomSheetDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.controller,
    required this.onItemSelected,
    this.selectedValue,
    this.enabled = true,
    this.showError = false,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<SearchableBottomSheetDropdown<T>> createState() =>
      _SearchableBottomSheetDropdownState<T>();
}

class _SearchableBottomSheetDropdownState<T>
    extends State<SearchableBottomSheetDropdown<T>> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _syncTextWithSelectedValue();
  }

  @override
  void didUpdateWidget(SearchableBottomSheetDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _textController = widget.controller!;
    }
    if (widget.selectedValue != oldWidget.selectedValue ||
        widget.items != oldWidget.items) {
      _syncTextWithSelectedValue();
    }
  }

  void _syncTextWithSelectedValue() {
    if (widget.selectedValue != null) {
      DropdownItem<T>? matchingItem;
      for (final item in widget.items) {
        if (item.id == widget.selectedValue) {
          matchingItem = item;
          break;
        }
      }
      if (matchingItem != null) {
        if (_textController.text != matchingItem.name) {
          _textController.text = matchingItem.name;
        }
      } else {
        if (_textController.text.isNotEmpty && widget.controller == null) {
          _textController.clear();
        }
      }
    } else {
      if (_textController.text.isNotEmpty && widget.controller == null) {
        _textController.clear();
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredList = widget.items.where((item) {
              final name = item.name.toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            final cleanHint = widget.hintText.replaceAll('*', '').trim();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $cleanHint',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search TextField
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search ${cleanHint.toLowerCase()}...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final isSelected = widget.selectedValue == item.id;
                        return ListTile(
                          title: Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.bluebutton
                                  : AppColors.textBlack,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: AppColors.bluebutton)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            widget.onItemSelected(item.id);
                            setState(() {
                              _textController.text = item.name;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Rebuild the field itself to ensure synced state is rendered
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasAsterisk = widget.hintText.contains('*');
    final cleanHint = widget.hintText.replaceAll('*', '').trim();
    
    // Find selected item if any
    final selectedId = widget.selectedValue;
    
    // Determine the list of items to display as chips.
    final List<DropdownItem<T>> displayItems = widget.items.take(5).toList();
    if (selectedId != null) {
      final hasSelected = displayItems.any((item) => item.id == selectedId);
      if (!hasSelected) {
        DropdownItem<T>? selectedItemObj;
        for (final item in widget.items) {
          if (item.id == selectedId) {
            selectedItemObj = item;
            break;
          }
        }
        if (selectedItemObj != null) {
          displayItems.insert(0, selectedItemObj);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and search/add button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: cleanHint,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.showError ? Colors.red : AppColors.textGrey4,
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
            if (widget.enabled)
              GestureDetector(
                onTap: _showBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bluebutton.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle,
                    size: 20,
                    color: AppColors.bluebutton,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Horizontal list of chips
        if (widget.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No options available',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textGrey3,
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...displayItems.map((item) {
                  final isSelected = selectedId == item.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(item.name),
                      selected: isSelected,
                      onSelected: widget.enabled
                          ? (bool selected) {
                              if (selected) {
                                widget.onItemSelected(item.id);
                                setState(() {
                                  _textController.text = item.name;
                                });
                              }
                            }
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      selectedColor: AppColors.lightBlueColor,
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.textBlue800 : AppColors.textGrey3,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: isSelected ? AppColors.textBlue800 : AppColors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                }),
                if (widget.items.length > 5 && widget.enabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('More'),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textGrey3),
                        ],
                      ),
                      selected: false,
                      onSelected: (bool selected) {
                        _showBottomSheet();
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      backgroundColor: Colors.grey[100],
                      labelStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.textGrey3,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.showError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Please select $cleanHint',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
