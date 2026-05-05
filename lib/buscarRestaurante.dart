import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/pages.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/restauranteApi.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/tarjetas.dart';
import 'package:kultux/tarjetasBusqueda.dart';

import 'package:kultux/core/utils/iconos.dart';
class BuscarRestaurantePage extends StatefulWidget {
  const BuscarRestaurantePage({super.key});

  @override
  State<BuscarRestaurantePage> createState() => _BuscarRestaurantePageState();
}

class _BuscarRestaurantePageState extends State<BuscarRestaurantePage> {
  late Future<List<Localidad>> futureLocalidad;
  late Future<List<String>> futureCategorias;

  String nombre = "";
  String? categoria;
  int? localidad;
  bool? soloAbiertos;

  List<Restaurante> restaurantes = [];
  int paginaActual = 0;
  int totalPaginas = 0;

  bool cargando = false;
  bool cargandoInicial = true;

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    futureLocalidad = LocalidadApiService.obtenerLocalidadNombres();
    futureCategorias = RestauranteApiService.categoriasRestaurantes();

    _cargaInicial();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _resetYcargar() async {
    paginaActual = 0;
    restaurantes.clear();
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

    setState(() => cargando = true);

    try {
      final pageResponse =
      await RestauranteApiService.restaurantesFiltrados(
        nombre: nombre.isEmpty ? null : nombre,
        categoria: categoria,
        localidad: localidad,
        soloAbiertos: soloAbiertos,
        page: paginaActual,
      );

      setState(() {
        restaurantes.addAll(pageResponse.contenido);
        totalPaginas = pageResponse.totalPaginas;
        paginaActual++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en búsqueda: $e")),
      );
    }

    setState(() => cargando = false);
  }

  // ───────────────── BUILD ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cargandoInicial
          ? const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 166, 226, 70),
        ),
      )
          : CustomScrollView(
        controller: controller,
        slivers: [
          // ── Search ──

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


          // ── Filtros ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _filtros(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Empty / List ──
          if (restaurantes.isEmpty && !cargando)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      "No hay restaurantes",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < restaurantes.length) {
                    final r = restaurantes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: TarjetaBusqueda.restaurante(
                        titulo: r.nombre,
                        imagenUrl: r.imagenPrincipal,
                        textoEtiqueta: r.categoriaRestaurante,
                        iconoEtiqueta: Iconos.getIconoRestaurante(
                            r.categoriaRestaurante),
                        horario: r.horario!,
                        abierto: r.abierto!,
                        localidad: r.localidad,
                        onTap: () {},
                      ),
                    );
                  }

                  if (cargando) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color:
                          Color.fromARGB(255, 166, 226, 70),
                        ),
                      ),
                    );
                  }

                  if (paginaActual >= totalPaginas) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No hay más restaurantes",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
                childCount: restaurantes.length +
                    (cargando || paginaActual >= totalPaginas
                        ? 1
                        : 0),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────── UI COMPONENTS ─────────────────

  Widget _searchBar() {
    return SearchBar(
      hintText: 'Buscar restaurante...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child:
        Icon(Icons.search, size: 18, color: Colors.grey.shade600),
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
        _resetYcargar();
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
                soloAbiertos == true) ...[
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

  // ───────────────── SELECTORES ─────────────────
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
      if (!s.hasData) return _shimmerLoader();
      return Autocomplete<String>(
        optionsBuilder: (v) => v.text.isEmpty
            ? const Iterable<String>.empty()
            : s.data!.where((c) =>
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
          if (!s.hasData) return _shimmerLoader();
          return Autocomplete<Localidad>(
            optionsBuilder: (v) => v.text.isEmpty
                ? const Iterable<Localidad>.empty()
                : s.data!.where((l) => l.nombre
                .toLowerCase()
                .contains(v.text.toLowerCase())),
            onSelected: (l) {
              localidad = l.ine;
              _resetYcargar();
            },
            displayStringForOption: (l) => l.nombre,
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

  Widget _shimmerLoader() => Container(
    height: 36,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
  );



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
          color: seleccionado ? Color.fromARGB(136, 166, 226, 70):  Colors.grey.shade100,
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
    controller.dispose();
    super.dispose();
  }
}