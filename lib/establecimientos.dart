import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/restauranteAPI.dart';
import 'package:kultux/api/alojamientoAPI.dart';
import 'package:kultux/componentes/tarjetas.dart';
import 'package:kultux/core/utils/estado_ui.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/estados_widgets.dart';
import 'package:kultux/componentes/modal_alerta.dart';
class EstablecimientosPage extends StatefulWidget {


  final Function(dynamic objetoDetalle) onDetalleSeleccionado;

  const EstablecimientosPage({
    super.key,
    required this.onDetalleSeleccionado,
  });

  @override
  State<EstablecimientosPage> createState() => _EstablecimientosPageState();
}

class _EstablecimientosPageState extends State<EstablecimientosPage> {

  static const _verde = Color(0xFFA6E246);
  static const _fondoPagina = Color(0xFFF1EFE9);
  static const _fondoCard = Color(0xFFF8F7F4);
  static const _texto = Color(0xFF1A1A1A);
  static const _textoSuave = Color(0xFF6B6B6B);
  static const _borde = Color(0xFFE0DDD6);

  List<Restaurante> _restaurantes = [];
  List<Alojamiento> _alojamientos = [];
  EstadoUi _estadoResumen = EstadoUi.cargando;
  String _mensajeErrorResumen = '';


  List<Restaurante> _todosRestaurantes = [];
  EstadoUi _estadoRestaurantes = EstadoUi.cargando;
  String _mensajeErrorRestaurantes = '';


  List<Alojamiento> _todosAlojamientos = [];
  EstadoUi _estadoAlojamientos = EstadoUi.cargando;
  String _mensajeErrorAlojamientos = '';

  bool _mostrandoListadoRestaurantes = false;
  bool _mostrandoListadoAlojamientos = false;


  bool _restaurantesCargados = false;
  bool _alojamientosCargados = false;

  final Map<String, String> iconosAlojamiento = {
    "HOTEL": "assets/iconos/hotel.svg",
    "HOSTAL": "assets/iconos/hostal.svg",
    "APARTAMENTO_TURISTICO": "assets/iconos/apartamento.svg",
    "CASA_RURAL": "assets/iconos/casa_rural.svg",
    "PENSION": "assets/iconos/hostal.svg",
    "CAMPING": "assets/iconos/casa_rural.svg",
    "ALBERGUE": "assets/iconos/casa_rural.svg",
    "PARADOR": "assets/iconos/casa_rural.svg",
    "RESORT": "assets/iconos/hotel.svg",
    "BALNEARIO": "assets/iconos/hotel.svg",
    "APARTAHOTEL": "assets/iconos/hostal.svg",
    "BUNGALOW": "assets/iconos/hostal.svg",
    "FINCA": "assets/iconos/casa_rural.svg",
  };

