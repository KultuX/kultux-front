import 'package:flutter/material.dart';
import 'package:kultux/componentes/bottom_nav.dart';
import 'package:kultux/componentes/app_bar.dart';
import 'package:kultux/componentes/asset_login.dart';
import 'package:kultux/mapas.dart';
import 'package:kultux/perfil.dart';
import 'package:kultux/buscar.dart';
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
  void _cerrarSesion(){
    setState(() {
      _logeado = false;
      _indexActual = 0;
    });
  }



  @override
  Widget build(BuildContext context) {
    final List<Widget> _paginas = [
      _bodyInicio(),
      MapasPage(),
      BuscarPage(),
      Center(child: Text('Servicios')),
      PerfilPage(cerrarSesion: _cerrarSesion)
    ];
    return Scaffold(
      appBar: AppBarPersonalizado(),
      body: _indexActual == 0  ? Stack( alignment: .center,
        children:[
          _paginas[_indexActual],
          if(!_logeado) AssetLogin(
              cerrar: () {
                setState(() {
                  _logeado = true;
                });
              },
              logeado: () {
                setState(() {
                  _logeado = true;
                });
              }
          ),
        ]
      ) : _paginas[_indexActual],
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

  Widget _bodyInicio(){
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: .stretch,
        mainAxisAlignment: .center,
        children: [
          Text('Inicio'),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta(),
          pruebaTarjeta()
          //TARJETAS PERSONALIZADAS --> CRISTO // CREAR MODELOS DE DATOS y API

          //MODIFICAR MAIN PARA QUE SE ENCHUFE CADA BODY CORRESPONDIENTE. --> AHORA SE SOBRESCRIBE
          //

        ],
      ),
    );
  }

  Widget pruebaTarjeta(){
    return Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child:Padding(
          padding: const EdgeInsets.all(16),
          child:Column(
              children:[
                CircleAvatar(
                    radius: 90,
                    backgroundImage: AssetImage("assets/images/logo_registro.png")
                ),
                const SizedBox(height: 8,),
                Text('Nombre usuario', style: TextStyle(fontFamily: 'RobotoCondensed',fontSize: 20)),
                const SizedBox(height: 8,),
                Text('correo@correo.com')
              ]
          ),
        )
    );
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

