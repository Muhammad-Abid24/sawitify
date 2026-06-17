import 'package:flutter/material.dart';

class AppColors {
  static const background1 = Color(0xFF102715);
  static const background2 = Color(0xFF16331A);
  static const primary = Color(0xFF398A49);
  static const secondary1 = Color(0xFF84B745);
  static const secondary2 = Color(0xFF9CC350);
  static const secondary3 = Color(0xFFE89625);
  static const secondary4 = Color(0xFFFBC848);
  static const red = Color(0xFFC20D30);
  static const purple = Color(0xFF581FE7);
  static const pink = Color(0xFFE71FB8);
  static const green = Color(0xFF4CAF50);
}

class AppTextStyle {
  static const _base = TextStyle(
    fontFamily: 'SF-Pro-Display',
    fontSize: 12.5,
  );

  static final regular14 = _base.copyWith(fontSize: 14);
  static final regular16 = _base.copyWith(fontSize: 16);

  static final semibold14 = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  static final semibold16 = semibold14.copyWith(fontSize: 16);
  static final semibold18 = semibold14.copyWith(fontSize: 18);

  static final bold16 = _base.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    letterSpacing: 0.1,
  );

  static final bold18 = bold16.copyWith(
    fontSize: 18,
    letterSpacing: -0.5,
  );

  static final bold20 = bold16.copyWith(
    fontSize: 20,
    letterSpacing: -1,
  );

  static final bold24 = bold16.copyWith(
    fontSize: 24,
    letterSpacing: -1,
  );
}

class AppSpacing {
  // basic spacing
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  // EdgeInsets helpers
  static const paddingAll8 = EdgeInsets.all(8);
  static const paddingAll16 = EdgeInsets.all(16);
  static const paddingAll24 = EdgeInsets.all(24);

  static const horizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const vertical16 = EdgeInsets.symmetric(vertical: 16);

  static const screenPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 20,
  );

  static const cardPadding = EdgeInsets.all(16);
}