  final Map<String, String> iconosRestaurante = {
    "TRADICIONAL": "assets/iconos/restaurantes.svg",
    "EXTREMEÑA": "assets/iconos/restaurantes.svg",
    "INTERNACIONAL": "assets/iconos/restaurantes.svg",
    "ESPAÑOLA": "assets/iconos/restaurantes.svg",
    "ALTA_COCINA": "assets/iconos/restaurantes.svg",
    "ASADORES_Y_PARRILLAS": "assets/iconos/restaurantes.svg",
    "MARISQUERIAS": "assets/iconos/restaurantes.svg",
    "ITALIANO": "assets/iconos/restaurantes.svg",
    "MEXICANO": "assets/iconos/restaurantes.svg",
    "ASIATICO": "assets/iconos/restaurantes.svg",
    "VEGETARIANO": "assets/iconos/restaurantes.svg",
    "VEGANO": "assets/iconos/restaurantes.svg",
    "TAPAS": "assets/iconos/cerveceria.svg",
    "CAFETERIA": "assets/iconos/cafeteria.svg",
    "HAMBURGUESERIA": "assets/iconos/restaurantes.svg",
    "PIZZERIA": "assets/iconos/restaurantes.svg",
    "COPAS": "assets/iconos/copas.svg",
  };

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() => _estadoResumen = EstadoUi.cargando);
    try {
      final results = await Future.wait([
        RestauranteApiService.obtenerRestauranteDestacados(),
        AlojamientoApiService.obtenerAlojamientoDestacados(),
      ]);
      setState(() {
        _restaurantes = results[0] as List<Restaurante>;
        _alojamientos = results[1] as List<Alojamiento>;
        _estadoResumen = (_restaurantes.isEmpty && _alojamientos.isEmpty)
            ? EstadoUi.vacio
            : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoResumen = EstadoUi.sinConexion;
        _mensajeErrorResumen = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoResumen = uiError.estado;
        _mensajeErrorResumen = uiError.mensaje;
      });
    } catch (e, stack) {
      print('ERROR RESUMEN: $e\nSTACK: $stack');
      setState(() {
        _estadoResumen = EstadoUi.error;
        _mensajeErrorResumen = 'Error inesperado';
      });
    }
  }

  Future<void> _cargarTodosRestaurantes() async {
    if (_restaurantesCargados) return;
    setState(() => _estadoRestaurantes = EstadoUi.cargando);
    try {
      final lista = await RestauranteApiService.obtenerRestauranteDestacados();
      setState(() {
        _todosRestaurantes = lista;
        _restaurantesCargados = true;
        _estadoRestaurantes =
        lista.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoRestaurantes = EstadoUi.sinConexion;
        _mensajeErrorRestaurantes = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoRestaurantes = uiError.estado;
        _mensajeErrorRestaurantes = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoRestaurantes = EstadoUi.error;
        _mensajeErrorRestaurantes = 'Error inesperado';
      });
    }
  }

  Future<void> _cargarTodosAlojamientos() async {
    if (_alojamientosCargados) return;
    setState(() => _estadoAlojamientos = EstadoUi.cargando);
    try {
      final lista = await AlojamientoApiService.obtenerAlojamientoDestacados();
      setState(() {
        _todosAlojamientos = lista;
        _alojamientosCargados = true;
        _estadoAlojamientos =
        lista.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoAlojamientos = EstadoUi.sinConexion;
        _mensajeErrorAlojamientos = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoAlojamientos = uiError.estado;
        _mensajeErrorAlojamientos = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoAlojamientos = EstadoUi.error;
        _mensajeErrorAlojamientos = 'Error inesperado';
      });
    }
  }

  void _abrirListadoRestaurantes() {
    setState(() {
      _mostrandoListadoRestaurantes = true;
      _mostrandoListadoAlojamientos = false;
    });
    _cargarTodosRestaurantes();
  }

  void _abrirListadoAlojamientos() {
    setState(() {
      _mostrandoListadoAlojamientos = true;
      _mostrandoListadoRestaurantes = false;
    });
    _cargarTodosAlojamientos();
  }

  void _volverResumen() {
    setState(() {
      _mostrandoListadoRestaurantes = false;
      _mostrandoListadoAlojamientos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrandoListadoRestaurantes) return _buildListadoRestaurantes();
    if (_mostrandoListadoAlojamientos) return _buildListadoAlojamientos();

    return switch (_estadoResumen) {
      EstadoUi.cargando => const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 166, 226, 70),
        ),
      ),
      EstadoUi.vacio => estadoVacio(),
      EstadoUi.sinConexion => estadoError(
        icon: Icons.wifi_off,
        mensaje: _mensajeErrorResumen,
        onRetry: _cargarResumen,
      ),
      EstadoUi.error => estadoError(
        icon: Icons.error_outline,
        mensaje: _mensajeErrorResumen,
        onRetry: _cargarResumen,
      ),
      EstadoUi.contenido => _buildResumen(),
    };
  }

  Widget _buildResumen() {
    return Container(
      color: _fondoPagina,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, right: 0,
                    child: Opacity(
                      opacity: 0.12,
                      child: Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: _verde,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descubre',
                          style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0))),
                      const SizedBox(height: 2),
                      const Text('Establecimientos',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Container(
                        width: 36, height: 2,
                        decoration: BoxDecoration(
                          color: _verde, borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                children: [
                  _tarjetaEstablecimiento(
                    tituloBloque: 'Restaurantes destacados',
                    items: _restaurantes.map((r) => _ItemEstablecimiento(
                      titulo: r.nombre,
                      imagenUrl: r.imagenPrincipal!,
                      onTap: () async {
                        try {
                          final detalle = await RestauranteApiService.restauranteDetalle(r.id);
                          widget.onDetalleSeleccionado(detalle);
                        } catch (e) {
                          if (!context.mounted) return;
                          Alerta.show(context,
                              mensaje: 'No se ha podido cargar correctamente el restaurante.',
                              tipo: TipoAviso.error);
                        }
                      },
                    )).toList(),
                    onVerMas: _abrirListadoRestaurantes,
                  ),
                  const SizedBox(height: 16),
                  _tarjetaEstablecimiento(
                    tituloBloque: 'Alojamientos destacados',
                    items: _alojamientos.map((a) => _ItemEstablecimiento(
                      titulo: a.nombre,
                      imagenUrl: a.imagenPrincipal!,
                      onTap: () async {
                        try {
                          final detalle = await AlojamientoApiService.obtenerAlojamientoDetalle(a.id);
                          widget.onDetalleSeleccionado(detalle);
                        } catch (e) {
                          if (!context.mounted) return;
                          Alerta.show(context,mensaje:'No se ha podido cargar correctamente el restaurante.', tipo: TipoAviso.error );
                        }
                      },
                    )).toList(),
                    onVerMas: _abrirListadoAlojamientos,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildListadoRestaurantes() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0, right: 0,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _verde,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _volverResumen,
                      icon: const Icon(Icons.arrow_back,color: Colors.white,),
                    ),
                  ),
                  const Text('Restaurantes',
                      style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0))),
                  const SizedBox(height: 2),
                  const Text('Destacados',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    width: 36, height: 2,
                    decoration: BoxDecoration(
                      color: _verde, borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Restaurantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: switch (_estadoRestaurantes) {
            EstadoUi.cargando => const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 166, 226, 70),
              ),
            ),
            EstadoUi.vacio => estadoVacio(),
            EstadoUi.sinConexion => estadoError(
              icon: Icons.wifi_off,
              mensaje: _mensajeErrorRestaurantes,
              onRetry: () {
                _restaurantesCargados = false;
                _cargarTodosRestaurantes();
              },
            ),
            EstadoUi.error => estadoError(
              icon: Icons.error_outline,
              mensaje: _mensajeErrorRestaurantes,
              onRetry: () {
                _restaurantesCargados = false;
                _cargarTodosRestaurantes();
              },
            ),
            EstadoUi.contenido => ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _todosRestaurantes.length,
              itemBuilder: (context, index) {
                final r = _todosRestaurantes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Tarjeta.restaurante(
                    titulo: r.nombre,
                    imagenUrl: r.imagenPrincipal!,
                    textoEtiqueta: r.categoriaRestaurante[0].toUpperCase() +
                        r.categoriaRestaurante.substring(1).toLowerCase(),
                    iconoEtiqueta:
                    iconosRestaurante[r.categoriaRestaurante] ??
                        'assets/iconos/restaurantes.svg',
                    onTap: () async {
                      try {
                        final detalle = await RestauranteApiService
                            .restauranteDetalle(r.id);
                        widget.onDetalleSeleccionado(detalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        Alerta.show(context,mensaje:'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.', tipo: TipoAviso.error );
                      }
                    },
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }

  Widget _buildListadoAlojamientos() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0, right: 0,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: _verde,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _volverResumen,
                      icon: const Icon(Icons.arrow_back,color: Colors.white,),
                    ),
                  ),
                  const Text('Alojamientos',
                      style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0))),
                  const SizedBox(height: 2),
                  const Text('Destacados',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    width: 36, height: 2,
                    decoration: BoxDecoration(
                      color: _verde, borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_estadoAlojamientos) {
            EstadoUi.cargando => const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 166, 226, 70),
              ),
            ),
            EstadoUi.vacio => estadoVacio(),
            EstadoUi.sinConexion => estadoError(
              icon: Icons.wifi_off,
              mensaje: _mensajeErrorAlojamientos,
              onRetry: () {
                _alojamientosCargados = false;
                _cargarTodosAlojamientos();
              },
            ),
            EstadoUi.error => estadoError(
              icon: Icons.error_outline,
              mensaje: _mensajeErrorAlojamientos,
              onRetry: () {
                _alojamientosCargados = false;
                _cargarTodosAlojamientos();
              },
            ),
            EstadoUi.contenido => ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _todosAlojamientos.length,
              itemBuilder: (context, index) {
                final a = _todosAlojamientos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Tarjeta.alojamiento(
                    titulo: a.nombre,
                    imagenUrl: a.imagenPrincipal!,
                    textoEtiqueta: a.categoriaAlojamiento[0].toUpperCase() +
                        a.categoriaAlojamiento.substring(1).toLowerCase(),
                    iconoEtiqueta:
                    iconosAlojamiento[a.categoriaAlojamiento] ??
                        'assets/iconos/casa_rural.svg',
                    onTap: () async {
                      try {
                        final detalle = await AlojamientoApiService
                            .obtenerAlojamientoDetalle(a.id);
                        widget.onDetalleSeleccionado(detalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        Alerta.show(context,mensaje:'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.', tipo: TipoAviso.error );
                      }
                    },
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }

  Widget _tarjetaEstablecimiento({
    required String tituloBloque,
    required List<_ItemEstablecimiento> items,
    required VoidCallback onVerMas,
  }) {
    final filas = <Widget>[];
    for (int i = 0; i < items.length; i += 3) {
      final filaItems = items.skip(i).take(3).toList();
      filas.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(filaItems.length * 2 - 1, (index) {
          if (index.isOdd) return const SizedBox(width: 10);
          return Expanded(
              child: _miniTarjetaEstablecimiento(item: filaItems[index ~/ 2]));
        }),
      ));
      if (i + 3 < items.length) filas.add(const SizedBox(height: 12));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tituloBloque,
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _texto,
                ),
              ),
              GestureDetector(
                onTap: onVerMas,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _verde,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ver más',
                      style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _texto)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filas,
        ],
      ),
    );
  }

  Widget _miniTarjetaEstablecimiento({required _ItemEstablecimiento item}) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _verde, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8E5DF),
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: _textoSuave),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: _texto,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ── Headers de listados (_buildListadoRestaurantes / _buildListadoAlojamientos)
// Reemplazar el Align+IconButton+Text existente por este bloque en ambos:
  Widget _headerListado(String titulo, VoidCallback onVolver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onVolver,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Establecimientos',
                  style: TextStyle(fontSize: 11, color: Color(0xFFb0b0b0))),
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}


Widget imagenEstablecimiento(String? url) {
  if (url == null || url.trim().isEmpty) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 36,
      ),
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    placeholder: (context, _) => Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 166, 226, 70),
        ),
      ),
    ),
    errorWidget: (context, _, __) => Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 36,
      ),
    ),
  );
}

Widget _headerListado(String titulo, VoidCallback onVolver) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: onVolver,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Establecimientos',
                style: TextStyle(fontSize: 11, color: Color(0xFFb0b0b0))),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ],
    ),
  );
}


class _ItemEstablecimiento {
  final String titulo;
  final String imagenUrl;
  final VoidCallback? onTap;

  const _ItemEstablecimiento({
    required this.titulo,
    required this.imagenUrl,
    this.onTap,
  });
}