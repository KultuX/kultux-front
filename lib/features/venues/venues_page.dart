import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/core/models/accommodation.dart';
import 'package:kultux/data/api/restaurant_api.dart';
import 'package:kultux/data/api/accommodation_api.dart';
import 'package:kultux/core/utils/ui_state.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/widget_states.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/data/api/venues_api.dart';

import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/page_header.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/core/utils/app_icons.dart';

import 'package:kultux/shared/widget/app_card.dart';

import 'package:kultux/config/app_colors.dart';
import 'package:kultux/shared/widget/skeleton_venues.dart';


class VenuesPage extends StatefulWidget {
  final Function(dynamic objetoDetalle) onSelectedDetail;

  const VenuesPage({super.key, required this.onSelectedDetail});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {


  List<Restaurant> _restaurants = [];
  List<Accommodation> _accommodations = [];
  UiState _resumeStatus = UiState.loading;
  String _errorMessageResume = '';

  List<Restaurant> _restaurantsAll = [];
  UiState _restaurantsStatus = UiState.loading;
  String _errorMessageRestaurants = '';

  List<Accommodation> _accommodationsAll = [];
  UiState _accommodationsStatus = UiState.loading;
  String _errorMessageAccommodations = '';

  bool _showRestaurantsList = false;
  bool _showAccommodationsList = false;

  bool _loadRestaurants = false;
  bool _loadAccommodations = false;

  int _restaurantsPages = 0;
  bool _hasMoreRestaurants = true;
  bool _loadingMoreRestaurants = false;
  final ScrollController _scrollRestaurants = ScrollController();

  int _accommodationsPages = 0;
  bool _hasMoreAccommodations = true;
  bool _loadingMoreAccommodations = false;
  final ScrollController _scrollAccommodations = ScrollController();

  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _loadResume();
    _scrollRestaurants.addListener(() {
      if (_scrollRestaurants.position.pixels >=
          _scrollRestaurants.position.maxScrollExtent - 200) {
        _loadMoreRestaurants();
      }
    });
    _scrollAccommodations.addListener(() {
      if (_scrollAccommodations.position.pixels >=
          _scrollAccommodations.position.maxScrollExtent - 200) {
        _loadMoreAccommodations();
      }
    });
  }

  @override
  void dispose() {
    _scrollRestaurants.dispose();
    _scrollAccommodations.dispose();
    super.dispose();
  }

  Future<void> _loadResume() async {
    setState(() => _resumeStatus = UiState.loading);
    try {
      final result =
          await VenuesApiService.venuesTrending();
      setState(() {
        _restaurants = result['restaurantes'] as List<Restaurant>;
        _accommodations = result['alojamientos'] as List<Accommodation>;
        _resumeStatus = UiState.content;
      });
    } on SocketException {
      setState(() {
        _resumeStatus = UiState.noConnection;
        _errorMessageResume = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _resumeStatus = uiError.estado;
        _errorMessageResume = uiError.mensaje;
      });
    } catch (e, stack) {
      setState(() {
        _resumeStatus = UiState.error;
        _errorMessageResume = 'Error inesperado';
      });
    }
  }

  Future<void> _loadAllRestaurants() async {
    if (_loadRestaurants) return;
    setState(() => _restaurantsStatus = UiState.loading);
    try {
      final page = await RestaurantApiService.restaurantsTrending(
        page: 0,
      );
      setState(() {
        _restaurantsAll = page.content;
        _hasMoreRestaurants = page.number + 1 < page.totalPages;
        _restaurantsPages = 1;
        _loadRestaurants = true;
        _restaurantsStatus = page.content.isEmpty
            ? UiState.empty
            : UiState.content;
      });
    } on SocketException {
      setState(() {
        _restaurantsStatus = UiState.noConnection;
        _errorMessageRestaurants = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _restaurantsStatus = uiError.estado;
        _errorMessageRestaurants = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _restaurantsStatus = UiState.error;
        _errorMessageRestaurants = 'Error inesperado';
      });
    }
  }

  Future<void> _loadMoreRestaurants() async {
    if (!_hasMoreRestaurants || _loadingMoreRestaurants) return;
    setState(() => _loadingMoreRestaurants = true);
    try {
      final page = await RestaurantApiService.restaurantsTrending(
        page: _restaurantsPages,
      );
      setState(() {
        _restaurantsAll.addAll(page.content);
        _hasMoreRestaurants = page.number + 1 < page.totalPages;
        _restaurantsPages++;
      });
    } catch (_) {
    } finally {
      setState(() => _loadingMoreRestaurants = false);
    }
  }

