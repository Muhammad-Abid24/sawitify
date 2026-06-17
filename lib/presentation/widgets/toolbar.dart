import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Toolbar extends StatelessWidget implements PreferredSizeWidget {
  final String txtTitle;
  final Color titleColor;
  final Color bgColor;
  final IconData icons;
  final Color iconsColor;
  final VoidCallback? onTap;

  const Toolbar({
    super.key,
    required this.txtTitle,
    required this.titleColor,
    required this.bgColor,
    required this.icons,
    required this.iconsColor,
    this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        // Android
        statusBarIconBrightness: Brightness.light,

        // iOS
        statusBarBrightness: Brightness.dark,
      ),
      leadingWidth: 80,
      // leading: IconButton(
      //   icon: _buildIcon(icons, iconsColor),
      //   onPressed: () => Navigator.pop(context),
      // ),

      leading: IconButton(
        icon: _buildIcon(
          icons,
          iconsColor,
        ),
        onPressed:
        onTap ??
                () => Navigator.pop(context),
      ),
      toolbarHeight: preferredSize.height,
      elevation: 1,
      shadowColor: Colors.black45,
      title: Text(
          txtTitle,
          style: TextStyle(
            color: titleColor,
            fontSize: 22
          ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(icon, color: color, size: 35),
    );
  }
}