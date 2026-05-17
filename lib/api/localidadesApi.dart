import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/localidad.dart';

class LocalidadApiService {
  static final String _BASE_URL_LOCALIDADES = "micro-localidades-hpsr.onrender.com";
  //static final String _BASE_URL_LOCALIDADES = "micro-localidades-58ih.onrender.com";
//static final String _BASE_URL_LOCALIDADES = "micro-localidades.onrender.com";
//static final String _BASE_URL_LOCALIDADES = "10.0.2.2:8080";
  static List<Localidad>? _cache;
  static List<Localidad>? _mapaCache;

  static Future<List<Localidad>> obtenerLocalidadNombres() async {
    if (_cache != null) {
      return _cache!;
    }

    final url = Uri.https(
      _BASE_URL_LOCALIDADES,
      '/api/v1/localidades/nombres',
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
      final List<dynamic> lista = jsonDecode(response.body);
      _cache = lista.map((json) => Localidad.fromJson(json)).toList();
      return _cache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<Localidad>> obtenerLocalidadesMapa() async {
    if (_mapaCache != null) {
      return _mapaCache!;
    }

    final url = Uri.https(
      _BASE_URL_LOCALIDADES,
      '/api/v1/localidades/mapas',
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
      final List<dynamic> lista = jsonDecode(response.body);
      _mapaCache = lista.map((json) => Localidad.fromJson(json)).toList();
      return _mapaCache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }



  static List<Localidad>? get cache => _cache;

  static List<Localidad>? get mapaCache => _mapaCache;



}
