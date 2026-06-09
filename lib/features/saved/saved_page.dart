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


import 'package:kultux/config/app_colors.dart';

import 'package:kultux/shared/widget/skeleton_saved.dart';

class SavedPage extends StatefulWidget {
  final Function(dynamic objeto, SavedTabs tab) onSelectedSaved;
  final VoidCallback onBack;
  final SavedTabs initTab;

  const SavedPage({
    super.key,
    required this.onSelectedSaved,
    required this.onBack,
    this.initTab = SavedTabs.activities,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late SavedTabs _currentTab;
  final List<Activity> _activities = [];
  UiState _activitiesStatus = UiState.loading;
  String _errorActivities = '';
  int _activitiesPages = 0;
  int _activitiesTotalPages = 1;
  bool _loadingActivities = false;
  int _totalActivities = 0;
  final ScrollController _scrollActivities = ScrollController();

  final List<Restaurant> _restaurants = [];
  UiState _restaurantsStatus = UiState.loading;
  String _errorRestaurants = '';
  int _restaurantsPages = 0;
  int _restaurantsTotalPages = 1;
  bool _loadingRestaurants = false;
  int _totalRestaurants = 0;
  final ScrollController _scrollRestaurants = ScrollController();

  final List<Accommodation> _accommodations = [];
  UiState _accommodationsStatus = UiState.loading;
  String _errorAccommodations = '';
  int _accommodationsPages = 0;
  int _accommodationsTotalPages = 1;
  bool _loadingAccommodations = false;
  int _totalAccommodations = 0;
  final ScrollController _scrollAccommodations = ScrollController();

  int? get _userId => User.activeUser?.id;

  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();

    _currentTab = widget.initTab;

    _scrollActivities.addListener(() {
      if (_scrollActivities.position.pixels >=
          _scrollActivities.position.maxScrollExtent - 200) {
        _loadActivities();
      }
    });

    _scrollRestaurants.addListener(() {
      if (_scrollRestaurants.position.pixels >=
          _scrollRestaurants.position.maxScrollExtent - 200) {
        _loadRestaurants();
      }
    });

    _scrollAccommodations.addListener(() {
      if (_scrollAccommodations.position.pixels >=
          _scrollAccommodations.position.maxScrollExtent - 200) {
        _loadAccommodations();
      }
    });

    _loadActivities();
    if (_currentTab == SavedTabs.restaurants) _loadRestaurants();
    if (_currentTab == SavedTabs.accommodations) _loadAccommodations();
  }

  @override
  void dispose() {
    _scrollActivities.dispose();
    _scrollRestaurants.dispose();
    _scrollAccommodations.dispose();
    super.dispose();
  }

  Future<void> _loadActivities({bool reset = false}) async {
    if (_loadingActivities) return;
    if (!reset &&
        _activitiesPages >= _activitiesTotalPages &&
        _activitiesPages != 0)
      return;

    if (reset) {
      setState(() {
        _activities.clear();
        _activitiesPages = 0;
        _activitiesTotalPages = 1;
        _activitiesStatus = UiState.loading;
      });
    }

    setState(() => _loadingActivities = true);

    try {
      if (_userId == null) {
        setState(() => _activitiesStatus = UiState.empty);
        return;
      }
      final page = await ActivityApiService.activitiesSaved(
        userId: _userId!,
        page: _activitiesPages,
      );
      setState(() {
        _activities.addAll(page.content);
        _activitiesTotalPages = page.totalPages;
        _totalActivities = page.totalElements;
        _activitiesPages++;
        _activitiesStatus = _activities.isEmpty
            ? UiState.empty
            : UiState.content;
      });
    } on SocketException {
      setState(() {
        _activitiesStatus = UiState.noConnection;
        _errorActivities = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _activitiesStatus = uiError.estado;
        _errorActivities = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _activitiesStatus = UiState.error;
        _errorActivities = 'Error inesperado';
      });
    } finally {
      setState(() => _loadingActivities = false);
    }
  }

  Future<void> _loadRestaurants({bool reset = false}) async {
    if (_loadingRestaurants) return;
    if (!reset &&
        _restaurantsPages >= _restaurantsTotalPages &&
        _restaurantsPages != 0)
      return;

    if (reset) {
      setState(() {
        _restaurants.clear();
        _restaurantsPages = 0;
        _restaurantsTotalPages = 1;

        _restaurantsStatus = UiState.loading;
      });
    }

    setState(() => _loadingRestaurants = true);

    try {
      if (_userId == null) {
        setState(() => _restaurantsStatus = UiState.empty);
        return;
      }
      final page = await RestaurantApiService.restaurantsSaved(
        userId: _userId!,
        page: _restaurantsPages,
      );
      setState(() {
        _restaurants.addAll(page.content);
        _restaurantsTotalPages = page.totalPages;
        _totalRestaurants = page.totalElements;
        _restaurantsPages++;
        _restaurantsStatus = _restaurants.isEmpty
            ? UiState.empty
            : UiState.content;
      });
    } on SocketException {
      setState(() {
        _restaurantsStatus = UiState.noConnection;
        _errorRestaurants = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _restaurantsStatus = uiError.estado;
        _errorRestaurants = uiError.mensaje;
      });
    } catch (e) {
      setState(() {
        _restaurantsStatus = UiState.error;
        _errorRestaurants = 'Error inesperado';
      });
    } finally {
      setState(() => _loadingRestaurants = false);
    }
  }

  Future<void> _loadAccommodations({bool reset = false}) async {
    if (_loadingAccommodations) return;
    if (!reset &&
        _accommodationsPages >= _accommodationsTotalPages &&
        _accommodationsPages != 0)
      return;

    if (reset) {
      setState(() {
        _accommodations.clear();
        _accommodationsPages = 0;
        _accommodationsTotalPages = 1;
        _accommodationsStatus = UiState.loading;
      });
    }

    setState(() => _loadingAccommodations = true);

    try {
      if (_userId == null) {
        setState(() => _accommodationsStatus = UiState.empty);
        return;
      }
      final page = await AccommodationApiService.accommodationsSaved(
        userId: _userId!,
        page: _accommodationsPages,
      );
      setState(() {
        _accommodations.addAll(page.content);
        _accommodationsTotalPages = page.totalPages;
        _totalAccommodations = page.totalElements;
        _accommodationsPages++;
        _accommodationsStatus = _accommodations.isEmpty
            ? UiState.empty
            : UiState.content;
      });
    } on SocketException {
      setState(() {
        _accommodationsStatus = UiState.noConnection;
        _errorAccommodations = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        _accommodationsStatus = uiError.estado;
        _errorAccommodations = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        _accommodationsStatus = UiState.error;
        _errorAccommodations = 'Error inesperado';
      });
    } finally {
      setState(() => _loadingAccommodations = false);
    }
  }

  void _onTabChanged(SavedTabs tab) {
    setState(() => _currentTab = tab);
    if (tab == SavedTabs.restaurants &&
        _restaurantsStatus == UiState.loading) {
      _loadRestaurants();
    }
    if (tab == SavedTabs.accommodations &&
        _accommodationsStatus == UiState.loading) {
      _loadAccommodations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(
      cargando: _loadingDetail,
      child: Container(
        color: AppColors.pageBg,
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
            icon: Icons.calendar_today_outlined,
            active: _currentTab == SavedTabs.activities,
            onTap: () => _onTabChanged(SavedTabs.activities),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Restaurantes',
            icon: Icons.restaurant_outlined,
            active: _currentTab == SavedTabs.restaurants,
            onTap: () => _onTabChanged(SavedTabs.restaurants),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Alojamientos',
            icon: Icons.hotel_outlined,
            active: _currentTab == SavedTabs.accommodations,
            onTap: () => _onTabChanged(SavedTabs.accommodations),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_currentTab) {
      SavedTabs.activities => _bodyActivities(),
      SavedTabs.restaurants => _bodyRestaurants(),
      SavedTabs.accommodations => _bodyAccommodations(),
    };
  }

  Widget _bodyActivities() {
    return switch (_activitiesStatus) {
      UiState.loading => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonSavedCard(),
      ),
      UiState.empty => _withoutSaved('actividades'),
      UiState.noConnection => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorActivities,
        onRetry: () => _loadActivities(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorActivities,
        onRetry: () => _loadActivities(reset: true),
      ),
      UiState.content => _activitiesList(),
    };
  }

  Widget _activitiesList() {
    return ListView.builder(
      controller: _scrollActivities,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _activities.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            number: _totalActivities,
            label: 'Actividades guardadas',
          );
        }
        final i = index - 1;
        if (i == _activities.length) {
          if (_loadingActivities) {
            return const SkeletonSavedCard();
          }
          if (_activitiesPages >= _activitiesTotalPages) {
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
        final activity = _activities[i];
        return SavedCard.activity(
          title: activity.title,
          location: activity.location,
          category: activity.activityCategory,
          imageUrl: activity.coverImage,
          startDate: activity.startDate,
          onTap: () async {
            setState(() => _loadingDetail = true);
            try {
              final detail = await ActivityApiService.activityDetail(
                activity.id,
              );
              widget.onSelectedSaved(detail, SavedTabs.activities);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message: 'No se han podido cargar los datos.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _loadingDetail = false);
            }
          },
        );
      },
    );
  }

  Widget _bodyRestaurants() {
    return switch (_restaurantsStatus) {
      UiState.loading => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonSavedCard(),
      ),
      UiState.empty => _withoutSaved('restaurantes'),
      UiState.noConnection => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorRestaurants,
        onRetry: () => _loadRestaurants(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorRestaurants,
        onRetry: () => _loadRestaurants(reset: true),
      ),
      UiState.content => _restaurantsList(),
    };
  }

