import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class TaskChipsScroller extends StatefulWidget {
  final List<Widget> chips;

  const TaskChipsScroller({
    super.key,
    required this.chips,
  });

  @override
  State<TaskChipsScroller> createState() => _TaskChipsScrollerState();
}

class _TaskChipsScrollerState extends State<TaskChipsScroller> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateButtonVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateButtonVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    if (!mounted) return;

    setState(() {
      _showLeftButton = _scrollController.position.pixels > 0;
      _showRightButton = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    final currentPos = _scrollController.position.pixels;
    const scrollAmount = 250.0;

    _scrollController.animateTo(
      max(0, currentPos - scrollAmount),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    final currentPos = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    const scrollAmount = 200.0;

    _scrollController.animateTo(
      min(maxScroll, currentPos + scrollAmount),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.all(4.0),
          padding: EdgeInsets.only(
              left: _showLeftButton ? 24 : 0, right: _showRightButton ? 24 : 0),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: true,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: widget.chips,
                ),
              ),
            ),
          ),
        ),
        if (_showLeftButton)
          Positioned(
            left: 8,
            child: InkWell(
              onTap: _scrollLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.whiteColor),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        if (_showRightButton)
          Positioned(
            right: 8,
            child: InkWell(
              onTap: _scrollRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.whiteColor),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
