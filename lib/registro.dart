import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:kultux/componentes/selector_localidad.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/componentes/terminos_condiciones_dialog.dart';
import 'package:kultux/componentes/politica_privacidad_dialog.dart';

const _verde = Color(0xFFA6E246);
const _fondoPagina = Color(0xFFF1EFE9);
const _fondoCard = Color(0xFFF8F7F4);
const _texto = Color(0xFF1A1A1A);
const _textoSuave = Color(0xFF6B6B6B);
const _borde = Color(0xFFE0DDD6);

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  bool _checkedTerminos = false;
  bool _checkedPolitica = false;
  String? email;
  Localidad? _localidadSeleccionada;

  static Map<String, TextEditingController>? controllers;

  late Future<List<Localidad>> futureLocalidades;

  @override
  void initState() {
    super.initState();
    futureLocalidades = LocalidadApiService.obtenerLocalidadNombres();
    controllers = {
      'nombre': TextEditingController(),
      'apellidos': TextEditingController(),
      'email': TextEditingController(),
      'password': TextEditingController(),
      'password2': TextEditingController(),
      'fechaNacimiento': TextEditingController(),
    };
  }

  Future<bool> registrarUsuario() async {
    if (!_checkedTerminos || !_checkedPolitica) {
      _snack('⚠️ Debes aceptar los Términos y la Política de privacidad.');
      return false;
    }

    final campos = {
      'Nombre': controllers!['nombre']!.text,
      'Apellidos': controllers!['apellidos']!.text,
      'Correo electrónico': controllers!['email']!.text,
      'Contraseña': controllers!['password']!.text,
      'Repite contraseña': controllers!['password2']!.text,
      'Fecha de nacimiento': controllers!['fechaNacimiento']!.text,
    };

    for (final entry in campos.entries) {
      if (entry.value.trim().isEmpty) {
        _snack("⚠️ El campo '${entry.key}' es obligatorio.");
        return false;
      }
    }

    if (controllers!['password']!.text != controllers!['password2']!.text) {
      _snack('Las contraseñas no coinciden. ❌');
      return false;
    }

    if (_localidadSeleccionada == null) {
      _snack('⚠️ Selecciona una localidad válida.');
      return false;
    }

    try {
      email = await UsuarioApiService.registroUsuario(
        Usuario.registro({
          'nombre': controllers!['nombre']!.text,
          'apellidos': controllers!['apellidos']!.text,
          'email': controllers!['email']!.text,
          'password': controllers!['password']!.text,
          'localidad': _localidadSeleccionada!.ine,
          'fechaNacimiento': controllers!['fechaNacimiento']!.text,
        }),
      );
      return true;
    } catch (_) {
      _snack('⚠️ Ups.. algo ha ido mal. Revisa los datos introducidos.');
      return false;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPagina,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, right: 0,
                    child: Opacity(
                      opacity: 0.12,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: _verde,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo pequeño
                      Image.asset('assets/images/logo_registro.png',
                          width: 56, height: 56),
                      const SizedBox(height: 12),
                      const Text('Bienvenid@',
                          style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0))),
                      const SizedBox(height: 2),
                      const Text('Crear cuenta',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Container(
                        width: 36, height: 2,
                        decoration: BoxDecoration(
                          color: _verde,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Formulario ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SeccionLabel('Datos personales'),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Nombre', controller: controllers!['nombre']!)),
                  const SizedBox(height: 10),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Apellidos', controller: controllers!['apellidos']!)),
                  const SizedBox(height: 10),
                  _Campo(child: _calendarioCampo()),

                  const SizedBox(height: 16),
                  _SeccionLabel('Cuenta'),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Correo electrónico',
                      controller: controllers!['email']!,
                      tipo: TextInputType.emailAddress)),
                  const SizedBox(height: 10),
                  _Campo(child: CamposPersonalizados.password(
                      titulo: 'Contraseña', controller: controllers!['password']!)),
                  const SizedBox(height: 10),
                  _Campo(child: CamposPersonalizados.password(
                      titulo: 'Repite contraseña',
                      controller: controllers!['password2']!)),

                  const SizedBox(height: 16),
                  _SeccionLabel('Localidad'),
                  _Campo(child: _selectorLocalidad()),

                  const SizedBox(height: 16),
                  _SeccionLabel('Legal'),
                  _CheckLegal(
                    checked: _checkedTerminos,
                    onChanged: (v) => setState(() => _checkedTerminos = v ?? false),
                    normal: 'Acepto los ',
                    link: 'Términos y Condiciones',
                    onTap: () => TerminosCondicionesDialog.mostrar(context),
                  ),
                  const SizedBox(height: 6),
                  _CheckLegal(
                    checked: _checkedPolitica,
                    onChanged: (v) => setState(() => _checkedPolitica = v ?? false),
                    normal: 'Acepto la ',
                    link: 'Política de Privacidad',
                    onTap: () => PoliticaPrivacidadDialog.mostrar(context),
                  ),

                  const SizedBox(height: 24),
                  // ── Botones ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _borde, width: 1.5),
                            ),
                            child: const Center(
                              child: Text('Volver',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _textoSuave)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (await registrarUsuario()) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  showCloseIcon: true,
                                  content: Text('✅ ¡Registro completado!',
                                      textAlign: TextAlign.center),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _verde,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('Registrarse',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _texto)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers de layout ──────────────────────────────────────────────────────

  Widget _SeccionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'RobotoCondensed',
        fontSize: 11, fontWeight: FontWeight.w600,
        color: _textoSuave, letterSpacing: 0.8,
      ),
    ),
  );

  // Envuelve cada campo en un card ligero para darle coherencia visual
  Widget _Campo({required Widget child}) => Container(
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: _fondoCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _borde),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: child,
    ),
  );

  Widget _selectorLocalidad() {
    return FutureBuilder<List<Localidad>>(
      future: futureLocalidades,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(
                  color: _verde, strokeWidth: 2),
            ),
          );
        }
        return SelectorLocalidad(
          localidades: snapshot.data!,
          onSelected: (loc) => setState(() => _localidadSeleccionada = loc),
          label: 'Localidad',
        );
      },
    );
  }

  Widget _calendarioCampo() {
    final ctrl = controllers!['fechaNacimiento']!;
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: 'Fecha de nacimiento',
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset('assets/iconos/calendario_registro.svg',
              width: 16, height: 16),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: _verde, width: 1.5)),
      ),
      onTap: () async {
        final fecha = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (fecha != null) {
          final m = fecha.month.toString().padLeft(2, '0');
          final d = fecha.day.toString().padLeft(2, '0');
          ctrl.text = '${fecha.year}-$m-$d';
        }
      },
    );
  }
}

// ── Widget reutilizable para checkboxes legales ────────────────────────────────

class _CheckLegal extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String normal;
  final String link;
  final VoidCallback onTap;

  const _CheckLegal({
    required this.checked,
    required this.onChanged,
    required this.normal,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _fondoCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: checked ? _verde.withOpacity(0.6) : _borde,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            checkColor: _texto,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (s) => s.contains(WidgetState.selected) ? _verde : null,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    color: _textoSuave,
                    fontSize: 13),
                children: [
                  TextSpan(text: normal),
                  TextSpan(
                    text: link,
                    style: const TextStyle(
                        color: _verde,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600),
                    recognizer: TapGestureRecognizer()..onTap = onTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}