import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/core/models/accommodation.dart';

import 'package:kultux/core/utils/api_url.dart';

class VenuesApiService {
  static Future<Map<String, dynamic>>
  venuesTrending() async {
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
            .map((e) => Restaurant.trending(e))
            .toList(),
        'alojamientos': (json['alojamientos'] as List)
            .map((e) => Accommodation.trending(e))
            .toList(),
      };
    }

    if (response.statusCode == 204) {
      return {'restaurantes': <Restaurant>[], 'alojamientos': <Accommodation>[]};
    }

    throw HttpException(response.statusCode.toString());
  }
}
