import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/pages.dart';


class ActividadesApiService{
  static final String _BASE_URL_ACTIVIDADES = "micro-actividad-comd.onrender.com";
  //static final String _BASE_URL_ACTIVIDADES = "micro-actividad.onrender.com"
  //static final String _BASE_URL_ACTIVIDADES = "10.0.2.2:8081";

  static Future<Pages<Actividad>> obtenerActividadesInicio(int page) async {
    final url = Uri.https(
      _BASE_URL_ACTIVIDADES,
      '/api/v1/actividades/destacados',
      {
        'page': page.toString(),
        'size': '8',
      },
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
      return Pages<Actividad>.fromJson(
        {
          "content": [],
          "number": page,
          "totalPages": page,
        },
            (json) => Actividad.inicio(json),
      );
    }
    throw HttpException(response.statusCode.toString());
  }

  static Future<Actividad> detalleActividad(int idActividad) async {
    final url = Uri.https(_BASE_URL_ACTIVIDADES, '/api/v1/actividades/actividad_detalle/$idActividad');

    final response = await http.get(
      url,
      headers: {
        'Content-Type':'application/json',
        'Accept':'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if(response.statusCode == 200){
      final dynamic json = jsonDecode(response.body);
      return Actividad.detalle(json);
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> categoriasActividad() async {
    final url = Uri.https(_BASE_URL_ACTIVIDADES, '/api/v1/actividades/categoria_actividad');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if(response.statusCode == 200){
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((c) => c.toString()).toList();
    }else{
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
    final params = <String, String>{
      'page': page.toString(),
      'size': '8',
    };

    if (titulo != null && titulo.isNotEmpty) params['titulo'] = titulo;
    if (categoria != null) params['categoria'] = categoria;
    if (localidad != null) params['localidad'] = localidad.toString();
    if (fecha != null){
      params['fecha'] = "${fecha.year}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')}";
    }else {
      final now = DateTime.now();
      params['fecha'] =
      "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    }


    final url = Uri.https(
      _BASE_URL_ACTIVIDADES,
      '/api/v1/actividades/busqueda',
      params,
    );

    print("URL FINAL: $url");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if(response.statusCode == 200){
      final dynamic json = jsonDecode(response.body);
      return Pages<Actividad>.fromJson(
        json,
            (e) => Actividad.busqueda(e),
      );
    }
    else{
      throw HttpException(response.statusCode.toString());
    }

  }

  static Future<Pages<Actividad>> actividadesGuardadas({
    required List<int> idsGuardados,
    required int page,
  }) async {

    final params = <String, String>{
      'page': page.toString(),
      'size': '8',
    };

    final queryParams = <String, dynamic>{
      ...params,
    };

    if (idsGuardados.isNotEmpty) {
      queryParams['idsGuardados'] = idsGuardados.map((e) => e.toString()).toList();
    }

    final url = Uri.https(
      _BASE_URL_ACTIVIDADES,
      '/api/v1/actividades/listar_guardados',
      queryParams,
    );


    print("URL FINAL: $url");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if(response.statusCode == 200){
      final dynamic json = jsonDecode(response.body);
      return Pages<Actividad>.fromJson(
        json,
            (e) => Actividad.guardado(e),
      );
    }
    else{
      throw HttpException(response.statusCode.toString());
    }

  }

}