import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget{
  const PerfilPage({super.key});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>{
  
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: .center,
            children: [
              Card(),
              Column(children:[

                ]),
            Text('Estas en el perfil')
          ]
        )
    );
  }
}