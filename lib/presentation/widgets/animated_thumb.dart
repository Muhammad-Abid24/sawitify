import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedThumbShape extends SliderComponentShape {
  final double radius;

  const AnimatedThumbShape({
    required this.radius,
  });

  @override
  Size getPreferredSize(
      bool isEnabled,
      bool isDiscrete,
      ) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {

    final canvas = context.canvas;

    final animatedRadius =
        radius + (activationAnimation.value * 4);

    canvas.drawCircle(
      center,
      animatedRadius,
      Paint()..color = Colors.white,
    );
  }
}