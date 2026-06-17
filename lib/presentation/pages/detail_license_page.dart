import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/license_package.dart';
import '../widgets/toolbar.dart';

class LicenseDetailPage extends StatelessWidget {
  final LicensePackage package;

  const LicenseDetailPage({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: Toolbar(
        bgColor: AppColors.primary,
        txtTitle: package.packageName,
        titleColor: Colors.white,
        icons: Icons.arrow_back,
        iconsColor: Colors.white,
      ),

        // Content on top
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            package.packageName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${package.licenseCount} license${package.licenseCount > 1 ? 's' : ''}.',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          Divider(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 24),

          ...package.entries.expand((entry) {
            return entry.paragraphs.map(
                  (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SelectableText(
                  paragraph.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
