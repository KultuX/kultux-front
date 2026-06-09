import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/restaurant_api.dart';
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/shared/widget/scroll_button.dart';

import 'package:kultux/core/utils/app_icons.dart';
import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/locality_selector.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/core/utils/ui_state.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/widget_states.dart';

import 'package:kultux/shared/widget/app_card.dart';



class RestaurantSearchPage extends StatefulWidget {
  final Function(dynamic)? onSelectedDetail;
  const RestaurantSearchPage({super.key, this.onSelectedDetail});

  @override
  State<RestaurantSearchPage> createState() => _RestaurantSearchPageState();
}

class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
  late Future<List<Location>> futureLocations;
  late Future<List<String>> futureCategories;

  String name = "";
  String? category;
  int? location;
  bool? onlyOpen;

  List<Restaurant> restaurants = [];
  int currentPage = 0;
  int totalPages = 0;

  bool loading = false;
  Timer? _debounceTimer;

  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController? _controllerCategories;
  TextEditingController? _controllerLocations;

  UiState status = UiState.loading;
  String errorMessage = '';

  Key _selectorLocationsKey = UniqueKey();

  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    futureLocations = LocationApiService.locationsNames();
    futureCategories = RestaurantApiService.restaurantsCategories();
    _initLoad();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _resetAndLoad() async {
    await Future.microtask(() {});
    currentPage = 0;
    totalPages = 0;
    await _loadMore();
  }

  Future<void> _initLoad() async {
    setState(() => status = UiState.loading);
    await Future.microtask(() {});
    await _resetAndLoad();
  }

  Future<void> _loadMore() async {
    if (loading) return;
    if (currentPage >= totalPages && currentPage != 0) return;

    setState(() {
      loading = true;
      if (currentPage == 0) status = UiState.loading;
    });

    try {
      final pageResponse = await RestaurantApiService.restaurantsSearching(
        name: name.isEmpty ? null : name,
        category: category,
        location: location,
        onlyOpen: onlyOpen,
        page: currentPage,
      );

      setState(() {
        if (currentPage == 0) restaurants.clear();
        restaurants.addAll(pageResponse.content);
        totalPages = pageResponse.totalPages;
        currentPage++;
        status = restaurants.isEmpty ? UiState.empty : UiState.content;
      });
    } on SocketException {
      setState(() {
        status = UiState.noConnection;
        errorMessage = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        status = uiError.estado;
        errorMessage = uiError.mensaje;
      });
    } catch (e) {
      setState(() {
        status = UiState.error;
        errorMessage = 'Error inesperado $e';
      });
    } finally {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(cargando: _loadingDetail, child: _contentStatus());
  }

  Widget _contentStatus() {
    return Stack(
      children: [
        CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    Expanded(child: _searchBar()),
                    const SizedBox(width: 8),
                    _openNowChip(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _filters(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _sliverStatus(),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ScrollButton(controller: controller),
        ),
      ],
    );
  }

  Widget _sliverStatus() {
    switch (status) {
      case UiState.loading:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const SkeletonCard(),
            childCount: 5,
          ),
        );

      case UiState.empty:
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  "No hay restaurantes",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );

      case UiState.noConnection:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.wifi_off,
            mensaje: errorMessage,
            onRetry: _initLoad,
          ),
        );

      case UiState.error:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.error_outline,
            mensaje: errorMessage,
            onRetry: _initLoad,
          ),
        );

      case UiState.content:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < restaurants.length) {
                final r = restaurants[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: AppCard.restaurant(
                    name: r.name,
                    imageUrl: r.coverImage!,
                    textBadge: r.restaurantCategory,
                    iconBadge: AppIcons.getRestaurantIcon(
                      r.restaurantCategory,
                    ),
                    schedule: r.schedule!,
                    isOpen: r.isOpen!,
                    location: r.location,
                    onTap: () async {
                      setState(() => _loadingDetail = true);
                      try {
                        final detalle =
                            await RestaurantApiService.restaurantDetail(
                              r.id,
                            );
                        widget.onSelectedDetail?.call(detalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        AlertModal.show(
                          context,
                          message: 'No se han podido cargar los datos.',
                          type: AlertType.error,
                        );
                      } finally {
                        setState(() => _loadingDetail = false);
                      }
                    },
                  ),
                );
              }

              if (loading) {
                return const SkeletonCard();
              }

              if (currentPage >= totalPages) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No hay más restaurantes",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
            childCount:
                restaurants.length +
                (loading || currentPage >= totalPages ? 1 : 0),
          ),
        );
    }
  }

  Widget _searchBar() {
    return SearchBar(
      controller: _searchController,
      hintText: 'Buscar restaurante...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.search, size: 18, color: Colors.grey.shade600),
      ),
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
      onChanged: (value) {
        name = value;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
          _resetAndLoad();
        });
      },
    );
  }

  Widget _filters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _categoriesSelector()),
            const SizedBox(width: 8),
            Expanded(child: _locationsSelector()),
            if (category != null ||
                location != null ||
                onlyOpen == true ||
                name.isNotEmpty) ...[
              const SizedBox(width: 8),
              _resetButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _resetButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          category = null;
          location = null;
          onlyOpen = null;
          name = "";
          _selectorLocationsKey = UniqueKey();
          _searchController.clear();
          _controllerLocations?.clear();
          _controllerCategories?.clear();
        });
        _resetAndLoad();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Icon(Icons.clear, size: 18, color: Colors.red.shade700),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
    VoidCallback? onClear,
    bool hasValue = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 166, 226, 70),
          width: 1,
        ),
      ),
      suffixIcon: hasValue && onClear != null
          ? GestureDetector(
              onTap: onClear,
              child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
            )
          : Icon(icon, size: 16, color: Colors.grey.shade600),
    );
  }

  Widget _categoriesSelector() {
    return FutureBuilder<List<String>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        final categorias = snapshot.data!;
        return Autocomplete<String>(
          optionsBuilder: (v) {
            if (v.text.isEmpty) return const Iterable<String>.empty();
            return categorias.where(
              (c) => c.toLowerCase().contains(v.text.toLowerCase()),
            );
          },
          onSelected: (s) {
            setState(() => category = s);
            _resetAndLoad();
          },
          fieldViewBuilder: (context, ctrl, focusNode, _) {
            _controllerCategories = ctrl;
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDeco(
                label: 'Categoría',
                icon: Icons.category,
                hasValue: category != null,
                onClear: () {
                  setState(() => category = null);
                  ctrl.clear();
                  _resetAndLoad();
                },
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 180,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final o = options.elementAt(i);
                    return ListTile(
                      dense: true,
                      title: Text(o, style: const TextStyle(fontSize: 13)),
                      onTap: () => onSelected(o),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _locationsSelector() {
    return FutureBuilder<List<Location>>(
      future: LocationApiService.cache != null
          ? Future.value(LocationApiService.cache)
          : LocationApiService.locationsNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        return LocalitySelector(
          key: _selectorLocationsKey,
          locations: snapshot.data!,
          onSelected: (loc) {
            setState(() => location = loc?.ine);
            _resetAndLoad();
          },
        );
      },
    );
  }

  Widget _shimmerLoader() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _openNowChip() {
    final bool seleccionado = onlyOpen == true;

    return InkWell(
      splashColor: const Color.fromARGB(40, 166, 226, 70),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          onlyOpen = seleccionado ? null : true;
        });
        _resetAndLoad();
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? Color.fromARGB(136, 166, 226, 70)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado
                ? const Color.fromARGB(255, 166, 226, 70)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "Abierto",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
