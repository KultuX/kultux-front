import 'package:flutter/material.dart';

class MapasPage extends StatefulWidget{
  const MapasPage({super.key});
  @override
  State<MapasPage> createState() => _MapasPageState();
}

class _MapasPageState extends State<MapasPage>{

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [Container(child:Column(children: [Text('Próximamente'),CircularProgressIndicator()],)),
        LayoutBuilder(builder:
            (context, constraints){
          return SizedBox.expand(
              child:InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(200),
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                child: Image.asset("assets/images/mapas.png", fit: BoxFit.cover),
              )
          );
        }
        )
      ],
    );
  }
}