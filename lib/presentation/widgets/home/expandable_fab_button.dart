// common/widgets/expandable_create_fab.dart

import 'package:flutter/material.dart';

class FabOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const FabOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class ExpandableCreateFab extends StatefulWidget {
  final List<FabOption> options;
  final IconData mainIcon;
  final Color backgroundColor;
  final Color iconColor;

  const ExpandableCreateFab({
    super.key,
    required this.options,
    this.mainIcon = Icons.add,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.iconColor = Colors.greenAccent,
  });

  @override
  State<ExpandableCreateFab> createState() => _ExpandableCreateFabState();
}

class _ExpandableCreateFabState extends State<ExpandableCreateFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildOption(FabOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: widget.backgroundColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _toggle();
                option.onTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  option.label,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            mini: true,
            backgroundColor: widget.backgroundColor,
            onPressed: () {
              _toggle();
              option.onTap();
            },
            child: Icon(option.icon, color: widget.iconColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Dim background
        if (_isExpanded)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        // Expanded options
        Positioned(
          right: 16,
          bottom: 90,
          child: ScaleTransition(
            scale: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: widget.options.map(_buildOption).toList(),
            ),
          ),
        ),

        // Main FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: widget.backgroundColor,
            onPressed: _toggle,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.close : widget.mainIcon,
                key: ValueKey(_isExpanded),
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}