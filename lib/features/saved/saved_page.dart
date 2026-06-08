import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/data/api/accommodation_api.dart';
import 'package:kultux/data/api/restaurant_api.dart';
import 'package:kultux/core/utils/ui_state.dart';
import 'package:kultux/core/utils/widget_states.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/accommodation.dart';
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/features/saved/saved_tabs_enum.dart';
import 'package:kultux/shared/widget/saved_card.dart';

import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/page_header.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';

const _verde = Color(0xFFA6E246);
const _fondoPagina = Color(0xFFF1EFE9);



class SavedPage extends StatefulWidget {
  final Function(dynamic objeto, SavedTabs tab) onDetalleSeleccionado;
  final VoidCallback onVolver;
  final SavedTabs tabInicial;

  const SavedPage({
    super.key,
    required this.onDetalleSeleccionado,
    required this.onVolver,
    this.tabInicial = SavedTabs.activities,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late SavedTabs _tabActual;
  List<Activity> _actividades = [];
  UiState _estadoActividades = UiState.cargando;
  String _errorActividades = '';
  int _paginaActividades = 0;
  int _totalPaginasActividades = 1;
  bool _cargandoActividades = false;
  int _totalActividades = 0;
  final ScrollController _scrollActividades = ScrollController();

  List<Restaurant> _restaurantes = [];
  UiState _estadoRestaurantes = UiState.cargando;
  String _errorRestaurantes = '';
  int _paginaRestaurantes = 0;
  int _totalPaginasRestaurantes = 1;
  bool _cargandoRestaurantes = false;
  int _totalRestaurantes = 0;
  final ScrollController _scrollRestaurantes = ScrollController();

  List<Accommodation> _alojamientos = [];
  UiState _estadoAlojamientos = UiState.cargando;
  String _errorAlojamientos = '';
  int _paginaAlojamientos = 0;
  int _totalPaginasAlojamientos = 1;
  bool _cargandoAlojamientos = false;
  int _totalAlojamientos = 0;
  final ScrollController _scrollAlojamientos = ScrollController();

  int? get _idUsuario => User.activeUser?.id;

  bool _cargandoDetalle = false;

  @override
  void initState() {
    super.initState();

    _tabActual = widget.tabInicial;

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
    if (_tabActual == SavedTabs.restaurants) _cargarRestaurantes();
    if (_tabActual == SavedTabs.accommodations) _cargarAlojamientos();
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
    if (!reset &&
        _paginaActividades >= _totalPaginasActividades &&
        _paginaActividades != 0)
      return;

    if (reset) {
      setState(() {
        _actividades.clear();
        _paginaActividades = 0;
        _totalPaginasActividades = 1;
        _estadoActividades = UiState.cargando;
      });
    }

    setState(() => _cargandoActividades = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoActividades = UiState.vacio);
        return;
      }
      final page = await ActivityApiService.activitiesSaved(
        userId: _idUsuario!,
        page: _paginaActividades,
      );
      setState(() {
        _actividades.addAll(page.content);
        _totalPaginasActividades = page.totalPages;
        _totalActividades = page.totalElements;
        _paginaActividades++;
        _estadoActividades = _actividades.isEmpty
            ? UiState.vacio
            : UiState.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoActividades = UiState.sinConexion;
        _errorActividades = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _estadoActividades = uiError.estado;
        _errorActividades = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoActividades = UiState.error;
        _errorActividades = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoActividades = false);
    }
  }

  Future<void> _cargarRestaurantes({bool reset = false}) async {
    if (_cargandoRestaurantes) return;
    if (!reset &&
        _paginaRestaurantes >= _totalPaginasRestaurantes &&
        _paginaRestaurantes != 0)
      return;

    if (reset) {
      setState(() {
        _restaurantes.clear();
        _paginaRestaurantes = 0;
        _totalPaginasRestaurantes = 1;

        _estadoRestaurantes = UiState.cargando;
      });
    }

    setState(() => _cargandoRestaurantes = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoRestaurantes = UiState.vacio);
        return;
      }
      final page = await RestaurantApiService.restaurantsSaved(
        userId: _idUsuario!,
        page: _paginaRestaurantes,
      );
      setState(() {
        _restaurantes.addAll(page.content);
        _totalPaginasRestaurantes = page.totalPages;
        _totalRestaurantes = page.totalElements;
        _paginaRestaurantes++;
        _estadoRestaurantes = _restaurantes.isEmpty
            ? UiState.vacio
            : UiState.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoRestaurantes = UiState.sinConexion;
        _errorRestaurantes = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _estadoRestaurantes = uiError.estado;
        _errorRestaurantes = uiError.mensaje;
      });
    } catch (e) {
      setState(() {
        print(e);
        _estadoRestaurantes = UiState.error;
        _errorRestaurantes = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoRestaurantes = false);
    }
  }

