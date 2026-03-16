import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kultux/models/usuario.dart';

class UsuarioApiService{
  static final String _BASE_URL_USUARIOS = "micro-usuario.onrender.com";


  static Future<Usuario> loginUsuario(Usuario userLogin) async {
    final url = Uri.https(_BASE_URL_USUARIOS, '/api/usuarios/login');

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
    final url = Uri.https(_BASE_URL_USUARIOS, '/api/usuarios/crear');

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
      final dynamic json = jsonDecode(response.body);
      return json['email'] ?? userRegistro.email;
    }else{
      throw Exception('Error al registrarse ${response
          .statusCode}');
    }

  }





}