  Widget _restaurantsList() {
    return ListView.builder(
      controller: _scrollRestaurants,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _restaurants.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            number: _totalRestaurants,
            label: 'Restaurantes guardados',
          );
        }
        final i = index - 1;
        if (i == _restaurants.length) {
          if (_loadingRestaurants) {
            return const SkeletonSavedCard();
          }
          if (_restaurantsPages >= _restaurantsTotalPages) {
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
        final r = _restaurants[i];
        return SavedCard.restaurant(
          name: r.name,
          location: r.location,
          category: r.restaurantCategory,
          imageUrl: r.coverImage,
          isOpen: r.isOpen,
          onTap: () async {
            setState(() => _loadingDetail = true);
            try {
              final detail = await RestaurantApiService.restaurantDetail(
                r.id,
              );
              widget.onSelectedSaved(detail, SavedTabs.restaurants);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message: 'No se han podido cargar los datos.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _loadingDetail = false);
            }
          },
        );
      },
    );
  }

  Widget _bodyAccommodations() {
    return switch (_accommodationsStatus) {
      UiState.loading => ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        itemCount: 5,
        itemBuilder: (_, __) => const SkeletonSavedCard(),
      ),
      UiState.empty => _withoutSaved('alojamientos'),
      UiState.noConnection => errorState(
        icon: Icons.wifi_off,
        mensaje: _errorAccommodations,
        onRetry: () => _loadAccommodations(reset: true),
      ),
      UiState.error => errorState(
        icon: Icons.error_outline,
        mensaje: _errorAccommodations,
        onRetry: () => _loadAccommodations(reset: true),
      ),
      UiState.content => _accommodationsList(),
    };
  }

  Widget _accommodationsList() {
    return ListView.builder(
      controller: _scrollAccommodations,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _accommodations.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _StatCard(
            number: _totalAccommodations,
            label: 'Alojamientos guardados',
          );
        }
        final i = index - 1;
        if (i == _accommodations.length) {
          if (_loadingAccommodations) {
            return const SkeletonSavedCard();
          }
          if (_accommodationsPages >= _accommodationsTotalPages) {
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
        final a = _accommodations[i];
        return SavedCard.accommodation(
          name: a.name,
          location: a.location,
          category: a.accommodationCategory,
          imageUrl: a.coverImage,
          onTap: () async {
            setState(() => _loadingDetail = true);
            try {
              final detail =
                  await AccommodationApiService.accommodationDetail(a.id);
              widget.onSelectedSaved(detail, SavedTabs.activities);
            } catch (e) {
              if (!context.mounted) return;
              AlertModal.show(
                context,
                message:
                    'No se han podido cargar los datos. Inténtalo más tarde.',
                type: AlertTipe.error,
              );
            } finally {
              setState(() => _loadingDetail = false);
            }
          },
        );
      },
    );
  }

  Widget _withoutSaved(String tipo) {
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
  final int number;
  final String label;

  const _StatCard({required this.number, required this.label});

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
            '$number',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
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
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
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
            color: active ?  AppColors.green : const Color(0xFFF8F7F4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.green : const Color(0xFFE0DDD6),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: active
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
                  color: active
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
