import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BottomNavPill extends StatelessWidget {
  final String? label;
  final NetworkImage? image;
  final int selectedIndex;
  final Function(int)? onTabChanged;
  final double? width;
  final double? height;
  final double? horizontalMargin;
  final double? topMargin;
  final double? bottomMargin;

  const BottomNavPill({
    super.key,
    this.label,
    this.image,
    this.selectedIndex = 0,
    this.onTabChanged,
    this.width,
    this.height,
    this.horizontalMargin,
    this.topMargin,
    this.bottomMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalMargin ?? 20,
          right: horizontalMargin ?? 20,
          top: topMargin ?? 8,
          bottom: bottomMargin ?? 30,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary,
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.home,
                        label: "Home",
                        selected: selectedIndex == 0,
                        onTap: () => onTabChanged?.call(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: CupertinoIcons.search,
                        label: "Search",
                        selected: selectedIndex == 1,
                        onTap: () => onTabChanged?.call(1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: CupertinoIcons.music_albums,
                        label: "Library",
                        selected: selectedIndex == 2,
                        onTap: () => onTabChanged?.call(2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        image: image,
                        isProfile: true,
                        label: "Profile",
                        selected: selectedIndex == 3,
                        onTap: () => onTabChanged?.call(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;

  final NetworkImage? image;

  final bool isProfile;

  final String label;

  final bool selected;

  final VoidCallback? onTap;

  const _NavItem({
    super.key,

    this.icon,

    this.image,

    this.isProfile = false,

    required this.label,

    this.selected = false,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(100),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            if (image != null)
              ClipOval(
                child: Image(
                  image: image!,

                  width: 24,

                  height: 24,

                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.person,

                      size: 24,

                      color: selected ? AppColors.primary : Colors.black,
                    );
                  },
                ),
              )
            else if (isProfile)
              Icon(
                Icons.person,

                size: 24,

                color: selected ? AppColors.primary : Colors.black,
              )
            else
              Icon(
                icon,

                size: 24,

                color: selected ? AppColors.primary : Colors.black,
              ),

            const SizedBox(height: 3),

            Text(
              label,

              style: TextStyle(
                fontSize: 9,

                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,

                color: selected ? AppColors.primary : Colors.black,

                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
