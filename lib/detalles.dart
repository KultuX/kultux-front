import 'package:flutter/material.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/restaurante.dart';

class Detalle extends StatelessWidget {
  final String titulo;
  final String imagenPrincipal;
  final String? descripcion;
  final String? telefonoEmpresa;
  final String? correoCorporativo;
  final String? fechaInicio;
  final String? fechaFin;
  final String? horarioApertura;
  final String? localidad;

  const Detalle._({
    super.key,
    required this.titulo,
    required this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaInicio,
    this.fechaFin,
    this.horarioApertura,
    this.localidad,
  });

  factory Detalle.desdeObjeto({
    required dynamic objeto,
  }) {
    if (objeto is Actividad) {
      return Detalle._(
        titulo: objeto.titulo,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        descripcion: objeto.descripcion,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
        fechaInicio: objeto.fechaInicio,
        fechaFin: objeto.fechaFin,
      );
    }

    if (objeto is Alojamiento) {
      return Detalle._(
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
      );
    }

    if (objeto is Restaurante) {
      return Detalle._(
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        descripcion: objeto.descripcion,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
        horarioApertura: objeto.horarioApetura,
      );
    }

    throw Exception('Tipo de objeto no soportado');
  }

  @override
  Widget build(BuildContext context) {
    final bool esActividad = fechaInicio != null || fechaFin != null;
    final bool esRestaurante =
        !esActividad &&
            horarioApertura != null &&
            horarioApertura!.trim().isNotEmpty;
    final bool esAlojamiento = !esActividad && !esRestaurante;

    const Color verdeKultux = Color(0xFFA8D63F);
    const Color fondoCard = Color(0xFFF6F4F1);
    const Color colorTexto = Color(0xFF1F1F1F);

    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: BoxDecoration(
                color: fondoCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: colorTexto,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 168,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: verdeKultux,
                            width: 0.8,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imagenPrincipal,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 34,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        child: _botonFlecha(
                          icon: Icons.chevron_left,
                          color: verdeKultux,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        child: _botonFlecha(
                          icon: Icons.chevron_right,
                          color: verdeKultux,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (esActividad)
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoConIcono(
                          icono: Icons.calendar_today_outlined,
                          texto:
                          '${fechaInicio ?? ''}${fechaFin != null ? ' al $fechaFin' : ''}',
                        ),
                      ],
                    ),

                  if (esRestaurante)
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoConIcono(
                          icono: Icons.access_time_outlined,
                          texto: horarioApertura ?? '',
                        ),
                      ],
                    ),

                  if (esAlojamiento)
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoConIcono(
                          icono: Icons.hotel_outlined,
                          texto: localidad ?? '',
                        ),
                      ],
                    ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _infoConIcono(
                          icono: Icons.location_on_outlined,
                          texto: localidad ?? '',
                          iconColor: verdeKultux,
                          negrita: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if(esActividad)
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          color: colorTexto,
                          size: 24,
                        ),
                      if(esActividad) const SizedBox(width: 16),
                      const Icon(
                        Icons.bookmark_border,
                        color: colorTexto,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.share_outlined,
                        color: colorTexto,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (descripcion != null && descripcion!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  descripcion!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                    color: colorTexto,
                  ),
                ),
              ),

            if (descripcion != null && descripcion!.trim().isNotEmpty)
              const SizedBox(height: 22),

            if (esActividad)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black38),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorTexto,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '@Sandra : Comentario cualquiera sobre alguna duda del evento como por ejemplo si se devuelve el dinero en caso de cancelación, o si se puede llevar comida',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (esActividad) const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (esActividad)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Organizado por: Ayuntamiento de Mérida',
                        style: TextStyle(
                          fontSize: 15,
                          color: colorTexto,
                        ),
                      ),
                    ),

                  if (telefonoEmpresa != null && telefonoEmpresa!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: colorTexto,
                          ),
                          children: [
                            const TextSpan(text: 'Teléfono: '),
                            TextSpan(
                              text: telefonoEmpresa!,
                              style: const TextStyle(
                                color: Color(0xFF6C79FF),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (correoCorporativo != null &&
                      correoCorporativo!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: colorTexto,
                          ),
                          children: [
                            const TextSpan(text: 'Correo electrónico: '),
                            TextSpan(
                              text: correoCorporativo!,
                              style: const TextStyle(
                                color: Color(0xFF6C79FF),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: verdeKultux,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  esActividad ? 'Comprar entradas' : 'Reservar',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonFlecha({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: Colors.black54,
        size: 28,
      ),
    );
  }

  Widget _infoConIcono({
    required IconData icono,
    required String texto,
    Color iconColor = Colors.black,
    bool negrita = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 15,
              fontWeight: negrita ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF1F1F1F),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}