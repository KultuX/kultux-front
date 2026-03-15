import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kultux/models/restaurante.dart';

class RestauranteApiService{
  static final String _BASE_URL_RESTAURANTES = "micro-restaurante-n4bv.onrender.com";

  static Future<List<Restaurante>> obtenerRestauranteDestacados() async {
    final url = Uri.https(_BASE_URL_RESTAURANTES,'/api/v1/restaurantes/destacados');

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
      throw Exception('Error al obtener los restaurantes destacados: ${response.statusCode}');
    }
  }

  static Future<Restaurante> obtenerRestauranteDetalle(int id) async{
    final url = Uri.https(_BASE_URL_RESTAURANTES, '/api/v1/restaurantes/$id');

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
      throw Exception('Error al el restaurante: ${response.statusCode}');
    }
  }

}