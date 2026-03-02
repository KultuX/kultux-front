import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/iconosBottom.dart';
class BottomNav extends StatelessWidget{
  const BottomNav({super.key});
  @override
  Widget build(BuildContext context){
    return BottomNavigationBar(
      //onTap: ,
        iconSize: 24.0,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 166, 226, 70),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        items: [
          _bottomItem('assets/iconos/home.svg', 'Inicio'),
          _bottomItem('assets/iconos/maps.svg', 'Mapa'),
          _bottomItem('assets/iconos/buscar.svg','Buscar'),
          _bottomItem('assets/iconos/servicios.svg','Servicios'),
          _bottomItem('assets/iconos/perfil.svg','Perfil'),
        ]
    );
  }

  BottomNavigationBarItem _bottomItem(String path, String titulo){
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        width: 24.0,
        height: 24.0,
        path, // Puedes cambiar color
        colorFilter: ColorFilter.mode(Colors.white,BlendMode.srcIn),
      ),activeIcon: SvgPicture.asset(
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
