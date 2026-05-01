import 'package:flutter/material.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/api/restauranteAPI.dart';
import 'package:kultux/api/alojamientoAPI.dart';
import 'package:kultux/tarjetas.dart';

class EstablecimientosPage extends StatefulWidget {
  final Function(dynamic objetoDetalle) onDetalleSeleccionado;

  const EstablecimientosPage({
    super.key,
    required this.onDetalleSeleccionado,
  });

  @override
  State<EstablecimientosPage> createState() => _EstablecimientosPageState();
}

class _EstablecimientosPageState extends State<EstablecimientosPage> {
  late Future<List<Restaurante>> _futureRestaurantes;
  late Future<List<Alojamiento>> _futureAlojamientos;

  Future<List<Restaurante>>? _futureTodosRestaurantes;
  Future<List<Alojamiento>>? _futureTodosAlojamientos;

  bool _mostrandoListado = false;
  bool _mostrandoListadoRestaurantes = false;
  bool _mostrandoListadoAlojamientos = false;

  Map<String, String> iconosAlojamiento={
    "HOTEL":"assets/iconos/hotel.svg",
    "HOSTAL":"assets/iconos/hostal.svg",
    "APARTAMENTO_TURISTICO":"assets/iconos/apartamento.svg",
    "CASA_RURAL":"assets/iconos/casa_rural.svg",
    "PENSION":"assets/iconos/hostal.svg",
    "CAMPING":"assets/iconos/casa_rural.svg",
    "ALBERGUE":"assets/iconos/casa_rural.svg",
    "PARADOR": "assets/iconos/casa_rural.svg",
    "RESORT":"assets/iconos/hotel.svg",
    "BALNEARIO":"assets/iconos/hotel.svg",
    "APARTAHOTEL":"assets/iconos/hostal.svg",
    "BUNGALOW":"assets/iconos/hostal.svg",
    "FINCA":"assets/iconos/casa_rural.svg",
  };

  Map<String, String> iconosRestaurante={
    "TRADICIONAL":"assets/iconos/restaurantes.svg",
    "EXTREMEÑA":"assets/iconos/restaurantes.svg",
    "INTERNACIONAL":"assets/iconos/restaurantes.svg",
    "ESPAÑOLA":"assets/iconos/restaurantes.svg",
    "ALTA_COCINA":"assets/iconos/restaurantes.svg",
    "ASADORES_Y_PARRILLAS":"assets/iconos/restaurantes.svg",
    "MARISQUERIAS":"assets/iconos/restaurantes.svg",
    "ITALIANO": "assets/iconos/restaurantes.svg",
    "MEXICANO":"assets/iconos/restaurantes.svg",
    "ASIATICO":"assets/iconos/restaurantes.svg",
    "VEGETARIANO":"assets/iconos/restaurantes.svg",
    "VEGANO":"assets/iconos/restaurantes.svg",
    "TAPAS":"assets/iconos/cerveceria.svg",
    "CAFETERIA":"assets/iconos/cafeteria.svg",
    "HAMBURGUESERIA":"assets/iconos/restaurante.svg",
    "PIZZERIA":"assets/iconos/restaurante.svg",
    "COPAS":"assets/iconos/copas.svg"
  };


  @override
  void initState() {
    super.initState();
    _futureRestaurantes = RestauranteApiService.obtenerRestauranteDestacados();
    _futureAlojamientos = AlojamientoApiService.obtenerAlojamientoDestacados();
  }

  void _abrirListadoRestaurantes() {
    setState(() {
      _mostrandoListado = true;
      _mostrandoListadoRestaurantes = true;
      _mostrandoListadoAlojamientos = false;
      _futureTodosRestaurantes ??=
          RestauranteApiService.obtenerRestauranteDestacados();
    });
  }

  void _abrirListadoAlojamientos() {
    setState(() {
      _mostrandoListado = true;
      _mostrandoListadoRestaurantes = false;
      _mostrandoListadoAlojamientos = true;
      _futureTodosAlojamientos ??=
          AlojamientoApiService.obtenerAlojamientoDestacados();
    });
  }

