import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/guardados.dart';

class InteraccionesApiService {
  static const String _BASE_URL = "micro-interaccion.onrender.com"; // ajusta
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'KultuX APP',
  };

  static Future<Guardado> estadoGuardado({
    required int idActividad,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/actividad/$idActividad/guardados',
      {'idUsuario': idUsuario.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<List<int>> listarGuardados({required int idUsuario}) async {

    print(idUsuario);
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/actividad/listar_guardados',
      {'idUsuario': idUsuario.toString()},
    );
    final response = await http.get(url, headers: _headers);
    print(url);
    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((e) => e as int).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Guardado> guardarActividad({
    required int idActividad,
    required int idUsuario,
  }) async {
    final url = Uri.https(_BASE_URL, '/api/v1/interaccion/actividad/guardar');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'idActividad': idActividad, 'idUsuario': idUsuario}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<bool> quitarActividad({
    required int idActividad,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/actividad/eliminar',
      {
        'idActividad': idActividad.toString(),
        'idUsuario': idUsuario.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }
}