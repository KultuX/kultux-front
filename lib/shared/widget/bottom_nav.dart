import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/app_colors.dart';

class BottomNav extends StatefulWidget {
  final int selectedItem;
  final ValueChanged<int> itemSelected;

  const BottomNav({
    required this.selectedItem,
    required this.itemSelected,
    super.key,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      currentIndex: widget.selectedItem,
      onTap: widget.itemSelected,
      iconSize: 24.0,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: AppColors.white,
      selectedItemColor: AppColors.green,
      backgroundColor: Colors.black,
      items: [
        _bottomItem('assets/iconos/home.svg', 'Inicio'),
        _bottomItem('assets/iconos/maps.svg', 'Mapa'),
        _bottomItem('assets/iconos/buscar.svg', 'Buscar'),
        _bottomItem('assets/iconos/servicios.svg', 'Establecimientos'),
        _bottomItem('assets/iconos/guardados.svg', 'Guardados'),
      ],
    );
  }

  BottomNavigationBarItem _bottomItem(String path, String titulo) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        path,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        path,
        width: 30,
        height: 30,
        colorFilter: const ColorFilter.mode(
          AppColors.green,
          BlendMode.srcIn,
        ),
      ),
      label: titulo,
    );
  }
}
