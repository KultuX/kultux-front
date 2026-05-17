import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/api/localidadesAPI.dart';
import 'package:kultux/API/actividadesAPI.dart';
import 'package:kultux/componentes/tarjetas.dart';
import 'package:kultux/detalles.dart';

import 'componentes/cabecera.dart';

class PuntoMapa {
  final int ine;
  final String nombre;
  final LatLng coordenadas;
  final int totalActividades;

  const PuntoMapa({
    required this.ine,
    required this.nombre,
    required this.coordenadas,
    required this.totalActividades,
  });
}

class MapasPage extends StatefulWidget {
  const MapasPage({super.key});
  @override
  State<MapasPage> createState() => _MapasPageState();
}

class _MapasPageState extends State<MapasPage> {
  final MapController _mapController = MapController();
  List<PuntoMapa> _puntos = [];
  bool _cargandoMapa = true;
  String? _errorMapa;


  PuntoMapa? _localidadSeleccionada;
  Actividad? _actividadSeleccionada;





  static final _limites = LatLngBounds(
    LatLng(37.9, -8.4),
    LatLng(40.5, -4.0),
  );

  @override
  void initState() {
    super.initState();
    _cargarExtremadura();
    print("Extremadura polygons: ${_extremadura.length}");
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final localidades = await LocalidadApiService.obtenerLocalidadesMapa();
      final ines = localidades.map((l) => l.ine).toList();
      final totales = await ActividadesApiService.actividadesTotalMapa(ines: ines);

      final Map<int, int> totalMap = {
        for (final t in totales) t.ine!: t.total ?? 0
      };

      final puntos = localidades
          .where((l) => l.lat != null && l.lon != null)
          .map((l) => PuntoMapa(
        ine: l.ine,
        nombre: l.nombre,
        coordenadas: LatLng(l.lat!, l.lon!),
        totalActividades: totalMap[l.ine] ?? 0,
      ))
          .where((p) => p.totalActividades > 0)
          .toList();

      if (mounted) setState(() { _puntos = puntos; _cargandoMapa = false; });
    } catch (e) {

      if (mounted) setState(() { _errorMapa = e.toString(); _cargandoMapa = false; });
    }
  }

  void _abrirLocalidad(PuntoMapa punto) =>
      setState(() { _localidadSeleccionada = punto; _actividadSeleccionada = null; });

  void _volverAlMapa() =>
      setState(() { _localidadSeleccionada = null; _actividadSeleccionada = null; });

  void _abrirDetalle(Actividad actividad) =>
      setState(() => _actividadSeleccionada = actividad);

  void _volverALista() =>
      setState(() => _actividadSeleccionada = null);


 List<List<LatLng>> _extremadura = [];

  Future<void> _cargarExtremadura() async {
    final str = await rootBundle.loadString('assets/assets/extremadura.geojson');
    final json = jsonDecode(str);

    final multi = json['coordinates'] as List;

    final result = multi.map<List<LatLng>>((polygon) {
      final rings = polygon as List;
      final outerRing = rings[0] as List;

      return outerRing.map<LatLng>((c) {
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();
    }).toList();
    print("Polígonos encontrados: ${multi.length}");

    setState(() {
      _extremadura = result;
    });
  }

  void _resetMapa() {
    _mapController.camera.center;
    _mapController.camera.zoom;
    _mapController.move(
      const LatLng(39.2, -6.15),
      7.75,
    );
    _mapController.rotate(0);
  }

  LatLng _clampLatLng(LatLng p) {
    final lat = p.latitude.clamp(_limites.south + 0.1, _limites.north - 0.1);
    final lng = p.longitude.clamp(_limites.west + 0.1, _limites.east - 0.1);

    return LatLng(lat, lng);
  }

  bool _corrigiendo = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(39.2, -6.15),
            initialZoom: 7.75,
            minZoom: 7.5,
            maxZoom: 13.0,
            onPositionChanged: (position, hasGesture) {
              if (!hasGesture) return;

              final center = position.center;

              final clamped = _clampLatLng(center);
              if (center != clamped) {
                _mapController.move(
                  clamped,
                  position.zoom,
                );
              }
            },

          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kultux.kultux',
              keepBuffer: 5,
              panBuffer: 2,
            ),
            if (_extremadura.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: const [
                      LatLng(-90, -180),
                      LatLng(-90, 180),
                      LatLng(90, 180),
                      LatLng(90, -180),
                    ],
                    holePointsList: _extremadura,
                    color: Colors.black.withOpacity(0.35),
                    borderStrokeWidth: 0,
                  ),
                ],
              ),

            if (_extremadura.isNotEmpty)
              PolygonLayer(
                polygons: _extremadura.map((poly) {
                  return Polygon(
                    points: poly,
                    color: Colors.transparent,
                    borderColor: const Color(0xFFA8D63F),
                    borderStrokeWidth: 3,
                  );
                }).toList(),
              ),

            if (!_cargandoMapa && _errorMapa == null)
              MarkerLayer(
                markers: _puntos.map((p) => Marker(
                  point: p.coordenadas,
                  width: 36,
                  height: 36,
                  alignment: Alignment(0, -1.0),
                  child: GestureDetector(
                    onTap: () => _abrirLocalidad(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8D63F),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 1, // fino
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${p.totalActividades}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFA8D63F),
            onPressed: _resetMapa,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),

        if (_cargandoMapa)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFA8D63F)),
          ),


        if (_errorMapa != null)
          Center(child: Text('Error al cargar mapa')),


       if (_localidadSeleccionada != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

        if (_localidadSeleccionada != null && _actividadSeleccionada == null)
          Column(
            children: [
              CabeceraPagina(
                titulo: '${_localidadSeleccionada!.nombre}',
                subtitulo: 'Actividades en',
                onVolver: _volverAlMapa,
              ),
              Expanded(
                child: _ListaActividades(
                  punto: _localidadSeleccionada!,
                  onDetalle: _abrirDetalle,
                ),
              ),
            ],
          ),
        if (_actividadSeleccionada != null)
          Column(
            children: [
              CabeceraPagina(
                titulo: '${_localidadSeleccionada!.nombre}',
                subtitulo: 'Detalle',
                onVolver: _volverALista,
              ),
              Expanded(
                child: Detalle.desdeObjeto(
                  objeto: _actividadSeleccionada!,
                ),
              ),
            ],
          ),

      ],
    );
  }
}


