import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/pages.dart';

import '../models/ActividadTotal.dart';

import 'package:kultux/core/utils/api_url.dart';

class ActividadesApiService {
  static List<String>? categoriasCache;
  static Future<Pages<Actividad>> obtenerActividadesInicio(int page) async {
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
      return Pages<Actividad>.fromJson(
        jsonData,
        (json) => Actividad.inicio(json),
      );
    }

    if (response.statusCode == 204) {
      return Pages<Actividad>.fromJson({
        "content": [],
        "number": page,
        "totalPages": page,
      }, (json) => Actividad.inicio(json));
    }
    throw HttpException(response.statusCode.toString());
  }

  static Future<Actividad> detalleActividad(int idActividad) async {
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
      return Actividad.detalle(json);
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> categoriasActividad() async {
    if(categoriasCache != null ) return categoriasCache!;
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
      categoriasCache = json.map((c) => c.toString()).toList();
      return categoriasCache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Actividad>> actividadesFiltradas({
    String? titulo,
    String? categoria,
    int? localidad,
    DateTime? fecha,
    required int page,
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '5'};

    if (titulo != null && titulo.isNotEmpty) params['titulo'] = titulo;
    if (categoria != null) params['categoria'] = categoria;
    if (localidad != null) params['localidad'] = localidad.toString();
    if (fecha != null) {
      params['fecha'] =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
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
      return Pages<Actividad>.fromJson(json, (e) => Actividad.busqueda(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Actividad>> actividadesGuardadas({
    required int idUsuario,
    required int page,
  }) async {
    final params = <String, String>{
      'idUsuario': idUsuario.toString(),
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
      return Pages<Actividad>.fromJson(json, (e) => Actividad.guardado(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<ActividadTotal>> actividadesTotalMapa({
    //required List<int> ines,
    DateTime? fechaInicio,
    DateTime? fechaFin
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-actividades/mapa/total_actividades',
      {'fechaInicio': fechaInicio, 'fechaFin': fechaFin},
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
      return json.map((e) => ActividadTotal.fromJson(e)).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Actividad>> listaActividadesMapa({
    required int ine,
    required int page,
    DateTime? fechaInicio,
    DateTime? fechaFin
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '8', 'fechaInicio': fechaInicio.toString(), 'fechaFin': fechaFin.toString() };


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
      return Pages<Actividad>.fromJson(json, (e) => Actividad.inicio(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }
}
