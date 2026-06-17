import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/toolbar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
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
                  "assets/logo/ic_sawitify_text.png",
                  width: 200,
                  height: 200,),
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
                Text(
                  'Cari lagu, artis, atau album',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
