import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kultux/features/map/point_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/features/detail/detail_page.dart';


import 'package:kultux/shared/widget/page_header.dart';

import 'package:kultux/core/utils/web_container.dart';
import 'package:kultux/core/utils/widget_states.dart';

import 'activities_list.dart';



class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  List<PointMap> _points = [];
  bool _mapLoading = true;
  String? _mapError;

  PointMap? _selectedLocation;
  Activity? _selectedActivity;

  static final _limits = LatLngBounds(LatLng(37.9, -8.4), LatLng(40.5, -4.0));

  static List<List<LatLng>>? _extremaduraCache;

  @override
  void initState() {
    super.initState();
    _loadExtremadura();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final locations = await LocationApiService.locationsMap();
      final totals = await ActivityApiService.activitiesTotalMap(
        startDate: null,
        endDate:null
      );

      final Map<int, int> totalMap = {
        for (final t in totals) t.ine!: t.total ?? 0,
      };

      final points = locations
          .where(
            (l) =>
                l.lat != null &&
                l.lon != null &&
                totalMap[l.ine] != null &&
                totalMap[l.ine]! > 0,
          )
          .map(
            (l) => PointMap(
              ine: l.ine,
              name: l.name,
              coordinates: LatLng(l.lat!, l.lon!),
              totalActivities: totalMap[l.ine]!,
            ),
          )
          .toList();

      if (mounted) {
        setState(() {
          _points = points;
          _mapLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mapError = e.toString();
          _mapLoading = false;
        });
      }
    }
  }

  void _openLocation(PointMap punto) => setState(() {
    _selectedLocation = punto;
    _selectedActivity = null;
  });

  void _backToMap() => setState(() {
    _selectedLocation = null;
    _selectedActivity = null;
  });

  void _openDetail(Activity activity) =>
      setState(() => _selectedActivity = activity);

  void _backToList() => setState(() => _selectedActivity = null);

  List<List<LatLng>> _extremadura = [];

  Future<void> _loadExtremadura() async {
    if (_extremaduraCache != null) {
      setState(() {
        _extremadura = _extremaduraCache!;
      });
      return;
    }
    final str = await rootBundle.loadString(
      'assets/assets/extremadura.geojson',
    );
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
    _extremaduraCache = result;
    if (mounted) {
      setState(() {
        _extremadura = result;
      });
    }
  }

  void _mapReset() {
    _mapController.camera.center;
    _mapController.camera.zoom;
    _mapController.move(const LatLng(39.2, -6.15), 7.75);
    _mapController.rotate(0);
  }

  LatLng _clampLatLng(LatLng p) {
    final lat = p.latitude.clamp(_limits.south + 0.1, _limits.north - 0.1);
    final lng = p.longitude.clamp(_limits.west + 0.1, _limits.east - 0.1);

    return LatLng(lat, lng);
  }

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
            maxZoom: 12.0,
            onPositionChanged: (position, hasGesture) {
              if (!hasGesture) return;

              final center = position.center;

              final clamped = _clampLatLng(center);
              if (center != clamped) {
                _mapController.move(clamped, position.zoom);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kultux.kultux',
              keepBuffer: 5,
              panBuffer: 2,
              maxNativeZoom: 18,
              tileSize: 256,
              evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
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

            if (!_mapLoading && _mapError == null)
              MarkerLayer(
                markers: _points
                    .map(
                      (p) => Marker(
                        point: p.coordinates,
                        width: 36,
                        height: 36,
                        alignment: Alignment(0, -1.0),
                        child: GestureDetector(
                          onTap: () => _openLocation(p),
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
                              '${p.totalActivities}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFA8D63F),
            onPressed: _mapReset,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),

        if (_mapLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFA8D63F)),
          ),

        if (_mapError != null)
          Container(
            color: Colors.white,
            child: errorState(
              icon: Icons.wifi_off,
              mensaje: 'No hay conexión a internet',
              onRetry: () {
                setState(() {
                  _mapError = null;
                  _mapLoading = true;
                });
                _loadData();
              },
            ),
          ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _selectedActivity != null
              ? WebContainer(
                  key: const ValueKey('detalle_mapa'),
                  child: Column(
                    children: [
                      PageHeader(
                        title: _selectedLocation!.name,
                        subtitle: 'Detalle',
                        onBack: _backToList,
                      ),
                      Expanded(
                        child: DetailPage.fromObject(
                          objeto: _selectedActivity!,
                        ),
                      ),
                    ],
                  ),
                )
              : _selectedLocation != null
              ? WebContainer(
                  key: const ValueKey('lista_mapa'),
                  child: Column(
                    children: [
                      PageHeader(
                        title: _selectedLocation!.name,
                        subtitle: 'Actividades en',
                        onBack: _backToMap,
                      ),
                      Expanded(
                        child: ActivitiesList(
                          point: _selectedLocation!,
                          onDetail: _openDetail,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('vacio_mapa')),
        ),
      ],
    );
  }
}
