import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kultux/config/app_colors.dart';
import 'package:kultux/shared/widget/app_icon_button.dart';

import 'app_text_button.dart';

class AppBarCustom extends StatefulWidget
    implements PreferredSizeWidget {
  final bool isLogged;
  final bool guest;

  final VoidCallback? onShowLogin;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoProfile;
  final bool activateProfile;

  const AppBarCustom({
    super.key,
    this.isLogged = false,
    this.guest = false,
    this.onShowLogin,
    this.onGoHome,
    this.onGoProfile,
    this.activateProfile = false,
  });

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _AppBarCustomState extends State<AppBarCustom> {
  @override
  Widget build(BuildContext context) {
    final bool active = widget.activateProfile;

    return AppBar(
      backgroundColor: AppColors.navBg,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child:
        GestureDetector(
          onTap: widget.onGoHome,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo_kultux.png',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),

      actions: [
        if (widget.isLogged)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AppIconButton(
              onTap: widget.onGoProfile,
              icon: 'assets/iconos/perfil.svg',
              active: active
            ),
          ),
        if (widget.guest)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: AppTextButton(
                label:'Entrar',
                variant: AppButtonVariant.soft,
                width:60,
                onTap: widget.onShowLogin
            )
          ),
      ],
    );
  }
}
