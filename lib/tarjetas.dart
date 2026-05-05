import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/horario.dart';

const List<String> diasSemana = [
  "L", "M", "X", "J", "V", "S", "D"
];

String formatearHora(String hora) {
  return hora.substring(0, 5);
}
class Tarjeta extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final String? fecha;
  final String imagenUrl;
  final VoidCallback onTap;
  final String? textoEtiqueta;
  final String? iconoEtiqueta;
  final String? estado;
  final Horario? horario;
  final bool? abierto;

  const Tarjeta._({
    super.key,
    required this.titulo,
    this.localidad,
    this.fecha,
    required this.imagenUrl,
    required this.onTap,
    this.textoEtiqueta,
    this.iconoEtiqueta,
    this.estado,
    this.horario,
    this.abierto,
  });

  const Tarjeta.actividades({
    Key? key,
    required String titulo,
    required String localidad,
    required String fecha,
    required String imagenUrl,
    required VoidCallback onTap,
    required String estado
  }) : this._(
    key: key,
    titulo: titulo,
    localidad: localidad,
    fecha: fecha,
    imagenUrl: imagenUrl,
    onTap: onTap,
    estado: estado
  );

  const Tarjeta.restaurante({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
}) : this._(
    key: key,
    titulo: titulo,
    imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta,
    iconoEtiqueta: iconoEtiqueta,
    onTap: onTap
  );

  const Tarjeta.alojamiento({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    String? localidad
}) : this._(
    key: key,
    titulo: titulo,
    imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta,
    iconoEtiqueta: iconoEtiqueta,
    onTap: onTap,
    localidad: localidad
  );

  const Tarjeta.restauranteBusqueda({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    required Horario horario,
    required bool abierto,
    String? localidad,
  }) : this._(
    key: key,
    titulo: titulo,
    imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta,
    iconoEtiqueta: iconoEtiqueta,
    onTap: onTap,
    horario: horario,
    abierto: abierto,
    localidad: localidad,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 364,
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Imagen de fondo
            Positioned.fill(
              child: Image.network(
                imagenUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Borde de la tarjeta
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9ACD32),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Título arriba izquierda
            Positioned(
              top: 8,
              left: 8,
              child: TituloTarjeta(titulo: titulo),
            ),

            // Fecha arriba derecha
            if(fecha != null)
            Positioned(
              top: 8,
              right: 8,
              child: FechaTarjeta(fecha: fecha!),
            ),

            // Localidad abajo izquierda
            if(localidad != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: LocalidadTarjeta(localidad: localidad!),
            ),

            if(textoEtiqueta != null && iconoEtiqueta != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: EtiquetaTarjeta(
                texto: textoEtiqueta!,
                icono: iconoEtiqueta!
              ),
            ),

            // Botón derecha centrado
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: BotonTarjeta(onTap: onTap)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TituloTarjeta extends StatelessWidget {
  final String titulo;

  const TituloTarjeta({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(190, 235, 245, 233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        titulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "RobotoCondensed",
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

class EtiquetaTarjeta extends StatelessWidget{
  final String texto;
  final String icono;

  const EtiquetaTarjeta({
    super.key,
    required this.texto,
    required this.icono
  });

  @override
  Widget build(BuildContext context){
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFA6E246),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icono,
            width: 15,
            height: 15,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(
              fontFamily: "RobotoCondensed",
              fontSize: 14,
              color: Colors.black
            ),
          )
        ],
      ),
    );
  }
}

class FechaTarjeta extends StatelessWidget {
  final String fecha;

  const FechaTarjeta({
    super.key,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(190, 235, 245, 233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        fecha,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "RobotoCondensed",
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

class BotonTarjeta extends StatelessWidget{
  final VoidCallback onTap;
  const BotonTarjeta({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(227, 166, 226, 70),
          borderRadius: BorderRadius.circular(14)
        ),
        child: Center(
          child: SvgPicture.asset(
              "assets/iconos/flecha_siguiente.svg",
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class LocalidadTarjeta extends StatelessWidget {
  final String localidad;

  const LocalidadTarjeta({
    super.key,
    required this.localidad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(190, 235, 245, 233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: .center,
        children: [
        SvgPicture.asset("assets/iconos/ubicar.svg",
          width: 15,
          height: 15,
        ),
        const SizedBox(width: 10),
        Text(
          localidad,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: "RobotoCondensed",
            fontSize: 14,
            color: Colors.black,
        ),
      ),
      ]
      ),
    );
  }
}