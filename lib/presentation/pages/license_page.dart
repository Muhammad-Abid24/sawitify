import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/license_package.dart';
import '../widgets/toolbar.dart';
import 'detail_license_page.dart';

class LicensePageOwn extends StatelessWidget {
  const LicensePageOwn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      appBar: Toolbar(
        bgColor: AppColors.primary,
        txtTitle: 'Lisensi',
        titleColor: Colors.white,
        icons: Icons.arrow_back,
        iconsColor: Colors.white,
      ),

        // Content on top
      body: FutureBuilder<List<LicensePackage>>(
        future: getLicenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final licenses = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: licenses.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final item = licenses[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.packageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${item.licenseCount} license${item.licenseCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppColors.primary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LicenseDetailPage(
                        package: item,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
