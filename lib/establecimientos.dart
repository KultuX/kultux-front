import 'package:flutter/material.dart';
import 'package:kultux/componentes/botones.dart';

class EstablecimientosPage extends StatefulWidget{
  const EstablecimientosPage({super.key});
  @override
  State<EstablecimientosPage> createState() => _EstablecimientosPageState();
}

class _EstablecimientosPageState extends State<EstablecimientosPage>{
  @override
  Widget build(BuildContext context){
    return Center(
        child:Column(
            children: [
              Text("Establecimientos"),
              Card(
                child: Column(
                  children: [
                    Text('RESTAURANTES DESTACADOS'),
                    Row(mainAxisAlignment: .spaceAround,
                      children: [
                        _tarjetaEstablecimiento(titulo:'Tuétano'),
                        _tarjetaEstablecimiento(titulo: 'Barbarosa'),
                        _tarjetaEstablecimiento(titulo: '4 Torres')
                      ],
                    ),
                    Row(mainAxisAlignment: .spaceAround,
                      children: [
                        _tarjetaEstablecimiento(titulo:'Carnívora'),
                        _tarjetaEstablecimiento(titulo: 'La Mafia'),
                        _tarjetaEstablecimiento(titulo: 'Camaleónico')
                      ],
                    ),
                    Row(children:[]),
                    BotonesGenerico(titulo: "Ver más", ancho: 77)
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Card(
                child: Column( mainAxisAlignment: .spaceAround,
                  children: [
                    Text('ALOJAMIENTOS DESTACADOS'),
                    Row(mainAxisAlignment: .spaceAround,
                      children: [
                        _tarjetaEstablecimiento(titulo:'Hotel Velada'),
                        _tarjetaEstablecimiento(titulo: 'Las Fuentes'),
                        _tarjetaEstablecimiento(titulo: 'Pineir')
                      ],
                    ),
                    Row(mainAxisAlignment: .spaceAround,
                      children: [
                        _tarjetaEstablecimiento(titulo:'Las Cabañas'),
                        _tarjetaEstablecimiento(titulo: 'Emperador'),
                        _tarjetaEstablecimiento(titulo: 'La colonial')
                      ],
                    ),
                    BotonesGenerico(titulo: "Ver más", ancho: 77)
                  ],
                ),
              )
            ]
        )

    );
  }
  
  Widget _tarjetaEstablecimiento({required String titulo}){
    return Column(
      children: [
        Container(
          alignment: .center,
         padding: EdgeInsets.symmetric(horizontal:16, vertical:1),
          decoration: BoxDecoration(
            color: Color.fromARGB(198, 166, 226, 70),
            borderRadius: BorderRadius.circular(5)
          ),
            child:Text(titulo, style: TextStyle(fontFamily: 'RobotoCondensed')
            )
        ),
        const SizedBox(height: 6,),
        Container(
          width:94.5,
            height: 94.5,
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 166, 226, 70), width:1.5),
              borderRadius: BorderRadius.circular(15)
            ),
        child:    ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                "https://www.ktchnrebel.com/wp-content/uploads/2024/02/Chefs_Table_at_Brooklyn_Fare_c_chefs-tableFilter-1.jpg",
               fit: .cover,
              )
            )
        ),

      ],
    );
  }
}