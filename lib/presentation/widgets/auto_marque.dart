import 'package:flutter/cupertino.dart';
import 'package:marquee/marquee.dart';

Widget autoMarquee({
  required String text,
  required TextStyle style,
  required double height,
}) {
  // batas karakter bisa kamu sesuaikan
  if (text.length <= 20) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }

  return SizedBox(
    height: height,
    child: Marquee(
      text: text,
      style: style,
      blankSpace: 60,
      velocity: 25,
      startPadding: 0,
      pauseAfterRound: const Duration(
        seconds: 1,
      ),
      accelerationDuration: const Duration(
        milliseconds: 500,
      ),
      decelerationDuration: const Duration(
        milliseconds: 500,
      ),
      fadingEdgeStartFraction: .08,
      fadingEdgeEndFraction: .08,
    ),
  );
}