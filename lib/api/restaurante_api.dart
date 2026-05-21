import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/pages.dart';
import 'package:kultux/core/utils/api_url.dart';
class RestauranteApiService{


  static Future<Pages<Restaurante>> obtenerRestauranteDestacados({required int page}) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-restaurantes/listar_destacados',
      {'page': page.toString(), 'size': '8'},
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP'
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      print(json);
      return Pages<Restaurante>.fromJson(json, (e) => Restaurante.busqueda(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }



  static Future<Restaurante> restauranteDetalle(int id) async{
    final url = Uri.https( ApiUrl.BASE_URL, '/api/v1/gateway-restaurantes/detalle_restaurante/$id');

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
    final url = Uri.https( ApiUrl.BASE_URL, 'api/v1/gateway-restaurantes/categoria_restaurante');

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

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-restaurantes/busqueda',
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
      print('restaurantes filtrados: $json');
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

  static Future<Pages<Restaurante>> restaurantesGuardados({
    required int idUsuario,
    required int page,
  }) async {

    final params = <String, String>{
      'idUsuario': idUsuario.toString(),
      'page': page.toString(),
      'size': '8',
    };

    final queryParams = <String, dynamic>{
      ...params,
    };

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-restaurantes/listar_guardados',
      queryParams,
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
            (e) => Restaurante.guardado(e),
      );
    }
    else{
      throw HttpException(response.statusCode.toString());
    }

  }

}