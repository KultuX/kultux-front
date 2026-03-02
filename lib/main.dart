import 'package:flutter/material.dart';
import 'package:kultux/componentes/bottomNav.dart';
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: Padding(padding: const EdgeInsets.only(left:10),child:Image.asset('assets/iconos/logo_kultux.png', width:30, height: 30,)),
        backgroundColor: Colors.black,
      ),
      body: Center(

        child: const SizedBox()
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}
