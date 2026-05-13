import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kultux/api/actividadesAPI.dart';
import 'package:kultux/api/alojamientoAPI.dart';
import 'package:kultux/api/restauranteAPI.dart';
import 'package:kultux/api/interaccionesAPI.dart';
import 'package:kultux/core/utils/estado_ui.dart';
import 'package:kultux/core/utils/estados_widgets.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/componentes/tarjeta_guardados.dart';


const _verde = Color(0xFFA6E246);
const _fondoPagina = Color(0xFFF1EFE9);


enum GuardadosTab { actividades, restaurantes, alojamientos }

class GuardadosPage extends StatefulWidget {

  final Function(dynamic objeto, GuardadosTab tab) onDetalleSeleccionado;
  final VoidCallback onVolver;
  final GuardadosTab tabInicial;

  const GuardadosPage({
    super.key,
    required this.onDetalleSeleccionado,
    required this.onVolver,
    this.tabInicial = GuardadosTab.actividades,
  });

  @override
  State<GuardadosPage> createState() => _GuardadosPageState();
}

class _GuardadosPageState extends State<GuardadosPage> {
  late GuardadosTab _tabActual;
  List<Actividad> _actividades = [];
  EstadoUi _estadoActividades = EstadoUi.cargando;
  String _errorActividades = '';
  int _paginaActividades = 0;
  int _totalPaginasActividades = 1;
  bool _cargandoActividades = false;
  final ScrollController _scrollActividades = ScrollController();


  List<Restaurante> _restaurantes = [];
  EstadoUi _estadoRestaurantes = EstadoUi.cargando;
  String _errorRestaurantes = '';
  int _paginaRestaurantes = 0;
  int _totalPaginasRestaurantes = 1;
  bool _cargandoRestaurantes = false;
  final ScrollController _scrollRestaurantes = ScrollController();


  List<Alojamiento> _alojamientos = [];
  EstadoUi _estadoAlojamientos = EstadoUi.cargando;
  String _errorAlojamientos = '';
  int _paginaAlojamientos = 0;
  int _totalPaginasAlojamientos = 1;
  bool _cargandoAlojamientos = false;
  final ScrollController _scrollAlojamientos = ScrollController();

  int? get _idUsuario => Usuario.usuarioActual?.id;

  @override
  void initState() {
    super.initState();

    _tabActual = widget.tabInicial;

    // Scroll listeners
    _scrollActividades.addListener(() {
      if (_scrollActividades.position.pixels >=
          _scrollActividades.position.maxScrollExtent - 200) {
        _cargarActividades();
      }
    });

    _scrollRestaurantes.addListener(() {
      if (_scrollRestaurantes.position.pixels >=
          _scrollRestaurantes.position.maxScrollExtent - 200) {
        _cargarRestaurantes();
      }
    });

    _scrollAlojamientos.addListener(() {
      if (_scrollAlojamientos.position.pixels >=
          _scrollAlojamientos.position.maxScrollExtent - 200) {
        _cargarAlojamientos();
      }
    });

    _cargarActividades();
    if (_tabActual == GuardadosTab.restaurantes) _cargarRestaurantes();
    if (_tabActual == GuardadosTab.alojamientos) _cargarAlojamientos();
  }

  @override
  void dispose() {
    _scrollActividades.dispose();
    _scrollRestaurantes.dispose();
    _scrollAlojamientos.dispose();
    super.dispose();
  }


