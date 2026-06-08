import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/location.dart';
import 'package:kultux/core/utils/api_url.dart';

class LocationApiService {
  static List<Location>? _cache;
  static List<Location>? _mapaCache;

  static Future<List<Location>> locationsNames() async {
    if (_cache != null) {
      return _cache!;
    }

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-localidades/nombres',
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
      _cache = lista.map((json) => Location.fromJson(json)).toList();
      return _cache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<Location>> locationsMap() async {
    if (_mapaCache != null) {
      return _mapaCache!;
    }

    final url = Uri.https(ApiUrl.BASE_URL, '/api/v1/gateway-localidades/mapas');

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
      _mapaCache = lista.map((json) => Location.fromJson(json)).toList();
      return _mapaCache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static List<Location>? get cache => _cache;

  static List<Location>? get mapaCache => _mapaCache;
}
