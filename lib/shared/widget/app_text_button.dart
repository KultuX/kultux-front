import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

enum AppButtonVariant { primary, outline, destructive, soft }

class AppTextButton extends StatelessWidget {
  final String? svgIcon;
  final String label;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool? icon;

  const AppTextButton({
    super.key,
    required this.label,
    this.width,
    this.onTap,
    this.height = 40,
    this.variant = AppButtonVariant.primary,
    this.svgIcon,
    this.icon = false,
  });
  @override
  Widget build(BuildContext context) {
    final isSoft = variant == AppButtonVariant.soft;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isSoft ? 10 : 14,
          horizontal: isSoft ? 5 : 0,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: _border,
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            if (icon != null && icon!)Icon(Icons.person_outline, size: 16, color: AppColors.textSoft),
            if(icon != null && icon!)SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: _textColor,
                fontWeight: .w400,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }

  Color get _backgroundColor => switch (variant) {
    AppButtonVariant.primary => AppColors.green,
    AppButtonVariant.outline => Colors.transparent,
    AppButtonVariant.destructive => AppColors.white,
    AppButtonVariant.soft => Colors.transparent,
  };

  Color get _textColor => switch (variant) {
    AppButtonVariant.primary => AppColors.text,
    AppButtonVariant.outline => AppColors.textSoft,
    AppButtonVariant.destructive => AppColors.white,
    AppButtonVariant.soft => AppColors.green,
  };

  Border? get _border => switch (variant) {
    AppButtonVariant.primary => null,
    AppButtonVariant.outline => Border.all(color: AppColors.border, width: 1.5),
    AppButtonVariant.destructive => Border.all(
      color: AppColors.destructiveBorder,
    ),
    AppButtonVariant.soft => Border.all(color: AppColors.green, width: 1),
  };
}
