import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedBottomBarWidget extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final TextStyle selectedLabelStyle;

  const AnimatedBottomBarWidget({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.selectedLabelStyle,
  });

  @override
  State<AnimatedBottomBarWidget> createState() =>
      _AnimatedBottomBarWidgetState();
}

class _AnimatedBottomBarWidgetState extends State<AnimatedBottomBarWidget>
    with TickerProviderStateMixin {
  // Separate controllers for more complex animations
  late List<AnimationController> _fadeControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize controllers for each item
    _fadeControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: index == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _scaleControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        value: index == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    // Set up animations with different curves for variety
    _fadeAnimations = _fadeControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut)))
        .toList();

    _scaleAnimations = _scaleControllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut)))
        .toList();
  }

  @override
  void didUpdateWidget(AnimatedBottomBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate out old selection
      _fadeControllers[oldWidget.currentIndex].reverse();
      _scaleControllers[oldWidget.currentIndex].reverse();

      // Animate in new selection
      _fadeControllers[widget.currentIndex].forward();
      _scaleControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _fadeControllers) {
      controller.dispose();
    }
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (index != widget.currentIndex) {
                  widget.onTap(index);
                }
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow animation
                  AnimatedBuilder(
                      animation: _fadeAnimations[index],
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimations[index].value * 0.15,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 7, right: 7, bottom: 0, top: 0),
                            decoration: BoxDecoration(
                              color: widget.selectedItemColor.withOpacity(.0),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(44),
                                  bottomRight: Radius.circular(44)),
                            ),
                            height: 110,
                          ),
                        );
                      }),

                  // Icon and text with animations
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon with scale and opacity
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_fadeAnimations[index], _scaleAnimations[index]]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimations[index].value,
                            child: Opacity(
                              opacity:
                                  0.5 + (0.5 * _fadeAnimations[index].value),
                              child: IconTheme(
                                data: IconThemeData(
                                  color: ColorTween(
                                    begin: widget.unselectedItemColor,
                                    end: widget.selectedItemColor,
                                  ).evaluate(_fadeAnimations[index]),
                                  size: 20 + (2 * _fadeAnimations[index].value),
                                ),
                                child: item.icon,
                              ),
                            ),
                          );
                        },
                      ),

                      // Animated text
                      AnimatedBuilder(
                        animation: _fadeAnimations[index],
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.5 + (0.5 * _fadeAnimations[index].value),
                            child: Text(
                              item.label ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: _fadeAnimations[index].value > 0.5
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: ColorTween(
                                  begin: widget.unselectedItemColor,
                                  end: widget.selectedItemColor,
                                ).evaluate(_fadeAnimations[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
