import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/actividadesApi.dart';
import 'package:kultux/tarjetasBusqueda.dart';
import 'package:kultux/componentes/scroll_boton.dart';
import 'package:kultux/core/utils/estado_ui.dart';

import 'core/utils/http_error_mapper.dart';

import 'package:kultux/core/utils/estados_widgets.dart';

class BuscarActividadPage extends StatefulWidget {
  final Function(dynamic)? onDetalleSeleccionado;
  const BuscarActividadPage({super.key, this.onDetalleSeleccionado});

  @override
  State<BuscarActividadPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarActividadPage> {
  late Future<List<Localidad>> futureLocalidad;
  late Future<List<String>> futureCategorias;

  String titulo = "";
  String? categoria;
  int? localidad;
  DateTime? fecha;

  List<Actividad> actividades = [];
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
    futureCategorias = ActividadesApiService.categoriasActividad();

    _cargaInicial();

    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });

  }


  Future<void> _resetYcargar() async {
    paginaActual = 0;
    actividades.clear();
    await _cargarMas();
  }


  Future<void> _cargarActividades() async {
    await _resetYcargar();
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
      final pageResponse = await ActividadesApiService.actividadesFiltradas(
        titulo: titulo.isEmpty ? null : titulo,
        categoria: categoria,
        localidad: localidad,
        fecha: fecha,
        page: paginaActual,
      );
      setState(() {
        actividades.addAll(pageResponse.contenido);
        totalPaginas = pageResponse.totalPaginas;
        paginaActual++;
        estado = actividades.isEmpty ? EstadoUi.vacio : EstadoUi.contenido;
      });
    }on SocketException {
      setState(() {
        estado = EstadoUi.sinConexion;
        mensajeError = 'No hay conexion a internet';
      });
    }on HttpException catch (e){
      final uiError = mapearStatusCode(int.parse(e.message));
      setState(() {
        estado = uiError.estado;
        mensajeError = uiError.mensaje;
      });
    }catch (_) {
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
            // Barra de búsqueda
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

            // Filtros
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _filtros(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Lista
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < actividades.length) {
                    final a = actividades[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: TarjetaBusqueda.actividad(
                        titulo: a.titulo,
                        localidad: a.localidad,
                        fecha: a.fechaInicio,
                        imagenUrl: a.imagenPrincipal,
                        onTap: () => widget.onDetalleSeleccionado?.call(a),
                        textoEtiqueta: a.categoriaActividad,
                        iconoEtiqueta: 'assets/iconos/actividad_etiquetas.svg',
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
                          "No hay más actividades",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
                childCount:
                actividades.length + (cargando || paginaActual >= totalPaginas ? 1 : 0),
              ),
            ),
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

  Widget _searchBar() {
    return SearchBar(
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
        _cargarActividades();
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
            if (categoria != null || localidad != null || fecha != null) ...[
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

  // ── Decoración compacta compartida ──
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
            _cargarActividades();
          },
          fieldViewBuilder: (context, ctrl, focusNode, _) {
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
    return FutureBuilder<List<Localidad>>(
      future: futureLocalidad,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        final localidades = snapshot.data!;
        return Autocomplete<Localidad>(
          optionsBuilder: (v) {
            if (v.text.isEmpty) return const Iterable<Localidad>.empty();
            return localidades.where((l) =>
                l.nombre.toLowerCase().contains(v.text.toLowerCase()));
          },
          onSelected: (s) {
            setState(() => localidad = s.ine);
            _cargarActividades();
          },
          displayStringForOption: (o) => o.nombre,
          fieldViewBuilder: (context, ctrl, focusNode, _) {
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDeco(
                label: 'Ubicación',
                icon: Icons.location_on,
                hasValue: localidad != null,
                onClear: () {
                  setState(() => localidad = null);
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
                      title: Text(o.nombre, style: const TextStyle(fontSize: 13)),
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


  Widget _selectorFecha() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
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
          color: fecha == null ? Colors.grey.shade100 : const Color.fromARGB(30, 166, 226, 70),
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
    controller.dispose();
    super.dispose();
  }
}