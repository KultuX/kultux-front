import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/restaurante.dart';
import 'package:kultux/models/alojamiento.dart';


import 'package:kultux/core/utils/api_url.dart';
class EstablecimientosApiService{

  static Future<Map<String, dynamic>> obtenerEstablecimientosDestacados() async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-restaurantes/destacados',
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
      final json = jsonDecode(response.body);
      return {
        'restaurantes': (json['restaurantes'] as List)
            .map((e) => Restaurante.destacado(e))
            .toList(),
        'alojamientos': (json['alojamientos'] as List)
            .map((e) => Alojamiento.destacado(e))
            .toList(),
      };
    }

    if (response.statusCode == 204) {
      return {'restaurantes': <Restaurante>[], 'alojamientos': <Alojamiento>[]};
    }

    throw HttpException(response.statusCode.toString());
  }

}


