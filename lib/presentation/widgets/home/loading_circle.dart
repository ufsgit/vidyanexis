import 'package:flutter/material.dart';
import 'package:techtify/constants/app_colors.dart';

class LoadingCircle extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final int numberOfCircles;

  const LoadingCircle({
    super.key,
    this.color = AppColors.bluebutton,
    this.size = 35.0,
    this.duration = const Duration(milliseconds: 1500),
    this.numberOfCircles = 3,
  });

  @override
  _LoadingCircleState createState() => _LoadingCircleState();
}

class _LoadingCircleState extends State<LoadingCircle>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.numberOfCircles,
      (index) => AnimationController(
        vsync: this,
        duration: widget.duration,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start animations with delays
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: (i * 300)),
        () {
          if (mounted) {
            _controllers[i].repeat();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(widget.numberOfCircles, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Opacity(
                  opacity: (1.0 - _animations[index].value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.5 + _animations[index].value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withOpacity(
                            (1.0 - _animations[index].value).clamp(0.0, 1.0),
                          ),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
