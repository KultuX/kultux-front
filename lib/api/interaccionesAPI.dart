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

  // == ACTIVIDAD == //

  static Future<Guardado> estadoGuardadoActividad({
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


  static Future<List<int>> listarGuardadosActividad({required int idUsuario}) async {

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

  // == RESTAURANTES == //

  static Future<Guardado> estadoGuardadoRestaurante({
    required int idRestaurante,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/restaurante/$idRestaurante/guardados',
      {'idUsuario': idUsuario.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<List<int>> listarGuardadosRestaurante({required int idUsuario}) async {

    print(idUsuario);
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/restaurante/listar_guardados',
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

  static Future<Guardado> guardarRestaurante({
    required int idRestaurante,
    required int idUsuario,
  }) async {
    final url = Uri.https(_BASE_URL, '/api/v1/interaccion/restaurante/guardar');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'idRestaurante': idRestaurante, 'idUsuario': idUsuario}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<bool> quitarRestaurante({
    required int idRestaurante,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/restaurante/eliminar',
      {
        'idRestaurante': idRestaurante.toString(),
        'idUsuario': idUsuario.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }


  // == ALOJAMIENTOS == //

  static Future<Guardado> estadoGuardadoAlojamiento({
    required int idAlojamiento,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/alojamiento/$idAlojamiento/guardados',
      {'idUsuario': idUsuario.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<List<int>> listarGuardadosAlojamiento({required int idUsuario}) async {

    print(idUsuario);
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/alojamiento/listar_guardados',
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

  static Future<Guardado> guardarAlojamiento({
    required int idAlojamiento,
    required int idUsuario,
  }) async {
    final url = Uri.https(_BASE_URL, '/api/v1/interaccion/alojamiento/guardar');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'idAlojamiento': idAlojamiento, 'idUsuario': idUsuario}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Guardado.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }


  static Future<bool> quitarAlojamiento({
    required int idAlojamiento,
    required int idUsuario,
  }) async {
    final url = Uri.https(
      _BASE_URL,
      '/api/v1/interaccion/alojamiento/eliminar',
      {
        'idAlojamiento': idAlojamiento.toString(),
        'idUsuario': idUsuario.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }



}