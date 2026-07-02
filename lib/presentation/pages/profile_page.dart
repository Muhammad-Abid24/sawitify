import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:Sawitify/presentation/pages/about_page.dart';
import 'package:Sawitify/presentation/pages/license_page.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/alert_dialog.dart';
import 'intro_page.dart';

class ProfilePage extends StatelessWidget {
  final String? userName;
  final String? email;
  final String? photoUrl;

  const ProfilePage({super.key, this.userName, this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background fills entire screen
        Container(decoration: BoxDecoration(color: Colors.black)),

        SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background2.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  title: userName ?? 'Guest',
                  subtitle: 'My Profile',
                  leading: Builder(
                    builder: (_) {
                      final url = photoUrl?.trim() ?? '';

                      final valid =
                          url.isNotEmpty &&
                          Uri.tryParse(url)?.hasAuthority == true;

                      if (!valid) {
                        return const CircleAvatar(
                          radius: 20,

                          backgroundColor: AppColors.primary,

                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      }

                      return ClipOval(
                        child: Image.network(
                          url,

                          width: 40,

                          height: 40,

                          fit: BoxFit.cover,

                          errorBuilder: (_, __, ___) {
                            return const CircleAvatar(
                              radius: 20,

                              backgroundColor: AppColors.primary,

                              child: Icon(
                                Icons.person,

                                color: Colors.white,

                                size: 20,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),

                _buildMenuItem(
                  title: 'Pengaturan Musik',
                  subtitle: 'Hapus Cache Aplikasi',
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  onTap: () {
                    MyAlertDialog.show(
                      context: context,
                      type: QuickAlertType.info,
                      title: 'Clear Cache',
                      text: 'Apakah Anda yakin?',
                      titleConfirm: 'Yakin',
                      titleCancel: 'Batal',
                    );
                  },
                ),

                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),

                _buildMenuItem(
                  title: 'Lisensi',
                  subtitle: 'Keluar dari aplikasi',
                  leading: const Icon(Icons.balance, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LicensePageOwn()),
                    );
                  },
                ),

                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),

                _buildMenuItem(
                  title: 'Tentang',
                  subtitle: 'Keluar dari aplikasi',
                  leading: const Icon(Icons.info, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),

                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),

                _buildMenuItem(
                  title: 'Logout',
                  subtitle: 'Keluar dari aplikasi',
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  onTap: () {
                    _logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required Widget leading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: Center(child: leading)),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    MyAlertDialog.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Logout',
      text: 'Apakah Anda yakin untuk keluar?',
      titleConfirm: 'Yakin',
      titleCancel: 'Batal',
      onConfirmBtnTap: () async {
        await SessionManager.logout();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreen()),
          (route) => false,
        );
      },
      onCancelBtnTap: () {
        Navigator.pop(context);
      },
    );
  }
}
