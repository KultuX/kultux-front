import 'package:flutter/material.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/imagen.dart';
import 'package:kultux/models/franja.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/API/interaccionesAPI.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kultux/componentes/modal_alerta.dart';


class _KTheme {
  static const verde       = Color(0xFFA8D63F);
  static const fondoCard   = Color(0xFFF8F7F4);
  static const fondoPagina = Color(0xFFF1EFE9);
  static const texto       = Color(0xFF1A1A1A);
  static const textoSuave  = Color(0xFF6B6B6B);
  static const borde       = Color(0xFFE0DDD6);
  static const verdeOscuro = Color(0xFF2E7D32);
  static const rojo        = Color(0xFFC62828);

  static const sombra = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4,  offset: Offset(0, 1)),
  ];

  static const sombraLeve = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

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
  final Map<String, List<Franja>>? horario;
  final bool? abierto;
  final String? urlCompraReserva;
  final String? urlWeb;
  final String? direccion;
  final int? idActividad;
  final int? idRestaurante;
  final int? idAlojamiento;

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
    this.urlCompraReserva,
    this.urlWeb,
    this.direccion,
    this.idActividad,
    this.idRestaurante,
    this.idAlojamiento,
  });

  List<String> get imagenesLista {
    if (imagenes == null || imagenes!.isEmpty) {
      return [
        'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg'
      ];
    }
    final ordenadas = [...imagenes!];
    ordenadas.sort((a, b) {
      if (a.esPortada == b.esPortada) return 0;
      return a.esPortada ? -1 : 1;
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
        urlCompraReserva: objeto.urlCompra,
        urlWeb: objeto.urlWeb,
        direccion: objeto.direccion,
        idActividad: objeto.id,
      );
    }
    if (objeto is Alojamiento) {
      return Detalle._(
        idAlojamiento: objeto.id,
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
        imagenes: objeto.imagenes,
        urlCompraReserva: objeto.urlReserva,
        urlWeb: objeto.urlWeb,
        descripcion: objeto.descripcion,
        direccion: objeto.direccion,
      );
    }
    if (objeto is Restaurante) {
      return Detalle._(
        idRestaurante: objeto.id,
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        descripcion: objeto.descripcion,
        telefonoEmpresa: objeto.telefonoEmpresa ?? '',
        correoCorporativo: objeto.correoCorporativo ?? '',
        horario: objeto.horario,
        imagenes: objeto.imagenes,
        abierto: objeto.abierto,
        urlCompraReserva: objeto.urlReserva,
        urlWeb: objeto.urlWeb,
        direccion: objeto.direccion,
      );
    }
    throw Exception('Tipo de objeto no soportado');
  }

  @override
  State<Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<Detalle> {
  int _indiceActual = 0;

  bool get _tieneUrlReserva =>
      widget.urlCompraReserva != null && widget.urlCompraReserva!.trim().isNotEmpty;

  bool get _tieneUrlWeb =>
      widget.urlWeb != null && widget.urlWeb!.trim().isNotEmpty;

  @override
  void didUpdateWidget(covariant Detalle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _indiceActual = 0;
  }

  String _normalizarUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://') ? url : 'https://$url';

  String _getImagenActual() {
    final lista = widget.imagenesLista;
    if (lista.isEmpty) return '';
    return lista[_indiceActual.clamp(0, lista.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final bool esActividad   = widget.idActividad != null;
    final bool esRestaurante = widget.idRestaurante != null;
    final bool esAlojamiento = widget.idAlojamiento != null;

    return Container(
      color: _KTheme.fondoPagina,
      child: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TarjetaPrincipal(
                titulo:          widget.titulo,
                localidad:       widget.localidad,
                esActividad:     esActividad,
                esRestaurante:   esRestaurante,
                esAlojamiento:   esAlojamiento,
                fechaInicio:     widget.fechaInicio,
                fechaFin:        widget.fechaFin,
                imagenesLista:   widget.imagenesLista,
                indiceActual:    _indiceActual,
                getImagenActual: _getImagenActual,
                idActividad:     widget.idActividad,
                idRestaurante:   widget.idRestaurante,
                idAlojamiento:   widget.idAlojamiento,
                idUsuario:       Usuario.usuarioActual?.id,
                onPrev: () => setState(() {
                  final len = widget.imagenesLista.length;
                  _indiceActual = (_indiceActual - 1 + len) % len;
                }),
                onNext: () => setState(() {
                  _indiceActual = (_indiceActual + 1) % widget.imagenesLista.length;
                }),
              ),

              const SizedBox(height: 16),

              if (widget.descripcion != null && widget.descripcion!.trim().isNotEmpty) ...[
                _SeccionCard(
                  child: Text(
                    widget.descripcion!,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: _KTheme.texto,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (esRestaurante && widget.horario != null) ...[
                _SeccionCard(
                  child: _BloqueHorario(
                    horario: widget.horario!,
                    abierto: widget.abierto,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _SeccionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (esActividad)
                      _FilaInfo(
                        icono: Icons.store_outlined,
                        label: 'Organizado por',
                        valor: 'Ayuntamiento de Mérida',
                      ),

                    if (_tieneUrlWeb)
                      _FilaInfo(
                        icono: Icons.language_outlined,
                        label: 'Web oficial',
                        valor: widget.urlWeb!,
                        esEnlace: true,
                        onTap: () async {
                          final uri = Uri.parse(_normalizarUrl(widget.urlWeb!));
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),

                    if (widget.telefonoEmpresa != null &&
                        widget.telefonoEmpresa!.trim().isNotEmpty)
                      _FilaInfo(
                        icono: Icons.phone_outlined,
                        label: 'Teléfono',
                        valor: widget.telefonoEmpresa!,
                        esEnlace: true,
                        onTap: () async {
                          final uri = Uri.parse('tel:${widget.telefonoEmpresa}');
                          await launchUrl(uri);
                        },
                      ),

                    if (widget.correoCorporativo != null &&
                        widget.correoCorporativo!.trim().isNotEmpty)
                      _FilaInfo(
                        icono: Icons.mail_outline,
                        label: 'Correo',
                        valor: widget.correoCorporativo!,
                        esEnlace: true,
                        onTap: () async {
                          final uri = Uri.parse('mailto:${widget.correoCorporativo}');
                          await launchUrl(uri);
                        },
                      ),

                    const SizedBox(height: 16),

                    _BotonCTA(
                      activo: _tieneUrlReserva,
                      esActividad: esActividad,
                      onTap: _tieneUrlReserva
                          ? () async {
                        final uri = Uri.parse(_normalizarUrl(widget.urlCompraReserva!));
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaPrincipal extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final bool esActividad;
  final bool esRestaurante;
  final bool esAlojamiento;
  final String? fechaInicio;
  final String? fechaFin;
  final List<String> imagenesLista;
  final int indiceActual;
  final String Function() getImagenActual;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final int? idActividad;
  final int? idRestaurante;
  final int? idAlojamiento;
  final int? idUsuario;

  const _TarjetaPrincipal({
    required this.titulo,
    required this.localidad,
    required this.esActividad,
    required this.esRestaurante,
    required this.esAlojamiento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.imagenesLista,
    required this.indiceActual,
    required this.getImagenActual,
    required this.onPrev,
    required this.onNext,
    this.idActividad,
    this.idRestaurante,
    this.idAlojamiento,
    this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final tieneVarias = imagenesLista.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: _KTheme.fondoCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _KTheme.borde),
        boxShadow: _KTheme.sombra,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    getImagenActual(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8E5DF),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 40, color: _KTheme.textoSuave),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0, right: 0, bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x66000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),

              if (tieneVarias) ...[
                Positioned(
                  left: 10, top: 0, bottom: 0,
                  child: Center(child: _BotonFlecha(icono: Icons.chevron_left, onTap: onPrev)),
                ),
                Positioned(
                  right: 10, top: 0, bottom: 0,
                  child: Center(child: _BotonFlecha(icono: Icons.chevron_right, onTap: onNext)),
                ),
              ],

              if (tieneVarias)
                Positioned(
                  bottom: 10, left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imagenesLista.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == indiceActual ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == indiceActual
                              ? _KTheme.verde
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 10, right: 10,
                child: Row(
                  children: [
                    _BotonGuardar(
                      esActividad: esActividad,
                      esRestaurante: esRestaurante,
                      esAlojamiento: esAlojamiento,
                      idActividad: idActividad,
                      idRestaurante: idRestaurante,
                      idAlojamiento: idAlojamiento,
                      idUsuario: idUsuario,
                    ),
                    const SizedBox(width: 6),
                    _BotonAccion(icono: Icons.share_outlined),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _KTheme.texto,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: _KTheme.verde),
                    const SizedBox(width: 4),
                    Text(
                      localidad ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _KTheme.textoSuave,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (esActividad && (fechaInicio != null || fechaFin != null)) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _KTheme.verde.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _KTheme.verde.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: _KTheme.verde),
                        const SizedBox(width: 6),
                        Text(
                          '${fechaInicio ?? ''}${fechaFin != null ? ' — $fechaFin' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _KTheme.texto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _BotonGuardar extends StatefulWidget {
  final bool esActividad;
  final bool esRestaurante;
  final bool esAlojamiento;
  final int? idActividad;
  final int? idRestaurante;
  final int? idAlojamiento;
  final int? idUsuario;

  const _BotonGuardar({
    required this.esActividad,
    this.esRestaurante = false,
    this.esAlojamiento = false,
    this.idActividad,
    this.idRestaurante,
    this.idAlojamiento,
    this.idUsuario,
  });

  @override
  State<_BotonGuardar> createState() => _BotonGuardarState();
}

class _BotonGuardarState extends State<_BotonGuardar> {
  bool? _guardado;
  bool _cargando = false;

  bool get _logueado => widget.idUsuario != null;

  bool get _soportado =>
      (widget.esActividad && widget.idActividad != null) ||
          (widget.esRestaurante && widget.idRestaurante != null) ||
          (widget.esAlojamiento && widget.idAlojamiento != null);

  @override
  void initState() {
    super.initState();
    if (_logueado && _soportado) _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    try {
      late bool guardado;
      if (widget.esActividad) {
        final r = await InteraccionesApiService.estadoGuardadoActividad(
            idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      } else if (widget.esRestaurante) {
        final r = await InteraccionesApiService.estadoGuardadoRestaurante(
            idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      } else {
        final r = await InteraccionesApiService.estadoGuardadoAlojamiento(
            idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      }
      if (mounted) setState(() => _guardado = guardado);
    } catch (_) {
      if (mounted) setState(() => _guardado = false);
    }
  }

  Future<void> _toggle(BuildContext context) async {
    if (_cargando || !_soportado) return;
    if (!_logueado) {
      Alerta.show(context,mensaje: 'Inicia sesión o registrate para guardar');
      return;
    }
    setState(() => _cargando = true);
    try {
      if (_guardado == true) {
        if (widget.esActividad) {
          await InteraccionesApiService.quitarActividad(
              idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        } else if (widget.esRestaurante) {
          await InteraccionesApiService.quitarRestaurante(
              idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        } else {
          await InteraccionesApiService.quitarAlojamiento(
              idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        }
        if (mounted) setState(() => _guardado = false);
      } else {
        if (widget.esActividad) {
          await InteraccionesApiService.guardarActividad(
              idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        } else if (widget.esRestaurante) {
          await InteraccionesApiService.guardarRestaurante(
              idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        } else {
          await InteraccionesApiService.guardarAlojamiento(
              idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        }
        if (mounted) setState(() => _guardado = true);
      }
    } catch (_) {
      if (mounted) {
        Alerta.show(context,mensaje: 'Error al guardar. Inténtalo de nuevo.', tipo: TipoAviso.error);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_soportado) return const SizedBox.shrink();

    final IconData icono;
    final Color color;

    if (!_logueado) {
      icono = Icons.bookmark_border; color = Colors.white70;
    } else if (_guardado == null || _cargando) {
      icono = Icons.bookmark_border; color = Colors.white54;
    } else if (_guardado == true) {
      icono = Icons.bookmark; color = _KTheme.verde;
    } else {
      icono = Icons.bookmark_border; color = Colors.white;
    }

    return GestureDetector(
      onTap: () => _toggle(context),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _cargando
            ? const Padding(
          padding: EdgeInsets.all(9),
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Icon(icono, color: color, size: 18),
      ),
    );
  }
}


class _SeccionCard extends StatelessWidget {
  final Widget child;
  const _SeccionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _KTheme.fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _KTheme.borde),
        boxShadow: _KTheme.sombraLeve,
      ),
      child: child,
    );
  }
}


class _BloqueHorario extends StatelessWidget {
  final Map<String, List<Franja>> horario;
  final bool? abierto;

  const _BloqueHorario({required this.horario, this.abierto});

  static const _diasOrden  = [1, 2, 3, 4, 5, 6, 7];
  static const _diasNombre = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule_outlined, size: 16, color: _KTheme.verde),
            const SizedBox(width: 6),
            const Text(
              'Horario',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _KTheme.texto),
            ),
            const Spacer(),
            if (abierto != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: abierto!
                      ? _KTheme.verdeOscuro.withOpacity(0.12)
                      : _KTheme.rojo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: abierto! ? _KTheme.verdeOscuro : _KTheme.rojo,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  abierto! ? '● Abierto' : '● Cerrado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: abierto! ? _KTheme.verdeOscuro : _KTheme.rojo,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(color: _KTheme.borde, height: 1),
        const SizedBox(height: 12),

        ..._diasOrden.map((dia) {
          final franjas     = horario['$dia'] ?? [];
          final estaCerrado = franjas.isEmpty;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    _diasNombre[dia]!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: estaCerrado ? _KTheme.textoSuave : _KTheme.texto,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 2,
                  height: estaCerrado ? 22 : (franjas.length * 26).toDouble(),
                  decoration: BoxDecoration(
                    color: estaCerrado ? _KTheme.borde : _KTheme.verde.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: estaCerrado
                      ? const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Cerrado',
                      style: TextStyle(
                        fontSize: 13,
                        color: _KTheme.textoSuave,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: franjas.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _KTheme.verde.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _KTheme.verde.withOpacity(0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${f.inicio} – ${f.fin}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _KTheme.texto,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}


class _FilaInfo extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final bool esEnlace;
  final VoidCallback? onTap;

  const _FilaInfo({
    required this.icono,
    required this.label,
    required this.valor,
    this.esEnlace = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _KTheme.verde.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, size: 16, color: _KTheme.verde),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _KTheme.textoSuave,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: esEnlace ? const Color(0xFF3B6FE8) : _KTheme.texto,
                      fontWeight: FontWeight.w500,
                      decoration: esEnlace ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (esEnlace)
              const Icon(Icons.open_in_new, size: 14, color: _KTheme.textoSuave),
          ],
        ),
      ),
    );
  }
}


class _BotonCTA extends StatelessWidget {
  final bool activo;
  final bool esActividad;
  final VoidCallback? onTap;

  const _BotonCTA({
    required this.activo,
    required this.esActividad,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Tooltip(
        message: activo ? '' : 'No hay enlace disponible',
        child: Opacity(
          opacity: activo ? 1.0 : 0.4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  color: _KTheme.verde,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: activo
                      ? const [
                    BoxShadow(
                      color: Color(0x40A8D63F),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        esActividad
                            ? Icons.confirmation_number_outlined
                            : Icons.hotel_outlined,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        esActividad ? 'Comprar entradas' : 'Reservar ahora',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _BotonFlecha extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonFlecha({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: Colors.white, size: 24),
      ),
    );
  }
}


class _BotonAccion extends StatelessWidget {
  final IconData icono;
  const _BotonAccion({required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icono, color: Colors.white, size: 18),
    );
  }
}