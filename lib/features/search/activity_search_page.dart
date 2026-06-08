import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/shared/widget/scroll_button.dart';
import 'package:kultux/core/utils/ui_state.dart';

import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/locality_selector.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';

import 'package:kultux/core/utils/widget_states.dart';

import '../../shared/widget/app_card.dart';


class ActivitySearchPage extends StatefulWidget {
  final Function(dynamic)? onDetalleSeleccionado;
  const ActivitySearchPage({super.key, this.onDetalleSeleccionado});

  @override
  State<ActivitySearchPage> createState() => _ActivitySearchPageState();
}

class _ActivitySearchPageState extends State<ActivitySearchPage> {
  late Future<List<Location>> futureLocalidad;
  late Future<List<String>> futureCategorias;

  String titulo = "";
  String? categoria;
  int? localidad;
  DateTime? fecha;

  List<Activity> actividades = [];
  int paginaActual = 0;
  int totalPaginas = 0;

  bool cargando = false;
  //bool cargandoInicial = true;
  Timer? _debounceTimer;
  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController? _categoriaController;
  TextEditingController? _localidadController;

  Key _selectorLocalidadKey = UniqueKey();

  UiState estado = UiState.cargando;
  String mensajeError = '';

  bool _cargandoDetalle = false;

  @override
  void initState() {
    super.initState();
    futureCategorias = ActivityApiService.activityCategories();
    futureLocalidad = LocationApiService.locationsNames();
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

  Future<void> _cargarActividades() async {
    await _resetYcargar();
  }

  Future<void> _cargaInicial() async {
    setState(() {
      estado = UiState.cargando;
    });
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
      final pageResponse = await ActivityApiService.activitiesSearching(
        titulo: titulo.isEmpty ? null : titulo,
        categoria: categoria,
        localidad: localidad,
        fecha: fecha,
        page: paginaActual,
      );
      setState(() {
        if (paginaActual == 0) actividades.clear();
        actividades.addAll(pageResponse.contenido);
        totalPaginas = pageResponse.totalPaginas;
        paginaActual++;
        estado = actividades.isEmpty ? UiState.vacio : UiState.contenido;
      });
    } on SocketException {
      setState(() {
        estado = UiState.sinConexion;
        mensajeError = 'No hay conexion a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        estado = uiError.estado;
        mensajeError = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        estado = UiState.error;
        mensajeError = 'Error inesperado';
      });
    } finally {
      cargando = false;
    }
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
        return SliverFillRemaining(child: emptyState());

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
              if (index < actividades.length) {
                final a = actividades[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: AppCard.activity(
                    title: a.titulo,
                    location: a.localidad!,
                    startDate: a.fechaInicio,
                    imageUrl: a.imagenPrincipal,
                    onTap: () async {
                      setState(() => _cargandoDetalle = true);
                      try {
                        final detalle =
                            await ActivityApiService.activityDetail(a.id);
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
                    textBadge: a.categoriaActividad!,
                    iconBadge: 'assets/iconos/actividad_etiquetas.svg',
                    endDate: a.fechaFin,
                    status: a.estado
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
                      "No hay más actividades",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
            childCount:
                actividades.length +
                (cargando || paginaActual >= totalPaginas ? 1 : 0),
          ),
        );
    }
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
                    _selectorFecha(),
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

  @override
  Widget build(BuildContext context) {
    return LoadingBar(cargando: _cargandoDetalle, child: _contenidoConEstado());
  }

  Widget _searchBar() {
    return SearchBar(
      controller: _searchController,
      hintText: 'Buscar actividad...',
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
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      ),
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
      onChanged: (value) {
        titulo = value;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
          _cargarActividades();
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
                fecha != null ||
                titulo.isNotEmpty) ...[
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
          fecha = null;
          titulo = "";
          _searchController.clear();
          _selectorLocalidadKey = UniqueKey();
          _localidadController?.clear();
          _categoriaController?.clear();
        });
        _cargarActividades();
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
            _cargarActividades();
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
                  _cargarActividades();
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
          localidades: snapshot.data!,
          onSelected: (loc) {
            setState(() => localidad = loc?.ine);
            _cargarActividades();
          },
        );
      },
    );
  }

  Widget _selectorFecha() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromARGB(255, 166, 226, 70),
                  onPrimary: Colors.black,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => fecha = picked);
          _cargarActividades();
        }
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: fecha == null
              ? Colors.grey.shade100
              : const Color.fromARGB(30, 166, 226, 70),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: fecha == null
                ? Colors.grey.shade300
                : const Color.fromARGB(255, 166, 226, 70),
          ),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 18,
          color: fecha == null
              ? Colors.grey.shade600
              : const Color.fromARGB(255, 166, 226, 70),
        ),
      ),
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
