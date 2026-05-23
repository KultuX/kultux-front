import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/restaurante_api.dart';
import 'package:kultux/api/alojamiento_api.dart';
import 'package:kultux/componentes/tarjeta_busqueda.dart';
import 'package:kultux/core/utils/estado_ui.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/estados_widgets.dart';
import 'package:kultux/componentes/modal_alerta.dart';
import 'package:kultux/api/establecimientos.dart';

import 'componentes/cabecera.dart';
import 'componentes/skeleton_tarjeta.dart';
import 'core/utils/iconos.dart';

class EstablecimientosPage extends StatefulWidget {
  final Function(dynamic objetoDetalle) onDetalleSeleccionado;

  const EstablecimientosPage({super.key, required this.onDetalleSeleccionado});

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

  int _pageRestaurantes = 0;
  bool _hayMasRestaurantes = true;
  bool _cargandoMasRestaurantes = false;
  final ScrollController _scrollRestaurantes = ScrollController();

  int _pageAlojamientos = 0;
  bool _hayMasAlojamientos = true;
  bool _cargandoMasAlojamientos = false;
  final ScrollController _scrollAlojamientos = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarResumen();
    _scrollRestaurantes.addListener(() {
      if (_scrollRestaurantes.position.pixels >=
          _scrollRestaurantes.position.maxScrollExtent - 200) {
        _cargarMasRestaurantes();
      }
    });
    _scrollAlojamientos.addListener(() {
      if (_scrollAlojamientos.position.pixels >=
          _scrollAlojamientos.position.maxScrollExtent - 200) {
        _cargarMasAlojamientos();
      }
    });
  }

  @override
  void dispose() {
    _scrollRestaurantes.dispose();
    _scrollAlojamientos.dispose();
    super.dispose();
  }

  Future<void> _cargarResumen() async {
    setState(() => _estadoResumen = EstadoUi.cargando);
    try {
      final result =
          await EstablecimientosApiService.obtenerEstablecimientosDestacados();
      setState(() {
        _restaurantes = result['restaurantes'] as List<Restaurante>;
        _alojamientos = result['alojamientos'] as List<Alojamiento>;
        _estadoResumen = EstadoUi.contenido;
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
      final pagina = await RestauranteApiService.obtenerRestauranteDestacados(
        page: 0,
      );
      print(pagina.toString());
      setState(() {
        _todosRestaurantes = pagina.contenido;
        _hayMasRestaurantes = pagina.numero + 1 < pagina.totalPaginas;
        _pageRestaurantes = 1;
        _restaurantesCargados = true;
        _estadoRestaurantes = pagina.contenido.isEmpty
            ? EstadoUi.vacio
            : EstadoUi.contenido;
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

  Future<void> _cargarMasRestaurantes() async {
    if (!_hayMasRestaurantes || _cargandoMasRestaurantes) return;
    setState(() => _cargandoMasRestaurantes = true);
    try {
      final pagina = await RestauranteApiService.obtenerRestauranteDestacados(
        page: _pageRestaurantes,
      );
      setState(() {
        _todosRestaurantes.addAll(pagina.contenido);
        _hayMasRestaurantes = pagina.numero + 1 < pagina.totalPaginas;
        _pageRestaurantes++;
      });
    } catch (_) {
    } finally {
      setState(() => _cargandoMasRestaurantes = false);
    }
  }

  Future<void> _cargarTodosAlojamientos() async {
    if (_alojamientosCargados) return;
    setState(() => _estadoAlojamientos = EstadoUi.cargando);
    try {
      final pagina = await AlojamientoApiService.obtenerAlojamientoDestacados(
        page: 0,
      );

      setState(() {
        _todosAlojamientos = pagina.contenido;
        _hayMasAlojamientos = pagina.numero + 1 < pagina.totalPaginas;
        _pageAlojamientos = 1;
        _alojamientosCargados = true;
        _estadoAlojamientos = pagina.contenido.isEmpty
            ? EstadoUi.vacio
            : EstadoUi.contenido;
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

  Future<void> _cargarMasAlojamientos() async {
    if (!_hayMasAlojamientos || _cargandoMasAlojamientos) return;
    setState(() => _cargandoMasAlojamientos = true);
    try {
      final pagina = await AlojamientoApiService.obtenerAlojamientoDestacados(
        page: _pageAlojamientos,
      );
      setState(() {
        _todosAlojamientos.addAll(pagina.contenido);
        _hayMasAlojamientos = pagina.numero + 1 < pagina.totalPaginas;
        _pageAlojamientos++;
      });
    } catch (_) {
    } finally {
      setState(() => _cargandoMasAlojamientos = false);
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _mostrandoListadoRestaurantes
          ? KeyedSubtree(
              key: const ValueKey('lista_restaurantes'),
              child: _buildListadoRestaurantes(),
            )
          : _mostrandoListadoAlojamientos
          ? KeyedSubtree(
              key: const ValueKey('lista_alojamientos'),
              child: _buildListadoAlojamientos(),
            )
          : KeyedSubtree(
              key: const ValueKey('resumen'),
              child: Column(
                children: [
                  CabeceraPagina(
                    titulo: 'Descubre',
                    subtitulo: 'Establecimientos',
                  ),
                  Expanded(
                    child: switch (_estadoResumen) {
                      EstadoUi.cargando => _buildResumen(),
                      EstadoUi.error => estadoError(
                        icon: Icons.error_outline,
                        mensaje: _mensajeErrorResumen,
                        onRetry: _cargarResumen,
                      ),
                      EstadoUi.sinConexion => estadoError(
                        icon: Icons.wifi_off,
                        mensaje: _mensajeErrorResumen,
                        onRetry: _cargarResumen,
                      ),
                      _ => _buildResumen(),
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResumen() {
    return Container(
      color: _fondoPagina,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                children: [
                  _tarjetaEstablecimiento(
                    tituloBloque: 'Restaurantes destacados',
                    items: _restaurantes
                        .map(
                          (r) => _ItemEstablecimiento(
                            titulo: r.nombre,
                            imagenUrl: r.imagenPrincipal!,
                            onTap: () async {
                              try {
                                final detalle =
                                    await RestauranteApiService.restauranteDetalle(
                                      r.id,
                                    );
                                widget.onDetalleSeleccionado(detalle);
                              } catch (e) {
                                if (!context.mounted) return;
                                Alerta.show(
                                  context,
                                  mensaje:
                                      'No se ha podido cargar correctamente el restaurante.',
                                  tipo: TipoAviso.error,
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
                    onVerMas: _abrirListadoRestaurantes,
                  ),
                  const SizedBox(height: 16),
                  _tarjetaEstablecimiento(
                    tituloBloque: 'Alojamientos destacados',
                    items: _alojamientos
                        .map(
                          (a) => _ItemEstablecimiento(
                            titulo: a.nombre,
                            imagenUrl: a.imagenPrincipal!,
                            onTap: () async {
                              try {
                                final detalle =
                                    await AlojamientoApiService.obtenerAlojamientoDetalle(
                                      a.id,
                                    );
                                widget.onDetalleSeleccionado(detalle);
                              } catch (e) {
                                if (!context.mounted) return;
                                Alerta.show(
                                  context,
                                  mensaje:
                                      'No se ha podido cargar correctamente el restaurante.',
                                  tipo: TipoAviso.error,
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
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
        CabeceraPagina(
          titulo: 'Restaurantes destacados',
          subtitulo: 'Descubre',
          onVolver: _volverResumen,
        ),
        Expanded(
          child: switch (_estadoRestaurantes) {
            EstadoUi.cargando => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonTarjetaBusqueda(),
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
              controller: _scrollRestaurantes,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _todosRestaurantes.length,
              itemBuilder: (context, index) {
                final r = _todosRestaurantes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TarjetaBusqueda.restaurante(
                    titulo: r.nombre,
                    imagenUrl: r.imagenPrincipal!,
                    textoEtiqueta:
                        r.categoriaRestaurante[0].toUpperCase() +
                        r.categoriaRestaurante.substring(1).toLowerCase(),
                    iconoEtiqueta: Iconos.getIconoRestaurante(
                      r.categoriaRestaurante,
                    ),
                    onTap: () async {
                      try {
                        final detalle =
                            await RestauranteApiService.restauranteDetalle(
                              r.id,
                            );
                        widget.onDetalleSeleccionado(detalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        Alerta.show(
                          context,
                          mensaje:
                              'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.',
                          tipo: TipoAviso.error,
                        );
                      }
                    },
                    horario: r.horario!,
                    abierto: r.abierto!,
                    localidad: r.localidad,
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
        CabeceraPagina(
          titulo: 'Alojamientos destacados',
          subtitulo: 'Descubre',
          onVolver: _volverResumen,
        ),
        Expanded(
          child: switch (_estadoAlojamientos) {
            EstadoUi.cargando => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonTarjetaBusqueda(),
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
              controller: _scrollAlojamientos,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _todosAlojamientos.length,
              itemBuilder: (context, index) {
                final a = _todosAlojamientos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TarjetaBusqueda.alojamiento(
                    titulo: a.nombre,
                    imagenUrl: a.imagenPrincipal!,
                    textoEtiqueta:
                        a.categoriaAlojamiento[0].toUpperCase() +
                        a.categoriaAlojamiento.substring(1).toLowerCase(),
                    iconoEtiqueta: Iconos.getIconoAlojamiento(
                      a.categoriaAlojamiento,
                    ),
                    onTap: () async {
                      try {
                        final detalle =
                            await AlojamientoApiService.obtenerAlojamientoDetalle(
                              a.id,
                            );
                        widget.onDetalleSeleccionado(detalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        Alerta.show(
                          context,
                          mensaje:
                              'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.',
                          tipo: TipoAviso.error,
                        );
                      }
                    },
                    localidad: a.localidad,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _verde,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _texto,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_estadoResumen == EstadoUi.cargando)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, __) => const SkeletonMiniTarjeta(),
            )
          else if (items.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text('No hay destacados disponibles ...'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) =>
                  _miniTarjetaEstablecimiento(item: items[index]),
            ),
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
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imagenEstablecimiento(item.imagenUrl),
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
      memCacheWidth: 400,
      memCacheHeight: 400,
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

class SkeletonMiniTarjeta extends StatefulWidget {
  const SkeletonMiniTarjeta({super.key});

  @override
  State<SkeletonMiniTarjeta> createState() => _SkeletonMiniTarjetaState();
}

class _SkeletonMiniTarjetaState extends State<SkeletonMiniTarjeta>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmer({double? width, double? height, BorderRadius? radius}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            stops: const [0.0, 0.5, 1.0],
            colors: const [Color(0xFFE8E8E8), Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            transform: SlideGradient(_anim.value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: _shimmer(radius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 5),
        _shimmer(width: double.infinity, height: 20, radius: BorderRadius.circular(6)),
      ],
    );
  }
}
