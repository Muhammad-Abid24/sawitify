import 'package:flutter/material.dart';
import 'package:sawitify/core/theme/app_theme.dart';

class HorizontalCard extends StatelessWidget {
  final double? width;
  final String? titleCard;
  final Color? colorTitleCard;
  final String? subTitleCard;
  final Color? colorSubTitleCard;
  final Widget? iconWidget;
  final IconData? iconData;
  final Color? colorIcon;
  final double borderRadiusCard;
  final double? borderRadiusIcon;
  final NetworkImage? image;
  final VoidCallback? onTap;

  const HorizontalCard({
    super.key,
    this.titleCard,
    this.colorTitleCard,
    this.subTitleCard,
    this.colorSubTitleCard,
    this.image,
    this.iconData, this.width, this.iconWidget, this.onTap, this.colorIcon, required this.borderRadiusCard, this.borderRadiusIcon
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background2.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(borderRadiusCard),
          border: Border.all(color:  AppColors.primary),
        ),
        child: Row(
        children: [
          if (iconData == null && iconWidget != null)
            iconWidget!
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(borderRadiusIcon ?? 10),
              ),
              child: image != null
                  ? ClipOval(
                      child: Image(
                        image: image!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(iconData, color: colorIcon ?? Colors.white, size: 20),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleCard ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorTitleCard ?? Colors.white,
                  ),
                ),
                Text(
                  subTitleCard ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: colorSubTitleCard ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   amount,
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //     color: amountColor,
          //   ),
          // ),
        ],
      ),
      ),
    );
  }
}