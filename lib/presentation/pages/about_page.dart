import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/toolbar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: Toolbar(
        bgColor: AppColors.primary,
        txtTitle: 'Tentang',
        titleColor: Colors.white,
        icons: Icons.arrow_back,
        iconsColor: Colors.white,
      ),

      // Content on top
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "assets/logo/ic_logo_vertical.png",
                width: 200,
                height: 200,
              ),
              Text(
                'by\nMuhammad Abid Misbahuddin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                child: Text(
                  'Thank you for using Sawitify!\n\n'
                  'Maintaining and improving this open-source project takes time and resources. Your support helps us continue to provide a free and reliable application for everyone.\n\n'
                  'If you find Sawitify helpful, please consider making a contribution. Every little bit helps!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
