import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/accommodation.dart';
import 'package:kultux/core/models/pages.dart';
import 'package:kultux/core/utils/api_url.dart';

class AccommodationApiService {
  static List<String>? categoriesCache;
  static Future<Pages<Accommodation>> accommodationTrending({
    required int page,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/listar_destacados',
      {'page': page.toString(), 'size': '8'},
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
      final dynamic json = jsonDecode(response.body);
      return Pages<Accommodation>.fromJson(json, (e) => Accommodation.trending(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Accommodation> accommodationDetail(int id) async {
    final url = Uri.https(ApiUrl.BASE_URL, '/api/v1/gateway-alojamientos/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Accommodation.detail(json);
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<String>> accommodationCategories() async {
    if(categoriesCache != null ) return categoriesCache!;
    final url = Uri.https(
      ApiUrl.BASE_URL,
      'api/v1/gateway-alojamientos/categoria_alojamiento',
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
      final List<dynamic> json = jsonDecode(response.body);
      categoriesCache = json.map((c) => c.toString()).toList();
      return categoriesCache!;
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Accommodation>> accommodationsSearching({
    String? name,
    String? category,
    int? location,
    required int page,
  }) async {
    final params = <String, String>{'page': page.toString(), 'size': '8'};

    if (name != null && name.isNotEmpty) params['nombre'] = name;
    if (category != null) params['categoria'] = category;
    if (location != null) params['localidad'] = location.toString();

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/busqueda',
      params,
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
      final dynamic json = jsonDecode(response.body);
      return Pages<Accommodation>.fromJson(json, (a) => Accommodation.search(a));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Pages<Accommodation>> accommodationsSaved({
    required int userId,
    required int page,
  }) async {
    final params = <String, String>{
      'idUsuario': userId.toString(),
      'page': page.toString(),
      'size': '8',
    };

    final queryParams = <String, dynamic>{...params};

    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-alojamientos/listar_guardados',
      queryParams,
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
      final dynamic json = jsonDecode(response.body);
      return Pages<Accommodation>.fromJson(json, (e) => Accommodation.saved(e));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }
}