  Future<void> _cargarActividades({bool reset = false}) async {
    if (_cargandoActividades) return;
    if (!reset && _paginaActividades >= _totalPaginasActividades && _paginaActividades != 0) return;

    if (reset) {
      setState(() {
        _actividades.clear();
        _paginaActividades = 0;
        _totalPaginasActividades = 1;
        _estadoActividades = EstadoUi.cargando;
      });
    }

    setState(() => _cargandoActividades = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoActividades = EstadoUi.vacio);
        return;
      }
      final ids = await InteraccionesApiService.listarGuardadosActividad(idUsuario: _idUsuario!);
      if (ids.isEmpty) {
        setState(() => _estadoActividades = EstadoUi.vacio);
        return;
      }
      final page = await ActividadesApiService.actividadesGuardadas(
        idsGuardados: ids,
        page: _paginaActividades,
      );
      setState(() {
        _actividades.addAll(page.contenido);
        _totalPaginasActividades = page.totalPaginas;
        _paginaActividades++;
        _estadoActividades = _actividades.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoActividades = EstadoUi.sinConexion;
        _errorActividades = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoActividades = uiError.estado;
        _errorActividades = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoActividades = EstadoUi.error;
        _errorActividades = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoActividades = false);
    }
  }


  Future<void> _cargarRestaurantes({bool reset = false}) async {
    if (_cargandoRestaurantes) return;
    if (!reset && _paginaRestaurantes >= _totalPaginasRestaurantes && _paginaRestaurantes != 0) return;

    if (reset) {
      setState(() {
        _restaurantes.clear();
        _paginaRestaurantes = 0;
        _totalPaginasRestaurantes = 1;
        _estadoRestaurantes = EstadoUi.cargando;
      });
    }

    setState(() => _cargandoRestaurantes = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoRestaurantes = EstadoUi.vacio);
        return;
      }
      final ids = await InteraccionesApiService.listarGuardadosRestaurante(idUsuario: _idUsuario!);
      if (ids.isEmpty) {
        setState(() => _estadoRestaurantes = EstadoUi.vacio);
        return;
      }
      final page = await RestauranteApiService.restaurantesGuardados(
        idsGuardados: ids,
        page: _paginaRestaurantes,
      );
      setState(() {
        _restaurantes.addAll(page.contenido);
        _totalPaginasRestaurantes = page.totalPaginas;
        _paginaRestaurantes++;
        _estadoRestaurantes = _restaurantes.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoRestaurantes = EstadoUi.sinConexion;
        _errorRestaurantes = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoRestaurantes = uiError.estado;
        _errorRestaurantes = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoRestaurantes = EstadoUi.error;
        _errorRestaurantes = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoRestaurantes = false);
    }
  }


  Future<void> _cargarAlojamientos({bool reset = false}) async {
    if (_cargandoAlojamientos) return;
    if (!reset && _paginaAlojamientos >= _totalPaginasAlojamientos && _paginaAlojamientos != 0) return;

    if (reset) {
      setState(() {
        _alojamientos.clear();
        _paginaAlojamientos = 0;
        _totalPaginasAlojamientos = 1;
        _estadoAlojamientos = EstadoUi.cargando;
      });
    }

    setState(() => _cargandoAlojamientos = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoAlojamientos = EstadoUi.vacio);
        return;
      }
      final ids = await InteraccionesApiService.listarGuardadosAlojamiento(idUsuario: _idUsuario!);
      if (ids.isEmpty) {
        setState(() => _estadoAlojamientos = EstadoUi.vacio);
        return;
      }
      final page = await AlojamientoApiService.alojamientosGuardados(
        idsGuardados: ids,
        page: _paginaAlojamientos,
      );
      setState(() {
        _alojamientos.addAll(page.contenido);
        _totalPaginasAlojamientos = page.totalPaginas;
        _paginaAlojamientos++;
        _estadoAlojamientos = _alojamientos.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoAlojamientos = EstadoUi.sinConexion;
        _errorAlojamientos = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        _estadoAlojamientos = uiError.estado;
        _errorAlojamientos = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoAlojamientos = EstadoUi.error;
        _errorAlojamientos = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoAlojamientos = false);
    }
  }


  void _onTabChanged(GuardadosTab tab) {
    setState(() => _tabActual = tab);
    if (tab == GuardadosTab.restaurantes && _estadoRestaurantes == EstadoUi.cargando) {
      _cargarRestaurantes();
    }
    if (tab == GuardadosTab.alojamientos && _estadoAlojamientos == EstadoUi.cargando) {
      _cargarAlojamientos();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: _fondoPagina,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -15,
            left: -10,
            child: IconButton(
              onPressed: widget.onVolver,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi colección',
                  style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Guardados',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _verde,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          _TabButton(
            label: 'Actividades',
            icono: Icons.calendar_today_outlined,
            activo: _tabActual == GuardadosTab.actividades,
            onTap: () => _onTabChanged(GuardadosTab.actividades),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Restaurantes',
            icono: Icons.restaurant_outlined,
            activo: _tabActual == GuardadosTab.restaurantes,
            onTap: () => _onTabChanged(GuardadosTab.restaurantes),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Alojamientos',
            icono: Icons.hotel_outlined,
            activo: _tabActual == GuardadosTab.alojamientos,
            onTap: () => _onTabChanged(GuardadosTab.alojamientos),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_tabActual) {
      GuardadosTab.actividades  => _bodyActividades(),
      GuardadosTab.restaurantes => _bodyRestaurantes(),
      GuardadosTab.alojamientos => _bodyAlojamientos(),
    };
  }


  Widget _bodyActividades() {
    return switch (_estadoActividades) {
      EstadoUi.cargando    => const Center(child: CircularProgressIndicator(color: _verde)),
      EstadoUi.vacio       => _sinGuardados('actividades'),
      EstadoUi.sinConexion => estadoError(
        icon: Icons.wifi_off,
        mensaje: _errorActividades,
        onRetry: () => _cargarActividades(reset: true),
      ),
      EstadoUi.error => estadoError(
        icon: Icons.error_outline,
        mensaje: _errorActividades,
        onRetry: () => _cargarActividades(reset: true),
      ),
      EstadoUi.contenido => _listaActividades(),
    };
  }

  Widget _listaActividades() {
    return ListView.builder(
      controller: _scrollActividades,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _actividades.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(numero: _actividades.length, label: 'Actividades guardadas');
        }
        final i = index - 1;
        if (i == _actividades.length) {
          if (_cargandoActividades) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: _verde)),
            );
          }
          if (_paginaActividades >= _totalPaginasActividades) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No hay más actividades guardadas',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final actividad = _actividades[i];
        return TarjetaGuardado.actividad(
          titulo: actividad.titulo,
          localidad: actividad.localidad,
          categoria: actividad.categoriaActividad,
          imagenUrl: actividad.imagenPrincipal,
          fecha: actividad.fechaInicio,
          onTap: () async {
            final detalle = await ActividadesApiService.detalleActividad(actividad.id);
            widget.onDetalleSeleccionado(detalle, GuardadosTab.actividades);
          },
        );
      },
    );
  }


  Widget _bodyRestaurantes() {
    return switch (_estadoRestaurantes) {
      EstadoUi.cargando    => const Center(child: CircularProgressIndicator(color: _verde)),
      EstadoUi.vacio       => _sinGuardados('restaurantes'),
      EstadoUi.sinConexion => estadoError(
        icon: Icons.wifi_off,
        mensaje: _errorRestaurantes,
        onRetry: () => _cargarRestaurantes(reset: true),
      ),
      EstadoUi.error => estadoError(
        icon: Icons.error_outline,
        mensaje: _errorRestaurantes,
        onRetry: () => _cargarRestaurantes(reset: true),
      ),
      EstadoUi.contenido => _listaRestaurantes(),
    };
  }

  Widget _listaRestaurantes() {
    return ListView.builder(
      controller: _scrollRestaurantes,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _restaurantes.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(numero: _restaurantes.length, label: 'Restaurantes guardados');
        }
        final i = index - 1;
        if (i == _restaurantes.length) {
          if (_cargandoRestaurantes) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: _verde)),
            );
          }
          if (_paginaRestaurantes >= _totalPaginasRestaurantes) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No hay más restaurantes guardados',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final r = _restaurantes[i];
        return TarjetaGuardado.restaurante(
          titulo: r.nombre,
          localidad: r.localidad,
          categoria: r.categoriaRestaurante,
          imagenUrl: r.imagenPrincipal,
          abierto: r.abierto,
          onTap: () => widget.onDetalleSeleccionado(r, GuardadosTab.restaurantes),
        );
      },
    );
  }


  Widget _bodyAlojamientos() {
    return switch (_estadoAlojamientos) {
      EstadoUi.cargando    => const Center(child: CircularProgressIndicator(color: _verde)),
      EstadoUi.vacio       => _sinGuardados('alojamientos'),
      EstadoUi.sinConexion => estadoError(
        icon: Icons.wifi_off,
        mensaje: _errorAlojamientos,
        onRetry: () => _cargarAlojamientos(reset: true),
      ),
      EstadoUi.error => estadoError(
        icon: Icons.error_outline,
        mensaje: _errorAlojamientos,
        onRetry: () => _cargarAlojamientos(reset: true),
      ),
      EstadoUi.contenido => _listaAlojamientos(),
    };
  }

  Widget _listaAlojamientos() {
    return ListView.builder(
      controller: _scrollAlojamientos,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _alojamientos.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(numero: _alojamientos.length, label: 'Alojamientos guardados');
        }
        final i = index - 1;
        if (i == _alojamientos.length) {
          if (_cargandoAlojamientos) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: _verde)),
            );
          }
          if (_paginaAlojamientos >= _totalPaginasAlojamientos) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No hay más alojamientos guardados',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final a = _alojamientos[i];
        return TarjetaGuardado.alojamiento(
          titulo: a.nombre,
          localidad: a.localidad,
          categoria: a.categoriaAlojamiento,
          imagenUrl: a.imagenPrincipal,
          onTap: () => widget.onDetalleSeleccionado(a, GuardadosTab.alojamientos),
        );
      },
    );
  }


  Widget _sinGuardados(String tipo) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bookmark_border, size: 52, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'No tienes $tipo guardados',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final int numero;
  final String label;

  const _StatCard({required this.numero, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0DDD6)),
      ),
      child: Row(
        children: [
          Text(
            '$numero',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA6E246),
              height: 1,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 13,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool activo;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icono,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: activo ? const Color(0xFFA6E246) : const Color(0xFFF8F7F4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activo ? const Color(0xFFA6E246) : const Color(0xFFE0DDD6),
            ),
          ),
          child: Column(
            children: [
              Icon(icono,
                  size: 16,
                  color: activo ? const Color(0xFF1A1A1A) : const Color(0xFF6B6B6B)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: activo ? const Color(0xFF1A1A1A) : const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}