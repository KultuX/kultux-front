
import 'package:flutter/cupertino.dart';
import 'package:kultux/features/map/point_map.dart';

import 'package:kultux/core/models/activity.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/shared/widget/app_card.dart';

class ActivitiesList extends StatefulWidget {
  final PointMap punto;
  final void Function(Activity) onDetalle;

  const ActivitiesList({required this.punto, required this.onDetalle});

  @override
  State<ActivitiesList> createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {
  final List<Activity> _actividades = [];
  final ScrollController _scroll = ScrollController();
  int _pagina = 0;
  bool _cargando = false;
  bool _hayMas = true;
  bool _cargandoDetalle = false;

  @override
  void initState() {
    super.initState();
    _cargarMas();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200)
        _cargarMas();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _cargarMas() async {
    if (_cargando || !_hayMas) return;
    setState(() => _cargando = true);
    try {
      final page = await ActivityApiService.activitiesListMap(
        ine: widget.punto.ine,
        startDate: null,
        endDate: null,
        page: _pagina,
      );
      setState(() {
        _actividades.addAll(page.content);
        _pagina++;
        _hayMas = _pagina < page.totalPages;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_actividades.isEmpty && _cargando) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppCardSkeleton(),
        ),
      );
    }
    if (_actividades.isEmpty) {
      return const Center(child: Text('No hay actividades disponibles'));
    }
    return LoadingBar(
      cargando: _cargandoDetalle,
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: _actividades.length + (_hayMas ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          if (i == _actividades.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: AppCardSkeleton(),
            );
          }
          final a = _actividades[i];
          return AppCard.activity(
              title: a.title,
              location: a.location ?? '',
              startDate: a.startDate,
              imageUrl: a.coverImage,
              onTap: () async {
                setState(() => _cargandoDetalle = true);
                try {
                  final detalle = await ActivityApiService.activityDetail(
                    a.id,
                  );
                  widget.onDetalle(detalle);
                } catch (e) {
                  if (!context.mounted) return;
                } finally {
                  setState(() => _cargandoDetalle = false);
                }
              },
              iconBadge: 'assets/iconos/actividad_etiquetas.svg',
              textBadge: a.activityCategory ?? '',
              status: a.status,
              endDate: a.endDate
          );
        },
      ),
    );
  }
}
