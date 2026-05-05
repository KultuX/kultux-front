import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/alojamientoApi.dart';
import 'package:kultux/tarjetas.dart';
import 'package:kultux/tarjetasBusqueda.dart';
import 'package:kultux/core/utils/iconos.dart';

class BuscarAlojamientoPage extends StatefulWidget {

  const BuscarAlojamientoPage({super.key});

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

  @override
  void initState() {
    super.initState();

    futureLocalidad = LocalidadApiService.obtenerLocalidadNombres();
    futureCategorias = AlojamientoApiService.categoriaAlojamientos();

    _cargarAlojamientos();

    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _cargarAlojamientos() async {
    paginaActual = 0;
    alojamientos.clear();
    setState(() => cargandoInicial = true);
    await _cargarMas();
    setState(() => cargandoInicial = false);
  }

  Future<void> _cargarMas() async {
    if (cargando) return;
    if (paginaActual >= totalPaginas && paginaActual != 0) return;

    setState(() => cargando = true);

    try {
      final pageResponse = await AlojamientoApiService.alojamientosFiltrados(
        nombre: nombre.isEmpty ? null : nombre,
        categoria: categoria,
        localidad: localidad,
        page: paginaActual,
      );

      setState(() {
        alojamientos.addAll(pageResponse.contenido);
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
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: _searchBar(),
          ),

          // FILTROS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _filtros(),
          ),

          const SizedBox(height: 12),

          // LISTADO
          Expanded(
            child: cargandoInicial
                ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 166, 226, 70)))
                : alojamientos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No hay alojamientos",
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
              itemCount:
              alojamientos.length + (cargando ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < alojamientos.length) {
                  final a = alojamientos[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: TarjetaBusqueda.alojamiento(
                      titulo: a.nombre,
                      localidad: a.localidad?.nombre,
                      imagenUrl: a.imagenPrincipal,
                      onTap: () {},
                      textoEtiqueta: a.categoriaAlojamiento,
                      iconoEtiqueta:
                      Iconos.getIconoAlojamiento(
                          a.categoriaAlojamiento),
                    ),
                  );
                }

                if (cargando) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: CircularProgressIndicator(color: Color.fromARGB(255, 166, 226, 70))),
                  );
                }

                if (paginaActual >= totalPaginas) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "¡Ya no hay más alojamientos para mostrar!",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _searchBar() {
    return SearchBar(
      hintText: 'Buscar alojamiento...',
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(Icons.search, color: Colors.grey.shade600),
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
        _cargarAlojamientos();
      },
    );
  }

  // FILTROS
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

                  _cargarAlojamientos();
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
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return categorias.where((cat) => cat
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) {
            setState(() => categoria = selection);
            _cargarAlojamientos();
          },
          fieldViewBuilder: (context, controller, focusNode, _) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: categoria != null
                    ? GestureDetector(
                  onTap: () {
                    setState(() => categoria = null);
                    controller.clear();
                    _cargarAlojamientos();
                  },
                  child: Icon(Icons.clear),
                )
                    : Icon(Icons.category),
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
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Localidad>.empty();
            }
            return localidades.where((loc) => loc.nombre
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) {
            setState(() => localidad = selection.ine);
            _cargarAlojamientos();
          },
          displayStringForOption: (option) => option.nombre,
          fieldViewBuilder: (context, controller, focusNode, _) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Ubicación',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: localidad != null
                    ? GestureDetector(
                  onTap: () {
                    setState(() => localidad = null);
                    controller.clear();
                    _cargarAlojamientos();
                  },
                  child: Icon(Icons.clear),
                )
                    : Icon(Icons.location_on),
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