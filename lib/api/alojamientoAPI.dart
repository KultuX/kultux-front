import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kultux/models/alojamiento.dart';

class AlojamientoApiService{
  //static final String _BASE_URL_ALOJAMIENTOS = "micro-alojamiento.onrender.com";
  static final String _BASE_URL_ALOJAMIENTOS = "10.0.2.2:8082";

  static Future<List<Alojamiento>> obtenerAlojamientoDestacados() async {
    final url = Uri.http(_BASE_URL_ALOJAMIENTOS,'/api/v1/alojamientos/destacados');

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
      throw Exception('Error al obtener los alojamientoss: ${response.statusCode}');
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
      throw Exception('Error al obtener los nombre de las localidades: ${response.statusCode}');
    }
  }

}

