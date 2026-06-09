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
  bool _isLogged = false;
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

  UiState startStatus = UiState.loading;
  String homeMessageError = '';

  int _indexCategorySearch = 0;

  bool _showSavedDetail = false;
  dynamic _savedSelectedDetail;

  bool _showSavedList = false;
  bool _showProfile = false;

  SavedTabs _activeSavedTab = SavedTabs.activities;

  late final VenuesPage _venuesPage;

  bool _loadingHomeDetail = false;

  @override
  void initState() {
    super.initState();
    if (widget.startUser != null) {
      user = widget.startUser;
      _isLogged = true;
    }

    _venuesPage = VenuesPage(
      onSelectedDetail: _openVenueDetail,
    );

    if (widget.startActivities != null) {
      _activities = widget.startActivities!;
      _totalPages = widget.totalPages ?? 1;
      _currentPage = 1;
      startStatus = UiState.content;
    } else {
      _loadActivities(init: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadActivities({bool init = false}) async {
    if (_loading) return;
    // _cargando = true;
    setState(() {
      _loading = true;
      if (init) {
        startStatus = UiState.loading;
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
          startStatus = UiState.empty;
        } else {
          startStatus = UiState.content;
        }
      });
    } on SocketException {
      setState(() {
        startStatus = UiState.noConnection;
        homeMessageError = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));

      setState(() {
        startStatus = uiError.estado;
        homeMessageError = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        startStatus = UiState.error;
        homeMessageError = 'Error inesperado';
        homeMessageError = 'Error inesperado';
      });
    } finally {
      _loading = false;
    }
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    if (_currentPage >= _totalPages) return;
    await _loadActivities();
  }

  void _logout() async {
    await UserRepository.closeSession();

    setState(() {
      user = null;
      User.activeUser = null;

      _isLogged = false;
      _isGuest = false;

      _currentIndex = 0;

      _showProfile = false;

      _showHomeDetail = false;
      _activitySelectedDetail = null;

      _showVenuesDetail = false;
      _venuesSelectedDetail = null;

      _showSearchDetail = false;
      _searchSelectedDetail = null;

      _showSavedDetail = false;
      _savedSelectedDetail = null;

      _showSavedList = false;
    });
  }

  void _openActivityDetail(Activity activity) {
    setState(() {
      _activitySelectedDetail = activity;
      _showHomeDetail = true;
    });
  }

  void _backHomeList() {
    setState(() {
      _showHomeDetail = false;
      _activitySelectedDetail = null;
      _activities.clear();
      _currentPage = 0;
    });
    _loadActivities();
  }

  void _openVenueDetail(dynamic object) {
    setState(() {
      _venuesSelectedDetail = object;
      _showVenuesDetail = true;
    });
  }

  void _backVenuesList() {
    setState(() {
      _showVenuesDetail = false;
      _venuesSelectedDetail = null;
    });
  }

  void _openSearchDetail(dynamic object) {
    setState(() {
      _searchSelectedDetail = object;
      _showSearchDetail = true;
    });
  }

  void _backSearchList() {
    setState(() {
      _showSearchDetail = false;
      _searchSelectedDetail = null;
    });
  }

  void _openSavedDetail(dynamic object, SavedTabs tab) {
    setState(() {
      _savedSelectedDetail = object;
      _showSavedDetail = true;
      _activeSavedTab = tab;
      _currentIndex = 4;
    });
  }

  void _backToSaved() {
    setState(() {
      _showSavedDetail = false;
      _savedSelectedDetail = null;
      _showSavedList = true;
    });
  }

  Widget _getCurrentPage() {
    if (_showProfile) {
      return WebContainer(key: ValueKey('perfil'), child: _profileBody());
    }
    switch (_currentIndex) {
      case 0:
        return WebContainer(
          key: ValueKey('inicio_${_showHomeDetail}'),
          child: _homeBody(),
        );
      case 1:
        return const MapPage(key: ValueKey('mapas'));
      case 2:
        return WebContainer(
          key: ValueKey('buscar_${_showSearchDetail}'),
          child: _searchBody(),
        );
      case 3:
        return WebContainer(
          key: ValueKey('establecimientos'),
          child: _venuesBody(),
        );
      case 4:
        if (_showSavedDetail && _savedSelectedDetail != null) {
          return WebContainer(
            key: const ValueKey('detalle_guardado'),
            child: Column(
              children: [
                PageHeader(
                  title: 'Información',
                  subtitle: 'Detalle',
                  onBack: _backToSaved,
                ),
                Expanded(
                  child: DetailPage.fromObject(
                    objeto: _savedSelectedDetail!,
                  ),
                ),
              ],
            ),
          );
        }

        return WebContainer(
          key: const ValueKey('guardados_lista'),
          child: SavedPage(
            initTab: _activeSavedTab,

            onBack: () {
              setState(() {
                _currentIndex = 0;
              });
            },
            onSelectedSaved: (objeto, tab) {
              _openSavedDetail(objeto, tab);
            },
          ),
        );
      default:
        return const SizedBox(key: ValueKey('vacio'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: isWeb
          ? null
          : AppBarCustom(
              isLogged: _isLogged,
              guest: _isGuest,
              onShowLogin: () {
                setState(() {
                  _isLogged = false;
                  _isGuest = false;
                });
              },
              activateProfile: _showProfile,
              onGoHome: () {
                setState(() {
                  _showProfile = false;
                  _currentIndex = 0;
                  _showHomeDetail = false;
                  _activitySelectedDetail = null;
                  _showVenuesDetail = false;
                  _venuesSelectedDetail = null;
                  _showSearchDetail = false;
                  _searchSelectedDetail = null;
                  _showSavedDetail = false;
                  _savedSelectedDetail = null;
                });
              },
              onGoProfile: () {
                setState(() {
                  _showProfile = true;
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
          if (isWeb) _sidebarWeb(context),
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
                  child: _getCurrentPage(),
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
                  child: !_isLogged && !_isGuest
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
                                  _isLogged = true;
                                  _isGuest = true;
                                });
                              },
                              userLoged: (User logeado) {
                                setState(() {
                                  _isLogged = true;
                                  _isGuest = false;
                                  user = logeado;
                                });
                              },
                              userGuest: () {
                                setState(() {
                                  _isGuest = true;
                                  _isLogged = false;
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
      bottomNavigationBar: isWeb
          ? null
          : BottomNav(
              selectedItem: _currentIndex,
              itemSelected: _navChange,
            ),
    );
  }

  Widget _homeContent() {
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

                await _loadActivities(init: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: _activities.length + 1,
                itemBuilder: (context, index) {
                  if (index < _activities.length) {
                    final activity = _activities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: AppCard.activity(
                        title: activity.title,
                        location: activity.location!,
                        startDate: activity.startDate,
                        imageUrl: activity.coverImage,
                        onTap: () async {
                          setState(() => _loadingHomeDetail = true);
                          final detalle =
                              await ActivityApiService.activityDetail(
                                activity.id,
                              );
                          setState(() => _loadingHomeDetail = false);
                          _openActivityDetail(detalle);
                        },
                        textBadge: activity.activityCategory!,
                        iconBadge: 'assets/iconos/actividad_etiquetas.svg',
                        endDate: activity.endDate,
                        status: activity.status
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
        selectedIndex: _showProfile ? null : _currentIndex,
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
        onDestinationSelected: _navChange,
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
            inactive: _isGuest,
          ),
        ],
        trailing: SizedBox(
          width: esExtendido ? 256 : 72,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _sidebarUserButton(esExtendido),
          ),
        ),
      ),
    );
  }

  NavigationRailDestination _sidebarItem(
    String path,
    String title, {
    bool inactive = false,
  }) {
    final opacity = inactive ? 0.3 : 1.0;
    return NavigationRailDestination(
      icon: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          path,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      selectedIcon: Opacity(
        opacity: opacity,
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
      label: Text(title),
    );
  }

  Widget _sidebarUserButton(bool isExpanded) {
    final Widget separator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isExpanded ? 16 : 8,
            right: isExpanded ? 16 : 8,
          ),
          child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1),
        ),
        const SizedBox(height: 16),
      ],
    );

    if (_isLogged) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          separator,
          Padding(
            padding: EdgeInsets.only(left: isExpanded ? 12 : 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showProfile = true;
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
                          width: _showProfile ? 30 : 24,
                          height: _showProfile ? 30 : 24,
                          colorFilter: ColorFilter.mode(
                            _showProfile
                                ? const Color.fromARGB(255, 166, 226, 70)
                                : Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
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
          separator,
          Padding(
            padding: EdgeInsets.only(left: isExpanded ? 16 : 8),
            child: SizedBox(
              width: isExpanded ? 224 : 56,
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
                        horizontal: isExpanded ? 20 : 0,
                        vertical: isExpanded ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLogged = false;
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
                          if (isExpanded) ...[
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
                      fontSize: isExpanded ? 11 : 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: isExpanded ? 1 : 2,
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

  void _navChange(int index) {
    _showProfile = false;
    if (!_isLogged && !_isGuest) {
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
        _isLogged = false;
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
        _showSavedDetail = false;
        _savedSelectedDetail = null;
        _showSavedList = false;
      }
    });
  }

  Widget _homeBody() {
    if (_showHomeDetail && _activitySelectedDetail != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _backHomeList,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _activitySelectedDetail!),
          ),
        ],
      );
    }
    return LoadingBar(
      cargando: _loadingHomeDetail,
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
            UiState.loading => Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: 4,
                itemBuilder: (_, _) => const AppCardSkeleton(),
              ),
            ),
            UiState.empty => Expanded(child: emptyState()),
            UiState.noConnection => Expanded(
              child: errorState(
                icon: Icons.wifi_off,
                mensaje: homeMessageError,
                onRetry: _loadActivities,
              ),
            ),
            UiState.error => Expanded(
              child: errorState(
                icon: Icons.error_outline,
                mensaje: homeMessageError,
                onRetry: _loadActivities,
              ),
            ),
            UiState.content => _homeContent(),
          },
        ],
      ),
    );
  }

  Widget _venuesBody() {
    return Stack(
      children: [
        _venuesPage,
        if (_showVenuesDetail &&
            _venuesSelectedDetail != null)
          Column(
            children: [
              PageHeader(
                title: 'Información',
                subtitle: 'Detalle',
                onBack: _backVenuesList,
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

  Widget _searchBody() {
    if (_showSearchDetail && _searchSelectedDetail != null) {
      return Column(
        children: [
          PageHeader(
            title: 'Información',
            subtitle: 'Detalle',
            onBack: _backSearchList,
          ),
          Expanded(
            child: DetailPage.fromObject(objeto: _searchSelectedDetail!),
          ),
        ],
      );
    }
    return SearchPage(
      onSelectedDetail: _openSearchDetail,
      selectedIndex: _indexCategorySearch,
      onIndexChanged: (index) {
        _indexCategorySearch = index;
      },
    );
  }

  Widget _profileBody() {
    return ProfilePage(
      logout: _logout,
      user: user,
      onBack: () {
        setState(() {
          _showProfile = false;
        });
      },
    );
  }
}


