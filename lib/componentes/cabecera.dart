import 'package:flutter/material.dart';

class CabeceraPagina extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  final bool mostrarFecha;
  final bool mostrarEtiquetaHoy;

  final VoidCallback? onVolver;

  final EdgeInsets padding;

  final bool mostrarImagenDerecha;

  const CabeceraPagina({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.mostrarFecha = false,
    this.mostrarEtiquetaHoy = false,
    this.onVolver,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 12),
    this.mostrarImagenDerecha = false
  });

  @override
  Widget build(BuildContext context) {

    final bool tieneFlecha = onVolver != null;

    final fechaActual = DateTime.now();

    const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final dia = dias[fechaActual.weekday - 1];

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF2d2d2d),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (mostrarImagenDerecha)
            Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: 0.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      "assets/images/extrem.png",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade700,
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (tieneFlecha)
            Positioned(
              top: -16,
              left: -14,
              child: IconButton(
                onPressed: onVolver,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(
              top: tieneFlecha ? 18 : 0,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      if (subtitulo != null) ...[
                        Text(
                          subtitulo!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFb0b0b0),
                          ),
                        ),

                        const SizedBox(height: 2),
                      ],

                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA6E246),
                          borderRadius:
                          BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),

                if (mostrarFecha)
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [

                      if (mostrarEtiquetaHoy)
                        const Text(
                          'Hoy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFb0b0b0),
                          ),
                        ),

                      if (mostrarEtiquetaHoy)
                        const SizedBox(height: 2),

                      Text(
                        "$dia. ${fechaActual.day}/${fechaActual.month}/${fechaActual.year}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}