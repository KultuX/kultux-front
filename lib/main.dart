import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/bottom_nav.dart';
import 'package:kultux/componentes/app_bar.dart';
import 'package:kultux/componentes/asset_login.dart';
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
      home: const MyHomePage(title: 'KultuX'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _logeado = false;
  int _indexActual = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPersonalizado(),
      body: Center(
        child: Column(children: [
          // Ventana flotante
          if (_logeado)
            AssetLogin(
              cerrar: () {
                setState(() {
                  _logeado = false;
                });
              },
            ),
        ],),
      ),
      bottomNavigationBar: BottomNav(
        itemSeleccionado: _indexActual,
        itemSeleccion: (index){
          setState((){
            _indexActual = index;
          });
        }
      ),
    );
  }
}
