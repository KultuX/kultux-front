import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/shared/widget/bottom_nav.dart';
import 'package:kultux/shared/widget/app_bar_custom.dart';
import 'package:kultux/features/auth/login_widget.dart';
import 'package:kultux/shared/widget/page_header.dart';
import 'package:kultux/shared/widget/scroll_button.dart';
import 'package:kultux/features/map/map_page.dart';
import 'package:kultux/features/profile/profile_page.dart';
import 'package:kultux/features/search/search_page.dart';
import 'package:kultux/data/repository/user_repository.dart';

import 'package:kultux/features/venues/venues_page.dart';
import 'package:kultux/features/detail/detail_page.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/user.dart';

import 'dart:io';
import 'package:kultux/core/utils/ui_state.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/widget_states.dart';

import 'package:kultux/shared/widget/alert_modal.dart';

import 'package:kultux/features/saved/saved_page.dart' show SavedTabs, SavedPage;

import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/shared/widget/app_card.dart';
import 'package:kultux/core/utils/web_container.dart';

import '../saved/saved_tabs_enum.dart';

class MyHomePage extends StatefulWidget {
  final List<Activity>? actividadesIniciales;
  final int? totalPaginas;
  final User? usuarioInicial;
  const MyHomePage({
    super.key,
    this.actividadesIniciales,
    this.totalPaginas,
    this.usuarioInicial,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _logeado = false;
  int _indexActual = 0;
  bool _invitado = false;
  User? usuario;

  List<Activity> _actividades = [];
  int _paginaActual = 0;
  int _totalPaginas = 1;
  bool _cargando = false;

  final ScrollController _scrollController = ScrollController();

  bool _mostrandoDetalleInicio = false;
  Activity? _actividadDetalleSeleccionada;

  bool _mostrandoDetalleEstablecimiento = false;
  dynamic _establecimientoDetalleSeleccionado;

  bool _mostrandoDetalleBuscar = false;
  dynamic _buscarDetalleSeleccionado;

  UiState estadoInicio = UiState.cargando;
  String mensajeErrorInicio = '';

  int _buscarCategoriaIndex = 0;

  bool _mostrandoDetalleGuardado = false;
  dynamic _guardadoDetalleSeleccionado;

  bool _mostrandoGuardadosLista = false;
  bool _mostrandoPerfil = false;

  SavedTabs _guardadosTabActivo = SavedTabs.activities;

  late final VenuesPage _establecimientosPage;

  bool _cargandoDetalleInicio = false;

  @override
  void initState() {
    super.initState();
    if (widget.usuarioInicial != null) {
      usuario = widget.usuarioInicial;
      _logeado = true;
    }

    _establecimientosPage = VenuesPage(
      onDetalleSeleccionado: _abrirDetalleEstablecimiento,
    );

    if (widget.actividadesIniciales != null) {
      _actividades = widget.actividadesIniciales!;
      _totalPaginas = widget.totalPaginas ?? 1;
      _paginaActual = 1;
      estadoInicio = UiState.contenido;
    } else {
      _cargarActividades(inicial: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _cargarActividades({bool inicial = false}) async {
    if (_cargando) return;
    // _cargando = true;
    setState(() {
      _cargando = true;
      if (inicial) {
        estadoInicio = UiState.cargando;
      }
    });

    try {
      final page = await ActivityApiService.trendingActivities(
        _paginaActual,
      );


      setState(() {
        _actividades.addAll(page.contenido);
        _totalPaginas = page.totalPaginas;
        _paginaActual++;
        if (_actividades.isEmpty) {
          estadoInicio = UiState.vacio;
        } else {
          estadoInicio = UiState.contenido;
        }
      });
    } on SocketException {
      setState(() {
        estadoInicio = UiState.sinConexion;
        mensajeErrorInicio = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));

      setState(() {
        estadoInicio = uiError.estado;
        mensajeErrorInicio = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        estadoInicio = UiState.error;
        mensajeErrorInicio = 'Error inesperado';
        mensajeErrorInicio = 'Error inesperado';
      });
    } finally {
      _cargando = false;
    }
  }

  Future<void> _cargarMas() async {
    if (_cargando) return;
    if (_paginaActual >= _totalPaginas) return;
    await _cargarActividades();
  }

  void _cerrarSesion() async {
    await UserRepository.closeSession();

    setState(() {
      usuario = null;
      User.activeUser = null;

      _logeado = false;
      _invitado = false;

      _indexActual = 0;

      _mostrandoPerfil = false;

      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;

      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;

      _mostrandoDetalleBuscar = false;
      _buscarDetalleSeleccionado = null;

      _mostrandoDetalleGuardado = false;
      _guardadoDetalleSeleccionado = null;

      _mostrandoGuardadosLista = false;
    });
  }

  void _abrirDetalleActividad(Activity actividad) {
    setState(() {
      _actividadDetalleSeleccionada = actividad;
      _mostrandoDetalleInicio = true;
    });
  }

  void _volverAListadoInicio() {
    setState(() {
      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;
      _actividades.clear();
      _paginaActual = 0;
    });
    _cargarActividades();
  }

  void _abrirDetalleEstablecimiento(dynamic objeto) {
    setState(() {
      _establecimientoDetalleSeleccionado = objeto;
      _mostrandoDetalleEstablecimiento = true;
    });
  }

  void _volverAListadoEstablecimientos() {
    setState(() {
      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;
    });
  }

  void _abrirDetalleBuscar(dynamic objeto) {
    setState(() {
      _buscarDetalleSeleccionado = objeto;
      _mostrandoDetalleBuscar = true;
    });
  }

  void _volverAListadoBuscar() {
    setState(() {
      _mostrandoDetalleBuscar = false;
      _buscarDetalleSeleccionado = null;
    });
  }

  void _abrirDetalleGuardados(dynamic objeto, SavedTabs tab) {
    setState(() {
      _guardadoDetalleSeleccionado = objeto;
      _mostrandoDetalleGuardado = true;
      _guardadosTabActivo = tab;
      _indexActual = 4;
    });
  }

  void _volverAGuardados() {
    setState(() {
      _mostrandoDetalleGuardado = false;
      _guardadoDetalleSeleccionado = null;
      _mostrandoGuardadosLista = true;
    });
  }

  Widget _getPaginaActual() {
    if (_mostrandoPerfil) {
      return WebContainer(key: ValueKey('perfil'), child: _bodyPerfil());
    }
    switch (_indexActual) {
      case 0:
        return WebContainer(
          key: ValueKey('inicio_${_mostrandoDetalleInicio}'),
          child: _bodyInicio(),
        );
      case 1:
        return const MapPage(key: ValueKey('mapas'));
      case 2:
        return WebContainer(
          key: ValueKey('buscar_${_mostrandoDetalleBuscar}'),
          child: _bodyBuscar(),
        );
      case 3:
        return WebContainer(
          key: ValueKey('establecimientos'),
          child: _bodyEstablecimientos(),
        );
      case 4:
        if (_mostrandoDetalleGuardado && _guardadoDetalleSeleccionado != null) {
          return WebContainer(
            key: const ValueKey('detalle_guardado'),
            child: Column(
              children: [
                PageHeader(
                  title: 'Información',
                  subtitle: 'Detalle',
                  onBack: _volverAGuardados,
                ),
                Expanded(
                  child: DetailPage.fromObject(
                    objeto: _guardadoDetalleSeleccionado!,
                  ),
                ),
              ],
            ),
          );
        }

        return WebContainer(
          key: const ValueKey('guardados_lista'),
          child: SavedPage(
            tabInicial: _guardadosTabActivo,

            onVolver: () {
              setState(() {
                _indexActual = 0;
              });
            },
            onDetalleSeleccionado: (objeto, tab) {
              _abrirDetalleGuardados(objeto, tab);
            },
          ),
        );
      default:
        return const SizedBox(key: ValueKey('vacio'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esWeb = anchoPantalla > 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: esWeb
          ? null
          : AppBarCustom(
              isLogged: _logeado,
              guest: _invitado,
              onShowLogin: () {
                setState(() {
                  _logeado = false;
                  _invitado = false;
                });
              },
              activateProfile: _mostrandoPerfil,
              onGoHome: () {
                setState(() {
                  _mostrandoPerfil = false;
                  _indexActual = 0;
                  _mostrandoDetalleInicio = false;
                  _actividadDetalleSeleccionada = null;
                  _mostrandoDetalleEstablecimiento = false;
                  _establecimientoDetalleSeleccionado = null;
                  _mostrandoDetalleBuscar = false;
                  _buscarDetalleSeleccionado = null;
                  _mostrandoDetalleGuardado = false;
                  _guardadoDetalleSeleccionado = null;
                });
              },
              onGoProfile: () {
                setState(() {
                  _mostrandoPerfil = true;
                  _mostrandoDetalleInicio = false;
                  _actividadDetalleSeleccionada = null;
                  _mostrandoDetalleEstablecimiento = false;
                  _establecimientoDetalleSeleccionado = null;
                  _mostrandoDetalleBuscar = false;
                  _buscarDetalleSeleccionado = null;
                });
              },
            ),
      body: Row(
        children: [
          if (esWeb) _sidebarWeb(context),
          Expanded(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(
                              0.05,
                              0.0,
                            ),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: _getPaginaActual(),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        if (child.key == const ValueKey('bloqueo_login')) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        }
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: !_logeado && !_invitado
                      ? Container(
                          key: const ValueKey('bloqueo_login'),

                          color: Colors.black.withOpacity(0.4),
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: LoginWidget(
                              key: const ValueKey('pantalla_asset_login'),
                              cerrar: () {
                                setState(() {
                                  _logeado = true;
                                  _invitado = true;
                                });
                              },
                              logeado: (User logeado) {
                                setState(() {
                                  _logeado = true;
                                  _invitado = false;
                                  usuario = logeado;
                                });
                              },
                              invitado: () {
                                setState(() {
                                  _invitado = true;
                                  _logeado = false;
                                });
                              },
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('sin_login')),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: esWeb
          ? null
          : BottomNav(
              itemSeleccionado: _indexActual,
              itemSeleccion: _cambioNav,
            ),
    );
  }

  Widget _contenidoInicio() {
    return Expanded(
      child: Center(
        child: Stack(
          children: [
            RefreshIndicator(
              color: const Color.fromARGB(255, 166, 226, 70),
              onRefresh: () async {
                setState(() {
                  _actividades.clear();
                  _paginaActual = 0;
                  _totalPaginas = 1;
                });

                await _cargarActividades(inicial: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: _actividades.length + 1,
                itemBuilder: (context, index) {
                  if (index < _actividades.length) {
                    final actividad = _actividades[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: AppCard.activity(
                        title: actividad.titulo,
                        location: actividad.localidad!,
                        startDate: actividad.fechaInicio,
                        imageUrl: actividad.imagenPrincipal,
                        onTap: () async {
                          setState(() => _cargandoDetalleInicio = true);
                          final detalle =
                              await ActivityApiService.activityDetail(
                                actividad.id,
                              );
                          setState(() => _cargandoDetalleInicio = false);
                          _abrirDetalleActividad(detalle);
                        },
                        textBadge: actividad.categoriaActividad!,
                        iconBadge: 'assets/iconos/actividad_etiquetas.svg',
                        endDate: actividad.fechaFin,
                        status: actividad.estado
                      ),
                    );
                  }

                  if (_cargando) {
                    return const SkeletonCard();
                  }

                  if (_paginaActual >= _totalPaginas) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "¡Ya no hay más actividades para mostrar!",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ScrollButton(controller: _scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarWeb(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esExtendido = anchoPantalla > 1000;

    return Theme(
      data: Theme.of(context).copyWith(
        navigationRailTheme: const NavigationRailThemeData(
          indicatorColor: Colors.transparent,
        ),
      ),
      child: NavigationRail(
        selectedIndex: _mostrandoPerfil ? null : _indexActual,
        extended: esExtendido,
        backgroundColor: Colors.black,
        unselectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: Color.fromARGB(255, 166, 226, 70),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        onDestinationSelected: _cambioNav,
        leading: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: esExtendido ? 16 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo_kultux.png',
                width: 36,
                height: 36,
              ),
              if (esExtendido) ...[
                const SizedBox(width: 12),
                const Text(
                  'KultuX',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
        destinations: [
          _sidebarItem('assets/iconos/home.svg', 'Inicio'),
          _sidebarItem('assets/iconos/maps.svg', 'Mapa'),
          _sidebarItem('assets/iconos/buscar.svg', 'Buscar'),
          _sidebarItem('assets/iconos/servicios.svg', 'Establecimientos'),
          _sidebarItem(
            'assets/iconos/guardados.svg',
            'Guardados',
            desactivado: _invitado,
          ),
        ],
        trailing: SizedBox(
          width: esExtendido ? 256 : 72,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _botonUsuarioSidebar(esExtendido),
          ),
        ),
      ),
    );
  }

  NavigationRailDestination _sidebarItem(
    String path,
    String titulo, {
    bool desactivado = false,
  }) {
    final opacidad = desactivado ? 0.3 : 1.0;
    return NavigationRailDestination(
      icon: Opacity(
        opacity: opacidad,
        child: SvgPicture.asset(
          path,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      selectedIcon: Opacity(
        opacity: opacidad,
        child: SvgPicture.asset(
          path,
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(
            Color.fromARGB(255, 166, 226, 70),
            BlendMode.srcIn,
          ),
        ),
      ),
      label: Text(titulo),
    );
  }

  Widget _botonUsuarioSidebar(bool esExtendido) {
    final Widget separador = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: esExtendido ? 16 : 8,
            right: esExtendido ? 16 : 8,
          ),
          child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1),
        ),
        const SizedBox(height: 16),
      ],
    );

    if (_logeado) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          separador,
          Padding(
            padding: EdgeInsets.only(left: esExtendido ? 12 : 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _mostrandoPerfil = true;
                  _mostrandoDetalleInicio = false;
                  _actividadDetalleSeleccionada = null;
                  _mostrandoDetalleEstablecimiento = false;
                  _establecimientoDetalleSeleccionado = null;
                  _mostrandoDetalleBuscar = false;
                  _buscarDetalleSeleccionado = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/iconos/perfil.svg',
                          width: _mostrandoPerfil ? 30 : 24,
                          height: _mostrandoPerfil ? 30 : 24,
                          colorFilter: ColorFilter.mode(
                            _mostrandoPerfil
                                ? const Color.fromARGB(255, 166, 226, 70)
                                : Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (esExtendido) ...[
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 110,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              usuario?.nombre ?? 'Usuario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Ver Perfil',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_invitado) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          separador,
          Padding(
            padding: EdgeInsets.only(left: esExtendido ? 16 : 8),
            child: SizedBox(
              width: esExtendido ? 224 : 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFA6E246,
                      ).withOpacity(0.15),
                      side: const BorderSide(
                        color: Color(0xFFA6E246),
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: esExtendido ? 20 : 0,
                        vertical: esExtendido ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _logeado = false;
                        _invitado = false;
                      });
                    },
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login,
                            color: Color(0xFFA6E246),
                            size: 18,
                          ),
                          if (esExtendido) ...[
                            const SizedBox(width: 8),
                            const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Color(0xFFA6E246),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iniciar Sesión o Registrarse',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: esExtendido ? 11 : 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: esExtendido ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _cambioNav(int index) {
    _mostrandoPerfil = false;
    if (!_logeado && !_invitado) {
      if (!context.mounted) return;
      AlertModal.show(
        context,
        message: '¡Inicia sesión, registrate o entra como invitado!',
      );
      return;
    }

    if (index == 4 && _invitado) {
      setState(() {
        _invitado = false;
        _logeado = false;
        _indexActual = 0;
        _mostrandoDetalleInicio = false;
        _actividadDetalleSeleccionada = null;
        _mostrandoDetalleEstablecimiento = false;
        _establecimientoDetalleSeleccionado = null;
        _mostrandoDetalleBuscar = false;
        _buscarDetalleSeleccionado = null;
      });
      AlertModal.show(
        context,
        message:
            '¡Inicia sesión o registrate para acceder a más funcionalidades!',
      );
      return;
    }

    setState(() {
      _indexActual = index;
      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;
      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;
      _mostrandoDetalleBuscar = false;
      _buscarDetalleSeleccionado = null;

      if (index != 4) {
        _mostrandoDetalleGuardado = false;
        _guardadoDetalleSeleccionado = null;
        _mostrandoGuardadosLista = false;
      }
    });
  }

  Widget _bodyInicio() {
    if (_mostrandoDetalleInicio && _actividadDetalleSeleccionada != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _volverAListadoInicio,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _actividadDetalleSeleccionada!),
          ),
        ],
      );
    }
    return LoadingBar(
      cargando: _cargandoDetalleInicio,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Actividades recientes',
            subtitle: 'Inicio',
            showDate: true,
            showTodayLabel: true,
          ),

          switch (estadoInicio) {
            UiState.cargando => Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: 4,
                itemBuilder: (_, _) => const SkeletonCard(),
              ),
            ),
            UiState.vacio => Expanded(child: emptyState()),
            UiState.sinConexion => Expanded(
              child: errorState(
                icon: Icons.wifi_off,
                mensaje: mensajeErrorInicio,
                onRetry: _cargarActividades,
              ),
            ),
            UiState.error => Expanded(
              child: errorState(
                icon: Icons.error_outline,
                mensaje: mensajeErrorInicio,
                onRetry: _cargarActividades,
              ),
            ),
            UiState.contenido => _contenidoInicio(),
          },
        ],
      ),
    );
  }

  Widget _bodyEstablecimientos() {
    return Stack(
      children: [
        _establecimientosPage,
        if (_mostrandoDetalleEstablecimiento &&
            _establecimientoDetalleSeleccionado != null)
          Column(
            children: [
              PageHeader(
                title: 'Información',
                subtitle: 'Detalle',
                onBack: _volverAListadoEstablecimientos,
              ),
              Expanded(
                child: DetailPage.fromObject(
                  objeto: _establecimientoDetalleSeleccionado!,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _bodyBuscar() {
    if (_mostrandoDetalleBuscar && _buscarDetalleSeleccionado != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _volverAListadoBuscar,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _buscarDetalleSeleccionado!),
          ),
        ],
      );
    }
    return SearchPage(
      onDetalleSeleccionado: _abrirDetalleBuscar,
      selectedIndex: _buscarCategoriaIndex,
      onIndexChanged: (index) {
        _buscarCategoriaIndex = index;
      },
    );
  }

  Widget _bodyPerfil() {
    return ProfilePage(
      cerrarSesion: _cerrarSesion,
      usuario: usuario,
      onVolver: () {
        setState(() {
          _mostrandoPerfil = false;
        });
      },
    );
  }
}


