import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/pages.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/restauranteApi.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/tarjetas.dart';

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

    _cargarRestaurantes();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _cargarRestaurantes() async {
    paginaActual = 0;
    restaurantes.clear();
    setState(() => cargandoInicial = true);
    await _cargarMas();
    setState(() => cargandoInicial = false);
  }

  Future<void> _cargarMas() async {
    if (cargando) return;
    if (paginaActual >= totalPaginas && paginaActual != 0) return;

    setState(() => cargando = true);

    try {
      final pageResponse = await RestauranteApiService.restaurantesFiltrados(
        nombre: nombre.isEmpty ? null : nombre,
        categoria: categoria,
        localidad: localidad,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 166, 226, 70), Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  "BUSCAR RESTAURANTES",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Encuentra restaurantes cerca de ti",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _searchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _filtros(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: cargandoInicial
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : restaurantes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No hay restaurantes",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: controller,
              itemCount: restaurantes.length + (cargando ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < restaurantes.length) {
                  final r = restaurantes[index];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Tarjeta.restauranteBusqueda(
                      titulo: r.nombre,
                      imagenUrl: r.imagenPrincipal,
                      textoEtiqueta: r.categoriaRestaurante,
                      iconoEtiqueta: Iconos.getIconoRestaurante(r.categoriaRestaurante),
                      onTap: () {},
                      horario: r.horario!,
                      abierto: r.abierto!,
                      localidad: r.localidad,

                    ),
                  );
                }

                if (cargando) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (paginaActual >= totalPaginas) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "¡Ya no hay más restaurantes para mostrar, ve a la sección de buscar!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return SearchBar(
      hintText: 'Buscar restaurante...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(
          Icons.search,
          color: Colors.grey.shade600,
        ),
      ),
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      onChanged: (value) {
        nombre = value;
        _cargarRestaurantes();
      },
    );
  }

  Widget _filtros() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _selectorCategorias()),
            const SizedBox(width: 12),
            Expanded(child: _selectorLocalidad()),
          ],
        ),
        const SizedBox(height: 12),

        // BOTÓN LIMPIAR
        if (categoria != null || localidad != null)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    categoria = null;
                    localidad = null;
                    nombre = "";
                  });

                  _cargarRestaurantes();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: Colors.red.shade300),
                  ),
                  child: Icon(Icons.clear,
                      color: Colors.red.shade700),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _selectorCategorias() {

    return FutureBuilder<List<String>>(
      future: futureCategorias,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _shimmerLoader();
        }

        final categorias = snapshot.data!;

        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return categorias.where((cat) => cat
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            setState(() => categoria = selection);
            _cargarRestaurantes();
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                  borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: categoria != null
                    ? GestureDetector(
                  onTap: () {
                    setState(() => categoria = null);
                    textEditingController.clear();
                    _cargarRestaurantes();
                  },
                  child: Icon(Icons.clear, size: 20, color: Colors.grey.shade600),
                )
                    : Icon(Icons.category, size: 20, color: Colors.grey.shade600),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _selectorLocalidad() {
    return FutureBuilder<List<Localidad>>(
      future: futureLocalidad,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _shimmerLoader();
        }

        final localidades = snapshot.data!;

        return Autocomplete<Localidad>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Localidad>.empty();
            }
            return localidades.where((loc) => loc.nombre
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (Localidad selection) {
            print("LOCALIDAD SELECCIONADA: ${selection.nombre} -> ${selection.ine}");
            setState(() => localidad = selection.ine);
            _cargarRestaurantes();
          },
          displayStringForOption: (Localidad option) => option.nombre,
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Ubicación',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                  borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: localidad != null
                    ? GestureDetector(
                  onTap: () {
                    setState(() => localidad = null);
                    textEditingController.clear();
                    _cargarRestaurantes();
                  },
                  child: Icon(Icons.clear, size: 20, color: Colors.grey.shade600),
                )
                    : Icon(Icons.location_on, size: 20, color: Colors.grey.shade600),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.nombre),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerLoader() {
    return Container(
      height: 44,
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