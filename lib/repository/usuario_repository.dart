import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kultux/models/usuario.dart';

class UsuarioRepository {

  static const String _key = 'usuario_actual';


  static Future<void> guardar(Usuario usuario) async {
    // Memoria
    Usuario.usuarioActual = usuario;

    // Disco
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(usuario.toJson()));
  }


  static Future<Usuario?> cargar() async {

    if (Usuario.usuarioActual != null) return Usuario.usuarioActual;

    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_key);

    if (json == null) return null;

    final usuario = Usuario.fromJson(jsonDecode(json));
    Usuario.usuarioActual = usuario;
    return usuario;
  }

  static Future<bool> haySesion() async{
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_key);
    return json != null ;
  }

  static Future<void> cerrarSesion() async {
    Usuario.usuarioActual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}