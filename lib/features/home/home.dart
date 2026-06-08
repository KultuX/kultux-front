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
  final List<Activity>? startActivities;
  final int? totalPages;
  final User? startUser;
  const MyHomePage({
    super.key,
    this.startActivities,
    this.totalPages,
    this.startUser,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _isLoged = false;
  int _currentIndex = 0;
  bool _isGuest = false;
  User? user;

  List<Activity> _activities = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _loading = false;

  final ScrollController _scrollController = ScrollController();

  bool _showHomeDetail = false;
  Activity? _activitySelectedDetail;

  bool _showVenuesDetail = false;
  dynamic _venuesSelectedDetail;

  bool _showSearchDetail = false;
  dynamic _searchSelectedDetail;

  UiState startStatus = UiState.cargando;
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
    if (widget.startUser != null) {
      user = widget.startUser;
      _isLoged = true;
    }

    _establecimientosPage = VenuesPage(
      onDetalleSeleccionado: _abrirDetalleEstablecimiento,
    );

    if (widget.startActivities != null) {
      _activities = widget.startActivities!;
      _totalPages = widget.totalPages ?? 1;
      _currentPage = 1;
      startStatus = UiState.contenido;
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
    if (_loading) return;
    // _cargando = true;
    setState(() {
      _loading = true;
      if (inicial) {
        startStatus = UiState.cargando;
      }
    });

    try {
      final page = await ActivityApiService.trendingActivities(
        _currentPage,
      );


      setState(() {
        _activities.addAll(page.content);
        _totalPages = page.totalPages;
        _currentPage++;
        if (_activities.isEmpty) {
          startStatus = UiState.vacio;
        } else {
          startStatus = UiState.contenido;
        }
      });
    } on SocketException {
      setState(() {
        startStatus = UiState.sinConexion;
        mensajeErrorInicio = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));

      setState(() {
        startStatus = uiError.estado;
        mensajeErrorInicio = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        startStatus = UiState.error;
        mensajeErrorInicio = 'Error inesperado';
        mensajeErrorInicio = 'Error inesperado';
      });
    } finally {
      _loading = false;
    }
  }

  Future<void> _cargarMas() async {
    if (_loading) return;
    if (_currentPage >= _totalPages) return;
    await _cargarActividades();
  }

  void _cerrarSesion() async {
    await UserRepository.closeSession();

    setState(() {
      user = null;
      User.activeUser = null;

      _isLoged = false;
      _isGuest = false;

      _currentIndex = 0;

      _mostrandoPerfil = false;

      _showHomeDetail = false;
      _activitySelectedDetail = null;

      _showVenuesDetail = false;
      _venuesSelectedDetail = null;

      _showSearchDetail = false;
      _searchSelectedDetail = null;

      _mostrandoDetalleGuardado = false;
      _guardadoDetalleSeleccionado = null;

      _mostrandoGuardadosLista = false;
    });
  }

  void _abrirDetalleActividad(Activity actividad) {
    setState(() {
      _activitySelectedDetail = actividad;
      _showHomeDetail = true;
    });
  }

  void _volverAListadoInicio() {
    setState(() {
      _showHomeDetail = false;
      _activitySelectedDetail = null;
      _activities.clear();
      _currentPage = 0;
    });
    _cargarActividades();
  }

  void _abrirDetalleEstablecimiento(dynamic objeto) {
    setState(() {
      _venuesSelectedDetail = objeto;
      _showVenuesDetail = true;
    });
  }

  void _volverAListadoEstablecimientos() {
    setState(() {
      _showVenuesDetail = false;
      _venuesSelectedDetail = null;
    });
  }

  void _abrirDetalleBuscar(dynamic objeto) {
    setState(() {
      _searchSelectedDetail = objeto;
      _showSearchDetail = true;
    });
  }

  void _volverAListadoBuscar() {
    setState(() {
      _showSearchDetail = false;
      _searchSelectedDetail = null;
    });
  }

  void _abrirDetalleGuardados(dynamic objeto, SavedTabs tab) {
    setState(() {
      _guardadoDetalleSeleccionado = objeto;
      _mostrandoDetalleGuardado = true;
      _guardadosTabActivo = tab;
      _currentIndex = 4;
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
    switch (_currentIndex) {
      case 0:
        return WebContainer(
          key: ValueKey('inicio_${_showHomeDetail}'),
          child: _bodyInicio(),
        );
      case 1:
        return const MapPage(key: ValueKey('mapas'));
      case 2:
        return WebContainer(
          key: ValueKey('buscar_${_showSearchDetail}'),
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
                _currentIndex = 0;
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
              isLogged: _isLoged,
              guest: _isGuest,
              onShowLogin: () {
                setState(() {
                  _isLoged = false;
                  _isGuest = false;
                });
              },
              activateProfile: _mostrandoPerfil,
              onGoHome: () {
                setState(() {
                  _mostrandoPerfil = false;
                  _currentIndex = 0;
                  _showHomeDetail = false;
                  _activitySelectedDetail = null;
                  _showVenuesDetail = false;
                  _venuesSelectedDetail = null;
                  _showSearchDetail = false;
                  _searchSelectedDetail = null;
                  _mostrandoDetalleGuardado = false;
                  _guardadoDetalleSeleccionado = null;
                });
              },
              onGoProfile: () {
                setState(() {
                  _mostrandoPerfil = true;
                  _showHomeDetail = false;
                  _activitySelectedDetail = null;
                  _showVenuesDetail = false;
                  _venuesSelectedDetail = null;
                  _showSearchDetail = false;
                  _searchSelectedDetail = null;
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
                  child: !_isLoged && !_isGuest
                      ? Container(
                          key: const ValueKey('bloqueo_login'),

                          color: Colors.black.withOpacity(0.4),
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: LoginWidget(
                              key: const ValueKey('pantalla_asset_login'),
                              onClose: () {
                                setState(() {
                                  _isLoged = true;
                                  _isGuest = true;
                                });
                              },
                              userLoged: (User logeado) {
                                setState(() {
                                  _isLoged = true;
                                  _isGuest = false;
                                  user = logeado;
                                });
                              },
                              userGuest: () {
                                setState(() {
                                  _isGuest = true;
                                  _isLoged = false;
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
              selectedItem: _currentIndex,
              itemSelected: _cambioNav,
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
                  _activities.clear();
                  _currentPage = 0;
                  _totalPages = 1;
                });

                await _cargarActividades(inicial: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: _activities.length + 1,
                itemBuilder: (context, index) {
                  if (index < _activities.length) {
                    final actividad = _activities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: AppCard.activity(
                        title: actividad.title,
                        location: actividad.location!,
                        startDate: actividad.startDate,
                        imageUrl: actividad.coverImage,
                        onTap: () async {
                          setState(() => _cargandoDetalleInicio = true);
                          final detalle =
                              await ActivityApiService.activityDetail(
                                actividad.id,
                              );
                          setState(() => _cargandoDetalleInicio = false);
                          _abrirDetalleActividad(detalle);
                        },
                        textBadge: actividad.activityCategory!,
                        iconBadge: 'assets/iconos/actividad_etiquetas.svg',
                        endDate: actividad.endDate,
                        status: actividad.status
                      ),
                    );
                  }

                  if (_loading) {
                    return const AppCardSkeleton();
                  }

                  if (_currentPage >= _totalPages) {
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
        selectedIndex: _mostrandoPerfil ? null : _currentIndex,
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
            desactivado: _isGuest,
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

    if (_isLoged) {
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
                  _showHomeDetail = false;
                  _activitySelectedDetail = null;
                  _showVenuesDetail = false;
                  _venuesSelectedDetail = null;
                  _showSearchDetail = false;
                  _searchSelectedDetail = null;
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
                              user?.name ?? 'Usuario',
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

    if (_isGuest) {
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
                        _isLoged = false;
                        _isGuest = false;
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
    if (!_isLoged && !_isGuest) {
      if (!context.mounted) return;
      AlertModal.show(
        context,
        message: '¡Inicia sesión, registrate o entra como invitado!',
      );
      return;
    }

    if (index == 4 && _isGuest) {
      setState(() {
        _isGuest = false;
        _isLoged = false;
        _currentIndex = 0;
        _showHomeDetail = false;
        _activitySelectedDetail = null;
        _showVenuesDetail = false;
        _venuesSelectedDetail = null;
        _showSearchDetail = false;
        _searchSelectedDetail = null;
      });
      AlertModal.show(
        context,
        message:
            '¡Inicia sesión o registrate para acceder a más funcionalidades!',
      );
      return;
    }

    setState(() {
      _currentIndex = index;
      _showHomeDetail = false;
      _activitySelectedDetail = null;
      _showVenuesDetail = false;
      _venuesSelectedDetail = null;
      _showSearchDetail = false;
      _searchSelectedDetail = null;

      if (index != 4) {
        _mostrandoDetalleGuardado = false;
        _guardadoDetalleSeleccionado = null;
        _mostrandoGuardadosLista = false;
      }
    });
  }

  Widget _bodyInicio() {
    if (_showHomeDetail && _activitySelectedDetail != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _volverAListadoInicio,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _activitySelectedDetail!),
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

          switch (startStatus) {
            UiState.cargando => Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: 4,
                itemBuilder: (_, _) => const AppCardSkeleton(),
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
        if (_showVenuesDetail &&
            _venuesSelectedDetail != null)
          Column(
            children: [
              PageHeader(
                title: 'Información',
                subtitle: 'Detalle',
                onBack: _volverAListadoEstablecimientos,
              ),
              Expanded(
                child: DetailPage.fromObject(
                  objeto: _venuesSelectedDetail!,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _bodyBuscar() {
    if (_showSearchDetail && _searchSelectedDetail != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _volverAListadoBuscar,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _searchSelectedDetail!),
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
      usuario: user,
      onVolver: () {
        setState(() {
          _mostrandoPerfil = false;
        });
      },
    );
  }
}


