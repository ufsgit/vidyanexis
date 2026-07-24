import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _hasBeenActivated;

  @override
  void initState() {
    super.initState();
    _hasBeenActivated = List<bool>.filled(widget.children.length, false);
    _hasBeenActivated[widget.index] = true;
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      final List<bool> newActivated = List<bool>.filled(widget.children.length, false);
      for (int i = 0; i < newActivated.length && i < _hasBeenActivated.length; i++) {
        newActivated[i] = _hasBeenActivated[i];
      }
      _hasBeenActivated = newActivated;
    }
    if (!_hasBeenActivated[widget.index]) {
      _hasBeenActivated[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List.generate(
        widget.children.length,
        (i) {
          if (_hasBeenActivated[i]) {
            return widget.children[i];
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
