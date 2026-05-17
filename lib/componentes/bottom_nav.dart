import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNav extends StatefulWidget {
  final int itemSeleccionado;
  final ValueChanged<int> itemSeleccion;

  const BottomNav({
    required this.itemSeleccionado,
    required this.itemSeleccion,
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
      currentIndex: widget.itemSeleccionado,
      onTap: widget.itemSeleccion,
      iconSize: 24.0,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 166, 226, 70),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        path,
        width: 30,
        height: 30,
        colorFilter: const ColorFilter.mode(
          Color.fromARGB(255, 166, 226, 70),
          BlendMode.srcIn,
        ),
      ),
      label: titulo,
    );
  }
}