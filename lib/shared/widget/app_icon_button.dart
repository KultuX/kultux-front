
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:kultux/config/app_colors.dart';

class AppIconButton extends StatelessWidget{
  final VoidCallback? onTap;
  final String icon;
  final bool active;

  const AppIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.active = false

});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        width: active ? 40 : 32,
        height: active ? 40 : 32,
        colorFilter: ColorFilter.mode(
          active ? AppColors.green : Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}