  Future<void> _cargarAlojamientos({bool reset = false}) async {
    if (_cargandoAlojamientos) return;
    if (!reset &&
        _paginaAlojamientos >= _totalPaginasAlojamientos &&
        _paginaAlojamientos != 0)
      return;

    if (reset) {
      setState(() {
        _alojamientos.clear();
        _paginaAlojamientos = 0;
        _totalPaginasAlojamientos = 1;
        _estadoAlojamientos = UiState.cargando;
      });
    }

    setState(() => _cargandoAlojamientos = true);

    try {
      if (_idUsuario == null) {
        setState(() => _estadoAlojamientos = UiState.vacio);
        return;
      }
      final page = await AccommodationApiService.accommodationsSaved(
        userId: _idUsuario!,
        page: _paginaAlojamientos,
      );
      setState(() {
        _alojamientos.addAll(page.content);
        _totalPaginasAlojamientos = page.totalPages;
        _totalAlojamientos = page.totalElements;
        _paginaAlojamientos++;
        _estadoAlojamientos = _alojamientos.isEmpty
            ? UiState.vacio
            : UiState.contenido;
      });
    } on SocketException {
      setState(() {
        _estadoAlojamientos = UiState.sinConexion;
        _errorAlojamientos = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _estadoAlojamientos = uiError.estado;
        _errorAlojamientos = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _estadoAlojamientos = UiState.error;
        _errorAlojamientos = 'Error inesperado';
      });
    } finally {
      setState(() => _cargandoAlojamientos = false);
    }
  }

  void _onTabChanged(SavedTabs tab) {
    setState(() => _tabActual = tab);
    if (tab == SavedTabs.restaurants &&
        _estadoRestaurantes == UiState.cargando) {
      _cargarRestaurantes();
    }
    if (tab == SavedTabs.accommodations &&
        _estadoAlojamientos == UiState.cargando) {
      _cargarAlojamientos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(
      cargando: _cargandoDetalle,
      child: Container(
        color: _fondoPagina,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: 'Guardados', subtitle: 'Mi colección'),
            _buildTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
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
            activo: _tabActual == SavedTabs.activities,
            onTap: () => _onTabChanged(SavedTabs.activities),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Restaurantes',
            icono: Icons.restaurant_outlined,
            activo: _tabActual == SavedTabs.restaurants,
            onTap: () => _onTabChanged(SavedTabs.restaurants),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Alojamientos',
            icono: Icons.hotel_outlined,
            activo: _tabActual == SavedTabs.accommodations,
            onTap: () => _onTabChanged(SavedTabs.accommodations),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_tabActual) {
      SavedTabs.activities => _bodyActividades(),
      SavedTabs.restaurants => _bodyRestaurantes(),
      SavedTabs.accommodations => _bodyAlojamientos(),
    };
  }

  Widget _bodyActividades() {
    return switch (_estadoActividades) {
      UiState.cargando => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonTarjetaGuardado(),
      ),
      UiState.vacio => _sinGuardados('actividades'),
      UiState.sinConexion => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorActividades,
        onRetry: () => _cargarActividades(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorActividades,
        onRetry: () => _cargarActividades(reset: true),
      ),
      UiState.contenido => _listaActividades(),
    };
  }

