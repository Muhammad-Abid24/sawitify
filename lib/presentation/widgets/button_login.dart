import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget logo;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final BorderRadius borderRadius;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.logo,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(30),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
        Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 24,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: logo,
                ),
              ),
            ),
        ),

             Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}