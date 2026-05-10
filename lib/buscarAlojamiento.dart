import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/alojamientoApi.dart';
import 'package:kultux/componentes/scroll_boton.dart';
import 'package:kultux/tarjetasBusqueda.dart';
import 'package:kultux/core/utils/iconos.dart';

import 'core/utils/estado_ui.dart';
import 'core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/estados_widgets.dart';

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

  final ScrollController controller = ScrollController();


  EstadoUi estado = EstadoUi.cargando;
  String mensajeError = '';


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

  // ────────────────── DATA ──────────────────

  Future<void> _resetYcargar() async {
    paginaActual = 0;
    alojamientos.clear();
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
      estado = EstadoUi.cargando;
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
    }
    on SocketException {
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


  @override
  Widget build(BuildContext context) {
    if (cargandoInicial) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 166, 226, 70),
        ),
      );
    }

    switch (estado) {
      case EstadoUi.cargando:
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 166, 226, 70),
          ),
        );

      case EstadoUi.vacio:
        return estadoVacio();

      case EstadoUi.sinConexion:
        return estadoError(
          icon: Icons.wifi_off,
          mensaje: mensajeError,
          onRetry: _cargaInicial,
        );

      case EstadoUi.error:
        return estadoError(
          icon: Icons.error_outline,
          mensaje: mensajeError,
          onRetry: _cargaInicial,
        );

      case EstadoUi.contenido:
        return _contenido();
    }
  }

  Widget _contenido() {
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

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < alojamientos.length) {
                    final a = alojamientos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: TarjetaBusqueda.alojamiento(
                        titulo: a.nombre,
                        localidad: a.localidad?.nombre,
                        imagenUrl: a.imagenPrincipal,
                        textoEtiqueta: a.categoriaAlojamiento,
                        iconoEtiqueta:
                        Iconos.getIconoAlojamiento(a.categoriaAlojamiento),
                        onTap: () =>
                            widget.onDetalleSeleccionado?.call(a),
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
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
                childCount: alojamientos.length +
                    (cargando || paginaActual >= totalPaginas ? 1 : 0),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ScrollBoton(controller: controller),
        )
      ],
    );
  }

  Widget _searchBar() {
    return SearchBar(
      hintText: 'Buscar alojamiento...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.search,
            size: 18, color: Colors.grey.shade600),
      ),
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
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
        _resetYcargar();
      },
    );
  }

  Widget _filtros() {
    return Row(
      children: [
        Expanded(child: _selectorCategorias()),
        const SizedBox(width: 8),
        Expanded(child: _selectorLocalidad()),
        if (categoria != null || localidad != null) ...[
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
        child: Icon(Icons.clear,
            size: 18, color: Colors.red.shade700),
      ),
    );
  }

  // ────────────────── INPUTS ──────────────────

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

  Widget _selectorCategorias() => FutureBuilder<List<String>>(
    future: futureCategorias,
    builder: (c, s) {
      if (!s.hasData) return _shimmer();
      final categorias = s.data!;
      return Autocomplete<String>(
        optionsBuilder: (v) => v.text.isEmpty
            ? const Iterable<String>.empty()
            : categorias.where((c) =>
            c.toLowerCase().contains(v.text.toLowerCase())),
        onSelected: (s) {
          categoria = s;
          _resetYcargar();
        },
        fieldViewBuilder:
            (_, ctrl, focus, __) => TextField(
          controller: ctrl,
          focusNode: focus,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDeco(
            label: "Categoría",
            icon: Icons.category,
            hasValue: categoria != null,
            onClear: () {
              categoria = null;
              ctrl.clear();
              _resetYcargar();
            },
          ),
        ),
      );
    },
  );

  Widget _selectorLocalidad() =>
      FutureBuilder<List<Localidad>>(
        future: futureLocalidad,
        builder: (c, s) {
          if (!s.hasData) return _shimmer();
          final locs = s.data!;
          return Autocomplete<Localidad>(
            displayStringForOption: (l) => l.nombre,
            optionsBuilder: (v) => v.text.isEmpty
                ? const Iterable<Localidad>.empty()
                : locs.where((l) =>
                l.nombre
                    .toLowerCase()
                    .contains(v.text.toLowerCase())),
            onSelected: (l) {
              localidad = l.ine;
              _resetYcargar();
            },
            fieldViewBuilder:
                (_, ctrl, focus, __) => TextField(
              controller: ctrl,
              focusNode: focus,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDeco(
                label: "Ubicación",
                icon: Icons.location_on,
                hasValue: localidad != null,
                onClear: () {
                  localidad = null;
                  ctrl.clear();
                  _resetYcargar();
                },
              ),
            ),
          );
        },
      );

  Widget _shimmer() => Container(
    height: 36,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}