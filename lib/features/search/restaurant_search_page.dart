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

import '../../shared/widget/app_card.dart';



class RestaurantSearchPage extends StatefulWidget {
  final Function(dynamic)? onDetalleSeleccionado;
  const RestaurantSearchPage({super.key, this.onDetalleSeleccionado});

  @override
  State<RestaurantSearchPage> createState() => _RestaurantSearchPageState();
}

class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
  late Future<List<Location>> futureLocalidad;
  late Future<List<String>> futureCategorias;

  String nombre = "";
  String? categoria;
  int? localidad;
  bool? soloAbiertos;

  List<Restaurant> restaurantes = [];
  int paginaActual = 0;
  int totalPaginas = 0;

  bool cargando = false;
  //bool cargandoInicial = true;
  Timer? _debounceTimer;

  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController? _categoriaController;
  TextEditingController? _localidadController;

  UiState estado = UiState.cargando;
  String mensajeError = '';

  Key _selectorLocalidadKey = UniqueKey();

  bool _cargandoDetalle = false;

  @override
  void initState() {
    super.initState();
    futureLocalidad = LocationApiService.locationsNames();
    futureCategorias = RestaurantApiService.restaurantsCategories();
    _cargaInicial();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _resetYcargar() async {
    await Future.microtask(() {});
    paginaActual = 0;
    totalPaginas = 0;
    await _cargarMas();
  }

  Future<void> _cargaInicial() async {
    setState(() => estado = UiState.cargando);
    await Future.microtask(() {});
    await _resetYcargar();
  }

  Future<void> _cargarMas() async {
    if (cargando) return;
    if (paginaActual >= totalPaginas && paginaActual != 0) return;

    setState(() {
      cargando = true;
      if (paginaActual == 0) estado = UiState.cargando;
    });

    try {
      final pageResponse = await RestaurantApiService.restaurantsSearching(
        name: nombre.isEmpty ? null : nombre,
        category: categoria,
        location: localidad,
        onlyOpen: soloAbiertos,
        page: paginaActual,
      );

      setState(() {
        if (paginaActual == 0) restaurantes.clear();
        restaurantes.addAll(pageResponse.content);
        totalPaginas = pageResponse.totalPages;
        paginaActual++;
        estado = restaurantes.isEmpty ? UiState.vacio : UiState.contenido;
      });
    } on SocketException {
      setState(() {
        estado = UiState.sinConexion;
        mensajeError = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        estado = uiError.estado;
        mensajeError = uiError.mensaje;
      });
    } catch (e) {
      setState(() {
        estado = UiState.error;
        mensajeError = 'Error inesperado $e';
      });
    } finally {
      cargando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(cargando: _cargandoDetalle, child: _contenidoConEstado());
  }

  Widget _contenidoConEstado() {
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
                    _chipAbiertoAhora(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _filtros(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _sliverSegunEstado(),
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

  Widget _sliverSegunEstado() {
    switch (estado) {
      case UiState.cargando:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const SkeletonCard(),
            childCount: 5,
          ),
        );

      case UiState.vacio:
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

      case UiState.sinConexion:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.wifi_off,
            mensaje: mensajeError,
            onRetry: _cargaInicial,
          ),
        );

      case UiState.error:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.error_outline,
            mensaje: mensajeError,
            onRetry: _cargaInicial,
          ),
        );

      case UiState.contenido:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < restaurantes.length) {
                final r = restaurantes[index];
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
                      setState(() => _cargandoDetalle = true);
                      try {
                        final detalle =
                            await RestaurantApiService.restaurantDetail(
                              r.id,
                            );
                        widget.onDetalleSeleccionado?.call(detalle);
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
                  ),
                );
              }

              if (cargando) {
                return const SkeletonCard();
              }

              if (paginaActual >= totalPaginas) {
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
                restaurantes.length +
                (cargando || paginaActual >= totalPaginas ? 1 : 0),
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
        nombre = value;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
          _resetYcargar();
        });
      },
    );
  }

  Widget _filtros() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _selectorCategorias()),
            const SizedBox(width: 8),
            Expanded(child: _selectorLocalidad()),
            if (categoria != null ||
                localidad != null ||
                soloAbiertos == true ||
                nombre.isNotEmpty) ...[
              const SizedBox(width: 8),
              _botonLimpiar(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _botonLimpiar() {
    return GestureDetector(
      onTap: () {
        setState(() {
          categoria = null;
          localidad = null;
          soloAbiertos = null;
          nombre = "";
          _selectorLocalidadKey = UniqueKey();
          _searchController.clear();
          _localidadController?.clear();
          _categoriaController?.clear();
        });
        _resetYcargar();
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

  Widget _selectorCategorias() {
    return FutureBuilder<List<String>>(
      future: futureCategorias,
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
            setState(() => categoria = s);
            _resetYcargar();
          },
          fieldViewBuilder: (context, ctrl, focusNode, _) {
            _categoriaController = ctrl;
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDeco(
                label: 'Categoría',
                icon: Icons.category,
                hasValue: categoria != null,
                onClear: () {
                  setState(() => categoria = null);
                  ctrl.clear();
                  _resetYcargar();
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

  Widget _selectorLocalidad() {
    return FutureBuilder<List<Location>>(
      future: LocationApiService.cache != null
          ? Future.value(LocationApiService.cache)
          : LocationApiService.locationsNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        return LocalitySelector(
          key: _selectorLocalidadKey,
          locations: snapshot.data!,
          onSelected: (loc) {
            setState(() => localidad = loc?.ine);
            _resetYcargar();
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

  Widget _chipAbiertoAhora() {
    final bool seleccionado = soloAbiertos == true;

    return InkWell(
      splashColor: const Color.fromARGB(40, 166, 226, 70),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          soloAbiertos = seleccionado ? null : true;
        });
        _resetYcargar();
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