  Future<void> _loadAllAccomodations() async {
    if (_loadAccommodations) return;
    setState(() => _accommodationsStatus = UiState.loading);
    try {
      final pagina = await AccommodationApiService.accommodationTrending(
        page: 0,
      );

      setState(() {
        _accommodationsAll = pagina.content;
        _hasMoreAccommodations = pagina.number + 1 < pagina.totalPages;
        _accommodationsPages = 1;
        _loadAccommodations = true;
        _accommodationsStatus = pagina.content.isEmpty
            ? UiState.empty
            : UiState.content;
      });
    } on SocketException {
      setState(() {
        _accommodationsStatus = UiState.noConnection;
        _errorMessageAccommodations = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _accommodationsStatus = uiError.estado;
        _errorMessageAccommodations = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _accommodationsStatus = UiState.error;
        _errorMessageAccommodations = 'Error inesperado';
      });
    }
  }

  Future<void> _loadMoreAccommodations() async {
    if (!_hasMoreAccommodations || _loadingMoreAccommodations) return;
    setState(() => _loadingMoreAccommodations = true);
    try {
      final pagina = await AccommodationApiService.accommodationTrending(
        page: _accommodationsPages,
      );
      setState(() {
        _accommodationsAll.addAll(pagina.content);
        _hasMoreAccommodations = pagina.number + 1 < pagina.totalPages;
        _accommodationsPages++;
      });
    } catch (_) {
    } finally {
      setState(() => _loadingMoreAccommodations = false);
    }
  }

  void _openRestaurantsList() {
    setState(() {
      _showRestaurantsList = true;
      _showAccommodationsList = false;
    });
    _loadAllRestaurants();
  }

  void _openAccommodationsList() {
    setState(() {
      _showAccommodationsList = true;
      _showRestaurantsList = false;
    });
    _loadAllAccomodations();
  }