  void _volverResumen() {
    setState(() {
      _mostrandoListado = false;
      _mostrandoListadoRestaurantes = false;
      _mostrandoListadoAlojamientos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrandoListado) {
      if (_mostrandoListadoRestaurantes) {
        return _buildListadoRestaurantes();
      }

      if (_mostrandoListadoAlojamientos) {
        return _buildListadoAlojamientos();
      }
    }

    return FutureBuilder(
      future: Future.wait([
        _futureRestaurantes,
        _futureAlojamientos,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color.fromARGB(255, 166, 226, 70)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final restaurantes = snapshot.data![0] as List<Restaurante>;
        final alojamientos = snapshot.data![1] as List<Alojamiento>;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          child: Column(
            children: [
              const Text(
                "Establecimientos",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _tarjetaEstablecimiento(
                tituloBloque: 'RESTAURANTES DESTACADOS',
                items: restaurantes.map((r) {
                  return _ItemEstablecimiento(
                    titulo: r.nombre,
                    imagenUrl: r.imagenPrincipal,
                    onTap: () async {
                      try {
                        final restauranteDetalle =
                        await RestauranteApiService
                            .obtenerRestauranteDetalle(r.id);

                        widget.onDetalleSeleccionado(restauranteDetalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            content: Text('Error al cargar detalle: $e'),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
                onVerMas: _abrirListadoRestaurantes,
              ),
              const SizedBox(height: 22),
              _tarjetaEstablecimiento(
                tituloBloque: 'ALOJAMIENTOS DESTACADOS',
                items: alojamientos.map((a) {
                  return _ItemEstablecimiento(
                    titulo: a.nombre,
                    imagenUrl: a.imagenPrincipal,
                    onTap: () async {
                      try {
                        final alojamientoDetalle =
                        await AlojamientoApiService
                            .obtenerAlojamientoDetalle(a.id);

                        widget.onDetalleSeleccionado(alojamientoDetalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            content: Text('Error al cargar detalle: $e'),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
                onVerMas: _abrirListadoAlojamientos,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListadoRestaurantes() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: _volverResumen,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Restaurantes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Restaurante>>(
            future: _futureTodosRestaurantes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color.fromARGB(255, 166, 226, 70)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final restaurantes = snapshot.data ?? [];

              if (restaurantes.isEmpty) {
                return const Center(
                  child: Text('No hay restaurantes disponibles'),
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: restaurantes.length,
                itemBuilder: (context, index) {
                  final restaurante = restaurantes[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tarjeta.restaurante(
                      titulo: restaurante.nombre,
                      imagenUrl: restaurante.imagenPrincipal,
                      textoEtiqueta: restaurante.categoriaRestaurante[0].toUpperCase() +
                          restaurante.categoriaRestaurante.substring(1).toLowerCase(),
                      iconoEtiqueta: iconosRestaurante[restaurante.categoriaRestaurante]!,
                      onTap: () async {
                        try {
                          final restauranteDetalle =
                          await RestauranteApiService
                              .obtenerRestauranteDetalle(restaurante.id);

                          widget.onDetalleSeleccionado(restauranteDetalle);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cargar detalle: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListadoAlojamientos() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: _volverResumen,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Alojamientos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Alojamiento>>(
            future: _futureTodosAlojamientos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final alojamientos = snapshot.data ?? [];

              if (alojamientos.isEmpty) {
                return const Center(
                  child: Text('No hay alojamientos disponibles'),
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: alojamientos.length,
                itemBuilder: (context, index) {
                  final alojamiento = alojamientos[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tarjeta.alojamiento(
                      titulo: alojamiento.nombre,
                      imagenUrl: alojamiento.imagenPrincipal,
                      textoEtiqueta: alojamiento.categoriaAlojamiento[0].toUpperCase() +
                          alojamiento.categoriaAlojamiento.substring(1).toLowerCase(),
                      iconoEtiqueta: iconosAlojamiento[alojamiento.categoriaAlojamiento]!,
                      onTap: () async {
                        try {
                          final alojamientoDetalle =
                          await AlojamientoApiService
                              .obtenerAlojamientoDetalle(alojamiento.id);

                          widget.onDetalleSeleccionado(alojamientoDetalle);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cargar detalle: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tarjetaEstablecimiento({
    required String tituloBloque,
    required List<_ItemEstablecimiento> items,
    required VoidCallback onVerMas,
  }) {
    final filas = <Widget>[];

    for (int i = 0; i < items.length; i += 3) {
      final filaItems = items.skip(i).take(3).toList();

      filas.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(filaItems.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const SizedBox(width: 10);
            }

            final item = filaItems[index ~/ 2];

            return Expanded(
              child: _miniTarjetaEstablecimiento(item: item),
            );
          }),
        ),
      );

      if (i + 3 < items.length) {
        filas.add(const SizedBox(height: 16));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              tituloBloque,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...filas,
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 66,
              height: 26,
              child: BotonesGenerico(
                titulo: "Ver más",
                ancho: 66,
                pulsar: onVerMas,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTarjetaEstablecimiento({
    required _ItemEstablecimiento item,
  }) {
    const Color verdeKultux = Color(0xFFA8D63F);

    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: verdeKultux,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 6),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: verdeKultux,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemEstablecimiento {
  final String titulo;
  final String imagenUrl;
  final VoidCallback? onTap;

  const _ItemEstablecimiento({
    required this.titulo,
    required this.imagenUrl,
    this.onTap,
  });
}