import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/alojamientoApi.dart';
import 'package:kultux/componentes/scroll_boton.dart';
import 'package:kultux/tarjetasBusqueda.dart';
import 'package:kultux/core/utils/iconos.dart';

import 'componentes/selector_localidad.dart';
import 'core/utils/estado_ui.dart';
import 'core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/estados_widgets.dart';

import 'dart:async';

class BuscarAlojamientoPage extends StatefulWidget {
  final Function(dynamic)? onDetalleSeleccionado;
  const BuscarAlojamientoPage({super.key, this.onDetalleSeleccionado});

  @override
  State<BuscarAlojamientoPage> createState() => _BuscarAlojamientoState();
}

class _BuscarAlojamientoState extends State<BuscarAlojamientoPage> {
  late Future<List<Localidad>> futureLocalidad;
  late Future<List<String>> futureCategorias;

  String nombre = "";
  String? categoria;
  int? localidad;

  List<Alojamiento> alojamientos = [];
  int paginaActual = 0;
  int totalPaginas = 0;

  bool cargando = false;
  bool cargandoInicial = true;
  Timer? _debounceTimer;

  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController? _categoriaController;
  TextEditingController? _localidadController;

  EstadoUi estado = EstadoUi.cargando;
  String mensajeError = '';

  Key _selectorLocalidadKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    futureLocalidad = LocalidadApiService.obtenerLocalidadNombres();
    futureCategorias = AlojamientoApiService.categoriaAlojamientos();

    _cargaInicial();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _resetYcargar() async {
    setState(() {
      paginaActual = 0;
      alojamientos.clear();
    });
    await _cargarMas();
  }

  Future<void> _cargaInicial() async {
    setState(() => cargandoInicial = true);
    await _resetYcargar();
    setState(() => cargandoInicial = false);
  }

  Future<void> _cargarMas() async {
    if (cargando) return;
    if (paginaActual >= totalPaginas && paginaActual != 0) return;

    setState(() {
      cargando = true;
      if (paginaActual == 0) estado = EstadoUi.cargando;
    });

    try {
      final pageResponse =
      await AlojamientoApiService.alojamientosFiltrados(
        nombre: nombre.isEmpty ? null : nombre,
        categoria: categoria,
        localidad: localidad,
        page: paginaActual,
      );

      setState(() {
        alojamientos.addAll(pageResponse.contenido);
        totalPaginas = pageResponse.totalPaginas;
        paginaActual++;
        estado =
        alojamientos.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    } on SocketException {
      setState(() {
        estado = EstadoUi.sinConexion;
        mensajeError = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        estado = uiError.estado;
        mensajeError = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        estado = EstadoUi.error;
        mensajeError = 'Error inesperado';
      });
    } finally {
      cargando = false;
    }
  }

  // ────────────────── UI ──────────────────

  @override
  Widget build(BuildContext context) {
    if (cargandoInicial) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 166, 226, 70),
        ),
      );
    }

    return _contenidoConEstado();
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
                child: _searchBar(),
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
          child: ScrollBoton(controller: controller),
        ),
      ],
    );
  }

  Widget _sliverSegunEstado() {
    switch (estado) {
      case EstadoUi.cargando:
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 166, 226, 70),
            ),
          ),
        );

      case EstadoUi.vacio:
        return SliverFillRemaining(child: estadoVacio());

      case EstadoUi.sinConexion:
        return SliverFillRemaining(
          child: estadoError(
            icon: Icons.wifi_off,
            mensaje: mensajeError,
            onRetry: _cargaInicial,
          ),
        );

      case EstadoUi.error:
        return SliverFillRemaining(
          child: estadoError(
            icon: Icons.error_outline,
            mensaje: mensajeError,
            onRetry: _cargaInicial,
          ),
        );

      case EstadoUi.contenido:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index < alojamientos.length) {
                final a = alojamientos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  child: TarjetaBusqueda.alojamiento(
                    titulo: a.nombre,
                    localidad: a.localidad,
                    imagenUrl: a.imagenPrincipal!,
                    textoEtiqueta: a.categoriaAlojamiento,
                    iconoEtiqueta:
                    Iconos.getIconoAlojamiento(a.categoriaAlojamiento),
                    onTap: () async {
                      final detalle = await AlojamientoApiService.obtenerAlojamientoDetalle(a.id);
                      print(detalle.toString());
                      widget.onDetalleSeleccionado?.call(detalle);
                    },
                  ),
                );
              }

              if (cargando) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 166, 226, 70),
                    ),
                  ),
                );
              }

              if (paginaActual >= totalPaginas) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No hay más alojamientos",
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
            childCount: alojamientos.length +
                (cargando || paginaActual >= totalPaginas ? 1 : 0),
          ),
        );
    }
  }

  Widget _searchBar() {
    return SearchBar(
      controller: _searchController,
      hintText: 'Buscar alojamiento...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.search,
            size: 18, color: Colors.grey.shade600),
      ),
      backgroundColor:
      WidgetStateProperty.all(Colors.grey.shade100),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      textStyle:
      WidgetStateProperty.all(const TextStyle(fontSize: 13)),
      constraints:
      const BoxConstraints(minHeight: 40, maxHeight: 40),
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
    return Row(
      children: [
        Expanded(child: _selectorCategorias()),
        const SizedBox(width: 8),
        Expanded(child: _selectorLocalidad()),
        if (categoria != null || localidad != null || nombre.isNotEmpty) ...[
          const SizedBox(width: 8),
          _botonLimpiar(),
        ],
      ],
    );
  }

  Widget _botonLimpiar() {
    return GestureDetector(
      onTap: () {
        setState(() {
          categoria = null;
          localidad = null;
          nombre = "";
          _searchController.clear();
          _categoriaController?.clear();
          _localidadController?.clear();
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
        child:
        Icon(Icons.clear, size: 18, color: Colors.red.shade700),
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
        borderSide: BorderSide(color: Color.fromARGB(255, 166, 226, 70), width: 1),
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
                    (c) => c.toLowerCase().contains(v.text.toLowerCase()));
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
    return FutureBuilder<List<Localidad>>(
      future: LocalidadApiService.cache != null
          ? Future.value(LocalidadApiService.cache)
          : LocalidadApiService.obtenerLocalidadNombres(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        return SelectorLocalidad(
          key: _selectorLocalidadKey,
          localidades: snapshot.data!,
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
