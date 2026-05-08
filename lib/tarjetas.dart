import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/franja.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Tarjeta extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final String? fecha;
  final String imagenUrl;
  final VoidCallback onTap;
  final String? textoEtiqueta;
  final String? iconoEtiqueta;
  final String? estado;
  final Map<String, List<Franja>>? horario;
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
  }) : this._(
    key: key,
    titulo: titulo,
    localidad: localidad,
    fecha: fecha,
    imagenUrl: imagenUrl,
    onTap: onTap,
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
    onTap: onTap,
  );

  const Tarjeta.alojamiento({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    String? localidad,
  }) : this._(
    key: key,
    titulo: titulo,
    imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta,
    iconoEtiqueta: iconoEtiqueta,
    onTap: onTap,
    localidad: localidad,
  );

  const Tarjeta.restauranteBusqueda({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    required Map<String, List<Franja>> horario,
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
            // ✅ IMAGEN CACHEADA
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imagenUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 166, 226, 70),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey.shade400,
                    size: 36,
                  ),
                ),
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

            Positioned(
              top: 8,
              left: 8,
              child: TituloTarjeta(titulo: titulo),
            ),

            if (fecha != null)
              Positioned(
                top: 8,
                right: 8,
                child: FechaTarjeta(fecha: fecha!),
              ),

            if (localidad != null)
              Positioned(
                bottom: 8,
                left: 8,
                child: LocalidadTarjeta(localidad: localidad!),
              ),

            if (textoEtiqueta != null && iconoEtiqueta != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: EtiquetaTarjeta(
                  texto: textoEtiqueta!,
                  icono: iconoEtiqueta!,
                ),
              ),

            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(child: BotonTarjeta(onTap: onTap)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────── COMPONENTES ───────────── */

class TituloTarjeta extends StatelessWidget {
  final String titulo;
  const TituloTarjeta({super.key, required this.titulo});

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
        ),
      ),
    );
  }
}

class EtiquetaTarjeta extends StatelessWidget {
  final String texto;
  final String icono;
  const EtiquetaTarjeta({super.key, required this.texto, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFA6E246),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icono,
            width: 15,
            height: 15,
            colorFilter:
            const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(
              fontFamily: "RobotoCondensed",
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class FechaTarjeta extends StatelessWidget {
  final String fecha;
  const FechaTarjeta({super.key, required this.fecha});

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
        ),
      ),
    );
  }
}

class BotonTarjeta extends StatelessWidget {
  final VoidCallback onTap;
  const BotonTarjeta({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(227, 166, 226, 70),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/iconos/flecha_siguiente.svg",
            width: 22,
            height: 22,
          ),
        ),
      ),
    );
  }
}

class LocalidadTarjeta extends StatelessWidget {
  final String localidad;
  const LocalidadTarjeta({super.key, required this.localidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(190, 235, 245, 233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset("assets/iconos/ubicar.svg", width: 15),
          const SizedBox(width: 10),
          Text(
            localidad,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: "RobotoCondensed",
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}