  Widget _listaActividades() {
    return ListView.builder(
      controller: _scrollActividades,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _actividades.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            numero: _totalActividades,
            label: 'Actividades guardadas',
          );
        }
        final i = index - 1;
        if (i == _actividades.length) {
          if (_cargandoActividades) {
            return const SkeletonTarjetaGuardado();
          }
          if (_paginaActividades >= _totalPaginasActividades) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay más actividades guardadas',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final actividad = _actividades[i];
        return SavedCard.activity(
          title: actividad.title,
          location: actividad.location,
          category: actividad.activityCategory,
          imageUrl: actividad.coverImage,
          startDate: actividad.startDate,
          onTap: () async {
            setState(() => _cargandoDetalle = true);
            try {
              final detalle = await ActivityApiService.activityDetail(
                actividad.id,
              );
              widget.onDetalleSeleccionado(detalle, SavedTabs.activities);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message: 'No se han podido cargar los datos.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _cargandoDetalle = false);
            }
          },
        );
      },
    );
  }

  Widget _bodyRestaurantes() {
    return switch (_estadoRestaurantes) {
      UiState.cargando => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonTarjetaGuardado(),
      ),
      UiState.vacio => _sinGuardados('restaurantes'),
      UiState.sinConexion => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorRestaurantes,
        onRetry: () => _cargarRestaurantes(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorRestaurantes,
        onRetry: () => _cargarRestaurantes(reset: true),
      ),
      UiState.contenido => _listaRestaurantes(),
    };
  }

  Widget _listaRestaurantes() {
    return ListView.builder(
      controller: _scrollRestaurantes,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _restaurantes.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            numero: _totalRestaurantes,
            label: 'Restaurantes guardados',
          );
        }
        final i = index - 1;
        if (i == _restaurantes.length) {
          if (_cargandoRestaurantes) {
            return const SkeletonTarjetaGuardado();
          }
          if (_paginaRestaurantes >= _totalPaginasRestaurantes) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay más restaurantes guardados',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final r = _restaurantes[i];
        return SavedCard.restaurant(
          name: r.name,
          location: r.location,
          category: r.restaurantCategory,
          imageUrl: r.coverImage,
          isOpen: r.isOpen,
          onTap: () async {
            setState(() => _cargandoDetalle = true);
            try {
              final detalle = await RestaurantApiService.restaurantDetail(
                r.id,
              );
              widget.onDetalleSeleccionado(detalle, SavedTabs.restaurants);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message: 'No se han podido cargar los datos.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _cargandoDetalle = false);
            }
          },
        );
      },
    );
  }

  Widget _bodyAlojamientos() {
    return switch (_estadoAlojamientos) {
      UiState.cargando => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonTarjetaGuardado(),
      ),
      UiState.vacio => _sinGuardados('alojamientos'),
      UiState.sinConexion => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorAlojamientos,
        onRetry: () => _cargarAlojamientos(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorAlojamientos,
        onRetry: () => _cargarAlojamientos(reset: true),
      ),
      UiState.contenido => _listaAlojamientos(),
    };
  }

  Widget _listaAlojamientos() {
    return ListView.builder(
      controller: _scrollAlojamientos,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _alojamientos.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            numero: _totalAlojamientos,
            label: 'Alojamientos guardados',
          );
        }
        final i = index - 1;
        if (i == _alojamientos.length) {
          if (_cargandoAlojamientos) {
            return const SkeletonTarjetaGuardado();
          }
          if (_paginaAlojamientos >= _totalPaginasAlojamientos) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay más alojamientos guardados',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
        final a = _alojamientos[i];
        return SavedCard.accommodation(
          name: a.name,
          location: a.location,
          category: a.accommodationCategory,
          imageUrl: a.coverImage,
          onTap: () async {
            setState(() => _cargandoDetalle = true);
            try {
              final detalle =
                  await AccommodationApiService.accommodationDetail(a.id);
              widget.onDetalleSeleccionado(detalle, SavedTabs.activities);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message:
                    'No se han podido cargar los datos. Inténtalo más tarde.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _cargandoDetalle = false);
            }
          },
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
              Icon(
                icono,
                size: 16,
                color: activo
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF6B6B6B),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: activo
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonTarjetaGuardado extends StatefulWidget {
  const SkeletonTarjetaGuardado({super.key});
  @override
  State<SkeletonTarjetaGuardado> createState() =>
      _SkeletonTarjetaGuardadoState();
}

class _SkeletonTarjetaGuardadoState extends State<SkeletonTarjetaGuardado>
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
    _anim = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _s(double w, double h, {BorderRadius? r}) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: r ?? BorderRadius.circular(4),
        gradient: LinearGradient(
          stops: const [0.0, 0.5, 1.0],
          colors: const [
            Color(0xFFE8E8E8),
            Color(0xFFF5F5F5),
            Color(0xFFE8E8E8),
          ],
          transform: SlideGradient(_anim.value),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0DDD6)),
      ),
      child: Row(
        children: [
          _s(64, 64, r: BorderRadius.circular(10)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _s(double.infinity, 13),
                const SizedBox(height: 6),
                _s(120, 13),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _s(70, 20, r: BorderRadius.circular(5)),
                    const SizedBox(width: 5),
                    _s(80, 20, r: BorderRadius.circular(5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _s(32, 32, r: BorderRadius.circular(8)),
        ],
      ),
    );
  }
}