  void _backToResume() {
    setState(() {
      _showRestaurantsList = false;
      _showAccommodationsList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(
      cargando: _loadingDetail,
      child: AnimatedSwitcher(
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
        child: _showRestaurantsList
            ? KeyedSubtree(
                key: const ValueKey('lista_restaurantes'),
                child: _buildRestaurantsList(),
              )
            : _showAccommodationsList
            ? KeyedSubtree(
                key: const ValueKey('lista_alojamientos'),
                child: _buildAccommodationsList(),
              )
            : KeyedSubtree(
                key: const ValueKey('resumen'),
                child: Column(
                  children: [
                    PageHeader(
                      title: 'Descubre',
                      subtitle: 'Establecimientos',
                    ),
                    Expanded(
                      child: switch (_resumeStatus) {
                        UiState.loading => _buildResume(),
                        UiState.error => errorState(
                          icon: Icons.error_outline,
                          mensaje: _errorMessageResume,
                          onRetry: _loadResume,
                        ),
                        UiState.noConnection => errorState(
                          icon: Icons.wifi_off,
                          mensaje: _errorMessageResume,
                          onRetry: _loadResume,
                        ),
                        _ => _buildResume(),
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildResume() {
    return Container(
      color: AppColors.pageBg,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                children: [
                  _venuesCard(
                    titleSection: 'Restaurantes destacados',
                    items: _restaurants
                        .map(
                          (r) => _VenueItem(
                            name: r.name,
                            imageUrl: r.coverImage!,
                            onTap: () async {
                              try {
                                setState(() => _loadingDetail = true);
                                final detail =
                                    await RestaurantApiService.restaurantDetail(
                                      r.id,
                                    );
                                setState(() => _loadingDetail = false);
                                widget.onSelectedDetail(detail);
                              } catch (e) {
                                if (!context.mounted) return;
                                AlertModal.show(
                                  context,
                                  message:
                                      'No se ha podido cargar correctamente el restaurante.',
                                  type: AlertTipe.error,
                                );
                              } finally {
                                setState(() {
                                  _loadingDetail = false;
                                });
                              }
                            },
                          ),
                        )
                        .toList(),
                    onShowMore: _openRestaurantsList,
                  ),
                  const SizedBox(height: 16),
                  _venuesCard(
                    titleSection: 'Alojamientos destacados',
                    items: _accommodations
                        .map(
                          (a) => _VenueItem(
                            name: a.name,
                            imageUrl: a.coverImage!,
                            onTap: () async {
                              try {
                                setState(() => _loadingDetail = true);
                                final detail =
                                    await AccommodationApiService.accommodationDetail(
                                      a.id,
                                    );
                                setState(() => _loadingDetail = false);
                                widget.onSelectedDetail(detail);
                              } catch (e) {
                                if (!context.mounted) return;
                                AlertModal.show(
                                  context,
                                  message:
                                      'No se ha podido cargar correctamente el restaurante.',
                                  type: AlertTipe.error,
                                );
                              } finally {
                                setState(() {
                                  _loadingDetail = false;
                                });
                              }
                            },
                          ),
                        )
                        .toList(),
                    onShowMore: _openAccommodationsList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return Column(
      children: [
        PageHeader(
          title: 'Restaurantes destacados',
          subtitle: 'Descubre',
          onBack: _backToResume,
        ),
        Expanded(
          child: switch (_restaurantsStatus) {
            UiState.loading => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonCard(),
              ),
            ),
            UiState.empty => emptyState(),
            UiState.noConnection => errorState(
              icon: Icons.wifi_off,
              mensaje: _errorMessageRestaurants,
              onRetry: () {
                _loadRestaurants = false;
                _loadAllRestaurants();
              },
            ),
            UiState.error => errorState(
              icon: Icons.error_outline,
              mensaje: _errorMessageRestaurants,
              onRetry: () {
                _loadRestaurants = false;
                _loadAllRestaurants();
              },
            ),
            UiState.content => ListView.builder(
              controller: _scrollRestaurants,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _restaurantsAll.length,
              itemBuilder: (context, index) {
                final r = _restaurantsAll[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard.restaurant(
                    name: r.name,
                    imageUrl: r.coverImage!,
                    textBadge:
                        r.restaurantCategory[0].toUpperCase() +
                        r.restaurantCategory.substring(1).toLowerCase(),
                    iconBadge: AppIcons.getRestaurantIcon(
                      r.restaurantCategory,
                    ),
                    onTap: () async {
                      try {
                        setState(() => _loadingDetail = true);
                        final detail =
                            await RestaurantApiService.restaurantDetail(
                              r.id,
                            );
                        setState(() => _loadingDetail = false);
                        widget.onSelectedDetail(detail);
                      } catch (e) {
                        if (!context.mounted) return;
                        AlertModal.show(
                          context,
                          message:
                              'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.',
                          type: AlertTipe.error,
                        );
                      } finally {
                        setState(() {
                          _loadingDetail = false;
                        });
                      }
                    },
                    schedule: r.schedule!,
                    isOpen: r.isOpen!,
                    location: r.location,
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }

  Widget _buildAccommodationsList() {
    return Column(
      children: [
        PageHeader(
          title: 'Alojamientos destacados',
          subtitle: 'Descubre',
          onBack: _backToResume,
        ),
        Expanded(
          child: switch (_accommodationsStatus) {
            UiState.loading => ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonCard(),
              ),
            ),
            UiState.empty => emptyState(),
            UiState.noConnection => errorState(
              icon: Icons.wifi_off,
              mensaje: _errorMessageAccommodations,
              onRetry: () {
                _loadAccommodations = false;
                _loadAllAccomodations();
              },
            ),
            UiState.error => errorState(
              icon: Icons.error_outline,
              mensaje: _errorMessageAccommodations,
              onRetry: () {
                _loadAccommodations = false;
                _loadAllAccomodations();
              },
            ),
            UiState.content => ListView.builder(
              controller: _scrollAccommodations,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _accommodationsAll.length,
              itemBuilder: (context, index) {
                final a = _accommodationsAll[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard.accommodation(
                    name: a.name,
                    imageUrl: a.coverImage!,
                    textBadge:
                        a.accommodationCategory[0].toUpperCase() +
                        a.accommodationCategory.substring(1).toLowerCase(),
                    iconBadge: AppIcons.getAccommodationIcon(
                      a.accommodationCategory,
                    ),
                    onTap: () async {
                      try {
                        setState(() => _loadingDetail = true);
                        final detail =
                            await AccommodationApiService.accommodationDetail(
                              a.id,
                            );
                        setState(() => _loadingDetail = false);
                        widget.onSelectedDetail(detail);
                      } catch (e) {
                        if (!context.mounted) return;
                        AlertModal.show(
                          context,
                          message:
                              'No se han podido cargar correctamente los datos. Prueba a intentarlo más tarde.',
                          type: AlertTipe.error,
                        );
                      } finally {
                        setState(() {
                          _loadingDetail = false;
                        });
                      }
                    },
                    location: a.location,
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }

  Widget _venuesCard({
    required String titleSection,
    required List<_VenueItem> items,
    required VoidCallback onShowMore,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                titleSection,
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              GestureDetector(
                onTap: onShowMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_resumeStatus == UiState.loading)
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
              itemBuilder: (_, __) => const SkeletonMiniVenues(),
            )
          else if (items.isEmpty)
            SizedBox(
              height: 120,
              child: Center(child: Text('No hay destacados disponibles ...')),
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
                  _venuesCardMini(item: items[index]),
            ),
        ],
      ),
    );
  }

  Widget _venuesCardMini({required _VenueItem item}) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green, width: 2),
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
                child: venueImage(item.imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.name,
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

  Widget venueImage(String? url) {
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

class _VenueItem {
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;

  const _VenueItem({
    required this.name,
    required this.imageUrl,
    this.onTap,
  });
}
