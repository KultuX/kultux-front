
import 'package:flutter/cupertino.dart';
import 'package:kultux/features/map/point_map.dart';

import 'package:kultux/core/models/activity.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/shared/widget/app_card.dart';

class ActivitiesList extends StatefulWidget {
  final PointMap point;
  final void Function(Activity) onDetail;

  const ActivitiesList({super.key, required this.point, required this.onDetail});

  @override
  State<ActivitiesList> createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {
  final List<Activity> _activities = [];
  final ScrollController _scroll = ScrollController();
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200)
        _loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final page = await ActivityApiService.activitiesListMap(
        ine: widget.point.ine,
        startDate: null,
        endDate: null,
        page: _page,
      );
      setState(() {
        _activities.addAll(page.content);
        _page++;
        _hasMore = _page < page.totalPages;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activities.isEmpty && _loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppCardSkeleton(),
        ),
      );
    }
    if (_activities.isEmpty) {
      return const Center(child: Text('No hay actividades disponibles'));
    }
    return LoadingBar(
      cargando: _loadingDetail,
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          if (i == _activities.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: AppCardSkeleton(),
            );
          }
          final a = _activities[i];
          return AppCard.activity(
              title: a.title,
              location: a.location ?? '',
              startDate: a.startDate,
              imageUrl: a.coverImage,
              onTap: () async {
                setState(() => _loadingDetail = true);
                try {
                  final detail = await ActivityApiService.activityDetail(
                    a.id,
                  );
                  widget.onDetail(detail);
                } catch (e) {
                  if (!context.mounted) return;
                } finally {
                  setState(() => _loadingDetail = false);
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
