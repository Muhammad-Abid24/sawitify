import 'dart:ui';

import 'package:flutter/material.dart';

class RectangleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? color;

  const RectangleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.width = 100,
    this.height = 40,
    this.color = Colors.white,
  });

  @override
  State<RectangleButton> createState() => _RectangleButtonState();
}

class _RectangleButtonState extends State<RectangleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scale = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();

    if (!mounted) return;

    await _controller.reverse();

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,

      child: GestureDetector(
        onTap: _handleTap,

        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: widget.width,
              height: widget.height,
              color: Colors.white.withValues(alpha: .12),
              child: Icon(widget.icon, color: widget.color),
            ),
          ),
        ),
      ),
    );
  }
}
