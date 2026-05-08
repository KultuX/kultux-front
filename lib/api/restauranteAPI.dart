import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/pages.dart';

class RestauranteApiService{
  static final String _BASE_URL_RESTAURANTES = "micro-restaurante-n4bv.onrender.com";
  //static final String _BASE_URL_RESTAURANTES = "10.0.2.2:8083";

  static Future<List<Restaurante>> obtenerRestauranteDestacados() async {
    final url = Uri.http(_BASE_URL_RESTAURANTES,'/api/v1/restaurantes/destacados');

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
      return lista.map((json) => Restaurante.destacado(json)).toList();
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Restaurante> restauranteDetalle(int id) async{
    final url = Uri.http(_BASE_URL_RESTAURANTES, '/api/v1/restaurantes/detalle_restaurante/$id');

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
      return Restaurante.detalle(json);
    }else{
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<List<String>> categoriasRestaurantes() async{
    final url = Uri.https(_BASE_URL_RESTAURANTES, 'api/v1/restaurantes/categoria_restaurante');

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

  static Future<Pages<Restaurante>> restaurantesFiltrados({
    String? nombre,
    String? categoria,
    int? localidad,
    bool? soloAbiertos,
    required int page,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'size': '8',
    };

    if (nombre != null && nombre.isNotEmpty) params['nombre'] = nombre;
    if (categoria != null) params['categoria'] = categoria;
    if (localidad != null) params['localidad'] = localidad.toString();
    if ( soloAbiertos != null ) params['soloAbiertos'] = soloAbiertos.toString();

    final url = Uri.http(
      _BASE_URL_RESTAURANTES,
      '/api/v1/restaurantes/busqueda',
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
      return Pages<Restaurante>.fromJson(
        json,
            (a) => Restaurante.busqueda(a),
      );
    }else if(response.statusCode == 204){
      throw HttpException(response.statusCode.toString());
    }
    else{
      throw HttpException(response.statusCode.toString());
    }

  }

}