class _ListaActividades extends StatefulWidget {
  final PuntoMapa punto;
  final void Function(Actividad) onDetalle;

  const _ListaActividades({required this.punto, required this.onDetalle});

  @override
  State<_ListaActividades> createState() => _ListaActividadesState();
}

class _ListaActividadesState extends State<_ListaActividades> {
  final List<Actividad> _actividades = [];
  final ScrollController _scroll = ScrollController();
  int _pagina = 0;
  bool _cargando = false;
  bool _hayMas = true;

  @override
  void initState() {
    super.initState();
    _cargarMas();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) _cargarMas();
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  Future<void> _cargarMas() async {
    if (_cargando || !_hayMas) return;
    setState(() => _cargando = true);
    try {
      final page = await ActividadesApiService.listaActividadesGuardadas(
        ine: widget.punto.ine,
        page: _pagina,
      );
      setState(() {
        _actividades.addAll(page.contenido);
        _pagina++;
        _hayMas = _pagina < page.totalPaginas;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_actividades.isEmpty && _cargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA8D63F)));
    }
    if (_actividades.isEmpty) {
      return const Center(child: Text('No hay actividades disponibles'));
    }
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _actividades.length + (_hayMas ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {        if (i == _actividades.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Color(0xFFA8D63F)),
            ),
          );
        }
        final a = _actividades[i];
        return Tarjeta.actividades(
          titulo: a.titulo,
          localidad: a.localidad ?? '',
          fecha: a.fechaInicio,
          imagenUrl: a.imagenPrincipal,
          onTap: () async {
            final detalle = await ActividadesApiService.detalleActividad(a.id);
            widget.onDetalle(detalle);
          },
        );
      },
    );
  }
}