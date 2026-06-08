import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/core/models/user.dart';
import 'package:kultux/core/utils/api_url.dart';

class UserApiService {
  static Future<User> loginUser(User userLogin) async {
    final url = Uri.https(ApiUrl.BASE_URL, '/api/v1/gateway-user/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
      body: jsonEncode(userLogin.toJsonLogin()),
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return User.logged(json);
    } else {
      throw Exception('Error en el login: ${response.statusCode}');
    }
  }

  static Future<String> registerUser(User userRegistro) async {
    final url = Uri.https(ApiUrl.BASE_URL, '/api/v1/gateway-user/registrar');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
      body: jsonEncode(userRegistro.toJsonRegister()),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      return userRegistro.email;
    } else {
      throw Exception('Error al registrarse ${response.statusCode}');
    }
  }

  static Future<User> editUser({
    required int id,
    required Map<String, dynamic> datos,
    File? imagen,
  }) async {
    final uri = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-user/editar-usuario/$id',
    );

    final request = http.MultipartRequest('PATCH', uri);

    request.files.add(
      http.MultipartFile.fromString(
        'datos',
        jsonEncode(datos),
        contentType: http.MediaType('application', 'json'),
      ),
    );

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al editar usuario: ${response.statusCode} - ${response.body}',
      );
    }

    return User.fromEdit(jsonDecode(response.body));
  }

  static Future<void> deleteUser(int id) async {
    final uri = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-user/eliminar-usuario/$id',
    );
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al eliminar cuenta: ${response.statusCode}');
    }
  }

  static Future<void> recoverPassword(String email) async {
    final url = Uri.https(
      ApiUrl.BASE_URL,
      '/api/v1/gateway-user/recuperar-password',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 404) {
      throw Exception('404');
    } else if (response.statusCode != 200) {
      throw Exception('ERROR');
    }
  }
}
