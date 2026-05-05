import 'package:flutter/material.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/imagen.dart';
import 'package:kultux/models/horario.dart';

class Detalle extends StatefulWidget {
  final String titulo;
  final String? imagenPrincipal;
  final String? descripcion;
  final String? telefonoEmpresa;
  final String? correoCorporativo;
  final String? fechaInicio;
  final String? fechaFin;
  final String? localidad;
  final List<Imagen>? imagenes;
  final Horario? horario;
  final bool? abierto;

  const Detalle._({
    super.key,
    required this.titulo,
    this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaInicio,
    this.fechaFin,
    this.horario,
    this.localidad,
    this.imagenes,
    this.abierto,
  });

  List<String> get imagenesLista {
    if (imagenes == null || imagenes!.isEmpty) {
      return ['https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg'];
    }
    final ordenadas = [...imagenes!];
    ordenadas.sort((a, b) {
      if (a.esPortada == b.esPortada) return 0;
      if (a.esPortada) return -1;
      return 1;
    });
    return ordenadas.map((i) => i.url).toList();
  }

  factory Detalle.desdeObjeto({required dynamic objeto}) {
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
        imagenes: objeto.imagenes,
      );
    }
    if (objeto is Alojamiento) {
      return Detalle._(
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad?.nombre,
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
        horario: objeto.horario,
        imagenes: objeto.imagenes,
        abierto: objeto.abierto,
      );
    }
    throw Exception('Tipo de objeto no soportado');
  }

  @override
  State<Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<Detalle> {
  int _indiceActual = 0;

  static const _diasNombre = {
    1: 'Lun', 2: 'Mar', 3: 'Mié',
    4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  @override
  void didUpdateWidget(covariant Detalle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _indiceActual = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool esActividad = widget.fechaInicio != null || widget.fechaFin != null;
    final bool esRestaurante = !esActividad && widget.horario != null;
    final bool esAlojamiento = !esActividad && !esRestaurante;

    const Color verdeKultux = Color(0xFFA8D63F);
    const Color fondoCard = Color(0xFFF6F4F1);
    const Color colorTexto = Color(0xFF1F1F1F);

    String getImagenActual() {
      final lista = widget.imagenesLista;
      if (lista.isEmpty) return 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg';
      return lista[_indiceActual.clamp(0, lista.length - 1)];
    }

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
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.titulo,
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
                          border: Border.all(color: verdeKultux, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            getImagenActual(),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported_outlined, size: 34, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        child: _botonFlecha(
                          icon: Icons.chevron_left,
                          color: verdeKultux,
                          accion: () {
                            setState(() {
                              final len = widget.imagenesLista.length;
                              _indiceActual = (_indiceActual - 1 + len) % len;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        right: 6,
                        child: _botonFlecha(
                          icon: Icons.chevron_right,
                          color: verdeKultux,
                          accion: () {
                            setState(() {
                              final len = widget.imagenesLista.length;
                              _indiceActual = (_indiceActual + 1) % len;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── BLOQUE HORARIO RESTAURANTE ──
                  if (esRestaurante) _bloqueHorario(widget.horario!, widget.abierto),

                  if (esActividad)
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoConIcono(
                          icono: Icons.calendar_today_outlined,
                          texto: '${widget.fechaInicio ?? ''}${widget.fechaFin != null ? ' al ${widget.fechaFin}' : ''}',
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
                          texto: widget.localidad ?? '',
                        ),
                      ],
                    ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _infoConIcono(
                          icono: Icons.location_on_outlined,
                          texto: widget.localidad ?? '',
                          iconColor: verdeKultux,
                          negrita: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (esActividad) ...[
                        const Icon(Icons.person_add_alt_1_outlined, color: colorTexto, size: 24),
                        const SizedBox(width: 16),
                      ],
                      const Icon(Icons.bookmark_border, color: colorTexto, size: 24),
                      const SizedBox(width: 16),
                      const Icon(Icons.share_outlined, color: colorTexto, size: 24),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (widget.descripcion != null && widget.descripcion!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.descripcion!,
                  style: const TextStyle(fontSize: 16, height: 1.28, fontWeight: FontWeight.w600, color: colorTexto),
                ),
              ),

            if (widget.descripcion != null && widget.descripcion!.trim().isNotEmpty)
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
                      Text('Comentarios', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorTexto)),
                      SizedBox(height: 4),
                      Text(
                        '@Sandra : Comentario cualquiera sobre alguna duda del evento como por ejemplo si se devuelve el dinero en caso de cancelación, o si se puede llevar comida',
                        style: TextStyle(fontSize: 8.5, color: Colors.black54),
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
                      child: Text('Organizado por: Ayuntamiento de Mérida', style: TextStyle(fontSize: 15, color: colorTexto)),
                    ),

                  if (widget.telefonoEmpresa != null && widget.telefonoEmpresa!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 15, color: colorTexto),
                          children: [
                            const TextSpan(text: 'Teléfono: '),
                            TextSpan(
                              text: widget.telefonoEmpresa!,
                              style: const TextStyle(color: Color(0xFF6C79FF), decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (widget.correoCorporativo != null && widget.correoCorporativo!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 15, color: colorTexto),
                          children: [
                            const TextSpan(text: 'Correo electrónico: '),
                            TextSpan(
                              text: widget.correoCorporativo!,
                              style: const TextStyle(color: Color(0xFF6C79FF), decoration: TextDecoration.underline),
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
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  esActividad ? 'Comprar entradas' : 'Reservar',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.confirmation_number_outlined, size: 20, color: Colors.black),
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

  Widget _bloqueHorario(Horario horario, bool? abierto) {
    const colorTexto = Color(0xFF1F1F1F);
    final diasOrdenados = [...horario.dias]..sort();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: icono + días + badge abierto/cerrado
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: colorTexto),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: diasOrdenados.map((d) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8D63F).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA8D63F)),
                      ),
                      child: Text(
                        _diasNombre[d] ?? '$d',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorTexto),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              // Badge abierto / cerrado
              if (abierto != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: abierto ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    abierto ? 'Abierto' : 'Cerrado',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Franjas horarias
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18, color: colorTexto),
              const SizedBox(width: 6),
              Wrap(
                spacing: 8,
                children: horario.franjas.map((f) {
                  return Text(
                    '${f.inicio} - ${f.fin}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorTexto),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonFlecha({required IconData icon, required Color color, required VoidCallback accion}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: accion,
        icon: Icon(icon, color: Colors.black54, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        Icon(icono, size: 20, color: iconColor),
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