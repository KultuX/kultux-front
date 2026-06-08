import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/saved_model.dart';
import 'package:kultux/core/utils/api_url.dart';

class InteractionApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'KultuX APP',
  };


  static Future<Saved> activitySavedState({
    required int activityId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/actividad/$activityId/guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<int>> activitiesListSaved({
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/actividad/listar_guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => e as int).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Saved> saveActivity({
    required int activityId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/actividad/guardar',
    );
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'idActividad': activityId, 'idUsuario': userId}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<bool> unsavedActivity({
    required int activityId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/actividad/eliminar',
      {
        'idActividad': activityId.toString(),
        'idUsuario': userId.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }


  static Future<Saved> restaurantSavedState({
    required int restaurantId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/restaurante/$restaurantId/guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<int>> restaurantsListSaved({
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/restaurante/listar_guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => e as int).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Saved> saveRestaurant({
    required int restaurantId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/restaurante/guardar',
    );
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'idRestaurante': restaurantId,
        'idUsuario': userId,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<bool> unsavedRestaurant({
    required int restaurantId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/restaurante/eliminar',
      {
        'idRestaurante': restaurantId.toString(),
        'idUsuario': userId.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }


  static Future<Saved> accommodationSavedState({
    required int accommodationId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/alojamiento/$accommodationId/guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<List<int>> accommodationsListSaved({
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/alojamiento/listar_guardados',
      {'idUsuario': userId.toString()},
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => e as int).toList();
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<Saved> saveAccommodation({
    required int accommodationId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/alojamiento/guardar',
    );
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'idAlojamiento': accommodationId,
        'idUsuario': userId,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Saved.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException(response.statusCode.toString());
    }
  }

  static Future<bool> unsavedAccommodation({
    required int accommodationId,
    required int userId,
  }) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-interaccion/alojamiento/eliminar',
      {
        'idAlojamiento': accommodationId.toString(),
        'idUsuario': userId.toString(),
      },
    );
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) return true;
    if (response.statusCode == 200) return false;
    throw HttpException(response.statusCode.toString());
  }
}
