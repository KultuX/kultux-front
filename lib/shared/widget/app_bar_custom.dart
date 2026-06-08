import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/app_colors.dart';

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
    final bool activo = widget.activateProfile;

    return AppBar(
      backgroundColor: AppColors.navBg,
      elevation: 0,
      leadingWidth: 70,

      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
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
            child: GestureDetector(
              onTap: widget.onGoProfile,
              child: SvgPicture.asset(
                'assets/iconos/perfil.svg',
                width: activo ? 40 : 32,
                height: activo ? 40 : 32,
                colorFilter: ColorFilter.mode(
                  activo ? AppColors.green : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

        if (widget.guest)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: GestureDetector(
                onTap: widget.onShowLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.green,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
