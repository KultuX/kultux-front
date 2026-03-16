import 'package:flutter/material.dart';

class MapasPage extends StatefulWidget{
  const MapasPage({super.key});
  @override
  State<MapasPage> createState() => _MapasPageState();
}

class _MapasPageState extends State<MapasPage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mapa interactivo
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.expand(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(200),
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                child: Image.asset(
                  "assets/images/mapa_extr.png",
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),

        // Overlay de "Próximamente"
        Container(
          color: Colors.black54, // Fondo semitransparente
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.construction, // puedes poner un icono o un asset
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Próximamente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}