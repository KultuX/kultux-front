import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/pages.dart';
import 'package:kultux/core/utils/api_url.dart';

class AlojamientoApiService {
  static List<String>? categoriasCache;
  static Future<Pages<Alojamiento>> obtenerAlojamientoDestacados({
    required int page,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/listar_destacados',
      {'page': page.toString(), 'size': '8'},
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
      return Pages<Alojamiento>.fromJson(json, (e) => Alojamiento.busqueda(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Alojamiento> obtenerAlojamientoDetalle(int id) async {
    final url = Uri.https(ApiUrl.BASE_URL, '/api/v1/gateway-alojamientos/$id');

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
      return Alojamiento.detalle(json);
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> categoriaAlojamientos() async {
    if(categoriasCache != null ) return categoriasCache!;
    final url = Uri.https(
      ApiUrl.BASE_URL,
      'api/v1/gateway-alojamientos/categoria_alojamiento',
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

  static Future<Pages<Alojamiento>> alojamientosFiltrados({
    String? nombre,
    String? categoria,
    int? localidad,
    required int page,
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '8'};

    if (nombre != null && nombre.isNotEmpty) params['nombre'] = nombre;
    if (categoria != null) params['categoria'] = categoria;
    if (localidad != null) params['localidad'] = localidad.toString();

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/busqueda',
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
      return Pages<Alojamiento>.fromJson(json, (a) => Alojamiento.busqueda(a));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Alojamiento>> alojamientosGuardados({
    required int idUsuario,
    required int page,
  }) async {
    final params = <String, String>{
      'idUsuario': idUsuario.toString(),
      'page': page.toString(),
      'size': '8',
    };

    final queryParams = <String, dynamic>{...params};

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/listar_guardados',
      queryParams,
    );

    print("URL FINAL: $url");

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
      return Pages<Alojamiento>.fromJson(json, (e) => Alojamiento.guardado(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }
}
