import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kultux/models/usuario.dart';
import 'package:http_parser/http_parser.dart';

class UsuarioApiService{
  //static final String _BASE_URL_USUARIOS = "micro-usuario.onrender.com";
  static final String _BASE_URL_USUARIOS = "10.0.2.2:8080";

  static Future<Usuario> loginUsuario(Usuario userLogin) async {
    //final url = Uri.https(_BASE_URL_USUARIOS, '/api/usuarios/login');
    final url = Uri.http(_BASE_URL_USUARIOS, '/api/usuarios/login');

    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'KultuX APP'
        },
        body: jsonEncode(userLogin.toJsonLogin())
    );

    if (response.statusCode == 200) {
      final dynamic json = jsonDecode(response.body);
      return Usuario.logeado(json);
    } else {
      throw Exception(
          'Error en el login: ${response
              .statusCode}');
    }
  }


  static Future<String> registroUsuario(Usuario userRegistro) async {
    //final url = Uri.https(_BASE_URL_USUARIOS, '/api/usuarios/registrar');
    final url = Uri.http(_BASE_URL_USUARIOS, '/api/usuarios/registrar');

    final response = await http.post(
      url,
      headers:{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KultuX APP'
      },
      body: jsonEncode(userRegistro.toJsonRegistro())
    );
    print(jsonEncode(userRegistro.toJsonRegistro()));
    if(response.statusCode == 200 || response.statusCode == 201){
      return userRegistro.email;
    }else{
      throw Exception('Error al registrarse ${response
          .statusCode}');
    }

  }

  static Future<Usuario> editarUsuario({
    required int id,
    required Map<String, dynamic> datos,
    File? imagen,
  }) async {
    final uri = Uri.http(
      _BASE_URL_USUARIOS,
      '/api/usuarios/editar-usuario/$id',
    );

    final request = http.MultipartRequest('PATCH', uri);

    request.files.add(
      http.MultipartFile.fromString(
        'datos',
        jsonEncode(datos),
        contentType: MediaType('application', 'json'),
      ),
    );

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imagen.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al editar usuario: ${response.statusCode} - ${response.body}',
      );
    }

    return Usuario.desdeEdicion(jsonDecode(response.body));
  }

  static Future<void> eliminarUsuario(int id) async {
    final uri = Uri.http(_BASE_URL_USUARIOS, '/api/usuarios/eliminar-usuario/$id');
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al eliminar cuenta: ${response.statusCode}');
    }
  }

}