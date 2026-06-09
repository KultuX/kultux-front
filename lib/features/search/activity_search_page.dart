import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/shared/widget/scroll_button.dart';
import 'package:kultux/core/utils/ui_state.dart';

import 'package:kultux/shared/widget/loading_bar.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/locality_selector.dart';
import 'package:kultux/shared/widget/skeleton_card.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';

import 'package:kultux/core/utils/widget_states.dart';

import '../../shared/widget/app_card.dart';


class ActivitySearchPage extends StatefulWidget {
  final Function(dynamic)? onSelectedDetail;
  const ActivitySearchPage({super.key, this.onSelectedDetail});

  @override
  State<ActivitySearchPage> createState() => _ActivitySearchPageState();
}

class _ActivitySearchPageState extends State<ActivitySearchPage> {
  late Future<List<Location>> futureLocation;
  late Future<List<String>> futureCategories;

  String title = "";
  String? category;
  int? location;
  DateTime? startDate;

  List<Activity> activities = [];
  int currentPage = 0;
  int totalPages = 0;

  bool loading = false;

  Timer? _debounceTimer;
  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController? _controllerCategories;
  TextEditingController? _controllerLocations;

  Key _selectorLocationKey = UniqueKey();

  UiState status = UiState.loading;
  String errorMessage = '';

  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    futureCategories = ActivityApiService.activityCategories();
    futureLocation = LocationApiService.locationsNames();
    _initLoad();
    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> resetAndLoad() async {
    await Future.microtask(() {});
    currentPage = 0;
    totalPages = 0;
    await _loadMore();
  }

  Future<void> _loadActivities() async {
    await resetAndLoad();
  }

  Future<void> _initLoad() async {
    setState(() {
      status = UiState.loading;
    });
    await Future.microtask(() {});
    await resetAndLoad();
  }

  Future<void> _loadMore() async {
    if (loading) return;

    if (currentPage >= totalPages && currentPage != 0) return;
    setState(() {
      loading = true;
      if (currentPage == 0) status = UiState.loading;
    });
    try {
      final pageResponse = await ActivityApiService.activitiesSearching(
        title: title.isEmpty ? null : title,
        category: category,
        location: location,
        startDate: startDate,
        page: currentPage,
      );
      setState(() {
        if (currentPage == 0) activities.clear();
        activities.addAll(pageResponse.content);
        totalPages = pageResponse.totalPages;
        currentPage++;
        status = activities.isEmpty ? UiState.empty : UiState.content;
      });
    } on SocketException {
      setState(() {
        status = UiState.noConnection;
        errorMessage = 'No hay conexion a internet';
      });
    } on HttpException catch (e) {
      final uiError = statusCodeMapper(int.parse(e.message));
      setState(() {
        status = uiError.estado;
        errorMessage = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        status = UiState.error;
        errorMessage = 'Error inesperado';
      });
    } finally {
      loading = false;
    }
  }

  Widget _sliverStatus() {
    switch (status) {
      case UiState.loading:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const SkeletonCard(),
            childCount: 5,
          ),
        );

      case UiState.empty:
        return SliverFillRemaining(child: emptyState());

      case UiState.noConnection:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.wifi_off,
            mensaje: errorMessage,
            onRetry: _initLoad,
          ),
        );

      case UiState.error:
        return SliverFillRemaining(
          child: errorState(
            icon: Icons.error_outline,
            mensaje: errorMessage,
            onRetry: _initLoad,
          ),
        );

      case UiState.content:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < activities.length) {
                final a = activities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: AppCard.activity(
                    title: a.title,
                    location: a.location!,
                    startDate: a.startDate,
                    imageUrl: a.coverImage,
                    onTap: () async {
                      setState(() => _loadingDetail = true);
                      try {
                        final detail =
                            await ActivityApiService.activityDetail(a.id);
                        widget.onSelectedDetail?.call(detail);
                      } catch (e) {
                        if (!context.mounted) return;
                        AlertModal.show(
                          context,
                          message: 'No se han podido cargar los datos.',
                          type: AlertTipe.error,
                        );
                      } finally {
                        setState(() => _loadingDetail = false);
                      }
                    },
                    textBadge: a.activityCategory!,
                    iconBadge: 'assets/iconos/actividad_etiquetas.svg',
                    endDate: a.endDate,
                    status: a.status
                  ),
                );
              }

              if (loading) {
                return const SkeletonCard();
              }

              if (currentPage >= totalPages) {
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
                activities.length +
                (loading || currentPage >= totalPages ? 1 : 0),
          ),
        );
    }
  }

  Widget _contentStatus() {
    return Stack(
      children: [
        CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    Expanded(child: _searchBar()),
                    const SizedBox(width: 8),
                    _dateSelector(),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _filters(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _sliverStatus(),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ScrollButton(controller: controller),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(cargando: _loadingDetail, child: _contentStatus());
  }

  Widget _searchBar() {
    return SearchBar(
      controller: _searchController,
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
        title = value;
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
          _loadActivities();
        });
      },
    );
  }

  Widget _filters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _categoriesSelector()),
            const SizedBox(width: 8),
            Expanded(child: _locationsSelector()),
            if (category != null ||
                location != null ||
                startDate != null ||
                title.isNotEmpty) ...[
              const SizedBox(width: 8),
              _resetButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _resetButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          category = null;
          location = null;
          startDate = null;
          title = "";
          _searchController.clear();
          _selectorLocationKey = UniqueKey();
          _controllerLocations?.clear();
          _controllerCategories?.clear();
        });
        _loadActivities();
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
        borderSide: BorderSide(
          color: Color.fromARGB(255, 166, 226, 70),
          width: 1,
        ),
      ),
      suffixIcon: hasValue && onClear != null
          ? GestureDetector(
              onTap: onClear,
              child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
            )
          : Icon(icon, size: 16, color: Colors.grey.shade600),
    );
  }

  Widget _categoriesSelector() {
    return FutureBuilder<List<String>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        final categories = snapshot.data!;
        return Autocomplete<String>(
          optionsBuilder: (v) {
            if (v.text.isEmpty) return const Iterable<String>.empty();
            return categories.where(
              (c) => c.toLowerCase().contains(v.text.toLowerCase()),
            );
          },
          onSelected: (s) {
            setState(() => category = s);
            _loadActivities();
          },
          fieldViewBuilder: (context, ctrl, focusNode, _) {
            _controllerCategories = ctrl;
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDeco(
                label: 'Categoría',
                icon: Icons.category,
                hasValue: category != null,
                onClear: () {
                  setState(() => category = null);
                  ctrl.clear();
                  _loadActivities();
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

  Widget _locationsSelector() {
    return FutureBuilder<List<Location>>(
      future: LocationApiService.cache != null
          ? Future.value(LocationApiService.cache)
          : LocationApiService.locationsNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _shimmerLoader();
        return LocalitySelector(
          key: _selectorLocationKey,
          locations: snapshot.data!,
          onSelected: (loc) {
            setState(() => location = loc?.ine);
            _loadActivities();
          },
        );
      },
    );
  }

  Widget _dateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromARGB(255, 166, 226, 70),
                  onPrimary: Colors.black,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => startDate = picked);
          _loadActivities();
        }
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: startDate == null
              ? Colors.grey.shade100
              : const Color.fromARGB(30, 166, 226, 70),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: startDate == null
                ? Colors.grey.shade300
                : const Color.fromARGB(255, 166, 226, 70),
          ),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 18,
          color: startDate == null
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
    _debounceTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
}
