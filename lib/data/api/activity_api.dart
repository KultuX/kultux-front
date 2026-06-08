import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/pages.dart';

import 'package:kultux/core/models/activity_total.dart';

import 'package:kultux/core/utils/api_url.dart';

class ActivityApiService {
  static List<String>? categoriesCache;
  static Future<Pages<Activity>> trendingActivities(int page) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/destacados',
      {'page': page.toString(), 'size': '5'},
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Pages<Activity>.fromJson(
        jsonData,
        (json) => Activity.trending(json),
      );
    }

    if (response.statusCode == 204) {
      return Pages<Activity>.fromJson({
        "content": [],
        "number": page,
        "totalPages": page,
      }, (json) => Activity.trending(json));
    }
    throw HttpException(response.statusCode.toString());
  }

  static Future<Activity> activityDetail(int idActividad) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/actividad_detalle/$idActividad',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Activity.detail(json);
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> activityCategories() async {
    if(categoriesCache != null ) return categoriesCache!;
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/categoria_actividad',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      categoriesCache = json.map((c) => c.toString()).toList();
      return categoriesCache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Activity>> activitiesSearching({
    String? title,
    String? category,
    int? location,
    DateTime? startDate,
    required int page,
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '5'};

    if (title != null && title.isNotEmpty) params['titulo'] = title;
    if (category != null) params['categoria'] = category;
    if (location != null) params['localidad'] = location.toString();
    if (startDate != null) {
      params['fecha'] =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    } else {
      final now = DateTime.now();
      params['fecha'] =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/busqueda',
      params,
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Pages<Activity>.fromJson(json, (e) => Activity.search(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Activity>> activitiesSaved({
    required int userId,
    required int page,
  }) async {
    final params = <String, String>{
      'idUsuario': userId.toString(),
      'page': page.toString(),
      'size': '5',
    };

    final queryParams = <String, dynamic>{...params};

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/listar_guardados',
      queryParams,
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Pages<Activity>.fromJson(json, (e) => Activity.saved(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<ActivityTotal>> activitiesTotalMap({
    DateTime? startDate,
    DateTime? endDate
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/mapa/total_actividades',
      {'fechaInicio': startDate, 'fechaFin': endDate},
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => ActivityTotal.fromJson(e)).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Activity>> activitiesListMap({
    required int ine,
    required int page,
    DateTime? startDate,
    DateTime? endDate
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '8'};

    if(startDate != null ) params['fechaInicio'] = startDate.toString();
    if(endDate != null ) params['fechaFin'] = endDate.toString();

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/mapa/lista_actividades/$ine',
      params,
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Pages<Activity>.fromJson(json, (e) => Activity.trending(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }
}
