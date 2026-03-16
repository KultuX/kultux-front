import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kultux/models/actividad.dart';

class ActividadesApiService{
  static final String _BASE_URL_ACTIVIDADES = "micro-actividad.onrender.com";
  static Future<List<Actividad>> obtenerActividadesDestacadas() async {
    final url = Uri.https(_BASE_URL_ACTIVIDADES,'/api/v1/actividades/destacados');

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
      return lista.map((json) => Actividad.inicio(json)).toList();
    }else{
      throw Exception('Error al obtener loslas actividades de inicio: ${response.statusCode}');
    }
  }

  static Future<Actividad> detalleActividad(int idActividad) async {
    final url = Uri.https(_BASE_URL_ACTIVIDADES, '/api/v1/actividades/$idActividad');

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
      throw Exception('Error al obtener la actividad con $idActividad: ${response.statusCode}');
    }
  }

}