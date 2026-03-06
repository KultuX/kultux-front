import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetLogin extends StatefulWidget{
  final VoidCallback? cerrar;
  const AssetLogin({super.key, this.cerrar});
  @override
  State<AssetLogin> createState() => _AssetLoginState();
}

class _AssetLoginState extends State<AssetLogin>{
  @override
  Widget build(BuildContext context){

    return Stack(
      children:[
        GestureDetector(
          onTap: widget.cerrar,
          child: Container(color: Colors.black54)
        ),
        Positioned(
            top:100,
            left:50,
            width:250,
            height: 150,
            child: Material(
                color: Colors.transparent,
                child:Container(
                    decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.circular(20),boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
                    child: Column(
                        mainAxisAlignment: .center,
                        children:[
                          Text('Login'),
                          Image.asset('assets/iconos/logo_kultux.png', width:60,height: 60,),
                          TextField(decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Correo Electrónico',
                            prefixIcon: Icon(Icons.person),
                          ),),
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.person),
                            ),),
                          ElevatedButton(onPressed: (){},child: Text('Login')),
                          ElevatedButton(onPressed: (){},child: Text('Registro')),
                          ElevatedButton(onPressed: (){},child: Text('Entrar como Invitado')),
                        ]
                    )
                )
            )
        )
      ]
    );
  }
}