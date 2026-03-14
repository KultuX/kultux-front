import 'package:flutter/material.dart';
import 'package:kultux/componentes/bottom_nav.dart';
import 'package:kultux/componentes/app_bar.dart';
import 'package:kultux/componentes/asset_login.dart';
import 'package:kultux/mapas.dart';
import 'package:kultux/perfil.dart';
import 'package:kultux/buscar.dart';
import 'package:kultux/tarjetas.dart';
import 'package:kultux/establecimientos.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KultuX',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  //final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _logeado = false;
  int _indexActual = 0;
  bool _invitado = false;

  void _cerrarSesion() {
    setState(() {
      _logeado = false;
      _invitado = false;
      _indexActual = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> _paginas = [
      _bodyInicio(),
      MapasPage(),
      BuscarPage(),
      EstablecimientosPage(),
      PerfilPage(cerrarSesion: _cerrarSesion)
    ];
    return Scaffold(
      appBar: AppBarPersonalizado(),
      body: _indexActual == 0
          ? Stack(alignment: .center,
          children: [
            _paginas[_indexActual],
            if(!_logeado && !_invitado ) AssetLogin(
                cerrar: () {
                  setState(() {
                    _logeado = true;
                    _invitado = true;
                  });
                },
                logeado: () {
                  setState(() {
                    _logeado = true;
                    _invitado = false;
                  });
                },
              invitado:(){
                  setState((){
                    _invitado = true;
                    _logeado = true;
                    _indexActual = 0;
                  });
              }
            ),
          ]
      ) : _paginas[_indexActual],
      bottomNavigationBar: BottomNav(
          itemSeleccionado: _indexActual,
          itemSeleccion: (index) {
            if(index == 4 && _invitado){
              setState(() {
                _invitado = false;
                _logeado = false; // mostrar login
                _indexActual = 0; // volver a la página inicial
              });
              return;
            }
            setState(() {
              _indexActual = index;

            });
          }
      ),
    );
  }

  Widget _bodyInicio() {
    return Center(child:Container(

      width: 364,
        child:
    ListView(children: [
      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),

      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),

      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),
      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),
      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),
      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),
      Tarjeta.actividades(
          titulo: 'Lucha de gladiadores',
          localidad: 'Mérida',
          fecha: '06/05/2026',
          imagenUrl:'https://www.saboraextremadura.es/wp-content/uploads/2018/07/m%C3%A9rida.webp',
          onTap: (){}),


    ],
    )
    ));
  }
}

class SplashPage extends StatefulWidget{
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>{

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 3), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }
  @override
  Widget build(BuildContext context){
    return Container(
        color: Colors.white,
        child:Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset("assets/images/imagen_splash.png")
          ],
        )
    );
  }
}

