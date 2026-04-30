import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kultux/models/usuario.dart';

class UsuarioRepository {

  static const String _key = 'usuario_actual';

  // ── Guardar usuario en memoria y en disco ──────────────────────────────────
  static Future<void> guardar(Usuario usuario) async {
    // Memoria
    Usuario.usuarioActual = usuario;

    // Disco
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(usuario.toJson()));
  }

  // ── Cargar usuario (primero memoria, luego disco) ──────────────────────────
  static Future<Usuario?> cargar() async {
    // Si ya está en memoria lo devolvemos directamente
    if (Usuario.usuarioActual != null) return Usuario.usuarioActual;

    // Si no, intentamos recuperarlo de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_key);

    if (json == null) return null;

    final usuario = Usuario.fromJson(jsonDecode(json));
    Usuario.usuarioActual = usuario; // lo dejamos en memoria para la sesión
    return usuario;
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────────────
  static Future<void> cerrarSesion() async {
    Usuario.usuarioActual = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}