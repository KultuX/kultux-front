import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/pages.dart';

class AlojamientoApiService{
  static final String _BASE_URL_ALOJAMIENTOS = "micro-alojamiento-d25y.onrender.com";
  //static final String _BASE_URL_ALOJAMIENTOS = "micro-alojamiento-xxal.onrender.com";
  // static final String _BASE_URL_ALOJAMIENTOS = "micro-alojamiento.onrender.com";
  //static final String _BASE_URL_ALOJAMIENTOS = "10.0.2.2:8082";

  static Future<List<Alojamiento>> obtenerAlojamientoDestacados() async {
    final url = Uri.https(_BASE_URL_ALOJAMIENTOS,'/api/v1/alojamientos/destacados');

    final response = await http.get(
      url,
      headers: {
        'Content-Type':'application/json',
        'Accept':'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if (response.statusCode == 200){
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((json) => Alojamiento.destacado(json)).toList();
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Alojamiento> obtenerAlojamientoDetalle(int id) async{
    final url = Uri.https(_BASE_URL_ALOJAMIENTOS, '/api/v1/alojamientos/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type':'application/json',
        'Accept':'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if (response.statusCode == 200){
      final dynamic json = jsonDecode(response.body);
      return Alojamiento.detalle(json);
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> categoriaAlojamientos() async{
    final url = Uri.https(_BASE_URL_ALOJAMIENTOS, 'api/v1/alojamientos/categoria_alojamiento');

    final response = await http.get(
      url,
      headers:{
        'Content-Type':'application/json',
        'Accept':'application/json',
        'User-Agent': 'KultuX APP'
      }
    );

    if(response.statusCode == 200){
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((c) => c.toString()).toList();
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Alojamiento>> alojamientosFiltrados({
    String? nombre,
    String? categoria,
    int? localidad,
    required int page,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'size': '8',
    };

    if (nombre != null && nombre.isNotEmpty) params['nombre'] = nombre;
    if (categoria != null) params['categoria'] = categoria;
    if (localidad != null) params['localidad'] = localidad.toString();

    final url = Uri.https(
      _BASE_URL_ALOJAMIENTOS,
      '/api/v1/alojamientos/busqueda',
      params,
    );

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
      return Pages<Alojamiento>.fromJson(
        json,
            (a) => Alojamiento.busqueda(a),
      );
    }else {
      throw HttpException(response.statusCode.toString());
    }

  }

  static Future<Pages<Alojamiento>> alojamientosGuardados({
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
      _BASE_URL_ALOJAMIENTOS,
      '/api/v1/alojamientos/listar_guardados',
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
      return Pages<Alojamiento>.fromJson(
        json,
            (e) => Alojamiento.guardado(e),
      );
    }
    else{
      throw HttpException(response.statusCode.toString());
    }

  }

}

