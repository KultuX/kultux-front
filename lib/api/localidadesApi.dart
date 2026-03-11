import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kultux/models/localidad.dart';

class LocalidadApiService{
  static Future<List<Localidad>> obtenerLocalidadNombres() async {
    final url = Uri.http('10.0.2.2:8080','/api/v1/localidades/nombres');

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
      return lista.map((json) => Localidad.fromJson(json)).toList();
    }else{
      throw Exception('Error al obtener los nombre de las localidades: ${response.statusCode}');
    }
  }
}